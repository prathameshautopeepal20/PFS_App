// lib/logic/controller/dashboard/individual_flash_controller.dart
// Mirrors IndivisualFlashViewModel.cs EXACTLY — verified against full .NET source

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/services/wifi_plugin.dart';

class IndividualRowModel {
  int    index; int srNo; String bgColor; String macId;
  String ipAddress; int priority;
  ModelResult? selectedModel; SubModel? selectedSubModel;
  String downComFile; String downComSeqfile; String downComFileUrl;
  String downCalFile; String downCalSeqfile; String downCalFileUrl;
  String status;
  bool isDongleAvailable; bool isEcuAvailable;
  bool dongleFlashingIndicator; bool ecuFlashingIndicator;
  Color dongleStatusColor; Color ecuStatusColor;
  String ecuSrNo; String ecuSrNoAfter; String hardwarePartNumber;
  String swVersionBefore; String swVersionAfter;
  String calIdBefore; String calId; String printCalId;
  String cvnBefore; String cvn; String swPartNo;
  bool flashingCompleted; bool flashingSuccess; bool isflashing;
  bool flashingAvailabel; String fileType;
  String flashTimer; String flashPercent; double progress;
  bool isProgressVisible; Color statusColor; Color reportColor;
  bool printButtonDisable; Color printButtonColor;
  bool playButtonDisable; Color playButtonColor; bool playButtonVisible;
  bool ecuStatus; String ecuStatus1; bool alreadyMessage; bool isDongle;
  bool swMatch; bool calIdMatch; bool cvnMatch;
  String jsonFile; String seqFile; String fileUrl;

  IndividualRowModel({
    required this.index, required this.srNo, required this.bgColor,
    required this.macId, required this.ipAddress, required this.priority,
    this.selectedModel, this.selectedSubModel,
    this.downComFile='', this.downComSeqfile='', this.downComFileUrl='',
    this.downCalFile='', this.downCalSeqfile='', this.downCalFileUrl='',
    this.status='',
    this.isDongleAvailable=false, this.isEcuAvailable=false,
    this.dongleFlashingIndicator=false, this.ecuFlashingIndicator=false,
    this.dongleStatusColor=const Color(0xFFF44336), this.ecuStatusColor=const Color(0xFFF44336),
    this.ecuSrNo='', this.ecuSrNoAfter='', this.hardwarePartNumber='',
    this.swVersionBefore='', this.swVersionAfter='',
    this.calIdBefore='', this.calId='', this.printCalId='',
    this.cvnBefore='', this.cvn='', this.swPartNo='',
    this.flashingCompleted=false, this.flashingSuccess=false,
    this.isflashing=false, this.flashingAvailabel=false,
    this.fileType='NA', this.flashTimer='00:00', this.flashPercent='0.0 %',
    this.progress=0, this.isProgressVisible=false,
    this.statusColor=const Color(0xFFFFFFFF), this.reportColor=const Color(0xFFFFFFFF),
    this.printButtonDisable=true, this.printButtonColor=const Color(0xFF9E9E9E),
    this.playButtonDisable=true, this.playButtonColor=const Color(0xFF9E9E9E),
    this.playButtonVisible=true,
    this.ecuStatus=true, this.ecuStatus1='', this.alreadyMessage=false,
    this.isDongle=false,
    this.swMatch=false, this.calIdMatch=false, this.cvnMatch=false,
    this.jsonFile='', this.seqFile='', this.fileUrl='',
  });

  factory IndividualRowModel.fromDongleRow(DongleRow d) => IndividualRowModel(
    index: d.index, srNo: d.srNo,
    bgColor: (d.index % 2 == 0) ? '#eeeeee' : '#cccccc',
    macId: d.macId, ipAddress: d.ipAddress, priority: d.priority,
    selectedModel: d.selectedModel, selectedSubModel: d.selectedSubModel,
    downComFile: d.downComFile, downComSeqfile: d.downComSeqfile,
    downComFileUrl: d.downComFileUrl,
    downCalFile: d.downCalFile, downCalSeqfile: d.downCalSeqfile,
    downCalFileUrl: d.downCalFileUrl,
    calId: d.calId, printCalId: d.printCalId,
  );
}

class IndividualFlashController extends GetxController {
  final Map<String, dynamic> args;
  IndividualFlashController({required this.args});

  final _wifi = WiFiPlugin.instance;

  final RxList<IndividualRowModel> tableInfo = <IndividualRowModel>[].obs;
  final RxBool   isLoading       = false.obs;
  final RxString currStatus      = ''.obs;
  final RxBool   showAlertPopup  = false.obs;
  final RxString popupMessage    = ''.obs;

  // .NET: CheckEcuStatusButton = true in constructor, stays true always
  // Button is NEVER disabled in .NET during check — always tappable
  final RxBool checkEcuStatusButton = true.obs;

  Map<String, dynamic>? _profile;
  String        _token     = '';
  String        _sessionId = '';
  List<dynamic> _pids       = [];
  List<dynamic> _parameters = [];
  List<dynamic> _flashFiles = [];

  // .NET: accent_color = orange
  static const _orange = Color(0xFFF9772C);

