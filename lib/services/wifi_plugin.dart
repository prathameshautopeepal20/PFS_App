// lib/services/wifi_plugin.dart
// Uses CommController + DongleComm + UDSDiagnostic — EXACT mirror of .NET
// .NET: new DongleCommWin(client, client.GetStream(), protocol, IP) → IsChannel=true
// .NET: SecurityAccess → CAN_StopTP → SetProtocol → SetTxHeader → SetRxHeader → StartPadding
// .NET: UDSDiagnostic.ReadParameters (NOT raw CAN_TxRx)

import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_diagnostic/enum/seedkeyIndexType.dart';
import 'package:ap_diagnostic/models/flashingMtrixModel.dart';
import 'package:ap_diagnostic/models/readParameterPIDModel.dart';
import 'package:ap_diagnostic/structure/flash_structures.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_dongle_comm/utils/enums/protocol.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';

class _Slot {
  CommController ctrl = CommController();
  DongleComm?    dongle;
  UDSDiagnostic? diag;
  String  ip       = '';
  String  txHeader = '07E0';
  String  rxHeader = '07E8';
  int     proto    = 0x02;
  bool    ready    = false;
}

class WiFiPlugin {
  WiFiPlugin._();
  static final WiFiPlugin instance = WiFiPlugin._();

  final Map<int, _Slot>     _slots = {};
  final Map<String, double> flashPercentMap = {};

  Future<void> initSockets() async {
    for (int i = 1; i <= 8; i++) _slots[i] = _Slot();
    print('✅ [WiFiPlugin] Sockets initialized');
  }

  Future<void> closeSockets() async {
    for (final s in _slots.values) {
      try { await s.ctrl.disconnect(); } catch (_) {}
      s.ready = false;
    }
    print('✅ [WiFiPlugin] Closed');
  }

  // checkDongle — just TCP connect (mirrors .NET CheckClient_1)
  Future<bool> checkDongle(String ip, int index, {
    String txHeader     = '7E0',
    String rxHeaderMask = '7E8',
    String protocolHex  = '02',
  }) async {
    try {
      final txH   = txHeader.length.isOdd ? '0$txHeader' : txHeader;
      final rxH   = rxHeaderMask.length.isOdd ? '0$rxHeaderMask' : rxHeaderMask;
      final proto = int.tryParse(protocolHex, radix: 16) ?? 0x02;

      final slot = _slots[index]!;
      if (slot.ctrl.isConnected.value) {
        await slot.ctrl.disconnect();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await slot.ctrl.connectWifi(
        host: ip, port: 6888, selectedType: Connectivity.wiFi);

      if (!slot.ctrl.isConnected.value) return false;

      // Create DongleComm with isChannel=true (mirrors .NET DongleCommWin ctor)
      final protocol = Protocol.values.firstWhere(
          (p) => p.value == proto,
          orElse: () => Protocol.ISO15765_500KB_11BIT_CAN);
      final dongle = DongleComm(comm: slot.ctrl, isChannel: true, channelId: '00');
      dongle.protocol = protocol;

      slot.dongle   = dongle;
      slot.diag     = UDSDiagnostic(dongle, ECUCalculateSeedkey());
      slot.ip       = ip;
      slot.txHeader = txH;
      slot.rxHeader = rxH;
      slot.proto    = proto;
      slot.ready    = true;

      print('✅ [WiFiPlugin] Dongle $index @ $ip TX=$txH RX=$rxH');
      return true;
    } catch (e) {
      print('❌ checkDongle[$index]: $e'); return false;
    }
  }

  // _readPid — mirrors .NET GetESN exactly
  // SA → CAN_StopTP → SetProtocol → SetTxHeader → SetRxHeader → StartPadding
  // → UDSDiagnostic.ReadParameters
  Future<List<String>> _readPid(int index, List<dynamic> rawPids,
      {String pidType = 'ESN'}) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready) {
        print('❌ _readPid[$index]: not ready'); return ['false', ''];
      }
      if (rawPids.isEmpty) return ['false', ''];

