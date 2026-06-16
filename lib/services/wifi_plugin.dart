// lib/services/wifi_plugin.dart
// Uses CommController.sendCommand() with correct .NET CRC-16/Kermit
// Bypasses DongleComm setup commands (wrong CRC) — uses raw bytes instead

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
  CommController ctrl     = CommController();
  DongleComm?    dongle;
  UDSDiagnostic? diag;
  String         ip       = '';
  String         txHeader = '07DF';
  String         rxHeader = '07E8';
  int            proto    = 0x02;
  bool           ready    = false;
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

  // ════════════════════════════════════════════════════════════
  //  checkDongle — TCP connect only (mirrors .NET CheckClient_1)
  // ════════════════════════════════════════════════════════════
  Future<bool> checkDongle(String ip, int index, {
    String txHeader     = '7DF',
    String rxHeaderMask = '7E8',
    String protocolHex  = '02',
  }) async {
    try {
      final txH   = txHeader.length.isOdd     ? '0$txHeader'     : txHeader;
      final rxH   = rxHeaderMask.length.isOdd ? '0$rxHeaderMask' : rxHeaderMask;
      final proto = int.tryParse(protocolHex, radix: 16) ?? 0x02;

      final slot = _slots[index]!;
      if (slot.ctrl.isConnected.value) {
        await slot.ctrl.disconnect();
        await Future.delayed(const Duration(milliseconds: 50));
      }

      print('🌐 CheckClient_$index: connecting $ip:6888...');
      await slot.ctrl.connectWifi(
        host: ip, port: 6888, selectedType: Connectivity.wiFi);

      if (!slot.ctrl.isConnected.value) return false;

      final protocol = Protocol.values.firstWhere(
          (p) => p.value == proto,
          orElse: () => Protocol.ISO15765_500KB_11BIT_CAN);
      final dongle = DongleComm(comm: slot.ctrl, isChannel: false);
      dongle.protocol = protocol;

      slot.dongle   = dongle;
      slot.diag     = UDSDiagnostic(dongle, ECUCalculateSeedkey());
      slot.ip       = ip;
      slot.txHeader = txH;
      slot.rxHeader = rxH;
      slot.proto    = proto;
      slot.ready    = true;

      print('✅ [WiFiPlugin] Dongle $index connected @ $ip:6888');
      return true;
    } catch (e) {
      print('❌ checkDongle[$index]: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  _readPid — sends setup commands with CORRECT .NET CRC
  //  then uses UDSDiagnostic.readParameters for the actual read
  // ════════════════════════════════════════════════════════════
  Future<List<String>> _readPid(int index, List<dynamic> rawPids) async {
    try {
      final slot = _slots[index];
      if (slot == null) {
        print('❌ _readPid[$index]: no slot'); return ['false',''];
      }
      if (rawPids.isEmpty) {
        print('❌ _readPid[$index]: no pids'); return ['false',''];
      }

      final p   = rawPids.first;
      final map = p is Map ? Map<String,dynamic>.from(p) : <String,dynamic>{};
      final pidHex = (map['pid']??map['did']??map['code']??map['hex']) as String?;
      if (pidHex==null||pidHex.isEmpty) {
        print('❌ _readPid[$index]: no pid field'); return ['false',''];
      }

      // Fresh connect — mirrors .NET new DongleCommWin each time
      if (slot.ctrl.isConnected.value) {
        await slot.ctrl.disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      print('\n🔍 _readPid[$index]: PID=$pidHex TX=${slot.txHeader}');

      await slot.ctrl.connectWifi(
        host: slot.ip, port: 6888, selectedType: Connectivity.wiFi);

      if (!slot.ctrl.isConnected.value) {
        print('❌ reconnect failed'); return ['false',''];
      }

      // Recreate DongleComm on fresh connection
      final protocol = Protocol.values.firstWhere(
          (p) => p.value == slot.proto,
          orElse: () => Protocol.ISO15765_500KB_11BIT_CAN);
      final dongle = DongleComm(comm: slot.ctrl, isChannel: false);
      dongle.protocol = protocol;
      slot.dongle = dongle;
      slot.diag   = UDSDiagnostic(dongle, ECUCalculateSeedkey());

      final ctrl  = slot.ctrl;
      final proto = slot.proto;
      final txH   = slot.txHeader;
      final rxH   = slot.rxHeader;
      final txB   = _h2b(txH.padLeft(4,'0'));
      final rxB   = _h2b(rxH.padLeft(4,'0'));
      final prH   = proto.toRadixString(16).padLeft(2,'0').toUpperCase();

      // Send each command and wait for response
      Future<Uint8List?> send(String hex, String label) =>
          ctrl.sendCommand(_h2b(hex));

      print('🔐 SecurityAccess...');
      var r = await send('500C47568AFE56214E238000FFC3', 'SA');
      print('   SA: ${_hex(r)}'); await _ms(150);

      print('🛑 CAN_StopTP...');
      r = await ctrl.sendCommand(_build('200311',[0x11]));
      print('   Stop: ${_hex(r)}'); await _ms(150);

      print('⚙️  SetProtocol($prH)...');
      r = await ctrl.sendCommand(_build('200402$prH',[0x02,proto]));
      print('   Proto: ${_hex(r)}'); await _ms(150);

      print('📤 SetTxHeader($txH)...');
      r = await ctrl.sendCommand(_build('200504$txH',[0x04,...txB]));
      print('   TxH: ${_hex(r)}'); await _ms(100);

      print('📥 SetRxHeaderMask($rxH)...');
      r = await ctrl.sendCommand(_build('200506$rxH',[0x06,...rxB]));
      print('   RxH: ${_hex(r)}'); await _ms(100);

      print('🟢 StartPadding...');
      r = await ctrl.sendCommand(_build('20041200',[0x12,0x00]));
      print('   Pad: ${_hex(r)}'); await _ms(200);

      // ReadParameters
      final pidList = <ReadParameterPID>[];
      for (final item in rawPids) {
        if (item is! Map) continue;
        final m    = Map<String,dynamic>.from(item);
        final code = (m['pid']??m['did']??m['code']??m['hex']) as String?;
        if (code==null||code.isEmpty) continue;
        m['pid'] = code;
        pidList.add(ReadParameterPID.fromJson(m));
      }
      if (pidList.isEmpty) return ['false',''];

      print('📡 ReadParameters: ${pidList.length} pid=${pidList[0].pid}');
      final responses = await slot.diag!.readParameters(pidList.length, pidList);

      if (responses.isEmpty) { print('❌ empty'); return ['false','']; }
      for (final resp in responses) {
        final val = resp.variables?.firstOrNull?.responseValue ?? '';
        if (val.isNotEmpty) {
          print('✅ _readPid[$index]: "$val"');
          return ['true', val];
        }
      }
      print('❌ _readPid[$index]: all empty');
      return ['false',''];
    } catch (e) {
      print('❌ _readPid[$index]: $e');
      return ['false',''];
    }
  }

  // ════════════════════════════════════════════════════════════
  //  CRC-16/Kermit — MATCHES .NET Crc16CcittKermit.ComputeChecksum
  //  init=0x0000, poly=0x8408 (reflected 0x1021)
  // ════════════════════════════════════════════════════════════
  Uint8List _build(String cmdHex, List<int> crcBytes) {
    final crc = _kermit(crcBytes);
    final hi  = (crc >> 8) & 0xFF;
    final lo  = crc & 0xFF;
    return _h2b(cmdHex +
        hi.toRadixString(16).padLeft(2, '0').toUpperCase() +
        lo.toRadixString(16).padLeft(2, '0').toUpperCase());
  }

  int _kermit(List<int> data) {
    int crc = 0x0000;
    for (final b in data) {
      crc ^= b;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0x8408 : crc >> 1;
      }
    }
    return crc;
  }

  Uint8List _h2b(String hex) {
    hex = hex.replaceAll(' ', '');
    if (hex.length.isOdd) hex = '0$hex';
    final r = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < r.length; i++)
      r[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    return r;
  }

  String _hex(Uint8List? b) {
    if (b == null || b.isEmpty) return 'null';
    return b.map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  Future<void> _ms(int ms) => Future.delayed(Duration(milliseconds: ms));

  // ════════════════════════════════════════════════════════════
  //  Public API
  // ════════════════════════════════════════════════════════════
  Future<List<String>> getESN(String ip, int i, List<dynamic> p) async =>
      _readPid(i, p);
  Future<List<String>> getHW(String ip, int i, List<dynamic> p) async =>
      _readPid(i, p);
  Future<List<String>> getSW(String ip, int i, List<dynamic> p) async =>
      _readPid(i, p);
  Future<List<String>> getCalId(String ip, int i, List<dynamic> p) async =>
      _readPid(i, p);
  Future<List<String>> getCVN(String ip, int i, List<dynamic> p) async =>
      _readPid(i, p);

  // ════════════════════════════════════════════════════════════
  //  Flash
  // ════════════════════════════════════════════════════════════
  Future<String> startECUFlashing({
    required String ip,
    required int    index,
    required String seqFileContent,
    required String hexFileContent,
    required String seedKeyIndex,
    required String txHeader,
    required String rxHeader,
    required String protocolHex,
    required Function(double) onProgress,
    required Function(String) onStatus,
  }) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready || slot.diag == null)
        return 'ERROR: slot $index not initialized';

      final jsonData = FlashingMatrixData.fromJson(
          jsonDecode(hexFileContent) as Map<String, dynamic>);
      if (jsonData.noOfSectors == null) return 'ERROR: invalid hex JSON';

      SEEDKEYINDEXTYPE seedEnum;
      try {
        seedEnum = SEEDKEYINDEXTYPE.values.firstWhere(
            (e) => e.name == seedKeyIndex,
            orElse: () => SEEDKEYINDEXTYPE.RE_SEEDKEY);
      } catch (_) { seedEnum = SEEDKEYINDEXTYPE.RE_SEEDKEY; }

      final result = await slot.diag!.flashInterpreter(
        FlashConfig(seedKeyIndex: seedEnum),
        jsonData.noOfSectors!,
        jsonData.sectorData!,
        seqFileContent,
      );
      return result ?? 'NOERROR';
    } catch (e) {
      print('❌ startECUFlashing[$index]: $e');
      return 'ERROR: $e';
    }
  }

  Future<void> resetDongle(String ip, int index) async {
    try {
      final slot = _slots[index];
      if (slot != null && slot.ready) {
        // DongleReset: "200301" + CRC([0x01])
        await slot.ctrl.sendCommand(_build('200301', [0x01]));
      }
    } catch (e) { print('❌ resetDongle[$index]: $e'); }
  }
}