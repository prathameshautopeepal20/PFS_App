// lib/services/wifi_plugin.dart

import 'dart:convert';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_diagnostic/models/readParameterPIDModel.dart';
import 'package:ap_diagnostic/models/flashingMtrixModel.dart';
import 'package:ap_diagnostic/structure/flash_structures.dart';
import 'package:ap_diagnostic/enum/seedkeyIndexType.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';

class WiFiPlugin {
  WiFiPlugin._();
  static final WiFiPlugin instance = WiFiPlugin._();

  final Map<int, CommController> _controllers = {};
  final Map<int, DongleComm>     _dongles     = {};
  final Map<int, UDSDiagnostic>  _diagnostics = {};
  final Map<String, double>      flashPercentMap = {};

  // ── Init: pre-create 8 controller slots ──────────────────
  Future<void> initSockets() async {
    for (int i = 1; i <= 8; i++) {
      if (!_controllers.containsKey(i)) {
        _controllers[i] = CommController();
      }
    }
    print('✅ [WiFiPlugin] Sockets initialized');
  }

  // ── Close all sockets ────────────────────────────────────
  Future<void> closeSockets() async {
    for (final ctrl in _controllers.values) {
      try { await ctrl.disconnect(); } catch (_) {}
    }
    _dongles.clear();
    _diagnostics.clear();
    print('✅ [WiFiPlugin] All sockets closed');
  }