      // Find the specific PID for this type from rawPids
      // rawPids contains ALL pids — find the one matching pidType
      Map<String,dynamic>? targetPid;
      for (final item in rawPids) {
        if (item is! Map) continue;
        final m = Map<String,dynamic>.from(item);
        final t = (m['pid_type'] ?? m['type'] ?? m['pidType'] ?? '').toString().toUpperCase();
        if (t.contains(pidType.toUpperCase()) ||
            pidType == 'ESN' && (m['pid'] ?? '').toString() == '0906' ||
            pidType == 'HW'  && (m['pid'] ?? '').toString().startsWith('22F188') ||
            pidType == 'SW'  && (m['pid'] ?? '').toString().startsWith('22F18B') ||
            pidType == 'CALID' && (m['pid'] ?? '').toString() == '0904' ||
            pidType == 'CVN' && (m['pid'] ?? '').toString().startsWith('22F18C')) {
          targetPid = m;
          break;
        }
      }
      // Fallback: use first pid
      if (targetPid == null && rawPids.first is Map) {
        targetPid = Map<String,dynamic>.from(rawPids.first as Map);
      }
      if (targetPid == null) return ['false', ''];

      final pid = (targetPid['pid'] ?? targetPid['did'] ?? targetPid['code'] ?? '').toString();
      if (pid.isEmpty) return ['false', ''];

      print('\n🔍 _readPid[$index] type=$pidType PID=$pid TX=${slot.txHeader}');

      final dongle = slot.dongle!;

      // .NET exact sequence from GetESN:
      // dongleCommWin.SecurityAccess(index)
      print('🔐 SA...');
      final saR = await dongle.securityAccess();
      print('   SA: ${_hexR(saR)}');
      await _ms(200);

      // dongleCommWin.CAN_StopTP(index)
      print('🛑 StopTP...');
      final stR = await dongle.canStopTP();
      print('   StopTP: ${_hexR(stR)}');
      await _ms(200);

      // dongleCommWin.Dongle_SetProtocol(protocolValue, index)
      print('⚙️  Proto...');
      final prR = await dongle.dongleSetProtocol(slot.proto);
      print('   Proto: ${_hexR(prR)}');
      await _ms(200);

      // dongleCommWin.CAN_SetTxHeader(tx, index)
      print('📤 TxH(${slot.txHeader})...');
      final txR = await dongle.canSetTxHeader(slot.txHeader);
      print('   TxH: ${_hexR(txR)}');
      await _ms(200);

      // dongleCommWin.CAN_SetRxHeaderMask(rx, index)
      print('📥 RxH(${slot.rxHeader})...');
      final rxR = await dongle.canSetRxHeaderMask(slot.rxHeader);
      print('   RxH: ${_hexR(rxR)}');
      await _ms(200);

      // dongleCommWin.CAN_StartPadding("00", index)
      print('🟢 Pad...');
      final padR = await dongle.canStartPadding('00');
      print('   Pad: ${_hexR(padR)}');
      await _ms(200);

      // UDSDiagnostic.ReadParameters — same as .NET
      // Build PID list with just the target PID
      final pidList = <ReadParameterPID>[];
      for (final item in rawPids) {
        if (item is! Map) continue;
        final m    = Map<String,dynamic>.from(item);
        final code = (m['pid']??m['did']??m['code']??m['hex']) as String?;
        if (code == null || code.isEmpty) continue;
        m['pid'] = code;
        pidList.add(ReadParameterPID.fromJson(m));
      }
      if (pidList.isEmpty) return ['false', ''];

      // Find the single PID matching our type and read only that
      ReadParameterPID? targetPidObj;
      for (final p in pidList) {
        final code = p.pid ?? '';
        if (pidType == 'ESN'   && code == '0906') { targetPidObj = p; break; }
        if (pidType == 'CALID' && code == '0904') { targetPidObj = p; break; }
        if (pidType == 'SW'    && code.toUpperCase().startsWith('22F18B')) { targetPidObj = p; break; }
        if (pidType == 'HW'    && code.toUpperCase().startsWith('22F188')) { targetPidObj = p; break; }
        if (pidType == 'CVN'   && code.toUpperCase().startsWith('22F18C')) { targetPidObj = p; break; }
      }
      // Fallback to first in list
      targetPidObj ??= pidList.first;

      print('📡 ReadParameters: type=$pidType pid=${targetPidObj.pid}');
      final responses = await slot.diag!.readParameters(1, [targetPidObj]);

