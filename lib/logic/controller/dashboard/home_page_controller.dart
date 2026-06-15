// home_page_controller.dart — COMPLETE with WiFiPlugin integrated
// All // TODO: WiFiPlugin.xxx() replaced with real calls
// Path: lib/logic/controller/dashboard/home_page_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/services/wifi_plugin.dart'; // ← ADD THIS

// ── WiFiPlugin singleton shorthand ───────────────────────────
final _wifi = WiFiPlugin.instance;

// ─────────────────────────────────────────────────────────────
//  TableInfoModel (unchanged)
// ─────────────────────────────────────────────────────────────
class TableInfoModel {
  int index;
  int srNo;
  String bgColor;
  String macId;
  String ipAddress;
  String status;
  int priority;
  bool isDongleAvailable;
  bool isEcuAvailable;
  bool dongleFlashingIndicator;
  bool ecuFlashingIndicator;
  Color dongleStatusColor;
  Color ecuStatusColor;
  String ecuSrNo;
  String ecuSrNoAfter;
  String hardwarePartNumber;
  String swVersionBefore;
  String swVersionAfter;
  String calIdBefore;
  String calId;
  String printCalId;
  String cvnBefore;
  String cvn;
  String swPartNo;
  bool flashingCompleted;
  bool flashingSuccess;
  bool isflashing;
  bool flashingAvailabel;
  String fileType;
  String flashTimer;
  String flashPercent;
  double progress;
  bool isProgressVisible;
  Color statusColor;
  Color reportColor;
  bool printButtonDisable;
  Color printButtonColor;
  bool playButtonDisable;
  Color playButtonColor;
  bool playButtonVisible;
  bool ecuStatus;
  String ecuStatus1;
  bool alreadyMessage;
  bool isDongle;
  bool swMatch;
  bool calIdMatch;
  bool cvnMatch;
  String jsonFile;
  String seqFile;
  String fileUrl;
  String downComFile;
  String downComSeqfile;
  String downComFileUrl;
  String downCalFile;
  String downCalSeqfile;
  String downCalFileUrl;
  ModelResult? selectedModel;
  SubModel? selectedSubModel;

  TableInfoModel({
    required this.index, required this.srNo, required this.bgColor,
    required this.macId, required this.ipAddress, required this.status,
    required this.priority,
    this.isDongleAvailable = false, this.isEcuAvailable = false,
    this.dongleFlashingIndicator = false, this.ecuFlashingIndicator = false,
    this.dongleStatusColor = Colors.red, this.ecuStatusColor = Colors.red,
    this.ecuSrNo = '', this.ecuSrNoAfter = '', this.hardwarePartNumber = '',
    this.swVersionBefore = '', this.swVersionAfter = '',
    this.calIdBefore = '', this.calId = '', this.printCalId = '',
    this.cvnBefore = '', this.cvn = '', this.swPartNo = '',
    this.flashingCompleted = false, this.flashingSuccess = false,
    this.isflashing = false, this.flashingAvailabel = false,
    this.fileType = 'NA', this.flashTimer = '00:00', this.flashPercent = '0.0 %',
    this.progress = 0, this.isProgressVisible = false,
    this.statusColor = Colors.white, this.reportColor = Colors.white,
    this.printButtonDisable = true, this.printButtonColor = Colors.grey,
    this.playButtonDisable = true, this.playButtonColor = Colors.grey,
    this.playButtonVisible = false,
    this.ecuStatus = true, this.ecuStatus1 = '', this.alreadyMessage = false,
    this.isDongle = false, this.swMatch = false, this.calIdMatch = false,
    this.cvnMatch = false,
    this.jsonFile = '', this.seqFile = '', this.fileUrl = '',
    this.downComFile = '', this.downComSeqfile = '', this.downComFileUrl = '',
    this.downCalFile = '', this.downCalSeqfile = '', this.downCalFileUrl = '',
    this.selectedModel, this.selectedSubModel,
  });
}

// ─────────────────────────────────────────────────────────────
//  HomePageController
// ─────────────────────────────────────────────────────────────
class HomePageController extends GetxController {

  final Map<String, dynamic> args;
  HomePageController({required this.args});

  late final String      _flashingType;
  late final ModelResult? _selectedModel;
  late final SubModel?   _selectedSubModel;
  late final String      _downComFile;
  late final String      _downComSeqfile;
  late final String      _downComFileUrl;
  late final String      _downCalFile;
  late final String      _downCalSeqfile;
  late final String      _downCalFileUrl;
  Map<String, dynamic>?  _profile;
  String                 _token     = '';
  String                 _sessionId = '';
  List<dynamic>          _parameters = [];
  List<dynamic>          _pids       = [];
  List<dynamic>          _flashFiles = [];
  bool                   _alreadyFlashedEcu = false;
  bool                   _nextCheck         = false;