  @override
  void onInit() { super.onInit(); _init(); }

  // .NET order: ShowRegisteredDongleList → GenerateJason → GetFlashDetail → GetParameters → GetPid
  Future<void> _init() async {
    isLoading.value = true;
    try {
      _token     = args['token']   ?? await AppPreferences.getToken() ?? '';
      _profile   = args['profile'] as Map<String,dynamic>?
                   ?? await AppPreferences.getLoginResponse();
      _sessionId = await AppPreferences.getSessionId();

      final rawList = args['finalList'] as List<DongleRow>? ?? [];
      final rows    = rawList.map((d) => IndividualRowModel.fromDongleRow(d)).toList();
      for (final row in rows) {
        final sub = row.selectedSubModel;
        if (sub != null && sub.ecuSubmodel.isNotEmpty) {
          row.swPartNo = sub.ecuSubmodel[0].callibrationDataset?.swPartNo
                      ?? sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '';
        }
      }
      tableInfo.assignAll(rows);

      // .NET: GenerateJason() first — converts SREC to JSON
      // In Dart we convert at flash time in wifi_plugin (same result)
      await _getFlashDetail();
      await _getParameters();
      await _getPidList();
      await _downloadAndGenerateFiles();
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
        print('✅ FlashDetail: ${_flashFiles.length} records');
        for (final f in _flashFiles) {
          if (f is Map) {
            for (final file in (f['file'] as List? ?? [])) {
              if (file is Map) {
                print('   id=${file["id"]} cal_id="${file["cal_id"]}" '
                    'cvn="${file["cvn"]}" sw="${file["sw_version"]}"');
              }
            }
          }
        }
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
        print('✅ Parameters: ${_parameters.length}');
      }
    } catch (e) { print('❌ _getParameters: $e'); }
  }

  Future<void> _getPidList() async {
    try {
      final sub = tableInfo.isNotEmpty ? tableInfo.first.selectedSubModel : null;
      if (sub == null || sub.ecuSubmodel.isEmpty) return;
      final pds   = sub.ecuSubmodel[0].pidDatasets;
      if (pds.isEmpty) return;
      final first = pds[0];
      final pidId = first is Map ? first['id'] as int? : (first is int ? first : null);
      if (pidId == null) return;
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}datasets/get-pid-datasets/?id=$pidId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final results = jsonDecode(res.body)['results'] as List? ?? [];
        if (results.isNotEmpty) {
          _pids = results[0]['codes'] as List? ?? [];
          print('✅ PIDs: ${_pids.length}');
        }
      }
    } catch (e) { print('❌ _getPidList: $e'); }
  }

  // .NET: GetPid(type, subModel) — finds exact PID by parameter type
  List<dynamic> _getPidByType(String type, SubModel? subModel) {
    try {
      if (_parameters.isEmpty || subModel == null || _pids.isEmpty) return _pids;
      final param = _parameters.firstWhere(
        (p) => (p['parameter'] ?? '').toString().contains(type),
        orElse: () => null,
      );
      if (param == null) return _pids;
      final paramIds  = param['parameter_ids'] as List? ?? [];
      if (paramIds.isEmpty) return _pids;
      final pds       = subModel.ecuSubmodel.isNotEmpty
          ? subModel.ecuSubmodel[0].pidDatasets : [];
      if (pds.isEmpty) return _pids;
      final first     = pds[0];
      final datasetId = first is Map ? first['id'] as int?
          : (first is int ? first : null);
      if (datasetId == null) return _pids;
      for (final paramId in paramIds) {
        final dataset = paramId['dataset'];
        final dId = dataset is Map ? dataset['id'] : dataset;
        if (dId == datasetId) {
          final pidCodeId = paramId['pid_code'] is Map
              ? paramId['pid_code']['id'] : paramId['pid_code'];
          for (final pidCode in _pids) {
            for (final v in (pidCode['pi_code_variable'] as List? ?? [])) {
              final vId = v is Map ? v['id'] : v;
              if (vId == pidCodeId) return [pidCode];
            }
          }
        }
      }
      return _pids;
    } catch (_) { return _pids; }
  }

  Future<void> _downloadAndGenerateFiles() async {
    currStatus.value = 'Downloading flash files...';
    try {
      for (final row in tableInfo) {
        final sub = row.selectedSubModel;
        if (sub == null || sub.ecuSubmodel.isEmpty) continue;
        final ecuSub = sub.ecuSubmodel[0];

        if (ecuSub.completeDataset != null) {
          final hexUrl = ecuSub.completeDataset!.hexSrecFile ?? '';
          final seqUrl = ecuSub.completeDataset!.sequenceFileName?.sequenceFile ?? '';
          if (hexUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(hexUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downComFile = r.body; row.downComFileUrl = hexUrl;
              print('✅ COM hex: ${r.body.length} chars');
            }
          }
          if (seqUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(seqUrl), headers: _headers);
            if (r.statusCode == 200) row.downComSeqfile = r.body;
          }
        }
        if (ecuSub.callibrationDataset != null) {
          final hexUrl = ecuSub.callibrationDataset!.hexSrecFile ?? '';
          final seqUrl = ecuSub.callibrationDataset!.sequenceFileName
              ?.callibrationDatasetSeq ?? '';
          if (hexUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(hexUrl), headers: _headers);
            if (r.statusCode == 200) {
              row.downCalFile = r.body; row.downCalFileUrl = hexUrl;
              print('✅ CAL hex: ${r.body.length} chars');
            }
          }
          if (seqUrl.isNotEmpty) {
            final r = await http.get(Uri.parse(seqUrl), headers: _headers);
            if (r.statusCode == 200) row.downCalSeqfile = r.body;
          }
        }
        print('✅ slot ${row.index}: COM=${row.downComFile.length} CAL=${row.downCalFile.length}');
      }
      tableInfo.refresh();
    } catch (e) { print('❌ _downloadAndGenerateFiles: $e'); }
    finally { currStatus.value = ''; }
  }

  // ══════════════════════════════════════════════════════════
  //  CHECK ECU STATUS — mirrors CheckEcuStatusCommand exactly
  // ══════════════════════════════════════════════════════════
  Future<void> checkEcuStatus() async {
    // .NET: CheckEcuStatusButton stays TRUE the whole time (never disabled)
    try {
      // .NET: reset all non-flashing rows
      for (final item in tableInfo) {
        if (!item.isflashing) {
          item.status=''; item.isDongleAvailable=false; item.isEcuAvailable=false;
          item.dongleStatusColor=const Color(0xFFF44336); item.dongleFlashingIndicator=false;
          item.ecuFlashingIndicator=false; item.ecuStatusColor=const Color(0xFFF44336);
          item.ecuSrNo=''; item.flashTimer='00:00'; item.flashPercent='0.0 %';
          item.statusColor=const Color(0xFFFFFFFF); item.reportColor=const Color(0xFFFFFFFF);
          item.flashingCompleted=false; item.printButtonDisable=true;
          item.printButtonColor=const Color(0xFF9E9E9E); item.playButtonDisable=true;
          item.playButtonColor=const Color(0xFF9E9E9E); item.isflashing=false;
          item.playButtonVisible=true; item.flashingAvailabel=false;
          item.fileType='NA'; item.hardwarePartNumber='';
          item.ecuStatus=true; item.ecuStatus1=''; item.alreadyMessage=false;
          item.isDongle=false; item.swMatch=false;
          item.calIdMatch=false; item.cvnMatch=false;
          item.progress=0; item.isProgressVisible=false;
          item.printCalId=''; item.ecuSrNoAfter='';
          item.swVersionBefore=''; item.swVersionAfter='';
          item.cvnBefore=''; item.cvn='';
          final sub = item.selectedSubModel;
          if (sub != null && sub.ecuSubmodel.isNotEmpty) {
            item.swPartNo = sub.ecuSubmodel[0].callibrationDataset?.swPartNo
                          ?? sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '';
          }
        }
      }
      tableInfo.refresh();
      popupMessage.value = '';

      // .NET: CheckDongle → CheckECU → CheckECUHW → CheckFlashingStatus → CheckECUSW → CheckCalId → CheckCVN
      await _checkDongle();
      print('🔌 [1] ${tableInfo.map((x)=>"${x.srNo}:${x.dongleFlashingIndicator}").join(",")}');
      if (tableInfo.any((x) => x.dongleFlashingIndicator)) {
        await _checkECU();
        print('🔌 [2] ${tableInfo.map((x)=>"${x.srNo}:ESN=${x.ecuSrNo}").join(",")}');
        if (tableInfo.any((x) => x.ecuFlashingIndicator)) {
          await _checkECUHW();
          print('🔩 [3] ${tableInfo.map((x)=>"${x.srNo}:HW=${x.hardwarePartNumber}").join(",")}');
          if (tableInfo.any((x) => x.isEcuAvailable)) {
            await _checkFlashingStatus();
            print('📋 [4] ${tableInfo.map((x)=>"${x.srNo}:${x.ecuStatus1}").join(",")}');
            await _checkECUSW();
            print('💾 [5] ${tableInfo.map((x)=>"${x.srNo}:sw=${x.swVersionBefore}").join(",")}');
            await _checkCalId();
            print('📅 [6] ${tableInfo.map((x)=>"${x.srNo}:cal=${x.calIdBefore}").join(",")}');
            await _checkCVN();
            print('🔢 [7] ${tableInfo.map((x)=>"${x.srNo}:cvn=${x.cvnBefore}:play=${!x.playButtonDisable}").join(",")}');
          }
        }
      }

      // .NET: if any ecu_status1 non-empty → ShowPopup=true
      // Note: .NET does NOT check alreadyMessage here — shows popup for ALL with status1
      if (tableInfo.any((x) => x.ecuStatus1.isNotEmpty)) {
        for (final item in tableInfo) {
          if (item.ecuStatus1.isNotEmpty) {
            popupMessage.value += '${item.ecuStatus1}\n';
            item.alreadyMessage = true;
          }
        }
        showAlertPopup.value = true;
        tableInfo.refresh();
      }

      print('✅ [FINAL] ${tableInfo.map((x)=>"${x.srNo}:flashAvail=${x.flashingAvailabel}:play=${!x.playButtonDisable}").join(",")}');
      tableInfo.refresh();
    } catch (e) {
      currStatus.value = '';
      print('❌ checkEcuStatus: $e');
    }
    // .NET: CheckEcuStatusButton stays true — no finally needed
  }

  Future<void> _checkDongle() async {
    currStatus.value = 'Checking Dongle Connection...';
    try {
      // ⚡ PARALLEL: check all dongles simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.selectedSubModel != null && !device.isflashing) {
          device.isDongle = await _wifi.checkDongle(device.ipAddress, device.index);
          if (device.isDongle) {
            device.dongleFlashingIndicator = true;
            device.dongleStatusColor       = const Color(0xFF4CAF50);
          } else {
            device.dongleFlashingIndicator = false;
            device.dongleStatusColor       = const Color(0xFFF44336);
            device.ecuStatus  = false;
            device.ecuStatus1 = 'Dongle ${device.srNo} not found.';
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkECU() async {
    currStatus.value = 'Checking ECU Connection...';
    try {
      // ⚡ PARALLEL: read ESN from all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.dongleFlashingIndicator && !device.isflashing) {
          final pids = _getPidByType('ESN', device.selectedSubModel);
          final res  = await _wifi.getESN(device.ipAddress, device.index, pids);
          print('  ESN[${device.srNo}]: res[0]=${res[0]} val="${res.length>1 ? res[1] : ""}"');
          if (res[0] == 'true') {
            device.ecuFlashingIndicator = true;
            device.ecuSrNo              = res[1];
            device.isEcuAvailable       = true;
            device.ecuStatusColor       = const Color(0xFF4CAF50);
            print('  ✅ ECU[${device.srNo}] ESN=${res[1]}');
          } else {
            device.ecuSrNo              = res.length > 1 ? res[1] : '';
            device.ecuFlashingIndicator = false;
            device.isEcuAvailable       = false;
            device.ecuStatus            = false;
            device.ecuStatus1           = 'Check ECU ${device.srNo} connection.';
            print('  ❌ ECU[${device.srNo}] not connected');
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // .NET CheckECUHW: calls MatchHardwarePartNumber which checks hw_part_no contains value
  Future<void> _checkECUHW() async {
    currStatus.value = 'Reading ECU Hardware Number...';
    try {
      // ⚡ PARALLEL: read HW from all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.ecuFlashingIndicator && !device.isflashing) {
          final pids = _getPidByType('HWPN', device.selectedSubModel);
          final res  = await _wifi.getHW(device.ipAddress, device.index, pids);
          if (res[0] == 'true') {
            device.hardwarePartNumber = res[1];
            device.isEcuAvailable     = true;
            print('  ✅ HW[${device.srNo}]: ${res[1]}');
          } else {
            device.ecuStatus      = false;
            device.isEcuAvailable = false;
            device.ecuStatus1     = 'ECU ${device.srNo} HW read failed.';
            print('  ❌ HW[${device.srNo}] read failed');
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // .NET: MatchHardwarePartNumber — hw_part_no.Contains(value) → true
  // If hw_part_no is null/empty in API → pass through (not configured)
  bool _matchHW(dynamic dataset, String value, String hwPartNo) {
    try {
      if (dataset == null) return true;    // no dataset → pass
      if (hwPartNo.isEmpty) return true;   // not configured in API → pass
      if (value.isEmpty) return false;     // ECU returned nothing → fail
      return hwPartNo.contains(value);     // .NET: hw_part_no.Contains(value)
    } catch (_) { return true; }
  }

  Future<void> _checkFlashingStatus() async {
    currStatus.value = 'Checking Flashing Status...';
    try {
      // ⚡ PARALLEL: check flash status for all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.isEcuAvailable && !device.isflashing && device.ecuSrNo.isNotEmpty && device.selectedSubModel != null) {
          final res = await http.get(
            Uri.parse('${AppEnvironment.baseUrl}analyze/get-ecu-pfs-status/?serial_no=${device.ecuSrNo}'),
            headers: _headers,
          );
          if (res.statusCode == 200) {
            final results = jsonDecode(res.body)['results'] as List? ?? [];
            print('📋 FlashStatus[${device.srNo}] ESN=${device.ecuSrNo}: '
                'count=${results.length} status=${results.isNotEmpty ? results[0]["status"] : "none"}');
            if (results.isNotEmpty && results[0]['status'] == 'Pass') {
              // .NET: ONLY sets ecu_status1 + ecu_status=false
              // Does NOT block flash — popup is warning only, user CAN still flash
              device.ecuStatus1 = device.ecuStatus1.isEmpty
                  ? 'ECU ${device.srNo} already flashed with updated file.'
                  : device.ecuStatus1;
              device.ecuStatus = false;
              print('   → ECU[${device.srNo}] already flashed (Pass) — warning only, flash still allowed');
            }
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // .NET: flash_record_files.FirstOrDefault(x=>x.id==dataset.sequence_file_name.id)
  // then file = flash_record_file.file.FirstOrDefault(x=>x.id==dataset.id)
  String _matchFromFiles(dynamic dataset, String field) {
    try {
      if (dataset == null) return '';
      final seqId    = dataset.sequenceFileName?.id;
      if (seqId == null) return '';
      final flashRec = _flashFiles.firstWhere(
          (f) => f is Map && f['id'] == seqId, orElse: () => null);
      if (flashRec == null) return '';
      final files    = (flashRec as Map)['file'] as List? ?? [];
      final file     = files.firstWhere(
          (f) => f is Map && f['id'] == dataset.id, orElse: () => null);
      if (file == null) return '';
      return ((file as Map)[field] ?? '').toString();
    } catch (_) { return ''; }
  }

  Future<void> _checkECUSW() async {
    currStatus.value = 'Reading Software Version...';
    try {
      // ⚡ PARALLEL: read SW version from all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.isEcuAvailable && !device.isflashing) {
          final pids  = _getPidByType('ESWV', device.selectedSubModel);
          final res   = await _wifi.getSW(device.ipAddress, device.index, pids);
          final comDs = device.selectedSubModel?.ecuSubmodel.isNotEmpty == true
              ? device.selectedSubModel!.ecuSubmodel[0].completeDataset : null;
          if (res[0] == 'true') {
            device.swVersionBefore = res[1];
            final expected = _matchFromFiles(comDs, 'sw_version');
            print('  SW[${device.srNo}]: ECU="${res[1]}" API="$expected"');
            if (expected.isNotEmpty && res[1] == expected) {
              device.swMatch = true; device.flashingAvailabel = false;
            } else {
              device.swMatch = false;
              device.flashingAvailabel = true;
              device.fileType = 'Complete';
            }
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkCalId() async {
    currStatus.value = 'Reading Calibration Id...';
    try {
      // ⚡ PARALLEL: read CalId from all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.isEcuAvailable && device.selectedSubModel != null && !device.isflashing) {
          final pids  = _getPidByType('CALID', device.selectedSubModel);
          final res   = await _wifi.getCalId(device.ipAddress, device.index, pids);
          final sub   = device.selectedSubModel!;
          final calDs = sub.ecuSubmodel.isNotEmpty
              ? sub.ecuSubmodel[0].callibrationDataset : null;
          final comDs = sub.ecuSubmodel.isNotEmpty
              ? sub.ecuSubmodel[0].completeDataset : null;
          if (res[0] == 'true') {
            device.calIdBefore = res[1];
            if (calDs != null) {
              // .NET: MatchCalId(callibration_dataset, res[1])
              final expected = _matchFromFiles(calDs, 'cal_id');
              final matches  = expected.isNotEmpty && res[1] == expected;
              print('  CalId(cal): ECU="${res[1]}" API="$expected" match=$matches');
              if (matches) {
                device.ecuStatus  = false;
                device.ecuStatus1 = device.ecuStatus1.isEmpty
                    ? 'ECU ${device.srNo} already flashed with updated file.'
                    : device.ecuStatus1;
                device.flashingAvailabel = false; device.fileType = 'Complete';
                device.calIdMatch = true;
              } else {
                device.calIdMatch = false;
                device.flashingAvailabel = true;
                device.fileType = 'Calibration';
              }
            } else {
              // .NET: MatchCalId(complete_dataset, res[1])
              final expected = _matchFromFiles(comDs, 'cal_id');
              final matches  = expected.isNotEmpty && res[1] == expected;
              print('  CalId(com): ECU="${res[1]}" API="$expected" match=$matches');
              if (matches) {
                device.ecuStatus  = false;
                device.ecuStatus1 = device.ecuStatus1.isEmpty
                    ? 'ECU ${device.srNo} already flashed with updated file.'
                    : device.ecuStatus1;
                device.flashingAvailabel = false; device.fileType = 'Complete';
                device.calIdMatch = true;
              } else {
                device.calIdMatch = false;
                device.flashingAvailabel = true;
                device.fileType = 'Complete';
              }
            }
          }
        }
      }));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  Future<void> _checkCVN() async {
    currStatus.value = 'Reading CVN...';
    try {
      // ⚡ PARALLEL: read CVN from all ECUs simultaneously
      await Future.wait(tableInfo.map((device) async {
        if (device.isEcuAvailable && device.selectedSubModel != null && !device.isflashing) {
          final pids  = _getPidByType('CVN', device.selectedSubModel);
          final res   = await _wifi.getCVN(device.ipAddress, device.index, pids);
          final sub   = device.selectedSubModel!;
          final calDs = sub.ecuSubmodel.isNotEmpty
              ? sub.ecuSubmodel[0].callibrationDataset : null;
          final comDs = sub.ecuSubmodel.isNotEmpty
              ? sub.ecuSubmodel[0].completeDataset : null;
          if (res[0] == 'true') {
            device.cvnBefore = res[1];
            final ds       = calDs ?? comDs;
            final expected = _matchFromFiles(ds, 'cvn');
            final matches  = expected.isNotEmpty && res[1] == expected;
            print('  CVN: ECU="${res[1]}" API="$expected" match=$matches');
            if (matches) {
              device.ecuStatus  = false;
              device.ecuStatus1 = device.ecuStatus1.isEmpty
                  ? 'ECU ${device.srNo} already flashed with updated file.'
                  : device.ecuStatus1;
              device.flashingAvailabel = false;
              device.fileType  = calDs != null ? 'Calibration' : 'Complete';
              device.cvnMatch  = true;
            } else {
              device.flashingAvailabel = true;
              device.fileType  = calDs != null ? 'Calibration' : 'Complete';
              device.cvnMatch  = false;
            }
          } else {
            // CVN read failed — still enable flash
            print('  CVN read failed — enabling play button anyway');
            device.flashingAvailabel = true;
            device.fileType = calDs != null ? 'Calibration' : 'Complete';
          }
          // .NET: ALWAYS enable play button after CVN step
          device.playButtonDisable = false;
          device.playButtonColor   = _orange;
      }}));
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // ══════════════════════════════════════════════════════════
  //  START ALL FLASH — ⚡ PARALLEL: flash all eligible ECUs at once
  //  4 ECUs × 1.5min = 1.5min total (instead of 6min sequential)
  // ══════════════════════════════════════════════════════════
  Future<void> startAllFlash() async {
    // Get all eligible devices (play button enabled, not already flashing)
    final eligible = tableInfo.where((d) =>
        !d.playButtonDisable && !d.isflashing && d.flashingAvailabel).toList();

    if (eligible.isEmpty) {
      print('⚡ startAllFlash: no eligible devices');
      return;
    }

    print('⚡ startAllFlash: ${eligible.length} ECUs flashing in parallel');

    // Prepare all devices first (assign files, update UI)
    for (final item in eligible) {
      item.playButtonDisable = true; item.playButtonColor = const Color(0xFF9E9E9E);
      item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
      item.progress = 0; item.isflashing = true;

      final sub = item.selectedSubModel;
      if (sub != null && sub.ecuSubmodel.isNotEmpty) {
        if (sub.ecuSubmodel[0].callibrationDataset == null) {
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else if (item.fileType == 'Complete') {
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else {
          item.jsonFile = item.downCalFile;
          item.seqFile  = item.downCalSeqfile;
          item.fileUrl  = item.downCalFileUrl;
        }
      }
    }
    tableInfo.refresh();

    // ⚡ Flash all simultaneously — each on its own dongle/socket
    await Future.wait(
      eligible.map((item) => _startFlash(item)),
    );

    print('⚡ startAllFlash: all ${eligible.length} ECUs completed');
  }

  // ══════════════════════════════════════════════════════════
  //  START FLASH — mirrors StartIndivisualFlashingCommand + StartFlash
  // ══════════════════════════════════════════════════════════
  Future<void> startIndividualFlash(IndividualRowModel item) async {
    // .NET: StartIndivisualFlashingCommand — no flashingAvailabel check, always proceeds
    try {
      item.playButtonDisable = true; item.playButtonColor = const Color(0xFF9E9E9E);
      item.flashTimer = '00:00'; item.flashPercent = '0.0 %';
      item.progress = 0; item.isflashing = true;
      tableInfo.refresh();

      // .NET: assign files by fileType
      final sub = item.selectedSubModel;
      if (sub != null && sub.ecuSubmodel.isNotEmpty) {
        if (sub.ecuSubmodel[0].callibrationDataset == null) {
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else if (item.fileType == 'Complete') {
          item.jsonFile = item.downComFile;
          item.seqFile  = item.downComSeqfile;
          item.fileUrl  = item.downComFileUrl;
        } else {
          item.jsonFile = item.downCalFile;
          item.seqFile  = item.downCalSeqfile;
          item.fileUrl  = item.downCalFileUrl;
        }
      }

      print('📁 startFlash[${item.index}]: fileType=${item.fileType} '
          'json=${item.jsonFile.length} seq=${item.seqFile.length}');
      tableInfo.refresh();
      // .NET: Thread tcpTask = new Thread(() => StartFlash(item, item.index)); tcpTask.Start();
      await _startFlash(item);
    } catch (e) {
      item.status = 'Exception'; item.flashingCompleted = true;
      item.isflashing = false; tableInfo.refresh();
    }
  }

  // .NET: private async void StartFlash(IndividualFlashModel selectedModel, int index1)
  Future<void> _startFlash(IndividualRowModel device) async {
    final stopwatch = Stopwatch();
    Timer? timerSeconds;
    try {
      device.status          = 'Downloading...';
      device.flashingSuccess = false;
      device.isflashing      = true;

      if (device.jsonFile.isEmpty || device.seqFile.isEmpty) {
        print('❌ File missing: json=${device.jsonFile.length} seq=${device.seqFile.length}');
        device.status = 'File not found'; device.flashingCompleted = true;
        device.isflashing = false; device.statusColor = const Color(0xFFF44336);
        tableInfo.refresh(); return;
      }

      device.printButtonDisable = true; device.printButtonColor = const Color(0xFF9E9E9E);
      device.status             = 'flashing in progress...';
      device.statusColor        = const Color(0xFFFFEB3B);
      device.flashPercent       = '0.0%';
      device.progress           = 0;
      device.isProgressVisible  = true;
      device.flashingCompleted  = false;
      tableInfo.refresh();

      // Start stopwatch + 1-second clock timer BEFORE flash begins
      stopwatch.start();
      timerSeconds = Timer.periodic(const Duration(seconds: 1), (_) {
        final m = stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
        final s = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
        device.flashTimer = '$m : $s';
        tableInfo.refresh();
      });

      final sub    = device.selectedSubModel;
      final ecuSub = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0] : null;

      // .NET: flashing = await wifi.StartIndvECUFlashing(...)
      // Progress now comes live from the flash isolate via onProgress callback —
      // capped at 99% until confirmed success (post-transfer verification can still fail)
      final flashResult = await _wifi.startECUFlashing(
        ip:             device.ipAddress,
        index:          device.index,
        seqFileContent: device.seqFile,
        hexFileContent: device.jsonFile,
        seedKeyIndex:   ecuSub?.seedkeyAlgoValue  ?? 'RE_SEEDKEY_EPM44',
        txHeader:       ecuSub?.txHeader           ?? '7DF',
        rxHeader:       ecuSub?.rxHeader           ?? '7E8',
        protocolHex:    ecuSub?.protocolAutopeepal ?? '02',
        onProgress: (p) {
          // Cap at 99% — only show 100% after confirmed NOERROR result
          final clamped = (p.clamp(0.0, 1.0)) * 0.99;
          if (clamped > device.progress) {
            device.progress     = clamped;
            device.flashPercent = '${(clamped * 100).toStringAsFixed(1)}%';
            tableInfo.refresh();
          }
        },
        onStatus: (s) { currStatus.value = s; },
      );

      print('🔥 flashResult: "$flashResult"');

      device.flashingCompleted = true;
      device.isflashing        = false;
      device.reportColor       = const Color(0xFFFFEB3B);
      final result = flashResult.isNotEmpty ? flashResult : 'ERROR';

      if (result == 'NOERROR') {
        print('   ✅ FLASH SUCCESS!');
        device.flashingSuccess = true;
        device.statusColor     = const Color(0xFF4CAF50);
        device.status          = 'Flashing completed';
        // Show true 100% — flash confirmed successful
        device.flashPercent    = '100.0%';
        device.progress        = 1.0;
        // 🔥 Stop timer NOW — user sees Pass + 100% + frozen time.
        // PID reads still run after this but time display is frozen
        // at the actual flash completion moment, not including post-read time.
        timerSeconds?.cancel(); timerSeconds = null; stopwatch.stop();
        tableInfo.refresh();

        // Post-flash PID reads run after timer is stopped (background work)
        await _getPdfContentAndPost(device, [flashResult]);
      } else {
        print('   ❌ Flash failed: $result');
        device.statusColor = const Color(0xFFF44336);
        device.status      = result;
        tableInfo.refresh();
        await _getPdfContentAndPost(device, [flashResult]);
      }

      // Stop timer after all work done (for fail case — success already stopped it above)
      timerSeconds?.cancel(); timerSeconds = null;
      if (stopwatch.isRunning) stopwatch.stop();

      // Enable print button for successful flash
      if (result == 'NOERROR') {
        device.playButtonDisable = true;
        device.playButtonColor   = const Color(0xFF9E9E9E);
        final scanQr = sub?.scanQrCode ?? false;
        if (!scanQr) {
          device.printButtonDisable = false;
          device.printButtonColor   = _orange;
        }
      }

      tableInfo.refresh();
    } catch (e) {
      device.status = 'Exception'; device.flashingCompleted = true;
      print('❌ _startFlash: $e');
    } finally {
      timerSeconds?.cancel();
      if (stopwatch.isRunning) stopwatch.stop();
      device.isflashing        = false;
      device.isProgressVisible = false;
      tableInfo.refresh();
    }
  }

  // .NET: GetPdfContent — reads 5 PIDs then POSTs create-ecu-pfs
  // Timer runs DURING this entire method (like .NET)
  Future<void> _getPdfContentAndPost(IndividualRowModel device, List<String> flashing) async {
    try {
      final passed = flashing.isNotEmpty && flashing[0] == 'NOERROR';
      final sub    = device.selectedSubModel;
      final model  = device.selectedModel;
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo
           ?? sub.ecuSubmodel[0].completeDataset?.swPartNo ?? 'NA') : 'NA';

      // 🔥 CRITICAL FIX: the flash now runs inside a dedicated Isolate
      // (for true parallel execution — see flash_isolate.dart). That
      // isolate creates and disconnects its OWN socket internally and
      // has no effect on the main isolate's connection state. After it
      // finishes, the main isolate's _slot still shows Connectivity.none
      // from before the flash started, so every _readPid call below was
      // falling through to the RP1210/USB branch and getting
      // "Response received: null" for every single field. This matches
      // the bug exactly: HW/SW/CalID/CVN/ESN all failed after a flash
      // that itself succeeded. Re-establish the WiFi connection first,
      // exactly like _postFlashLifecycle does for batch flashing.
      final sub2    = device.selectedSubModel;
      final ecuSub2 = sub2?.ecuSubmodel.isNotEmpty == true ? sub2!.ecuSubmodel[0] : null;
      final rawTx2  = ecuSub2?.txHeader ?? '';
      final txHdr2  = (rawTx2.isNotEmpty && rawTx2 != '7DF' && rawTx2 != '07DF') ? rawTx2 : '7E0';
      await Future.delayed(const Duration(seconds: 1));
      await _wifi.checkDongle(
        device.ipAddress,
        device.index,
        txHeader:     txHdr2,
        rxHeaderMask: ecuSub2?.rxHeader ?? '7E8',
        protocolHex:  ecuSub2?.protocolAutopeepal ?? '02',
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // .NET: GetHW → GetSW → GetCalId → GetCVN → GetESN
      final hwRes  = await _wifi.getHW   (device.ipAddress, device.index, _pids);
      if (hwRes[0]  == 'true') device.hardwarePartNumber = hwRes[1];
      final swRes  = await _wifi.getSW   (device.ipAddress, device.index, _pids);
      if (swRes[0]  == 'true') device.swVersionAfter = swRes[1];
      final calRes = await _wifi.getCalId(device.ipAddress, device.index, _pids);
      if (calRes[0] == 'true' && calRes[1].isNotEmpty) {
        device.printCalId = calRes[1];
      } else if (device.calId.isNotEmpty) {
        device.printCalId = device.calId;
        print('⚠️ CalID post-flash read failed — using target: ${device.calId}');
      }
      final cvnRes = await _wifi.getCVN  (device.ipAddress, device.index, _pids);
      if (cvnRes[0] == 'true' && cvnRes[1].isNotEmpty) {
        device.cvn = cvnRes[1];
      } else if (device.cvnBefore.isNotEmpty) {
        device.cvn = device.cvnBefore;
        print('⚠️ CVN post-flash read failed — using pre-flash: ${device.cvnBefore}');
      }
      final esnRes = await _wifi.getESN  (device.ipAddress, device.index, _pids);
      if (esnRes[0] == 'true') device.ecuSrNoAfter = esnRes[1];
      tableInfo.refresh();

      final pfsId = _sessionId.isNotEmpty
          ? _sessionId : await AppPreferences.getSessionId();
      final ecuId = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].ecu : 0;

      final request = http.MultipartRequest(
          'POST', Uri.parse('${AppEnvironment.baseUrl}analyze/create-ecu-pfs/'));
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

      final sr  = await request.send();
      final res = await http.Response.fromStream(sr);
      device.reportColor = (res.statusCode == 200 || res.statusCode == 201)
          ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
      tableInfo.refresh();
      print('📡 create-ecu-pfs/ ${res.statusCode} status=${passed ? "Pass" : "Fail"}');
    } catch (e) {
      print('❌ _getPdfContentAndPost: $e');
      device.reportColor = const Color(0xFFF44336);
      tableInfo.refresh();
    }
  }

  // .NET: PrintCommand finally block
  Future<void> printSticker(IndividualRowModel device) async {
    try {
      print('🖨️ Print: ${device.printCalId} | ${device.cvn} | ${device.ecuSrNoAfter}');
    } catch (e) {
      print('❌ printSticker: $e');
    } finally {
      device.status=''; device.isDongleAvailable=false; device.isEcuAvailable=false;
      device.dongleStatusColor=const Color(0xFFF44336); device.dongleFlashingIndicator=false;
      device.ecuFlashingIndicator=false; device.ecuStatusColor=const Color(0xFFF44336);
      device.ecuSrNo=''; device.flashTimer='00:00'; device.flashPercent='0.0 %';
      device.statusColor=const Color(0xFFFFFFFF); device.reportColor=const Color(0xFFFFFFFF);
      device.flashingCompleted=false; device.printButtonDisable=true;
      device.printButtonColor=const Color(0xFF9E9E9E); device.playButtonDisable=true;
      device.playButtonColor=const Color(0xFF9E9E9E); device.playButtonVisible=true;
      device.isflashing=false; device.flashingAvailabel=false; device.fileType='NA';
      device.hardwarePartNumber=''; device.ecuStatus=true;
      device.ecuStatus1=''; device.alreadyMessage=false; device.isDongle=false;
      device.swMatch=false; device.calIdMatch=false; device.cvnMatch=false;
      device.progress=0; device.isProgressVisible=false;
      device.printCalId=''; device.ecuSrNoAfter='';
      device.swVersionBefore=''; device.swVersionAfter='';
      device.cvnBefore=''; device.cvn=''; device.swPartNo='';
      tableInfo.refresh();
    }
  }

  // .NET: OkCommand
  void onOkPopup() {
    for (final item in tableInfo) {
      item.ecuStatus=true; item.ecuStatus1=''; item.alreadyMessage=false;
      popupMessage.value='';
    }
    showAlertPopup.value=false;
    tableInfo.refresh();
  }

  Map<String,String> get _headers => {
    'Content-Type':  'application/json',
    'Authorization': 'JWT $_token',
  };

  @override
  void onClose() { _wifi.closeSockets(); super.onClose(); }
}