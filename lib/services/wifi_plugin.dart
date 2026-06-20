// lib/services/wifi_plugin.dart
// Mirrors .NET WifiFunctions.cs / IConnectionWifi exactly

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
  CommController ctrl   = CommController();
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

  final Map<int, _Slot>     _slots         = {};
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

  /// Used by progress timer to read flash percent from UDSDiagnostic
  UDSDiagnostic? getDiag(int index) => _slots[index]?.diag;

  // ─────────────────────────────────────────────────────────
  //  checkDongle — TCP connect + DongleComm/UDSDiagnostic setup
  // ─────────────────────────────────────────────────────────
  Future<bool> checkDongle(String ip, int index, {
    String txHeader     = '7E0',
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
        await Future.delayed(const Duration(milliseconds: 100));
      }

      await slot.ctrl.connectWifi(host: ip, port: 6888, selectedType: Connectivity.wiFi);
      if (!slot.ctrl.isConnected.value) return false;

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
      print('❌ checkDongle[$index]: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  _readPid — SA→StopTP→Proto→TxH→RxH→Pad→ReadParameters
  //  Mirrors .NET GetESN / GetCalId / GetSW / GetHW / GetCVN
  // ─────────────────────────────────────────────────────────
  Future<List<String>> _readPid(int index, List<dynamic> rawPids,
      {String pidType = 'ESN'}) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready) {
        print('❌ _readPid[$index]: slot not ready');
        return ['false', ''];
      }

      // Build target PID — hardcoded PIDs matching .NET exactly
      // From .NET debug log:
      // CHECK ESN  → PID 22F18C → "210535372---"  (serial_no for API)
      // CHECK HPN  → PID 22F18B → "A3C073719---"  (hw_part_no)
      // CHECK SW   → PID 22F188 → "CP352000"       (sw_version)
      // CHECK CALID→ PID 0904   → "RE23520P04EU5002"
      // CHECK CVN  → PID 0906   → "8DE09AA0"       (cvn for API)
      final _hardcoded = <String, String>{
        'ESN':   '22F18C',  // .NET ESN = PID 22F18C
        'CALID': '0904',
        'SW':    '22F188',  // .NET SW = PID 22F188
        'HW':    '22F18B',  // .NET HPN = PID 22F18B
        'CVN':   '0906',    // .NET CVN = PID 0906
      };

      // Try to find matching PID in rawPids from API first
      ReadParameterPID? targetPidObj;
      for (final item in rawPids) {
        if (item is! Map) continue;
        final m    = Map<String, dynamic>.from(item);
        final code = (m['pid'] ?? m['did'] ?? m['code'] ?? '').toString().toUpperCase();
        if (pidType == 'ESN'   && code.startsWith('22F18C')) { m['pid'] = code; targetPidObj = ReadParameterPID.fromJson(m); break; }
        if (pidType == 'CALID' && code == '0904')            { m['pid'] = '0904'; targetPidObj = ReadParameterPID.fromJson(m); break; }
        if (pidType == 'SW'    && code.startsWith('22F188')) { m['pid'] = code; targetPidObj = ReadParameterPID.fromJson(m); break; }
        if (pidType == 'HW'    && code.startsWith('22F18B')) { m['pid'] = code; targetPidObj = ReadParameterPID.fromJson(m); break; }
        if (pidType == 'CVN'   && code == '0906')            { m['pid'] = '0906'; targetPidObj = ReadParameterPID.fromJson(m); break; }
      }

      // Fallback: build from hardcoded — NEVER use pidList.first
      if (targetPidObj == null) {
        final hardPid = _hardcoded[pidType];
        if (hardPid == null) { print('❌ Unknown pidType: $pidType'); return ['false', '']; }
        targetPidObj = ReadParameterPID.fromJson({
          'pid': hardPid, 'pid_type': pidType, 'name': pidType, 'length': 0,
        });
        print('⚠️  Hardcoded PID $hardPid for $pidType');
      }

      print('\n🔍 _readPid[$index] type=$pidType PID=${targetPidObj.pid} TX=${slot.txHeader}');
      final dongle = slot.dongle!;

      // .NET: SecurityAccess → StopTP → SetProtocol → SetTxHeader → SetRxHeader → StartPadding
      print('🔐 SA...');
      final saR = await dongle.securityAccess();
      print('   SA: ${_hexR(saR)}');
      await _ms(200);

      print('🛑 StopTP...');
      await dongle.canStopTP();
      await _ms(200);

      print('⚙️  Proto...');
      await dongle.dongleSetProtocol(slot.proto);
      await _ms(200);

      print('📤 TxH(${slot.txHeader})...');
      await dongle.canSetTxHeader(slot.txHeader);
      await _ms(200);

      print('📥 RxH(${slot.rxHeader})...');
      await dongle.canSetRxHeaderMask(slot.rxHeader);
      await _ms(200);

      print('🟢 Pad...');
      await dongle.canStartPadding('00');
      await _ms(200);

      // Send DiagnosticSessionControl(DefaultSession=01) after CAN headers are set
      // Recovers ECU from stuck programming session after failed flash
      // 10 01 = 2 bytes only (NRC 0x13 = wrong length if 3 bytes sent)
      try {
        final dsResp = await dongle.can2xTxRx(2, '1001');
        final dsStatus = dsResp?.ecuResponseStatus ?? 'null';
        final dsData   = dsResp?.actualDataBytes?.map((e) => e.toRadixString(16).padLeft(2,'0').toUpperCase()).join(' ') ?? '';
        print('🔄 DiagSession(10 01): status=$dsStatus data=$dsData');
        if (dsStatus == 'NOERROR') {
          print('   ✅ ECU returned to default session');
        } else {
          print('   ⚠️  DiagSession failed: $dsStatus — ECU may be in bad state');
        }
        await _ms(300);
      } catch (e) {
        print('   ⚠️  DiagSession exception: $e');
      }

      print('📡 ReadParameters: type=$pidType pid=${targetPidObj.pid}');
      final responses = await slot.diag!.readParameters(1, [targetPidObj]);

      print('📋 responses count: ${responses?.length ?? 0}');
      for (final resp in (responses ?? [])) {
        // Skip ECU error responses (ECUERROR_SERVICENOTSUPPORTED etc.)
        final status = resp.status ?? '';
        if (status.isNotEmpty && status != 'NOERROR' && status.contains('ERROR')) {
          print('   ⚠️  skip error response: $status');
          continue;
        }

        // Try responseValue from variables
        final vars = resp.variables ?? [];
        if (vars.isNotEmpty) {
          final rv = vars.first.responseValue ?? '';
          if (rv.isNotEmpty) {
            print('✅ _readPid[$index] responseValue: "$rv"');
            return ['true', rv];
          }
        }

        // Try dataArray — raw ECU bytes
        final da = resp.dataArray;
        if (da != null && da.isNotEmpty) {
          List<int> data = da.toList();
          // Strip service response header: 49 06 xx or 62 F1 8x
          if (data.length > 3 && (data[0] == 0x49 || data[0] == 0x62)) {
            data = data.sublist(3);
          }
          // Strip padding bytes
          final clean = data.where((b) => b != 0xCC && b != 0x00).toList();
          if (clean.isEmpty) continue;
          final isAscii = clean.every((b) => b >= 0x20 && b < 0x7F);
          final result = isAscii
              ? String.fromCharCodes(clean)
              : clean.map((b) => b.toRadixString(16).padLeft(2,'0').toUpperCase()).join();
          print('✅ _readPid[$index] dataArray: "$result" status=$status');
          return ['true', result];
        }
        print('   resp: status=$status pidId=${resp.pidId}');
      }
    } catch (e) {
      print('❌ _readPid[$index] EXCEPTION: $e');
      print('   Stack: check if DongleComm/UDSDiagnostic is properly initialized');
    }
    print('⚠️  _readPid[$index] type=$pidType → no valid response found, returning false');
    return ['false', ''];
  }

  String _hexR(dynamic r) {
    if (r == null) return 'null';
    if (r is Uint8List) return r.map((e) => e.toRadixString(16).padLeft(2,'0').toUpperCase()).join(' ');
    return r.toString();
  }

  Future<void> _ms(int ms) => Future.delayed(Duration(milliseconds: ms));

  // ── Public read API ───────────────────────────────────────
  Future<List<String>> getESN  (String ip, int i, List p) => _readPid(i, p, pidType: 'ESN');
  Future<List<String>> getHW   (String ip, int i, List p) => _readPid(i, p, pidType: 'HW');
  Future<List<String>> getSW   (String ip, int i, List p) => _readPid(i, p, pidType: 'SW');
  Future<List<String>> getCalId(String ip, int i, List p) => _readPid(i, p, pidType: 'CALID');
  Future<List<String>> getCVN  (String ip, int i, List p) => _readPid(i, p, pidType: 'CVN');

  // ─────────────────────────────────────────────────────────
  //  startECUFlashing
  //  Mirrors .NET: CAN_StartTP → ReadJson(SREC→JSON) → FlashInterpreter → CAN_StopTP
  // ─────────────────────────────────────────────────────────
  Future<String> startECUFlashing({
    required String ip,            required int    index,
    required String seqFileContent, required String hexFileContent,
    required String seedKeyIndex,   required String txHeader,
    required String rxHeader,       required String protocolHex,
    required Function(double) onProgress, required Function(String) onStatus,
  }) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready || slot.diag == null) {
        return 'ERROR: slot $index not ready';
      }

      // Convert SREC → FlashingMatrixData (mirrors .NET ReadJson → GetJson.ConvertToJson)
      print('🔄 Converting SREC→JSON: ${hexFileContent.length} chars');
      final jsonData = _srecToFlashingMatrixData(seqFileContent, hexFileContent);
      if (jsonData == null || (jsonData.noOfSectors ?? 0) == 0) {
        return 'ERROR: SREC conversion failed — check seq/hex files';
      }
      print('✅ SREC converted: ${jsonData.noOfSectors} sectors');

      // Map seedKeyIndex string → SEEDKEYINDEXTYPE enum
      final seedEnum = SEEDKEYINDEXTYPE.values.firstWhere(
        (e) => e.name == seedKeyIndex,
        orElse: () => SEEDKEYINDEXTYPE.RE_SEEDKEY_EPM44,
      );

      print('▶️  startECUFlashing[$index]: CAN_StartTP...');
      await slot.dongle!.canStartTP();
      await Future.delayed(const Duration(milliseconds: 200));

      print('▶️  startECUFlashing[$index]: flashInterpreter '
            'seed=$seedKeyIndex sectors=${jsonData.noOfSectors}...');
      final result = await slot.diag!.flashInterpreter(
        FlashConfig(seedKeyIndex: seedEnum),
        jsonData.noOfSectors!, jsonData.sectorData!, seqFileContent,
      ) ?? 'NOERROR';

      print('⏹️  startECUFlashing[$index]: CAN_StopTP result=$result');
      if (result == 'NOERROR') {
        print('   ✅ FLASH SUCCESS: ECU flashed successfully!');
      } else if (result.contains('INVALIDKEY')) {
        print('   ❌ INVALIDKEY: Seed key rejected by ECU');
        print('   → ECU seed: check if ECU needs power cycle');
        print('   → Algorithm: RE_SEEDKEY_EPM44 with secret 13A120A0...');
        print('   → Try: power cycle ECU (ignition OFF 30s → ON)');
        print('   → Confirm with RE team the correct seed key secret');
      } else if (result.contains('SERVICENOTSUPPORTED')) {
        print('   ❌ ECU in wrong session — power cycle ECU');
      } else if (result.contains('ERROR')) {
        print('   ❌ FLASH FAILED: \$result');
      }
      await slot.dongle!.canStopTP();

      return result;
    } catch (e) {
      print('❌ startECUFlashing[$index]: $e');
      return 'ERROR: $e';
    }
  }

  // ─────────────────────────────────────────────────────────
  //  SREC → FlashingMatrixData converter
  //  Mirrors .NET GetJson.ConvertToJson(stream, ecuMapFiles, checksumAlgo)
  // ─────────────────────────────────────────────────────────
  FlashingMatrixData? _srecToFlashingMatrixData(String seqFile, String srecFile) {
    try {
      // Parse EcuMapFile address ranges from seq file
      final ranges = <_AddrRange>[];
      for (final raw in seqFile.split('\n')) {
        final line = raw.replaceAll('\r', '').trim();
        if (!line.startsWith('EcuMapFile:')) continue;
        final startMatch = RegExp(r'start_address,([0-9A-Fa-fx]+)').firstMatch(line);
        final endMatch   = RegExp(r'end_address,([0-9A-Fa-fx]+)').firstMatch(line);
        if (startMatch != null && endMatch != null) {
          final start = int.parse(startMatch.group(1)!.replaceAll('0x',''), radix: 16);
          final end   = int.parse(endMatch.group(1)!.replaceAll('0x',''), radix: 16);
          ranges.add(_AddrRange(start, end));
          print('  EcuMapFile: 0x${start.toRadixString(16)} - 0x${end.toRadixString(16)}');
        }
      }

      // Parse SREC S1/S2/S3 records → address→byte map
      final addrMap = <int, int>{};
      for (final raw in srecFile.split('\n')) {
        final line = raw.replaceAll('\r', '').trim();
        if (line.length < 4) continue;
        final type = line.substring(0, 2).toUpperCase();
        if (!['S1','S2','S3'].contains(type)) continue;
        final byteCount = int.parse(line.substring(2, 4), radix: 16);
        final addrLen   = type == 'S1' ? 2 : type == 'S2' ? 3 : 4;
        final addrEnd   = 4 + addrLen * 2;
        if (addrEnd > line.length) continue;
        final addr      = int.parse(line.substring(4, addrEnd), radix: 16);
        final dataEnd   = 4 + byteCount * 2 - 2; // exclude CRC byte
        if (dataEnd > line.length) continue;
        final dataHex   = line.substring(addrEnd, dataEnd);
        for (int i = 0; i < dataHex.length - 1; i += 2) {
          addrMap[addr + i ~/ 2] = int.parse(dataHex.substring(i, i + 2), radix: 16);
        }
      }
      print('  SREC parsed: ${addrMap.length} bytes');
      if (addrMap.isEmpty) {
        print('  ❌ SREC parse failed — no S1/S2/S3 records found');
        print('  First 100 chars of srecFile: ${srecFile.substring(0, srecFile.length > 100 ? 100 : srecFile.length)}');
      }

      final sectors = <FlashingMatrix>[];

      if (ranges.isEmpty) {
        // Auto-detect: group consecutive addresses into sectors (gap > 256 = new sector)
        if (addrMap.isEmpty) return null;
        final sorted = addrMap.keys.toList()..sort();
        var secStart = sorted.first;
        var prev     = sorted.first;
        final buf    = StringBuffer();
        for (final addr in sorted) {
          if (addr - prev > 256 && buf.isNotEmpty) {
            sectors.add(_makeSector(secStart, prev, buf.toString()));
            secStart = addr; buf.clear();
          }
          buf.write(addrMap[addr]!.toRadixString(16).padLeft(2,'0').toUpperCase());
          prev = addr;
        }
        if (buf.isNotEmpty) sectors.add(_makeSector(secStart, prev, buf.toString()));
      } else {
        // Use EcuMapFile address ranges from seq file
        for (final range in ranges) {
          final buf = StringBuffer();
          for (int addr = range.start; addr <= range.end; addr++) {
            buf.write((addrMap[addr] ?? 0xFF).toRadixString(16).padLeft(2,'0').toUpperCase());
          }
          sectors.add(_makeSector(range.start, range.end, buf.toString()));
        }
      }

      print('  Sectors built: ${sectors.length}');
      return FlashingMatrixData(noOfSectors: sectors.length, sectorData: sectors);
    } catch (e) {
      print('❌ _srecToFlashingMatrixData: $e');
      return null;
    }
  }

  FlashingMatrix _makeSector(int start, int end, String dataHex) => FlashingMatrix(
    jsonStartAddress:      start.toRadixString(16).toUpperCase().padLeft(8,'0'),
    jsonEndAddress:        end.toRadixString(16).toUpperCase().padLeft(8,'0'),
    jsonData:              dataHex,
    ecuMemMapStartAddress: start.toRadixString(16).toUpperCase().padLeft(8,'0'),
    ecuMemMapEndAddress:   end.toRadixString(16).toUpperCase().padLeft(8,'0'),
    jsonCheckSum:          '',
  );

  Future<void> resetDongle(String ip, int index) async {
    try {
      final slot = _slots[index];
      if (slot?.dongle != null) await slot!.dongle!.resetDongle();
    } catch (e) { print('❌ reset: $e'); }
  }
}

class _AddrRange {
  final int start, end;
  _AddrRange(this.start, this.end);
}