      print('📋 responses count: ${responses?.length ?? 0}');
      for (final resp in (responses ?? [])) {
        // Try responseValue from variables first
        final vars = resp.variables;
        if (vars.isNotEmpty) {
          final rv = vars.first.responseValue ?? '';
          if (rv.isNotEmpty) {
            print('✅ _readPid[$index] responseValue: "$rv"');
            return ['true', rv];
          }
        }

        // Try dataArray (Uint8List of actual ECU data bytes)
        final da = resp.dataArray;
        if (da != null && da.isNotEmpty) {
          // dataArray contains raw bytes e.g. [0x49,0x06,0x01,0x8D,0xE0,0x9A,0xA0]
          // Skip service prefix bytes
          List<int> data = da.toList();
          if (data.length > 3) {
            if (data[0] == 0x49 || data[0] == 0x62) {
              data = data.sublist(3); // skip 3 header bytes
            }
          }
          // Remove padding (0xCC, 0x00)
          final clean = data.where((b) => b != 0xCC && b != 0x00).toList();
          if (clean.isEmpty) continue;
          // Return as ASCII if printable, else hex string
          final isAscii = clean.every((b) => b >= 0x20 && b < 0x7F);
          final result = isAscii
              ? String.fromCharCodes(clean)
              : clean.map((b) => b.toRadixString(16).padLeft(2,'0').toUpperCase()).join();
          print('✅ _readPid[$index] dataArray: "$result" status=${resp.status}');
          return ['true', result];
        }

        // status contains useful info too
        print('   resp: status=${resp.status} pidId=${resp.pidId}');
      }
    } catch (e) {
      print('❌ _readPid[$index]: $e'); return ['false', ''];
    }
    return ['false', ''];
  }

  String _hexR(dynamic r) {
    if (r == null) return 'null';
    if (r is Uint8List) return r.map((e) => e.toRadixString(16).padLeft(2,'0').toUpperCase()).join(' ');
    return r.toString();
  }

  Future<void> _ms(int ms) => Future.delayed(Duration(milliseconds: ms));

  // Public API
  Future<List<String>> getESN(String ip, int i, List p) async => _readPid(i, p, pidType: 'ESN');
  Future<List<String>> getHW(String ip, int i, List p) async  => _readPid(i, p, pidType: 'HW');
  Future<List<String>> getSW(String ip, int i, List p) async  => _readPid(i, p, pidType: 'SW');
  Future<List<String>> getCalId(String ip, int i, List p) async => _readPid(i, p, pidType: 'CALID');
  Future<List<String>> getCVN(String ip, int i, List p) async  => _readPid(i, p, pidType: 'CVN');

  // Flash
  Future<String> startECUFlashing({
    required String ip, required int index,
    required String seqFileContent, required String hexFileContent,
    required String seedKeyIndex, required String txHeader,
    required String rxHeader, required String protocolHex,
    required Function(double) onProgress, required Function(String) onStatus,
  }) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready || slot.diag == null) {
        print('❌ startECUFlashing: slot $index not ready');
        return 'ERROR: slot $index not ready';
      }

      // .NET calls CAN_StartTP before FlashInterpreter
      print('▶️  startECUFlashing[$index]: CAN_StartTP...');
      await slot.dongle!.canStartTP();
      await Future.delayed(const Duration(milliseconds: 200));

      final jsonData = FlashingMatrixData.fromJson(
          jsonDecode(hexFileContent) as Map<String,dynamic>);
      if (jsonData.noOfSectors == null) return 'ERROR: invalid hex JSON';

      SEEDKEYINDEXTYPE seedEnum;
      try {
        seedEnum = SEEDKEYINDEXTYPE.values.firstWhere(
            (e) => e.name == seedKeyIndex,
            orElse: () => SEEDKEYINDEXTYPE.RE_SEEDKEY);
      } catch (_) { seedEnum = SEEDKEYINDEXTYPE.RE_SEEDKEY; }

      print('▶️  startECUFlashing[$index]: flashInterpreter seed=$seedKeyIndex...');
      final result = await slot.diag!.flashInterpreter(
        FlashConfig(seedKeyIndex: seedEnum),
        jsonData.noOfSectors!, jsonData.sectorData!, seqFileContent,
      ) ?? 'NOERROR';

      // .NET calls CAN_StopTP after flash
      print('⏹️  startECUFlashing[$index]: CAN_StopTP result=$result');
      await slot.dongle!.canStopTP();

      return result;
    } catch (e) {
      print('❌ startECUFlashing[$index]: $e');
      return 'ERROR: $e';
    }
  }

  Future<void> resetDongle(String ip, int index) async {
    try {
      final slot = _slots[index];
      if (slot?.dongle != null) await slot!.dongle!.resetDongle();
    } catch (e) { print('❌ reset: $e'); }
  }
}