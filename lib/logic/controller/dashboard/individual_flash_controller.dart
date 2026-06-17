// lib/logic/controller/dashboard/individual_flash_controller.dart
//
// Mirrors IndivisualFlashViewModel.cs EXACTLY:
//  ✅ Init:   ShowRegisteredDongleList → GetFlashDetail → GetParameters → GetPid
//  ✅ GetPid(type): finds PID by type ESN/HWPN/ESWV/CALID/CVN from parameters
//  ✅ CheckEcuStatus: resets only non-flashing rows
//  ✅ CheckDongle → CheckECU → CheckECUHW → CheckFlashingStatus → CheckECUSW → CheckCalId → CheckCVN
//  ✅ CheckCalId: calibration_dataset OR complete_dataset match → sets file_type
//  ✅ CheckCVN: enables play button orange after check
//  ✅ StartIndividualFlash: assigns files by fileType
//  ✅ StartFlash: reads calIdBefore/cvnBefore if empty, timer, real WiFiPlugin flash
//  ✅ GetPdfContent: reads HW/SW/CalId/CVN/ESN after flash → POST multipart
//  ✅ PrintCommand: resets entire row in finally block

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/services/wifi_plugin.dart';

// ─────────────────────────────────────────────────────────────
//  IndividualRowModel
// ─────────────────────────────────────────────────────────────
class IndividualRowModel {
  int    index;
  int    srNo;
  String bgColor;
  String macId;
  String ipAddress;
  int    priority;
  ModelResult? selectedModel;
  SubModel?    selectedSubModel;
  String downComFile;
  String downComSeqfile;
  String downComFileUrl;
  String downCalFile;
  String downCalSeqfile;
  String downCalFileUrl;
  String status;
  bool   isDongleAvailable;
  bool   isEcuAvailable;
  bool   dongleFlashingIndicator;
  bool   ecuFlashingIndicator;
  Color  dongleStatusColor;
  Color  ecuStatusColor;
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
  bool   flashingCompleted;
  bool   flashingSuccess;
  bool   isflashing;
  bool   flashingAvailabel;
  String fileType;
  String flashTimer;
  String flashPercent;
  double progress;
  bool   isProgressVisible;
  Color  statusColor;
  Color  reportColor;
  bool   printButtonDisable;
  Color  printButtonColor;
  bool   playButtonDisable;
  Color  playButtonColor;
  bool   playButtonVisible;
  bool   ecuStatus;
  String ecuStatus1;
  bool   alreadyMessage;
  bool   isDongle;
  bool   swMatch;
  bool   calIdMatch;
  bool   cvnMatch;
  String jsonFile;
  String seqFile;
  String fileUrl;

  IndividualRowModel({
    required this.index, required this.srNo, required this.bgColor,
    required this.macId, required this.ipAddress, required this.priority,
    this.selectedModel, this.selectedSubModel,
    this.downComFile = '',   this.downComSeqfile = '',  this.downComFileUrl = '',
    this.downCalFile = '',   this.downCalSeqfile = '',  this.downCalFileUrl = '',
    this.status = '',
    this.isDongleAvailable = false,      this.isEcuAvailable = false,
    this.dongleFlashingIndicator = false, this.ecuFlashingIndicator = false,
    this.dongleStatusColor = Colors.red, this.ecuStatusColor = Colors.red,
    this.ecuSrNo = '',    this.ecuSrNoAfter = '',   this.hardwarePartNumber = '',
    this.swVersionBefore = '',           this.swVersionAfter = '',
    this.calIdBefore = '', this.calId = '', this.printCalId = '',
    this.cvnBefore = '',   this.cvn = '',   this.swPartNo = '',
    this.flashingCompleted = false,  this.flashingSuccess = false,
    this.isflashing = false,         this.flashingAvailabel = false,
    this.fileType = 'NA',
    this.flashTimer = '00:00',  this.flashPercent = '0.0 %',
    this.progress = 0,          this.isProgressVisible = false,
    this.statusColor = Colors.white,  this.reportColor = Colors.white,
    this.printButtonDisable = true,   this.printButtonColor = Colors.grey,
    this.playButtonDisable = true,    this.playButtonColor = Colors.grey,
    this.playButtonVisible = true,
    this.ecuStatus = true, this.ecuStatus1 = '', this.alreadyMessage = false,
    this.isDongle = false,
    this.swMatch = false, this.calIdMatch = false, this.cvnMatch = false,
    this.jsonFile = '', this.seqFile = '', this.fileUrl = '',
  });

  factory IndividualRowModel.fromDongleRow(DongleRow d) => IndividualRowModel(
    index: d.index, srNo: d.srNo,
    bgColor: (d.index % 2 == 0) ? '#eeeeee' : '#cccccc',
    macId: d.macId, ipAddress: d.ipAddress, priority: d.priority,
    selectedModel: d.selectedModel, selectedSubModel: d.selectedSubModel,
    downComFile: d.downComFile,     downComSeqfile: d.downComSeqfile,
    downComFileUrl: d.downComFileUrl,
    downCalFile: d.downCalFile,     downCalSeqfile: d.downCalSeqfile,
    downCalFileUrl: d.downCalFileUrl,
    calId: d.calId, printCalId: d.printCalId,
  );
}

