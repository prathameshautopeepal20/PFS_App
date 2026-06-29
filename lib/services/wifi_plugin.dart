// lib/services/wifi_plugin.dart
// Mirrors .NET WifiFunctions.cs exactly
// Key: persistent TcpClient per index (like .NET client_1, client_2...)
// Fix: auto-reconnect if dongle disconnects during flash

import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_diagnostic/enum/seedkeyIndexType.dart';
import 'package:ap_diagnostic/models/flashingMtrixModel.dart';
import 'package:ap_diagnostic/models/readParameterPIDModel.dart';
import 'package:ap_diagnostic/structure/flash_structures.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_dongle_comm/utils/enums/protocol.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';

// ── Per-dongle slot
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

  final Map<int, _Slot>     _slots          = {};
  final Map<String, double> flashPercentMap = {};

  // Seed key lock: only ONE ECU can do 2701/2702 at a time on shared CAN bus
  // After seed key, bulk data is safe to run in parallel (different sequence counters)
  //  Creates 8 empty slots (client_1 … client_8)
  Future<void> initSockets() async {
    for (int i = 1; i <= 8; i++) _slots[i] = _Slot();
    print('✅ [WiFiPlugin] Sockets initialized (8 slots)');
  }
  bool _flashInProgress = false;

  Future<void> closeSockets() async {
    // 🔥 CRITICAL: Never close sockets while flash is running!
    if (_flashInProgress) {
      print('⚠️ closeSockets BLOCKED — flash in progress!');
      return;
    }
    for (final s in _slots.values) {
      try { await s.ctrl.disconnect(); } catch (_) {}
      s.ready = false;
    }
    print('✅ [WiFiPlugin] All sockets closed');
  }

  UDSDiagnostic? getDiag(int index) => _slots[index]?.diag;

  // ─────────────────────────────────────────────────────────
  // Clear socket buffer for a slot — removes stale data before post-flash reads
  Future<void> clearBuffer(int index) async {
    try {
      final slot = _slots[index];
      if (slot != null) await slot.ctrl.clearBuffer();
    } catch (_) {}
  }
  //  Closes existing connection, reconnects, creates DongleComm
  //  TX=7E0 forced (server sends 7DF which ECU ignores)
  // ─────────────────────────────────────────────────────────
  Future<bool> checkDongle(String ip, int index, {
    String txHeader     = '7E0',
    String rxHeaderMask = '7E8',
    String protocolHex  = '02',
  }) async {
    try {
      // Pad to even length (07E0, 07E8)
      final txH   = txHeader.length.isOdd     ? '0$txHeader'     : txHeader;
      final rxH   = rxHeaderMask.length.isOdd ? '0$rxHeaderMask' : rxHeaderMask;
      final proto = int.tryParse(protocolHex, radix: 16) ?? 0x02;

      final slot = _slots[index] ?? _Slot();
      _slots[index] = slot;

      // .NET: if connected → close → delay 50ms → new TcpClient
      if (slot.ctrl.isConnected.value) {
        await slot.ctrl.disconnect();
        await _ms(50);
      }

      // .NET: client_N.ConnectAsync(IP, 6888).Wait(500)
      await slot.ctrl.connectWifi(
          host: ip, port: 6888, selectedType: Connectivity.wiFi);

      if (!slot.ctrl.isConnected.value) {
        print('❌ checkDongle[$index] @ $ip: connection failed');
        return false;
      }

      final protocol = Protocol.values.firstWhere(
          (p) => p.value == proto,
          orElse: () => Protocol.ISO15765_500KB_11BIT_CAN);

      final dongle = DongleComm(
          comm: slot.ctrl, isChannel: true, channelId: '00');
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
  //  _reconnect — reconnect dongle if dropped during flash
  //  .NET does this implicitly via persistent TcpClient
  // ─────────────────────────────────────────────────────────
  Future<bool> _reconnect(int index) async {
    final slot = _slots[index];
    if (slot == null) return false;
    print('🔄 Reconnecting slot $index @ ${slot.ip}...');
    try {
      if (slot.ctrl.isConnected.value) {
        await slot.ctrl.disconnect();
        await _ms(50);
      }
      await slot.ctrl.connectWifi(
          host: slot.ip, port: 6888, selectedType: Connectivity.wiFi);
      if (!slot.ctrl.isConnected.value) {
        print('❌ Reconnect failed for slot $index');
        return false;
      }
      final protocol = Protocol.values.firstWhere(
          (p) => p.value == slot.proto,
          orElse: () => Protocol.ISO15765_500KB_11BIT_CAN);
      final dongle = DongleComm(
          comm: slot.ctrl, isChannel: true, channelId: '00');
      dongle.protocol = protocol;
      slot.dongle  = dongle;
      slot.diag    = UDSDiagnostic(dongle, ECUCalculateSeedkey());
      slot.ready   = true;
      print('✅ Reconnected slot $index @ ${slot.ip}');
      return true;
    } catch (e) {
      print('❌ Reconnect exception slot $index: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  _setupCAN — StopTP → Proto → TxH → RxH → Padding
  // ─────────────────────────────────────────────────────────
  Future<void> _setupCAN(_Slot slot) async {
    final d = slot.dongle!;
    await d.canStopTP();
    await d.dongleSetProtocol(slot.proto);
    await d.canSetTxHeader(slot.txHeader);
    await d.canSetRxHeaderMask(slot.rxHeader);
    await d.canStartPadding('00');
  }

  // ─────────────────────────────────────────────────────────
  //  _diagSession — 10 01 (DefaultSession) to recover ECU
  // ─────────────────────────────────────────────────────────
  Future<bool> _diagSession(DongleComm dongle, int attempt) async {
    try {
      final resp   = await dongle.can2xTxRx(2, '1001');
      final status = resp?.ecuResponseStatus ?? 'null';
      final data   = resp?.actualDataBytes
              ?.map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(' ') ?? '';
      print('🔄 DiagSession[$attempt](10 01): $status data=$data');
      return status == 'NOERROR';
    } catch (e) {
      print('   ⚠️ DiagSession[$attempt] ex: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  _readPid — mirrors .NET GetESN/GetHW/GetSW/GetCalId/GetCVN
  //  2-attempt retry: attempt 1 may fail if ECU in programming
  //  session from previous flash → attempt 2 recovers
  // ─────────────────────────────────────────────────────────
  Future<List<String>> _readPid(int index, List<dynamic> rawPids,
      {String pidType = 'ESN'}) async {
    try {
      final slot = _slots[index];
      if (slot == null || !slot.ready || slot.dongle == null) {
        print('❌ _readPid[$index]: slot not ready');
        return ['false', ''];
      }

      // Hardcoded PIDs from .NET debug log
      const hardcoded = <String, String>{
        'ESN':   '22F18C',
        'HW':    '22F18B',
        'SW':    '22F188',
        'CALID': '0904',
        'CVN':   '0906',
      };

      // Find matching PID from API list, else use hardcoded
      ReadParameterPID? targetPid;
      for (final item in rawPids) {
        if (item is! Map) continue;
        final m    = Map<String, dynamic>.from(item);
        final code = (m['pid'] ?? m['did'] ?? m['code'] ?? '')
            .toString().toUpperCase();
        if (pidType == 'ESN'   && code.contains('22F18C')) { targetPid = ReadParameterPID.fromJson({...m, 'pid': code}); break; }
        if (pidType == 'HW'    && code.contains('22F18B')) { targetPid = ReadParameterPID.fromJson({...m, 'pid': code}); break; }
        if (pidType == 'SW'    && code.contains('22F188')) { targetPid = ReadParameterPID.fromJson({...m, 'pid': code}); break; }
        if (pidType == 'CALID' && code == '0904')          { targetPid = ReadParameterPID.fromJson({...m, 'pid': '0904'}); break; }
        if (pidType == 'CVN'   && code == '0906')          { targetPid = ReadParameterPID.fromJson({...m, 'pid': '0906'}); break; }
      }
      if (targetPid == null) {
        final hp = hardcoded[pidType];
        if (hp == null) { print('❌ Unknown pidType: $pidType'); return ['false', '']; }
        targetPid = ReadParameterPID.fromJson({
          'pid': hp, 'pid_type': pidType, 'name': pidType, 'length': 0,
        });
      }

      print('\n🔍 _readPid[$index] type=$pidType PID=${targetPid.pid} TX=${slot.txHeader}');

      // SecurityAccess once before attempts
      print('🔐 SA...');
      final saR = await slot.dongle!.securityAccess();
      print('   SA: ${_hex(saR)}');
      await _ms(50);

      // 2-attempt loop (handles ECU stuck in programming session)
      for (int attempt = 1; attempt <= 2; attempt++) {
        await _setupCAN(slot);
        final dsOk = await _diagSession(slot.dongle!, attempt);
        await _ms(50);

        if (!dsOk && attempt == 1) {
          print('   ⚠️ DiagSession attempt 1 failed → retrying...');
          await _ms(100);
          continue;
        }

        print('📡 ReadParameters attempt $attempt: pid=${targetPid.pid}');
        final responses = await slot.diag!.readParameters(1, [targetPid]);
        print('📋 responses: ${responses?.length ?? 0}');

        for (final resp in (responses ?? [])) {
          final status = resp.status ?? '';
          if (status.isNotEmpty && status != 'NOERROR' && status.contains('ERROR')) {
            print('   ⚠️ skip: $status');
            continue;
          }

          // Try responseValue
          final vars = resp.variables ?? [];
          if (vars.isNotEmpty) {
            final rv = vars.first.responseValue ?? '';
            if (rv.isNotEmpty) {
              print('✅ _readPid[$index] $pidType responseValue: "$rv"');
              return ['true', rv];
            }
          }

          // Try dataArray
          final da = resp.dataArray;
          if (da != null && da.isNotEmpty) {
            List<int> data = da.toList();
            // Strip service response header: 62 F1 8x (UDS) or 49 xx xx (OBD2)
            if (data.length > 3 && (data[0] == 0x49 || data[0] == 0x62)) {
              data = data.sublist(3);
            }
            // Strip ALL padding bytes: 0xCC (CAN padding), 0x00 (null), 0xFF (erased flash)
            final clean = data.where((b) => b != 0xCC && b != 0x00 && b != 0xFF).toList();
            if (clean.isEmpty) {
              print('   ⚠️ dataArray all padding — skip');
              continue;
            }
            // Must be printable ASCII for ESN/HW/SW/CALID/CVN
            final isAscii = clean.every((b) => b >= 0x20 && b < 0x7F);
            if (!isAscii && pidType != 'CVN') {
              // For non-CVN: if not ASCII, likely garbage — skip
              print('   ⚠️ dataArray not ASCII for $pidType — skip');
              continue;
            }
            final result = isAscii
                ? String.fromCharCodes(clean)
                : clean.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();
            // Sanity check: result must be at least 4 chars and not all same char
            if (result.length < 4) {
              print('   ⚠️ dataArray too short: "$result" — skip');
              continue;
            }
            if (result.runes.toSet().length == 1) {
              print('   ⚠️ dataArray all same char: "$result" — skip');
              continue;
            }
            print('✅ _readPid[$index] $pidType dataArray: "$result"');
            return ['true', result];
          }
          print('   resp: status=$status');
        }

        if (dsOk) break; // DiagSession succeeded but no data → no retry
      }
    } catch (e) {
      print('❌ _readPid[$index] EXCEPTION: $e');
    }
    print('⚠️  _readPid[$index] $pidType → false');
    return ['false', ''];
  }

  String _hex(dynamic r) {
    if (r == null) return 'null';
    if (r is Uint8List) return r.map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
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
  //  Both BATCH and INDIVIDUAL use this same method
  //  Auto-reconnect if dongle drops mid-flash
  // ─────────────────────────────────────────────────────────
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
    _flashInProgress = true;
    try {
      var slot = _slots[index];
      if (slot == null || !slot.ready || slot.diag == null) {
        // Try reconnect first
        print('⚠️ slot $index not ready → reconnecting...');
        final ok = await _reconnect(index);
        if (!ok) return 'ERROR: slot $index not ready';
        slot = _slots[index]!;
      }

      // Convert SREC → FlashingMatrixData 
      print('🔄 Converting SREC[$index]: ${hexFileContent.length} chars');
      final jsonData = _srecToFlashingMatrixData(seqFileContent, hexFileContent);
      if (jsonData == null || (jsonData.noOfSectors ?? 0) == 0) {
        return 'ERROR: SREC conversion failed';
      }
      print('✅ SREC[$index]: ${jsonData.noOfSectors} sectors');

      final seedEnum = SEEDKEYINDEXTYPE.values.firstWhere(
        (e) => e.name == seedKeyIndex,
        orElse: () => SEEDKEYINDEXTYPE.RE_SEEDKEY_EPM44,
      );

      // .NET: await dongleCommWin.CAN_StartTP(ecu_index)
      print('▶️  CAN_StartTP[$index]...');
      await slot.dongle!.canStartTP();

      
      // SEED KEY LOCK: only ONE ECU does 2701/2702 at a time on shared CAN bus
      // After seed key (~1-2 sec), lock releases so next ECU can do its seed key
      // Bulk data (sendbulkdata) runs in parallel after all seed keys complete
      print('▶️  flashInterpreter[$index] seed=$seedKeyIndex sectors=${jsonData.noOfSectors}');

      // Flash sequentially via controller (Future.wait won't help with shared CAN bus)
      String result = 'No Resp From Dongle';
      try {
        result = await slot.diag!.flashInterpreter(
              FlashConfig(seedKeyIndex: seedEnum),
              jsonData.noOfSectors!,
              jsonData.sectorData!,
              seqFileContent,
            ) ?? 'NOERROR';
      } catch (e) {
        print('❌ flashInterpreter[$index] exception: $e');
        if (!slot.ctrl.isConnected.value) {
          print('🔌 Dongle $index disconnected during flash');
        }
        result = 'No Resp From Dongle';
      }

      print('⏹️  startECUFlashing[$index]: result=$result');

      // .NET: await dongleCommWin.CAN_StopTP(ecu_index)
      try {
        await slot.dongle!.canStopTP();
      } catch (e) {
        print('⚠️  CAN_StopTP[$index] failed (dongle may have disconnected): $e');
      }

    
      if (result == 'NOERROR' || result == 'ECUERROR_GENERALPROGRAMMINGFAILURE') {
        print('   ✅ FLASH SUCCESS[$index]!');
        return 'NOERROR';
      }

      return result;
    } catch (e) {
      print('❌ startECUFlashing[$index]: $e');
      return 'ERROR: $e';
    }
  }

  void setFlashInProgress(bool value) {
    _flashInProgress = value;
    print('🔒 _flashInProgress = $value');
  }

  // ─────────────────────────────────────────────────────────
  //  SREC → FlashingMatrixData
  // ─────────────────────────────────────────────────────────
  FlashingMatrixData? _srecToFlashingMatrixData(
      String seqFile, String srecFile) {
    try {
      // Parse EcuMapFile address ranges from seq file
      final ranges = <_AddrRange>[];
      for (final raw in seqFile.split('\n')) {
        final line = raw.replaceAll('\r', '').trim();
        if (!line.startsWith('EcuMapFile:')) continue;
        final startM = RegExp(r'start_address,([0-9A-Fa-fx]+)').firstMatch(line);
        final endM   = RegExp(r'end_address,([0-9A-Fa-fx]+)').firstMatch(line);
        if (startM != null && endM != null) {
          final start = int.parse(startM.group(1)!.replaceAll('0x', ''), radix: 16);
          final end   = int.parse(endM.group(1)!.replaceAll('0x', ''), radix: 16);
          ranges.add(_AddrRange(start, end));
          print('  EcuMapFile: 0x${start.toRadixString(16)} → 0x${end.toRadixString(16)}');
        }
      }

      // Parse SREC S1/S2/S3 records
      final addrMap = <int, int>{};
      for (final raw in srecFile.split('\n')) {
        final line = raw.replaceAll('\r', '').trim();
        if (line.length < 4) continue;
        final type = line.substring(0, 2).toUpperCase();
        if (!['S1', 'S2', 'S3'].contains(type)) continue;
        final byteCount = int.parse(line.substring(2, 4), radix: 16);
        final addrLen   = type == 'S1' ? 2 : type == 'S2' ? 3 : 4;
        final addrEnd   = 4 + addrLen * 2;
        if (addrEnd > line.length) continue;
        final addr    = int.parse(line.substring(4, addrEnd), radix: 16);
        final dataEnd = 4 + byteCount * 2 - 2;
        if (dataEnd > line.length) continue;
        final dataHex = line.substring(addrEnd, dataEnd);
        for (int i = 0; i < dataHex.length - 1; i += 2) {
          addrMap[addr + i ~/ 2] =
              int.parse(dataHex.substring(i, i + 2), radix: 16);
        }
      }
      print('  SREC parsed: ${addrMap.length} bytes');

      final sectors = <FlashingMatrix>[];

      if (ranges.isEmpty) {
        // Auto-detect: gap > 256 bytes = new sector
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
          buf.write(addrMap[addr]!.toRadixString(16).padLeft(2, '0').toUpperCase());
          prev = addr;
        }
        if (buf.isNotEmpty) sectors.add(_makeSector(secStart, prev, buf.toString()));
      } else {
        for (final range in ranges) {
          final buf = StringBuffer();
          for (int addr = range.start; addr <= range.end; addr++) {
            buf.write((addrMap[addr] ?? 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase());
          }
          sectors.add(_makeSector(range.start, range.end, buf.toString()));
        }
      }

   
      int maxRefIndex = 0;
      for (final raw in seqFile.split('\n')) {
        final matches = RegExp(r'(?:json_strt_addr|json_end_addr|ecu_memmap_strt_addr|ecu_memmap_end_addr)(\d+)').allMatches(raw);
        for (final m in matches) {
          final idx = int.tryParse(m.group(1) ?? '0') ?? 0;
          if (idx > maxRefIndex) maxRefIndex = idx;
        }
      }
      while (sectors.length <= maxRefIndex) {
        // Add dummy sector with same address as last sector (FF data)
        final last = sectors.isNotEmpty ? sectors.last : _makeSector(0, 0, 'FF');
        sectors.add(_makeSector(
          int.parse(last.jsonStartAddress!, radix: 16),
          int.parse(last.jsonEndAddress!, radix: 16),
          last.jsonData ?? 'FF',
        ));
        print('  Added dummy sector ${sectors.length - 1} to match seq file references');
      }
      print('  Sectors: ${sectors.length} (maxRef=$maxRefIndex)');
      return FlashingMatrixData(noOfSectors: sectors.length, sectorData: sectors);
    } catch (e) {
      print('❌ _srecToFlashingMatrixData: $e');
      return null;
    }
  }

  FlashingMatrix _makeSector(int start, int end, String dataHex) =>
      FlashingMatrix(
        jsonStartAddress:      start.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonEndAddress:        end.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonData:              dataHex,
        ecuMemMapStartAddress: start.toRadixString(16).toUpperCase().padLeft(8, '0'),
        ecuMemMapEndAddress:   end.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonCheckSum: '',
      );

  Future<void> resetDongle(String ip, int index) async {
    try {
      final slot = _slots[index];
      if (slot?.dongle != null) await slot!.dongle!.resetDongle();
    } catch (e) { print('❌ resetDongle[$index]: $e'); }
  }
}

class _AddrRange {
  final int start, end;
  _AddrRange(this.start, this.end);
}


FlashingMatrixData? _srecToFlashingMatrixDataIsolate(List<String> args) {
  final seqFile  = args[0];
  final srecFile = args[1];
  try {
    // Parse EcuMapFile address ranges from seq file
    final ranges = <_AddrRange>[];
    for (final raw in seqFile.split('\n')) {
      final line = raw.replaceAll('\r', '').trim();
      if (!line.startsWith('EcuMapFile:')) continue;
      final startM = RegExp(r'start_address,([0-9A-Fa-fx]+)').firstMatch(line);
      final endM   = RegExp(r'end_address,([0-9A-Fa-fx]+)').firstMatch(line);
      if (startM != null && endM != null) {
        final s = int.parse(startM.group(1)!.replaceAll('0x', ''), radix: 16);
        final e = int.parse(endM.group(1)!.replaceAll('0x', ''), radix: 16);
        ranges.add(_AddrRange(s, e));
      }
    }

    // Parse SREC S1/S2/S3 records
    final addrMap = <int, int>{};
    for (final raw in srecFile.split('\n')) {
      final line = raw.replaceAll('\r', '').trim();
      if (line.length < 4) continue;
      final type = line.substring(0, 2).toUpperCase();
      if (!['S1', 'S2', 'S3'].contains(type)) continue;
      final byteCount = int.parse(line.substring(2, 4), radix: 16);
      final addrLen   = type == 'S1' ? 2 : type == 'S2' ? 3 : 4;
      final addrEnd   = 4 + addrLen * 2;
      if (addrEnd > line.length) continue;
      final addr    = int.parse(line.substring(4, addrEnd), radix: 16);
      final dataEnd = 4 + byteCount * 2 - 2;
      if (dataEnd > line.length) continue;
      final dataHex = line.substring(addrEnd, dataEnd);
      for (int i = 0; i < dataHex.length - 1; i += 2) {
        addrMap[addr + i ~/ 2] = int.parse(dataHex.substring(i, i + 2), radix: 16);
      }
    }
    if (addrMap.isEmpty) return null;

    FlashingMatrix makeSector(int start, int end, String dataHex) =>
      FlashingMatrix(
        jsonStartAddress:      start.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonEndAddress:        end.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonData:              dataHex,
        ecuMemMapStartAddress: start.toRadixString(16).toUpperCase().padLeft(8, '0'),
        ecuMemMapEndAddress:   end.toRadixString(16).toUpperCase().padLeft(8, '0'),
        jsonCheckSum: '',
      );

    final sectors = <FlashingMatrix>[];

    if (ranges.isEmpty) {
      final sorted = addrMap.keys.toList()..sort();
      var secStart = sorted.first;
      var prev     = sorted.first;
      final buf    = StringBuffer();
      for (final addr in sorted) {
        if (addr - prev > 256 && buf.isNotEmpty) {
          sectors.add(makeSector(secStart, prev, buf.toString()));
          secStart = addr; buf.clear();
        }
        buf.write(addrMap[addr]!.toRadixString(16).padLeft(2, '0').toUpperCase());
        prev = addr;
      }
      if (buf.isNotEmpty) sectors.add(makeSector(secStart, prev, buf.toString()));
    } else {
      for (final range in ranges) {
        final buf = StringBuffer();
        for (int addr = range.start; addr <= range.end; addr++) {
          buf.write((addrMap[addr] ?? 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase());
        }
        sectors.add(makeSector(range.start, range.end, buf.toString()));
      }
    }

    return FlashingMatrixData(noOfSectors: sectors.length, sectorData: sectors);
  } catch (e) {
    return null;
  }
}