  // ── Connect to dongle via TCP WiFi on port 6888 ───────────
  Future<bool> checkDongle(String ip, int index) async {
    try {
      final ctrl = _getOrCreate(index);
      if (ctrl.isConnected.value) {
        await ctrl.disconnect();
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // CommController.connectWifi — Connectivity.wiFi (capital F)
      await ctrl.connectWifi(
        host: ip,
        port: 6888,
        selectedType: Connectivity.wiFi,
      );

      if (ctrl.isConnected.value) {
        // DongleComm requires isChannel + optional channelId
        final dongle = DongleComm(comm: ctrl, isChannel: false);
        // UDSDiagnostic requires DongleComm + ECUCalculateSeedkey
        final seedkey    = ECUCalculateSeedkey();
        final diagnostic = UDSDiagnostic(dongle, seedkey);

        _dongles[index]     = dongle;
        _diagnostics[index] = diagnostic;
        print('✅ [WiFiPlugin] Dongle $index connected @ $ip:6888');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WiFiPlugin] checkDongle[$index] $ip: $e');
      return false;
    }
  }

  // ── Get ECU Serial Number ────────────────────────────────
  Future<List<String>> getESN(
    String ip, int index,
    Map<String, dynamic> ecu, List<dynamic> pids,
  ) async => _readPid(index, pids);

  // ── Get Hardware Part Number ─────────────────────────────
  Future<List<String>> getHW(
    String ip, int index,
    Map<String, dynamic> ecu, List<dynamic> pids,
  ) async => _readPid(index, pids);

  // ── Get Software Version ─────────────────────────────────
  Future<List<String>> getSW(
    String ip, int index,
    Map<String, dynamic> ecu, List<dynamic> pids,
  ) async => _readPid(index, pids);

  // ── Get Calibration ID ───────────────────────────────────
  Future<List<String>> getCalId(
    String ip, int index,
    Map<String, dynamic> ecu, List<dynamic> pids,
  ) async => _readPid(index, pids);

  // ── Get CVN ──────────────────────────────────────────────
  Future<List<String>> getCVN(
    String ip, int index,
    Map<String, dynamic> ecu, List<dynamic> pids,
  ) async => _readPid(index, pids);

  // ── Start ECU Flashing ───────────────────────────────────
  Future<List<String>> startECUFlashing({
    required String seqFile,
    required String jsonFile,
    required String ip,
    required int    index,
    required String txHeader,
    required String rxHeader,
    required String protocol,
    required String seedkeyAlgo,
  }) async {
    try {
      final dongle     = _dongles[index];
      final diagnostic = _diagnostics[index];
      if (dongle == null || diagnostic == null) {
        return ['ERROR: Dongle not connected'];
      }

      flashPercentMap[ip] = 0.0;

      // Step 1: Start CAN transport protocol
      await dongle.canStartTP();

      // Step 2: Parse hex json file
      final jsonData = FlashingMatrixData.fromJson(
          jsonDecode(jsonFile) as Map<String, dynamic>);
      if (jsonData.sectorData == null || jsonData.sectorData!.isEmpty) {
        return ['ERROR: Invalid flash data'];
      }

      // Step 3: Resolve seedkey algorithm
      SEEDKEYINDEXTYPE seedKeyIndex;
      try {
        seedKeyIndex = SEEDKEYINDEXTYPE.values.firstWhere(
          (e) => e.name == seedkeyAlgo,
          orElse: () => SEEDKEYINDEXTYPE.RE_SEEDKEY_EPM44,
        );
      } catch (_) {
        seedKeyIndex = SEEDKEYINDEXTYPE.RE_SEEDKEY_EPM44;
      }

      // Step 4: Build FlashConfig
      final flashConfig = FlashConfig(seedKeyIndex: seedKeyIndex);

      // Step 5: Set TX header
      if (txHeader.isNotEmpty) {
        await dongle.canSetTxHeader(txHeader);
      }

      // Step 6: Monitor progress
      _monitorProgress(ip, index, diagnostic);

      // Step 7: Flash — UDSDiagnostic.flashInterpreter()
      // Internally calls ECUCalculateSeedkey for security unlock
      final result = await diagnostic.flashInterpreter(
        flashConfig,
        jsonData.noOfSectors ?? 0,
        jsonData.sectorData!,
        seqFile,
      );

      flashPercentMap[ip] = 1.0;
      print('✅ [WiFiPlugin] Flash[$index]: $result');
      return [result ?? 'NOERROR'];
    } catch (e) {
      print('❌ [WiFiPlugin] startECUFlashing[$index]: $e');
      return ['EXCEPTION: $e'];
    }
  }

  // ── Get flash percent ────────────────────────────────────
  Future<double> getFlashPercent(String ip, int index) async {
    try {
      final d = _diagnostics[index];
      if (d == null) return flashPercentMap[ip] ?? 0.0;
      final pct = await d.getRuntimeFlashPercent();
      flashPercentMap[ip] = pct;
      return pct;
    } catch (_) {
      return flashPercentMap[ip] ?? 0.0;
    }
  }

  // ── Reset dongle ─────────────────────────────────────────
  Future<void> resetDongle(String ip, int index) async {
    try {
      final dongle = _dongles[index];
      if (dongle != null) {
        await dongle.resetDongle();
        print('✅ [WiFiPlugin] Dongle $index reset');
      }
    } catch (e) {
      print('❌ [WiFiPlugin] resetDongle[$index]: $e');
    }
  }

  // ── Internal: read PID value using UDSDiagnostic ─────────
  Future<List<String>> _readPid(int index, List<dynamic> rawPids) async {
    try {
      final diagnostic = _diagnostics[index];
      if (diagnostic == null) return ['false', ''];

      // Convert raw pids to ReadParameterPID list
      final pidList = rawPids
          .whereType<Map>()
          .map((p) =>
              ReadParameterPID.fromJson(Map<String, dynamic>.from(p)))
          .toList();

      if (pidList.isEmpty) return ['false', ''];

      // UDSDiagnostic.readParameters()
      final responses = await diagnostic.readParameters(
        pidList.length,
        pidList,
      );

      if (responses.isEmpty) return ['false', ''];

      // ReadParameterResponse.variables → ReadParameterVariableResponse.responseValue
      final vars = responses.first.variables;
      if (vars.isEmpty) return ['false', ''];

      final value = vars.first.responseValue ?? '';
      return ['true', value];
    } catch (e) {
      print('❌ [WiFiPlugin] _readPid[$index]: $e');
      return ['false', ''];
    }
  }

  // ── Progress monitor ──────────────────────────────────────
  void _monitorProgress(String ip, int index, UDSDiagnostic d) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final pct = await d.getRuntimeFlashPercent();
        flashPercentMap[ip] = pct;
        return pct < 1.0;
      } catch (_) {
        return false;
      }
    });
  }

  CommController _getOrCreate(int index) {
    _controllers[index] ??= CommController();
    return _controllers[index]!;
  }
}