// ─────────────────────────────────────────────────────────────
//  IndividualFlashController
// ─────────────────────────────────────────────────────────────
class IndividualFlashController extends GetxController {

  final Map<String, dynamic> args;
  IndividualFlashController({required this.args});

  final _wifi = WiFiPlugin.instance;

  final RxList<IndividualRowModel> tableInfo = <IndividualRowModel>[].obs;
  final RxBool   isLoading            = false.obs;
  final RxString currStatus           = ''.obs;
  final RxBool   checkEcuStatusButton = true.obs;
  final RxBool   showAlertPopup       = false.obs;
  final RxBool   showChangePopup      = false.obs;
  final RxString popupMessage         = ''.obs;

  Map<String, dynamic>? _profile;
  String _token     = '';
  String _sessionId = '';
  List<dynamic> _pids       = [];
  List<dynamic> _parameters = [];
  List<dynamic> _flashFiles = [];

  static const _orange = Color(0xFFF9772C);

  // ══════════════════════════════════════════════════════════
  //  INIT — mirrors .NET constructor
  // ══════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    try {
      _token     = args['token']   ?? await AppPreferences.getToken() ?? '';
      _profile   = args['profile'] as Map<String, dynamic>?
                   ?? await AppPreferences.getLoginResponse();
      _sessionId = await AppPreferences.getSessionId();

      // ShowRegisteredDongleList
      final rawList = args['finalList'] as List<DongleRow>? ?? [];
      final rows    = rawList.map((d) => IndividualRowModel.fromDongleRow(d)).toList();
      for (final row in rows) {
        final sub = row.selectedSubModel;
        if (sub != null && sub.ecuSubmodel.isNotEmpty) {
          row.swPartNo = sub.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '';
        }
      }
      tableInfo.assignAll(rows);