  ModelResult? get selectedModel    => _selectedModel;
  SubModel?    get selectedSubModel => _selectedSubModel;

  final RxBool   isLoading               = false.obs;
  final RxString currStatus              = ''.obs;
  final RxString title                   = ''.obs;
  final RxList<TableInfoModel> tableInfo = <TableInfoModel>[].obs;
  final RxBool   checkEcuStatusButton    = true.obs;
  final RxBool   startFlashButtonDisable = true.obs;
  final Rx<Color> startFlashButtonColor  = Colors.grey.obs;
  final RxBool   startResetButtonDisable = true.obs;
  final Rx<Color> startResetButtonColor  = Colors.grey.obs;
  final RxBool   isResetDongleEnabled    = true.obs;
  final RxBool   flashingButtonVisible   = true.obs;
  final RxBool   showAlertPopup          = false.obs;
  final RxBool   showChangePopup         = false.obs;
  final RxBool   showPrintPopup          = false.obs;
  final RxBool   showWaitPopup           = false.obs;
  final RxString popupMessage            = ''.obs;
  final RxInt    afterFlashSeconds       = 0.obs;

  static const _orange = Color(0xFFF9772C);
  Timer? _waitTimer;

  @override
  void onInit() {
    super.onInit();
    _flashingType     = args['flashingType']    ?? 'Batch';
    _selectedModel    = args['selectedModel']   as ModelResult?;
    _selectedSubModel = args['selectedSubModel'] as SubModel?;
    _downComFile      = args['downComFile']     ?? '';
    _downComSeqfile   = args['downComSeqfile']  ?? '';
    _downComFileUrl   = args['downComFileUrl']  ?? '';
    _downCalFile      = args['downCalFile']     ?? '';
    _downCalSeqfile   = args['downCalSeqfile']  ?? '';
    _downCalFileUrl   = args['downCalFileUrl']  ?? '';
    _profile          = args['profile'] as Map<String, dynamic>?;
    _token            = args['token'] ?? '';
    _initPage();
  }