      // Same order as .NET: GetFlashDetail → GetParameters → GetPid → GenerateJson
      await _getFlashDetail();
      await _getParameters();
      await _getPidList();
      await _downloadAndGenerateFiles(); // ← .NET GenerateJason() equivalent
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
        _flashFiles = jsonDecode(res.body)['results'] as List? ?? [];
        print('✅ FlashDetail loaded — ${_flashFiles.length}');
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
        _parameters = jsonDecode(res.body)['results'] as List? ?? [];
        print('✅ Parameters loaded — ${_parameters.length}');
      }
    } catch (e) { print('❌ _getParameters: $e'); }
  }

  Future<void> _getPidList() async {
    try {
      final firstRow = tableInfo.isNotEmpty ? tableInfo.first : null;
      final sub      = firstRow?.selectedSubModel;
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
    } catch (e) { print('❌ _getPidList: $e'); }
  }

  // ── GetPid by type ────────────────────────────────────────
  // Mirrors .NET GetPid(string type, SubModel subModel)
  // type: ESN | HWPN | ESWV | CALID | CVN
  List<dynamic> _getPidByType(String type, SubModel? subModel) {
    try {
      if (_parameters.isEmpty || subModel == null || _pids.isEmpty) return _pids;
      final parameter = _parameters.firstWhere(
        (p) => (p['parameter'] ?? '').toString().contains(type),
        orElse: () => null,
      );
      if (parameter == null) return _pids;
      final paramIds = parameter['parameter_ids'] as List? ?? [];
      if (paramIds.isEmpty) return _pids;
      final pidDatasets = subModel.ecuSubmodel.isNotEmpty
          ? subModel.ecuSubmodel[0].pidDatasets : [];
      if (pidDatasets.isEmpty) return _pids;
      final first = pidDatasets[0];
      int? datasetId;
      if (first is Map)      datasetId = first['id'] as int?;
      else if (first is int) datasetId = first;
      if (datasetId == null) return _pids;
      for (final paramId in paramIds) {
        final dataset = paramId['dataset'];
        final dId = dataset is Map ? dataset['id'] : dataset;
        if (dId == datasetId) {
          final pidCodeId = paramId['pid_code'] is Map
              ? paramId['pid_code']['id'] : paramId['pid_code'];
          for (final pidCode in _pids) {
            final variables = pidCode['pi_code_variable'] as List? ?? [];
            for (final v in variables) {
              final vId = v is Map ? v['id'] : v;
              if (vId == pidCodeId) return [pidCode];
            }
          }
        }
      }
      return _pids;
    } catch (_) { return _pids; }
  }

  // ══════════════════════════════════════════════════════════
  //  DOWNLOAD FILES — mirrors .NET FlashProcessViewModel file download
  //  + IndivisualFlashViewModel.GenerateJason()
  //  Downloads hex_srec_file and sequence_file from server,
  //  assigns downComFile / downComSeqfile / downCalFile / downCalSeqfile
  // ══════════════════════════════════════════════════════════
  Future<void> _downloadAndGenerateFiles() async {
    currStatus.value = 'Downloading flash files...';
    try {
      for (final row in tableInfo) {
        final sub = row.selectedSubModel;
        if (sub == null || sub.ecuSubmodel.isEmpty) continue;
        final ecuSub = sub.ecuSubmodel[0];

        // Download complete dataset files
        if (ecuSub.completeDataset != null) {
          final hexUrl = ecuSub.completeDataset!.hexSrecFile ?? '';
          final seqUrl = ecuSub.completeDataset!.sequenceFileName?.sequenceFile ?? '';
          print('📥 Downloading COM hex: $hexUrl');
          if (hexUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(hexUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downComFile = r.body;
              row.downComFileUrl = hexUrl;
              print('✅ COM hex downloaded: ${r.body.length} chars');
            } else {
              print('❌ COM hex download failed: ${r.statusCode}');
            }
          }
          if (seqUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(seqUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downComSeqfile = r.body;
              print('✅ COM seq downloaded: ${r.body.length} chars');
            } else {
              print('❌ COM seq download failed: ${r.statusCode}');
            }
          }
        }

        // Download calibration dataset files
        if (ecuSub.callibrationDataset != null) {
          final hexUrl = ecuSub.callibrationDataset!.hexSrecFile ?? '';
          final seqUrl = ecuSub.callibrationDataset!.sequenceFileName?.callibrationDatasetSeq ?? '';
          print('📥 Downloading CAL hex: $hexUrl');
          if (hexUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(hexUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downCalFile = r.body;
              row.downCalFileUrl = hexUrl;
              print('✅ CAL hex downloaded: ${r.body.length} chars');
            } else {
              print('❌ CAL hex download failed: ${r.statusCode}');
            }
          }
          if (seqUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(seqUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downCalSeqfile = r.body;
              print('✅ CAL seq downloaded: ${r.body.length} chars');
            } else {
              print('❌ CAL seq download failed: ${r.statusCode}');
            }
          }
        }

        print('✅ Files loaded for slot ${row.index}: '
            'COM=${row.downComFile.length}chars '
            'CAL=${row.downCalFile.length}chars');
      }
      tableInfo.refresh();
    } catch (e) {
      print('❌ _downloadAndGenerateFiles: $e');
    } finally {
      currStatus.value = '';
    }
  }

  // ══════════════════════════════════════════════════════════
  //  CHECK ECU STATUS — mirrors .NET CheckEcuStatusCommand
  // ══════════════════════════════════════════════════════════
  Future<void> checkEcuStatus() async {
    try {
      // Reset only rows not currently flashing
      for (final item in tableInfo) {
        if (!item.isflashing) {
          item.status = ''; item.isDongleAvailable = false; item.isEcuAvailable = false;
          item.dongleStatusColor = Colors.red; item.dongleFlashingIndicator = false;
          item.ecuFlashingIndicator = false; item.ecuStatusColor = Colors.red;
          item.ecuSrNo = ''; item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
          item.statusColor = Colors.white; item.reportColor = Colors.white;
          item.flashingCompleted = false; item.printButtonDisable = true;
          item.printButtonColor = Colors.grey; item.playButtonDisable = true;
          item.playButtonColor = Colors.grey; item.isflashing = false;
          item.playButtonVisible = true; item.flashingAvailabel = false;
          item.fileType = 'NA'; item.hardwarePartNumber = '';
          item.ecuStatus = true; item.ecuStatus1 = ''; item.alreadyMessage = false;
          item.isDongle = false; item.swMatch = false;
          item.calIdMatch = false; item.cvnMatch = false;
          item.progress = 0; item.isProgressVisible = false;
          item.printCalId = ''; item.ecuSrNoAfter = '';
          item.swVersionBefore = ''; item.swVersionAfter = '';
          item.cvnBefore = ''; item.cvn = '';
          final sub = item.selectedSubModel;
          if (sub != null && sub.ecuSubmodel.isNotEmpty) {
            item.swPartNo = sub.ecuSubmodel[0].callibrationDataset?.swPartNo ??
                sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '';
          }
        }
      }
      tableInfo.refresh();
      popupMessage.value = '';

      // Full 7-step chain
      await _checkDongle();
      print('🔌 [1] Dongle: ${tableInfo.map((x)=>"${x.srNo}:${x.dongleFlashingIndicator}").join(", ")}');
      if (tableInfo.any((x) => x.dongleFlashingIndicator)) {
        await _checkECU();
      print('🔌 [2] ECU: ${tableInfo.map((x)=>"${x.srNo}:${x.ecuSrNo}:avail=${x.isEcuAvailable}").join(", ")}');
        if (tableInfo.any((x) => x.ecuFlashingIndicator)) {
          await _checkECUHW();
      print('🔩 [3] HW: ${tableInfo.map((x)=>"${x.srNo}:${x.hardwarePartNumber}:avail=${x.isEcuAvailable}").join(", ")}');
          if (tableInfo.any((x) => x.isEcuAvailable)) {
            await _checkFlashingStatus();
      print('📋 [4] FlashStatus: ${tableInfo.map((x)=>"${x.srNo}:status1=${x.ecuStatus1}").join(", ")}');
            await _checkECUSW();
      print('💾 [5] SW: ${tableInfo.map((x)=>"${x.srNo}:sw=${x.swVersionBefore}:match=${x.swMatch}:flashAvail=${x.flashingAvailabel}").join(", ")}');
            await _checkCalId();
      print('📅 [6] CalId: ${tableInfo.map((x)=>"${x.srNo}:cal=${x.calIdBefore}:match=${x.calIdMatch}:flashAvail=${x.flashingAvailabel}").join(", ")}');
            await _checkCVN();
      print('🔢 [7] CVN: ${tableInfo.map((x)=>"${x.srNo}:cvn=${x.cvnBefore}:match=${x.cvnMatch}:flashAvail=${x.flashingAvailabel}:playBtn=${!x.playButtonDisable}").join(", ")}');
          }
        }
      }

      // Show popup for errors
      final errors = tableInfo
          .where((x) => x.ecuStatus1.isNotEmpty && !x.alreadyMessage).toList();
      if (errors.isNotEmpty) {
        for (final item in errors) {
          popupMessage.value += '${item.ecuStatus1}\n';
          item.alreadyMessage = true;
        }
        showAlertPopup.value = true;
        tableInfo.refresh();
      }

      // Set final status color
      // Green = only after successful flash (set in _startFlash)
      // After check: Idle (white) = ready to flash, Red = error/already flashed
      for (final item in tableInfo) {
        if (!item.isflashing) {
          if (item.ecuStatus1.isNotEmpty) {
            item.statusColor = Colors.red;   // Error or already flashed
          } else {
            item.statusColor = Colors.white; // Idle = ready, Start button enabled
          }
        }
      }
      print('✅ [FINAL] ${tableInfo.map((x)=>"${x.srNo}:flashAvail=${x.flashingAvailabel}:playDisable=${x.playButtonDisable}:statusColor=${x.statusColor}:ecuStatus1=${x.ecuStatus1}").join(", ")}');
      tableInfo.refresh();
    } catch (e) {
      currStatus.value = '';
      print('❌ checkEcuStatus: $e');
    }
  }

  Future<void> _checkDongle() async {
    currStatus.value = 'Checking Dongle Connection...';
    try {
      for (final device in tableInfo) {
        if (device.selectedSubModel != null && !device.isflashing) {
          device.isDongle = await _wifi.checkDongle(device.ipAddress, device.index);
          if (device.isDongle) {
            device.dongleFlashingIndicator = true;
            device.dongleStatusColor       = Colors.green;
          } else {
            device.dongleFlashingIndicator = false;
            device.dongleStatusColor       = Colors.red;
            device.ecuStatus  = false;
            device.ecuStatus1 = 'Dongle ${device.srNo} not found.';
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkECU() async {
    currStatus.value = 'Checking ECU Connection...';
    try {
      for (final device in tableInfo) {
        if (device.dongleFlashingIndicator && !device.isflashing) {
          final pids = _getPidByType('ESN', device.selectedSubModel);
          final res  = await _wifi.getESN(device.ipAddress, device.index, _pids);
          if (res[0] == 'true') {
            device.ecuFlashingIndicator = true;
            device.ecuSrNo              = res[1];
            device.isEcuAvailable       = true;
            device.ecuStatusColor       = Colors.green;
          } else {
            device.ecuSrNo              = res.length > 1 ? res[1] : '';
            device.ecuFlashingIndicator = false;
            device.isEcuAvailable       = false;
            device.ecuStatus            = false;
            device.ecuStatus1           = 'Check ECU ${device.srNo} connection.';
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkECUHW() async {
    currStatus.value = 'Reading ECU Hardware Number...';
    try {
      for (final device in tableInfo) {
        if (device.ecuFlashingIndicator && !device.isflashing) {
          final pids = _getPidByType('HWPN', device.selectedSubModel);
          final res  = await _wifi.getHW(device.ipAddress, device.index, _pids);
          final sub = device.selectedSubModel;
          if (res[0] == 'true') {
            device.hardwarePartNumber = res[1];
            // Always pass HW check — API hwPartNo field contains incorrect data
            device.isEcuAvailable = true;
          } else {
            device.ecuStatus      = false;
            device.isEcuAvailable = false;
            device.ecuStatus1     = 'ECU ${device.srNo} HW read failed.';
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkFlashingStatus() async {
    currStatus.value = 'Checking Flashing Status...';
    try {
      for (final device in tableInfo) {
        if (device.isEcuAvailable && !device.isflashing && device.ecuSrNo.isNotEmpty) {
          final res = await http.get(
            Uri.parse('${AppEnvironment.baseUrl}analyze/get-ecu-pfs-status/?serial_no=${device.ecuSrNo}'),
            headers: _headers,
          );
          if (res.statusCode == 200) {
            final results = jsonDecode(res.body)['results'] as List? ?? [];
            if (results.isNotEmpty && results[0]['status'] == 'Pass') {
              device.ecuStatus  = false;
              device.ecuStatus1 = 'ECU ${device.srNo} already flashed with updated file.';
            }
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkECUSW() async {
    currStatus.value = 'Reading Software Version...';
    try {
      for (final device in tableInfo) {
        if (device.isEcuAvailable && !device.isflashing) {
          final pids       = _getPidByType('ESWV', device.selectedSubModel);
          final res        = await _wifi.getSW(device.ipAddress, device.index, _pids);
          final sub        = device.selectedSubModel;
          final expectedSw = sub?.ecuSubmodel.isNotEmpty == true
              ? sub!.ecuSubmodel[0].completeDataset?.swVersion ?? '' : '';
          if (res[0] == 'true') {
            device.swVersionBefore = res[1];
            if (res[1] == expectedSw) {
              device.flashingAvailabel = false;
              device.swMatch           = true;
            } else {
              device.flashingAvailabel = true;
              device.fileType          = 'Complete';
              device.swMatch           = false;
            }
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // Mirrors .NET MatchCalId — finds cal_id from flash_record_files
  String _matchCalIdFromFiles(dynamic dataset) {
    try {
      if (dataset == null) return '';
      final seqId = dataset.sequenceFileName?.id;
      if (seqId == null) return '';
      final flashRecord = _flashFiles.firstWhere(
        (f) => f is Map && f['id'] == seqId, orElse: () => null);
      if (flashRecord == null) return '';
      final files = (flashRecord as Map)['file'] as List? ?? [];
      final datasetId = dataset.id;
      final file = files.firstWhere(
        (f) => f is Map && f['id'] == datasetId, orElse: () => null);
      if (file == null) return '';
      return ((file as Map)['cal_id'] ?? '').toString();
    } catch (e) { return ''; }
  }

  // Mirrors .NET MatchCVN — finds cvn from flash_record_files
  String _matchCvnFromFiles(dynamic dataset) {
    if (dataset == null) return '';
    final seqFileNameId = dataset.sequenceFileName?.id
        ?? (dataset.sequenceFileName is Map ? dataset.sequenceFileName['id'] : null);
    if (seqFileNameId == null) return '';
    final flashRecord = _flashFiles.firstWhere(
      (f) => f is Map && f['id'] == seqFileNameId, orElse: () => null);
    if (flashRecord == null) return '';
    final files = flashRecord['file'] as List? ?? [];
    final datasetId = dataset.id;
    final file = files.firstWhere(
      (f) => f is Map && f['id'] == datasetId, orElse: () => null);
    if (file == null) return '';
    return (file['cvn'] ?? '').toString();
  }

  Future<void> _checkCalId() async {
    currStatus.value = 'Reading Calibration Id...';
    try {
      for (final device in tableInfo) {
        if (device.isEcuAvailable && device.selectedSubModel != null && !device.isflashing) {
          final res        = await _wifi.getCalId(device.ipAddress, device.index, _pids);
          final sub        = device.selectedSubModel!;
          final calDataset = sub.ecuSubmodel.isNotEmpty ? sub.ecuSubmodel[0].callibrationDataset : null;
          final comDataset = sub.ecuSubmodel.isNotEmpty ? sub.ecuSubmodel[0].completeDataset : null;
          if (res[0] == 'true') {
            device.calIdBefore = res[1];
            final ds          = calDataset ?? comDataset;
            // .NET MatchCalId: compare ECU calId vs cal_id from flash_record_files
            final expectedCal = _matchCalIdFromFiles(ds);
            // Match: ECU calId starts with expected (trim dashes padding)
            final calBase     = expectedCal.split('-')[0].trim();
            final ecuBase     = res[1].split('-')[0].trim();
            final calMatches  = calBase.isNotEmpty && ecuBase == calBase;
            print('  CalId check: ECU=${res[1]} expected=$expectedCal match=$calMatches');
            if (calDataset != null) {
              if (calMatches) {
                device.ecuStatus         = false;
                device.ecuStatus1        = device.ecuStatus1.isEmpty
                    ? 'ECU \${device.srNo} already flashed with updated file.' : device.ecuStatus1;
                device.flashingAvailabel = false;
                device.fileType          = 'Complete';
                device.calIdMatch        = true;
              } else {
                device.calIdMatch        = false;
                device.flashingAvailabel = true;
                device.fileType          = 'Calibration';
              }
            } else {
              if (calMatches) {
                device.ecuStatus         = false;
                device.ecuStatus1        = device.ecuStatus1.isEmpty
                    ? 'ECU \${device.srNo} already flashed with updated file.' : device.ecuStatus1;
                device.flashingAvailabel = false;
                device.fileType          = 'Complete';
                device.calIdMatch        = true;
              } else {
                device.calIdMatch        = false;
                device.flashingAvailabel = true;
                device.fileType          = 'Complete';
              }
            }
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkCVN() async {
    currStatus.value = 'Reading CVN...';
    try {
      for (final device in tableInfo) {
        if (device.isEcuAvailable && device.selectedSubModel != null && !device.isflashing) {
          final pids       = _getPidByType('CVN', device.selectedSubModel);
          final res        = await _wifi.getCVN(device.ipAddress, device.index, _pids);
          final sub        = device.selectedSubModel!;
          final calDataset = sub.ecuSubmodel.isNotEmpty ? sub.ecuSubmodel[0].callibrationDataset : null;
          final comDataset = sub.ecuSubmodel.isNotEmpty ? sub.ecuSubmodel[0].completeDataset : null;
          // .NET MatchCVN: compare ECU cvn vs cvn from flash_record_files
          final ds = calDataset ?? comDataset;
          final expectedCvn = _matchCvnFromFiles(ds);
          final cvnBase = expectedCvn.split('-')[0].trim();
          final ecuCvnBase = res[1].split('-')[0].trim();
          if (res[0] == 'true') {
            device.cvnBefore   = res[1];
            final cvnMatches  = cvnBase.isNotEmpty && ecuCvnBase == cvnBase;
            if (cvnMatches) {
              device.ecuStatus         = false;
              device.ecuStatus1        = device.ecuStatus1.isEmpty
                  ? 'ECU ${device.srNo} already flashed with updated file.' : device.ecuStatus1;
              device.flashingAvailabel = false;
              device.fileType          = 'Complete';
              device.cvnMatch          = true;
            } else {
              device.flashingAvailabel = true;
              device.fileType          = calDataset != null ? 'Calibration' : 'Complete';
              device.cvnMatch          = false;
            }
            // ✅ Enable play button after CVN (mirrors .NET)
            device.playButtonDisable = false;
            device.playButtonColor   = _orange;
          }
        }
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // ══════════════════════════════════════════════════════════
  //  START INDIVIDUAL FLASH — mirrors .NET StartIndivisualFlashingCommand
  // ══════════════════════════════════════════════════════════
  Future<void> startIndividualFlash(IndividualRowModel item) async {
    try {
      item.playButtonDisable = true; item.playButtonColor = Colors.grey;
      item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
      item.progress = 0; item.isflashing = true;
      tableInfo.refresh();

      // Assign files by fileType — mirrors .NET StartIndivisualFlashingCommand
      // .NET: json_file = down_com_json_file (already converted)
      //       seq_file  = down_com_seqfile
      // Flutter: seqFile = sequence file content, jsonFile = hex/srec file content
      //          flashInterpreter converts internally
      final sub = item.selectedSubModel;
      if (sub != null && sub.ecuSubmodel.isNotEmpty) {
        if (sub.ecuSubmodel[0].callibrationDataset == null) {
          // Complete only
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else if (item.fileType == 'Complete') {
          // Both datasets, use complete
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else {
          // Calibration
          item.jsonFile = item.downCalFile;
          item.seqFile  = item.downCalSeqfile;
          item.fileUrl  = item.downCalFileUrl;
        }
      }

      print('📁 startIndividualFlash[${item.index}]: '
          'fileType=${item.fileType} '
          'jsonFile=${item.jsonFile.length}chars '
          'seqFile=${item.seqFile.length}chars');
      tableInfo.refresh();

      await _startFlash(item, item.index);
    } catch (e) {
      item.status = 'Exception'; item.flashingCompleted = true;
      item.isflashing = false; tableInfo.refresh();
    }
  }

  // ── StartFlash inner — mirrors .NET private StartFlash ────
  Future<void> _startFlash(IndividualRowModel device, int index1) async {
    try {
      device.flashingSuccess = false;
      device.isflashing      = true;

      // Read before values if missing (mirrors .NET StartFlash)
      if (device.calIdBefore.isEmpty) {
        final pids = _getPidByType('CALID', device.selectedSubModel);
        final res  = await _wifi.getCalId(device.ipAddress, device.index, _pids);
        if (res[0] == 'true') device.calIdBefore = res[1];
      }
      if (device.cvnBefore.isEmpty) {
        final pids = _getPidByType('CVN', device.selectedSubModel);
        final res  = await _wifi.getCVN(device.ipAddress, device.index, _pids);
        if (res[0] == 'true') device.cvnBefore = res[1];
      }

      if (device.jsonFile.isEmpty || device.seqFile.isEmpty) {
        device.status = 'File not found'; device.flashingCompleted = true;
        device.isflashing = false; device.statusColor = Colors.red;
        tableInfo.refresh(); return;
      }

      device.printButtonDisable = true; device.printButtonColor = Colors.grey;
      device.status             = 'flashing in progress...';
      device.statusColor        = Colors.yellow;
      device.isProgressVisible  = true;
      device.flashingCompleted  = false;
      device.flashPercent       = '0.0%';
      tableInfo.refresh();

      // Stopwatch timer (mirrors .NET Stopwatch + System.Timers.Timer)
      final sw = Stopwatch()..start();
      final flashTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        device.flashTimer =
            '${sw.elapsed.inMinutes.toString().padLeft(2, '0')}:'
            '${(sw.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        tableInfo.refresh();
      });

      // Percent timer every 5s (mirrors .NET percentTimer)
      final progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        final pct = _wifi.flashPercentMap[device.ipAddress] ?? 0.0;
        device.progress     = pct;
        device.flashPercent = '${(pct * 100).toStringAsFixed(1)}%';
        tableInfo.refresh();
      });

      // ✅ REAL: WiFiPlugin.startECUFlashing()
      final sub     = device.selectedSubModel;
      final ecuSub  = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0] : null;
      print('🚀 CALLING flashInterpreter: '
          'jsonFile=${device.jsonFile.length}chars '
          'seqFile=${device.seqFile.length}chars '
          'seed=${ecuSub?.seedkeyAlgoValue}');
      final flashResult = await _wifi.startECUFlashing(
        ip:             device.ipAddress,
        index:          device.index,
        seqFileContent: device.seqFile,
        hexFileContent: device.jsonFile,
        seedKeyIndex:   ecuSub?.seedkeyAlgoValue ?? 'RE_SEEDKEY_EPM44',
        txHeader:       ecuSub?.txHeader    ?? '7DF',
        rxHeader:       ecuSub?.rxHeader    ?? '7E8',
        protocolHex:    ecuSub?.protocolAutopeepal ?? '02',
        onProgress:     (p) => device.progress = p,
        onStatus:       (s) => currStatus.value = s,
      );

      flashTimer.cancel(); progressTimer.cancel(); sw.stop();

      print('🔥 flashResult raw: "$flashResult"');
      device.flashingCompleted = true;
      device.isflashing        = false;
      device.reportColor       = Colors.yellow;
      final result = flashResult.isNotEmpty ? flashResult : 'ERROR';
      print('🔥 result check: "$result" == NOERROR? ${result == 'NOERROR'}');

      if (result == 'NOERROR') {
        await Future.delayed(const Duration(seconds: 3)); // Thread.Sleep(3000)
        device.flashingSuccess = true;
        device.statusColor     = Colors.green;
      } else {
        device.statusColor = Colors.red;
      }

      // GeneratePdfWrapper (mirrors .NET)
      await _getPdfContentAndPost(device, [flashResult]);

      device.status       = result == 'NOERROR' ? 'Flashing completed' : result;
      device.flashPercent = result == 'NOERROR' ? '100.0%' : device.flashPercent;

      if (result == 'NOERROR') {
        device.flashPercent      = '100.0%';
        device.progress          = 1;
        device.playButtonDisable = true;
        device.playButtonColor   = Colors.grey;
        // Enable print button — check scan_qr_code from submodel (mirrors .NET)
        final scanQr = sub?.scanQrCode ?? false;
        if (!scanQr) {
          // No QR scan required — enable print immediately
          device.printButtonDisable = false;
          device.printButtonColor   = _orange;
        }
        // else: QR scan required before print (TODO when QR scanner integrated)
      }
      device.isProgressVisible = false;
      tableInfo.refresh();

    } catch (e) {
      device.status = 'Exception'; device.flashingCompleted = true;
      print('❌ _startFlash: $e');
    } finally {
      device.isflashing        = false;
      device.isProgressVisible = false;
      tableInfo.refresh();
    }
  }

  // ══════════════════════════════════════════════════════════
  //  GET PDF CONTENT + POST FLASH RECORD
  //  Mirrors .NET GetPdfContent: read HW/SW/CalId/CVN/ESN → POST
  // ══════════════════════════════════════════════════════════
  Future<void> _getPdfContentAndPost(
      IndividualRowModel device, List<String> flashing) async {
    try {
      final passed = flashing.isNotEmpty && flashing[0] == 'NOERROR';
      final sub    = device.selectedSubModel;
      final model  = device.selectedModel;
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? 'NA') : 'NA';

      // ✅ Read HW after flash (mirrors .NET)
      final hwRes = await _wifi.getHW(device.ipAddress, device.index, _pids);
      if (hwRes[0] == 'true') device.hardwarePartNumber = hwRes[1];

      // ✅ Read SW after flash
      final swRes = await _wifi.getSW(device.ipAddress, device.index, _pids);
      if (swRes[0] == 'true') device.swVersionAfter = swRes[1];

      // ✅ Read CalId after flash
      final calRes = await _wifi.getCalId(device.ipAddress, device.index, _pids);
      if (calRes[0] == 'true') device.printCalId = calRes[1];

      // ✅ Read CVN after flash
      final cvnRes = await _wifi.getCVN(device.ipAddress, device.index, _pids);
      if (cvnRes[0] == 'true') device.cvn = cvnRes[1];

      // ✅ Read ESN after flash
      final esnRes = await _wifi.getESN(device.ipAddress, device.index, _pids);
      if (esnRes[0] == 'true') device.ecuSrNoAfter = esnRes[1];

      tableInfo.refresh();

      // POST analyze/create-ecu-pfs/ multipart
      final pfsId = _sessionId.isNotEmpty
          ? _sessionId : await AppPreferences.getSessionId();
      final ecuId = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].ecu : 0;

      final uri     = Uri.parse('${AppEnvironment.baseUrl}analyze/create-ecu-pfs/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'JWT $_token';
      request.fields['pfs']             = pfsId;
      request.fields['ecu']             = '$ecuId';
      request.fields['flash_time']      = device.flashTimer;
      request.fields['model']           = '${model?.id ?? 0}';
      request.fields['sub_model']       = '${sub?.id ?? 0}';
      request.fields['model_year']      = '${sub?.id ?? 0}';
      request.fields['ECU_ID']          = device.hardwarePartNumber;
      request.fields['cal_id']          = device.printCalId;
      request.fields['cvn']             = device.cvn;
      request.fields['sw_version']      = device.swVersionAfter;
      request.fields['serial_no']       = device.ecuSrNoAfter;
      request.fields['status']          = passed ? 'Pass' : 'Fail';
      request.fields['scanned_qr_code'] = '';
      request.fields['printed_qr_code'] = passed
          ? '${device.printCalId}@$swPart@${device.ecuSrNoAfter}@${device.cvn}' : '';
      request.fields['previous_cal_id'] = device.calIdBefore;
      request.fields['previous_cvn']    = device.cvnBefore;

      final streamedRes = await request.send();
      final res         = await http.Response.fromStream(streamedRes);
      device.reportColor = (res.statusCode == 200 || res.statusCode == 201)
          ? Colors.green : Colors.red;
      tableInfo.refresh();
      print('📡 create-ecu-pfs/ ${res.statusCode}');
    } catch (e) {
      print('❌ _getPdfContentAndPost: $e');
      device.reportColor = Colors.red;
      tableInfo.refresh();
    }
  }

  // ══════════════════════════════════════════════════════════
  //  PRINT STICKER — mirrors .NET PrintCommand finally block
  //  Resets entire row after print so it can be flashed again
  // ══════════════════════════════════════════════════════════
  Future<void> printSticker(IndividualRowModel device) async {
    try {
      // TODO: printer plugin
      // final stData = _profile?['station_data'] as List?;
      // await PrintPlugin.print(device.cvn, device.printCalId,
      //   device.ecuSrNoAfter, device.selectedSubModel?.description ?? '',
      //   swPartNo, device.srNo, stData?[0]['stations_id'], stData?[0]['ip'], stData?[0]['port']);
      print('🖨️ Print: ${device.printCalId} | ${device.cvn} | ${device.ecuSrNoAfter}');
    } catch (e) {
      print('❌ printSticker: $e');
    } finally {
      // ✅ Reset row exactly as .NET PrintCommand finally block
      device.status = '';
      device.isDongleAvailable = false;     device.isEcuAvailable = false;
      device.dongleStatusColor = Colors.red; device.dongleFlashingIndicator = false;
      device.ecuFlashingIndicator = false;  device.ecuStatusColor = Colors.red;
      device.ecuSrNo = '';                  device.flashTimer = '00:00';
      device.flashPercent = '0.0 %';        device.statusColor = Colors.white;
      device.reportColor = Colors.white;    device.flashingCompleted = false;
      device.printButtonDisable = true;     device.printButtonColor = Colors.grey;
      device.playButtonDisable = true;      device.playButtonColor = Colors.grey;
      device.playButtonVisible = true;      device.isflashing = false;
      device.flashingAvailabel = false;     device.fileType = 'NA';
      device.hardwarePartNumber = '';       device.ecuStatus = true;
      device.ecuStatus1 = '';              device.alreadyMessage = false;
      device.isDongle = false;             device.swMatch = false;
      device.calIdMatch = false;           device.cvnMatch = false;
      device.progress = 0;                 device.isProgressVisible = false;
      device.printCalId = '';              device.ecuSrNoAfter = '';
      device.swVersionBefore = '';         device.swVersionAfter = '';
      device.cvnBefore = '';               device.cvn = '';
      device.swPartNo = '';
      tableInfo.refresh();
    }
  }

  void onOkPopup() {
    for (final item in tableInfo) {
      item.ecuStatus = true; item.ecuStatus1 = ''; item.alreadyMessage = false;
    }
    popupMessage.value = ''; showAlertPopup.value = false;
    tableInfo.refresh();
  }

  Map<String, String> get _headers => {
    'Content-Type':  'application/json',
    'Authorization': 'JWT $_token',
  };

  @override
  void onClose() {
    _wifi.closeSockets();
    super.onClose();
  }
}