  Future<void> _initPage() async {
    isLoading.value = true;
    try {
      if (_token.isEmpty)   _token     = await AppPreferences.getToken() ?? '';
      if (_profile == null) _profile   = await AppPreferences.getLoginResponse();
      _sessionId = await AppPreferences.getSessionId();

      flashingButtonVisible.value   = _flashingType == 'Batch';
      startResetButtonDisable.value = true;
      startResetButtonColor.value   = Colors.grey;
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = Colors.grey;
      checkEcuStatusButton.value    = true;
      isResetDongleEnabled.value    = true;

      title.value =
          '${_selectedSubModel?.description ?? ''}/${_selectedModel?.name ?? ''}';

      await _getFlashDetail();
      await _getParameters();
      await _getPids();
      await _loadDongleList();

      // ── OPEN SOCKETS for all 8 dongle slots ──────────────
      await _wifi.initSockets();

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getFlashDetail() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}flash/flash-list/'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        _flashFiles = (jsonDecode(res.body)['results'] as List? ?? []);
      }
    } catch (e) { print('❌ _getFlashDetail: $e'); }
  }

  Future<void> _getParameters() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}parameter/parameter-list/'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        _parameters = (jsonDecode(res.body)['results'] as List? ?? []);
      }
    } catch (e) { print('❌ _getParameters: $e'); }
  }

  Future<void> _getPids() async {
    try {
      final sub = _selectedSubModel;
      if (sub == null || sub.ecuSubmodel.isEmpty) return;
      final pidDatasets = sub.ecuSubmodel[0].pidDatasets;
      if (pidDatasets.isEmpty) return;
      final first = pidDatasets[0];
      int? pidId;
      if (first is Map)      pidId = first['id'] as int?;
      else if (first is int) pidId = first;
      if (pidId == null) return;

      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}datasets/get-pid-datasets/?id=$pidId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final results = jsonDecode(res.body)['results'] as List? ?? [];
        if (results.isNotEmpty) {
          _pids = results[0]['codes'] as List? ?? [];
          print('✅ PIDs loaded — ${_pids.length}');
        }
      }
    } catch (e) { print('❌ _getPids: $e'); }
  }

  Future<void> _loadDongleList() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}devices/prodbuddongle/list/'),
        headers: _headers,
      );
      if (res.statusCode != 200) return;

      final results   = (jsonDecode(res.body)['results'] as List? ?? []);
      final stationId = _stationId;
      final sorted    = [...results]
        ..sort((a, b) => ((a['priority'] ?? 0) as int)
            .compareTo((b['priority'] ?? 0) as int));

      final sub    = _selectedSubModel;
      final calId  = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.calId ??
              sub.ecuSubmodel[0].completeDataset?.calId ?? '') : '';
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '') : '';

      final table = <TableInfoModel>[];
      int idx = 0, srNo = 0;
      for (final x in sorted) {
        if ((x['station'] as int? ?? 0) == stationId) {
          srNo++;
          if (x['is_active'] == true) {
            idx++;
            table.add(TableInfoModel(
              index: idx, srNo: srNo,
              bgColor: (idx % 2 == 0) ? '#eeeeee' : '#cccccc',
              macId: x['mac_id'] ?? '',
              ipAddress: x['ip'] ?? '',
              status: '', priority: x['priority'] ?? 0,
              calId: calId, printCalId: calId, swPartNo: swPart,
              playButtonVisible: _flashingType != 'Batch',
            ));
          }
        }
      }
      tableInfo.assignAll(table);
    } catch (e) { print('❌ _loadDongleList: $e'); }
  }

  // ══════════════════════════════════════════════════════════
  //  CHECK ECU STATUS
  //  Full 7-step chain using WiFiPlugin (real hardware)
  // ══════════════════════════════════════════════════════════
  Future<void> checkEcuStatus() async {
    try {
      for (final item in tableInfo) {
        item.status = ''; item.isDongleAvailable = false;
        item.isEcuAvailable = false; item.dongleStatusColor = Colors.red;
        item.dongleFlashingIndicator = false; item.ecuFlashingIndicator = false;
        item.ecuStatusColor = Colors.red; item.ecuSrNo = '';
        item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
        item.statusColor = Colors.white; item.reportColor = Colors.white;
        item.flashingCompleted = false; item.printButtonDisable = true;
        item.printButtonColor = Colors.grey; item.playButtonDisable = true;
        item.playButtonColor = Colors.grey; item.isflashing = false;
        item.playButtonVisible = _flashingType != 'Batch';
        item.flashingAvailabel = false; item.fileType = 'NA';
        item.hardwarePartNumber = ''; item.ecuStatus = true;
        item.ecuStatus1 = ''; item.alreadyMessage = false;
        item.isDongle = false; item.swMatch = false;
        item.calIdMatch = false; item.cvnMatch = false;
      }
      tableInfo.refresh();

      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = Colors.grey;
      _alreadyFlashedEcu            = false;
      popupMessage.value            = '';

      final dongleOk = await _checkDongle();
      if (dongleOk) {
        final ecuOk = await _checkECU();
        if (ecuOk) {
          final hwOk = await _checkECUHW();
          if (hwOk) {
            await _checkFlashingStatus();
            final swOk = await _checkECUSW();
            if (swOk) {
              final calOk = await _checkCalId();
              if (calOk) { await _checkCVN(); }
              else        { await _getCVN(); }
            } else {
              await _getCalId();
              await _getCVN();
            }
          }
        }
      }

      if (_alreadyFlashedEcu) {
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        showChangePopup.value      = true;
      }
      if (popupMessage.value.isNotEmpty) {
        showAlertPopup.value = true;
      }
    } catch (e) {
      currStatus.value = '';
      print('❌ checkEcuStatus: $e');
    }
  }

  // ════════════════════════════════════════════════════════
  //  SCAN NETWORK — find dongle IPs on port 6888
  //  Called by Find Dongle button in UI
  // ════════════════════════════════════════════════════════
  Future<List<String>> scanNetworkForDongles() async {
    currStatus.value = 'Scanning network for dongles...';
    final found = <String>[];
    try {
      final subnet = await _getWifiSubnet();
      if (subnet == null) {
        currStatus.value = 'WiFi not connected';
        return [];
      }

      print('🔍 Scanning $subnet.1–254 on port 6888...');
      const batchSize = 20;

      for (int start = 1; start <= 254; start += batchSize) {
        final end     = (start + batchSize - 1).clamp(1, 254);
        final futures = <Future<String?>>[];
        for (int i = start; i <= end; i++) {
          futures.add(_tryPort('$subnet.$i', 6888));
        }
        final results = await Future.wait(futures);
        for (final ip in results) {
          if (ip != null) {
            found.add(ip);
            print('✅ Dongle found: $ip:6888');
          }
        }
        currStatus.value =
            'Scanning... ${(end / 254 * 100).toInt()}%'
            ' — Found: ${found.length}';
      }
    } catch (e) {
      print('❌ scanNetworkForDongles: $e');
    } finally {
      currStatus.value = '';
    }
    return found;
  }

  // ── Get WiFi subnet from network interfaces ───────────────
  Future<String?> _getWifiSubnet() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4);
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;
          final parts = ip.split('.');
          if (parts.length == 4) {
            return '${parts[0]}.${parts[1]}.${parts[2]}';
          }
        }
      }
    } catch (e) {
      print('❌ _getWifiSubnet: $e');
    }
    return null;
  }

  // ── Try TCP connect on port with 400ms timeout ────────────
  Future<String?> _tryPort(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port,
        timeout: const Duration(milliseconds: 400));
      socket.destroy();
      return ip;
    } catch (_) {
      return null;
    }
  }

  // ── Step 1: CheckDongle — with auto-scan fallback ─────────
  Future<bool> _checkDongle() async {
    bool value = false;
    currStatus.value = 'Checking Dongle Connection...';
    try {
      for (final device in tableInfo) {
        // ── Try stored IP first ───────────────────────────
        device.isDongle = await _wifi.checkDongle(
          device.ipAddress, device.index);

        // ── If stored IP failed → scan network ────────────
        if (!device.isDongle) {
          print('⚠️ Stored IP ${device.ipAddress} failed'
              ' → scanning network...');
          currStatus.value =
              'Dongle ${device.srNo} not at ${device.ipAddress}'
              ' — scanning network...';

          final subnet = await _getWifiSubnet();
          if (subnet != null) {
            // Scan full subnet for port 6888
            const batchSize = 20;
            bool foundNewIP = false;

            for (int start = 1; start <= 254 && !foundNewIP;
                start += batchSize) {
              final end     = (start + batchSize - 1).clamp(1, 254);
              final futures = <Future<String?>>[];
              for (int i = start; i <= end; i++) {
                // Skip already known IPs of other dongles
                final ip = '$subnet.$i';
                futures.add(_tryPort(ip, 6888));
              }
              final results = await Future.wait(futures);
              for (final ip in results) {
                if (ip != null) {
                  // Check if this IP is not used by another dongle
                  final alreadyUsed = tableInfo.any((d) =>
                      d != device && d.ipAddress == ip && d.isDongle);
                  if (!alreadyUsed) {
                    // Try connecting via WiFiPlugin
                    final ok = await _wifi.checkDongle(ip, device.index);
                    if (ok) {
                      print('✅ Dongle ${device.srNo} found at new IP: $ip'
                          ' (was: ${device.ipAddress})');
                      device.ipAddress = ip; // update IP for this session
                      device.isDongle  = true;
                      foundNewIP       = true;
                      break;
                    }
                  }
                }
              }
            }
          }
        }

        if (device.isDongle) {
          device.dongleFlashingIndicator = true;
          device.dongleStatusColor       = Colors.green;
        } else {
          device.dongleFlashingIndicator = false;
          device.dongleStatusColor       = Colors.red;
          device.ecuStatus  = false;
          device.ecuStatus1 =
              'Dongle ${device.srNo} not found.\n'
              'Stored IP: ${device.ipAddress}';
        }
      }
      tableInfo.refresh();

      final failed = tableInfo
          .where((x) => !x.isDongle && !x.ecuStatus && !x.alreadyMessage)
          .toList();
      if (failed.isNotEmpty) {
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        for (final item in failed) {
          item.alreadyMessage = true;
          popupMessage.value += '${item.ecuStatus1}\n';
        }
        value = false;
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
    } finally {
      currStatus.value = '';
    }
    return value;
  }

  // ── Step 2: CheckECU — reads ESN serial number ────────────
  Future<bool> _checkECU() async {
    bool value = false;
    currStatus.value = 'Checking ECU Connection...';
    try {
      for (final device in tableInfo) {
        // ✅ REAL: UDSDiagnostic.readParameters() → ESN
        final res = await _wifi.getESN(
          device.ipAddress,
          device.index,
          _ecuMap,
          _pids,
        );

        if (res[0] == 'true') {
          device.ecuSrNo              = res[1];
          device.isEcuAvailable       = true;
          device.ecuFlashingIndicator = true;
          device.ecuStatusColor       = Colors.green;
        } else {
          device.isEcuAvailable = false;
          device.ecuStatus  = false;
          device.ecuStatus1 = 'ECU ${device.srNo} not responding.';
        }
      }
      tableInfo.refresh();

      final failed = tableInfo
          .where((x) => !x.isEcuAvailable && !x.ecuStatus && !x.alreadyMessage)
          .toList();
      if (failed.isNotEmpty) {
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        for (final item in failed) {
          item.alreadyMessage = true;
          popupMessage.value += '${item.ecuStatus1}\n';
        }
        value = false;
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
    } finally { currStatus.value = ''; }
    return value;
  }

  // ── Step 3: CheckECUHW — reads hardware part number ───────
  Future<bool> _checkECUHW() async {
    bool value = false;
    currStatus.value = 'Reading ECU Hardware Number...';
    try {
      final sub        = _selectedSubModel;
      final expectedHw = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset?.swPartNo ?? '' : '';

      for (final device in tableInfo) {
        // ✅ REAL: UDSDiagnostic.readParameters() → HW Part No
        final res = await _wifi.getHW(
          device.ipAddress,
          device.index,
          _ecuMap,
          _pids,
        );

        if (res[0] == 'true') {
          device.hardwarePartNumber = res[1];
          if (expectedHw.isEmpty || res[1] == expectedHw) {
            device.isEcuAvailable = true;
          } else {
            device.isEcuAvailable = false;
            device.ecuStatus  = false;
            device.ecuStatus1 =
                'ECU ${device.srNo} HW mismatch.\nExpected: $expectedHw\nFound: ${res[1]}';
          }
        } else {
          device.isEcuAvailable = false;
          device.ecuStatus  = false;
          device.ecuStatus1 = 'ECU ${device.srNo} HW read failed.';
        }
      }
      tableInfo.refresh();

      final failed = tableInfo
          .where((x) => !x.isEcuAvailable && !x.ecuStatus && !x.alreadyMessage)
          .toList();
      if (failed.isNotEmpty) {
        for (final item in failed) {
          item.alreadyMessage = true;
          popupMessage.value += '${item.ecuStatus1}\n';
        }
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        value = false;
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
    } finally { currStatus.value = ''; }
    return value;
  }

  // ── Step 4: CheckFlashingStatus (API check) ───────────────
  Future<void> _checkFlashingStatus() async {
    currStatus.value = 'Checking Flashing Status...';
    try {
      for (final device in tableInfo) {
        if (!device.isEcuAvailable || device.ecuSrNo.isEmpty) continue;
        final res = await http.get(
          Uri.parse(
              '${AppEnvironment.baseUrl}analyze/get-ecu-pfs-status/?serial_no=${device.ecuSrNo}'),
          headers: _headers,
        );
        if (res.statusCode == 200) {
          final results = (jsonDecode(res.body)['results'] as List? ?? []);
          if (results.isNotEmpty && results[0]['status'] == 'Pass') {
            device.ecuStatus1  = 'ECU ${device.srNo} already flashed.';
            device.ecuStatus   = false;
            _alreadyFlashedEcu = true;
          }
        }
      }
    } catch (e) { print('❌ _checkFlashingStatus: $e'); }
    finally { currStatus.value = ''; }
  }

  // ── Step 5: CheckECUSW ────────────────────────────────────
  Future<bool> _checkECUSW() async {
    bool value = false;
    currStatus.value = 'Reading Software Version...';
    _nextCheck = false;
    try {
      final sub        = _selectedSubModel;
      final expectedSw = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset?.swVersion ?? '' : '';

      for (final device in tableInfo) {
        // ✅ REAL: UDSDiagnostic.readParameters() → SW Version
        final res = await _wifi.getSW(
          device.ipAddress,
          device.index,
          _ecuMap,
          _pids,
        );

        if (res[0] == 'true') {
          device.swVersionBefore   = res[1];
          device.flashingAvailabel = true;
          device.swMatch           = (res[1] == expectedSw);
          device.fileType          = device.swMatch ? 'Calibration' : 'Complete';
        } else {
          device.swVersionBefore   = '';
          device.flashingAvailabel = false;
        }
      }
      tableInfo.refresh();

      final available = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (available.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _orange;
        value = _nextCheck;
      }
    } finally { currStatus.value = ''; }
    return value;
  }

  // ── Step 6: CheckCalId ────────────────────────────────────
  Future<bool> _checkCalId() async {
    bool value = false;
    currStatus.value = 'Reading Calibration Id...';
    _alreadyFlashedEcu = false;
    _nextCheck         = false;
    try {
      final sub           = _selectedSubModel;
      final calDataset    = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].callibrationDataset : null;
      final comDataset    = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset : null;
      final expectedCalId = calDataset?.calId ?? comDataset?.calId ?? '';

      for (final device in tableInfo) {
        if (!device.swMatch) {
          // ✅ REAL: UDSDiagnostic.readParameters() → CalId
          final res = await _wifi.getCalId(
            device.ipAddress,
            device.index,
            _ecuMap,
            _pids,
          );

          if (res[0] == 'true') {
            device.calIdBefore       = res[1];
            device.flashingAvailabel = true;
            device.calIdMatch        = (res[1] == expectedCalId);
            device.fileType          = calDataset != null ? 'Calibration' : 'Complete';
          }
        }
      }
      tableInfo.refresh();

      final available = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (available.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _orange;
        value = _nextCheck;
      }
    } finally { currStatus.value = ''; }
    return value;
  }

  // ── Step 7: CheckCVN ──────────────────────────────────────
  Future<bool> _checkCVN() async {
    bool value = false;
    currStatus.value = 'Reading CVN...';
    _nextCheck = false;
    try {
      final sub        = _selectedSubModel;
      final calDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].callibrationDataset : null;

      for (final device in tableInfo) {
        // ✅ REAL: UDSDiagnostic.readParameters() → CVN
        final res = await _wifi.getCVN(
          device.ipAddress,
          device.index,
          _ecuMap,
          _pids,
        );

        if (res[0] == 'true') {
          device.cvnBefore         = res[1];
          device.flashingAvailabel = true;
          device.cvnMatch          = false;
          device.fileType          = calDataset != null ? 'Calibration' : 'Complete';
        }
      }
      tableInfo.refresh();

      final available = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (available.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _orange;
        value = _nextCheck;
      }
    } finally { currStatus.value = ''; }
    return value;
  }

  Future<void> _getCalId() async {
    currStatus.value = 'Reading Calibration Id...';
    try {
      for (final device in tableInfo) {
        final res = await _wifi.getCalId(device.ipAddress, device.index, _ecuMap, _pids);
        if (res[0] == 'true') device.calIdBefore = res[1];
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _getCVN() async {
    currStatus.value = 'Reading CVN...';
    try {
      for (final device in tableInfo) {
        final res = await _wifi.getCVN(device.ipAddress, device.index, _ecuMap, _pids);
        if (res[0] == 'true') device.cvnBefore = res[1];
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // ══════════════════════════════════════════════════════════
  //  START FLASH
  // ══════════════════════════════════════════════════════════
  Future<void> startFlash() async {
    if (startFlashButtonDisable.value) return;
    try {
      isResetDongleEnabled.value    = false;
      checkEcuStatusButton.value    = false;
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = Colors.grey;

      final sub = _selectedSubModel;
      for (final item in tableInfo) {
        if (sub?.ecuSubmodel.isNotEmpty == true &&
            sub!.ecuSubmodel[0].callibrationDataset == null) {
          item.jsonFile = _downComFile; item.seqFile = _downComSeqfile;
          item.fileUrl  = _downComFileUrl;
        } else if (item.fileType == 'Complete') {
          item.jsonFile = _downComFile; item.seqFile = _downComSeqfile;
          item.fileUrl  = _downComFileUrl;
        } else if (item.fileType == 'Calibration') {
          item.jsonFile = _downCalFile; item.seqFile = _downCalSeqfile;
          item.fileUrl  = _downCalFileUrl;
        }
        item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
        item.statusColor = Colors.yellow; item.progress = 0;
      }
      tableInfo.refresh();

      final futures = tableInfo
          .where((d) => d.isEcuAvailable)
          .map((d) => _flashDevice(d))
          .toList();
      await Future.wait(futures);
    } catch (e) { print('❌ startFlash: $e'); }
  }

  // ── Flash single device ───────────────────────────────────
  Future<void> _flashDevice(TableInfoModel device) async {
    try {
      if (device.jsonFile.isEmpty || device.seqFile.isEmpty) {
        device.status = 'File not found'; device.flashingCompleted = true;
        device.isflashing = false; device.statusColor = Colors.red;
        tableInfo.refresh(); _onAllComplete(); return;
      }

      device.printButtonDisable = true; device.printButtonColor = Colors.grey;
      device.status = 'Flashing in progress...';
      device.statusColor = Colors.yellow; device.isProgressVisible = true;
      device.isflashing = true; device.flashingSuccess = false;
      tableInfo.refresh();
      currStatus.value = 'Flashing In Progress...';

      // Timer
      final sw = Stopwatch()..start();
      final t  = Timer.periodic(const Duration(seconds: 1), (_) {
        device.flashTimer =
            '${sw.elapsed.inMinutes.toString().padLeft(2, '0')}:'
            '${(sw.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        // Update progress from WiFiPlugin
        device.progress = _wifi.flashPercentMap[device.ipAddress] ?? 0.0;
        device.flashPercent =
            '${(device.progress * 100).toStringAsFixed(1)}%';
        tableInfo.refresh();
      });

      // Get ECU model info for flash
      final sub     = _selectedSubModel;
      final ecuSub  = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0] : null;

      // ✅ REAL: WiFiPlugin.startECUFlashing()
      // Uses ap_dongle_comm → CommController → DongleComm
      // Uses ap_diagnostic → UDSDiagnostic.flashInterpreter()
      // Uses ecu_seedkey → ECUCalculateSeedkey (inside flashInterpreter)
      final flashResult = await _wifi.startECUFlashing(
        seqFile:      device.seqFile,
        jsonFile:     device.jsonFile,
        ip:           device.ipAddress,
        index:        device.index,
        txHeader:     ecuSub?.completeDataset?.swPartNo ?? '',
        rxHeader:     '',
        protocol:     'ISO15765_500KB_11BIT_CAN',
        seedkeyAlgo:  'RE_SEEDKEY_EPM44',
      );

      final result = flashResult.isNotEmpty ? flashResult[0] : 'ERROR';
      t.cancel(); sw.stop();
      device.reportColor = Colors.yellow;

      if (result == 'NOERROR') {
        await Future.delayed(const Duration(seconds: 3));
        device.flashingSuccess = true;
        device.statusColor     = Colors.green;
        device.flashPercent    = '100.0%';
        device.progress        = 1.0;
        device.status          = 'Flashing completed';

        // ✅ REAL: Read after-flash values
        final calAfter = await _wifi.getCalId(device.ipAddress, device.index, _ecuMap, _pids);
        if (calAfter[0] == 'true') device.printCalId = calAfter[1];

        final cvnAfter = await _wifi.getCVN(device.ipAddress, device.index, _ecuMap, _pids);
        if (cvnAfter[0] == 'true') device.cvn = cvnAfter[1];

        final swAfter = await _wifi.getSW(device.ipAddress, device.index, _ecuMap, _pids);
        if (swAfter[0] == 'true') device.swVersionAfter = swAfter[1];

        device.ecuSrNoAfter = device.ecuSrNo;
      } else {
        device.statusColor = Colors.red;
        device.status      = result;
      }

      device.flashingCompleted = true; device.isflashing = false;
      device.isProgressVisible = false;
      tableInfo.refresh();

      await _generatePdfAndPostRecord(device, result == 'NOERROR');
      _onAllComplete();
    } catch (e) {
      device.status = 'Exception'; device.flashingCompleted = true;
      device.isflashing = false; tableInfo.refresh(); _onAllComplete();
    }
  }

  void _onAllComplete() {
    if (!tableInfo.every((x) => x.flashingCompleted)) return;
    currStatus.value = '';

    if (tableInfo.any((x) => x.flashingSuccess)) {
      final waitAfter = _selectedSubModel?.waitAfterFlash;
      if (waitAfter != null && waitAfter > 0) {
        afterFlashSeconds.value = waitAfter;
        showWaitPopup.value     = true;
        _startWaitTimer();
      } else {
        for (final item in tableInfo) {
          if (item.flashingSuccess) {
            item.printButtonDisable = false;
            item.printButtonColor   = _orange;
            break;
          }
        }
        tableInfo.refresh();
      }
    } else {
      startResetButtonDisable.value = false;
      startResetButtonColor.value   = _orange;
    }
  }

  void _startWaitTimer() {
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      afterFlashSeconds.value--;
      if (afterFlashSeconds.value <= 0) {
        t.cancel(); showWaitPopup.value = false;
        for (final item in tableInfo) {
          if (item.flashingSuccess) {
            item.printButtonDisable = false;
            item.printButtonColor   = _orange;
            break;
          }
        }
        tableInfo.refresh();
      }
    });
  }

  Future<void> _generatePdfAndPostRecord(TableInfoModel device, bool passed) async {
    try {
      final sub    = _selectedSubModel;
      final model  = _selectedModel;
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '') : '';

      final pfsId = _sessionId.isNotEmpty
          ? _sessionId : await AppPreferences.getSessionId();
      final ecuId = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].ecu : 0;

      final uri     = Uri.parse('${AppEnvironment.baseUrl}analyze/create-ecu-pfs/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'JWT $_token';

      request.fields['pfs']             = pfsId;
      request.fields['ECU_ID']          = device.hardwarePartNumber;
      request.fields['model']           = '${model?.id ?? 0}';
      request.fields['sub_model']       = '${sub?.id ?? 0}';
      request.fields['model_year']      = '${sub?.id ?? 0}';
      request.fields['ecu']             = '$ecuId';
      request.fields['flash_time']      = '${device.flashTimer} mins';
      request.fields['sw_version']      = device.swVersionAfter;
      request.fields['cvn']             = device.cvn;
      request.fields['cal_id']          = device.printCalId;
      request.fields['serial_no']       = device.ecuSrNo;
      request.fields['status']          = passed ? 'Pass' : 'Fail';
      request.fields['scanned_qr_code'] = '';
      request.fields['printed_qr_code'] = passed
          ? '${device.printCalId}@$swPart@${device.ecuSrNo}@${device.cvn}' : '';
      request.fields['previous_cal_id'] = device.calIdBefore;
      request.fields['previous_cvn']    = device.cvnBefore;

      final streamedRes = await request.send();
      final res         = await http.Response.fromStream(streamedRes);
      device.reportColor = (res.statusCode == 200 || res.statusCode == 201)
          ? Colors.green : Colors.red;
      tableInfo.refresh();
    } catch (e) {
      device.reportColor = Colors.red; tableInfo.refresh();
    }
  }

  Future<void> reset() async {
    if (startResetButtonDisable.value) return;
    isLoading.value = true;
    try {
      startResetButtonDisable.value = true; startResetButtonColor.value = Colors.grey;
      startFlashButtonDisable.value = true; startFlashButtonColor.value = Colors.grey;
      checkEcuStatusButton.value    = true;

      // ✅ Close + reopen sockets on reset
      await _wifi.closeSockets();
      await _wifi.initSockets();

      final stationData = _profile?['station_data'] as List?;
      final userId  = _profile?['user_id'] ?? 0;
      final plants  = stationData?.isNotEmpty == true
          ? (stationData![0]['plants'] as int? ?? 0) : 0;

      final res = await http.post(
        Uri.parse('${AppEnvironment.baseUrl}analyze/create-pfs/'),
        headers: _headers,
        body: jsonEncode({
          'user': userId, 'plant': plants,
          'status': 'New', 'station': _stationId,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final session = jsonDecode(res.body) as Map<String, dynamic>;
        await AppPreferences.saveSession(session);
        _sessionId = session['id']?.toString() ?? '';
      }

      await _loadDongleList();
      isResetDongleEnabled.value = true;
    } finally { isLoading.value = false; }
  }

  Future<void> resetDongle() async {
    if (!isResetDongleEnabled.value) return;
    isLoading.value = true;
    try {
      isResetDongleEnabled.value    = false;
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = Colors.grey;
      checkEcuStatusButton.value    = true;

      await _loadDongleList();

      // ✅ REAL: DongleComm.resetDongle() via WiFiPlugin
      for (final item in tableInfo) {
        await _wifi.resetDongle(item.ipAddress, item.index);
      }

      isResetDongleEnabled.value = true;
    } finally { isLoading.value = false; }
  }

  Future<void> printSticker(TableInfoModel device) async {
    try {
      device.printButtonDisable = true; device.printButtonColor = Colors.grey;
      tableInfo.refresh();

      // TODO: call printer plugin when available
      // await PrintPlugin.printSticker(device.cvn, device.printCalId, ...)

      if (_flashingType == 'Batch') {
        showPrintPopup.value = true;
        popupMessage.value   =
            'Paste the sticker on ECU ${device.srNo} and remove ECU ${device.srNo}';
        await Future.delayed(const Duration(seconds: 3));
        showPrintPopup.value = false;
        popupMessage.value   = '';

        int nextIdx = device.index;
        while (nextIdx <= tableInfo.length) {
          if (nextIdx == tableInfo.length) {
            startResetButtonDisable.value = false;
            startResetButtonColor.value   = _orange;
            break;
          }
          if (tableInfo[nextIdx].flashingSuccess) {
            tableInfo[nextIdx].printButtonDisable = false;
            tableInfo[nextIdx].printButtonColor   = _orange;
            tableInfo.refresh(); break;
          }
          nextIdx++;
        }
      } else {
        device.printButtonDisable = true;
        device.printButtonColor   = Colors.grey;
        tableInfo.refresh();
      }
    } catch (e) { print('❌ printSticker: $e'); }
  }

  void onOkPopup() {
    for (final item in tableInfo) {
      item.ecuStatus = true; item.ecuStatus1 = ''; item.alreadyMessage = false;
    }
    popupMessage.value = ''; showAlertPopup.value = false; tableInfo.refresh();
  }

  void onReflash() {
    for (final item in tableInfo) {
      item.ecuStatus = true; item.ecuStatus1 = ''; item.alreadyMessage = false;
    }
    popupMessage.value = ''; showChangePopup.value = false;
    checkEcuStatusButton.value = false; isResetDongleEnabled.value = false;
    startFlashButtonDisable.value = false; startFlashButtonColor.value = _orange;
    tableInfo.refresh();
  }

  void onChangeECU() {
    for (final item in tableInfo) {
      item.ecuStatus = true; item.ecuStatus1 = ''; item.alreadyMessage = false;
    }
    popupMessage.value = ''; showChangePopup.value = false;
    checkEcuStatusButton.value = true; isResetDongleEnabled.value = true;
    startFlashButtonDisable.value = true; startFlashButtonColor.value = Colors.grey;
    tableInfo.refresh();
  }

  Future<void> startIndividualFlash(TableInfoModel device) async {
    try {
      device.playButtonDisable = true; device.playButtonColor = Colors.grey;
      device.flashTimer = '00:00'; device.flashPercent = '0.0 %';
      device.progress = 0; device.isflashing = true; tableInfo.refresh();
      await Future.delayed(const Duration(seconds: 2));
      await _flashDevice(device);
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────
  int get _stationId {
    final list = _profile?['station_data'] as List?;
    return list?.isNotEmpty == true ? (list![0]['id'] as int? ?? 0) : 0;
  }

  // ECU map passed to WiFiPlugin for each call
  Map<String, dynamic> get _ecuMap {
    final sub = _selectedSubModel;
    if (sub == null || sub.ecuSubmodel.isEmpty) return {};
    final ecuSub = sub.ecuSubmodel[0];
    return {
      'tx_header': ecuSub.completeDataset?.swPartNo ?? '',
      'rx_header': '',
      'protocol':  'ISO15765_500KB_11BIT_CAN',
      'seedkeyalgo': 'RE_SEEDKEY_EPM44',
    };
  }

  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'Authorization': 'JWT $_token',
  };

  @override
  void onClose() {
    _waitTimer?.cancel();
    _wifi.closeSockets(); // ✅ close TCP connections when page closes
    super.onClose();
  }
}