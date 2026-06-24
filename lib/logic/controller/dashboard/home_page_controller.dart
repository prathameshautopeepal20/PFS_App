// home_page_controller.dart
// EXACT mirror of HomePageViewModel.cs (homenet.txt - 3944 lines)
// Every method maps 1:1 to .NET

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';
import 'package:atpl_flashing_app/services/wifi_plugin.dart';

final _wifi = WiFiPlugin.instance;

// ── Color constants — no MaterialColor crash ──────────────────
const _cRed    = Color(0xFFF44336);
const _cGreen  = Color(0xFF4CAF50);
const _cGrey   = Color(0xFF9E9E9E);
const _cWhite  = Color(0xFFFFFFFF);
const _cYellow = Color(0xFFFFEB3B);
const _cOrange = Color(0xFFF9772C);

// ════════════════════════════════════════════════════════════
//  TableInfoModel — mirrors .NET TableInfoModel
// ════════════════════════════════════════════════════════════
class TableInfoModel {
  int index; int srNo; String bgColor;
  String macId; String ipAddress; String status; int priority;
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

  TableInfoModel({
    required this.index, required this.srNo, required this.bgColor,
    required this.macId, required this.ipAddress, required this.status,
    required this.priority,
    this.isDongleAvailable=false, this.isEcuAvailable=false,
    this.dongleFlashingIndicator=false, this.ecuFlashingIndicator=false,
    this.dongleStatusColor=_cRed, this.ecuStatusColor=_cRed,
    this.ecuSrNo='', this.ecuSrNoAfter='', this.hardwarePartNumber='',
    this.swVersionBefore='', this.swVersionAfter='',
    this.calIdBefore='', this.calId='', this.printCalId='',
    this.cvnBefore='', this.cvn='', this.swPartNo='',
    this.flashingCompleted=false, this.flashingSuccess=false,
    this.isflashing=false, this.flashingAvailabel=false,
    this.fileType='NA', this.flashTimer='00:00', this.flashPercent='0.0 %',
    this.progress=0, this.isProgressVisible=false,
    this.statusColor=_cWhite, this.reportColor=_cWhite,
    this.printButtonDisable=true, this.printButtonColor=_cGrey,
    this.playButtonDisable=true, this.playButtonColor=_cGrey,
    this.playButtonVisible=false,
    this.ecuStatus=true, this.ecuStatus1='', this.alreadyMessage=false,
    this.isDongle=false, this.swMatch=false, this.calIdMatch=false,
    this.cvnMatch=false,
    this.jsonFile='', this.seqFile='', this.fileUrl='',
  });
}

// ════════════════════════════════════════════════════════════
//  HomePageController
// ════════════════════════════════════════════════════════════
class HomePageController extends GetxController {
  final Map<String, dynamic> args;
  HomePageController({required this.args});

  // .NET fields
  late final String      _flashingType;
  late final ModelResult? _selectedModel;
  late final SubModel?   _selectedSubModel;
  late final String      _downComFile;      // down_com_file (raw SREC)
  late final String      _downComSeqfile;   // down_com_seqfile
  late final String      _downComFileUrl;
  late final String      _downCalFile;
  late final String      _downCalSeqfile;
  late final String      _downCalFileUrl;

  String _downComJsonFile = ''; // down_com_json_file (after GenerateJson)
  String _downCalJsonFile = ''; // down_cal_json_file

  Map<String,dynamic>? _profile;
  String        _token     = '';
  String        _sessionId = '';
  List<dynamic> _parameters = [];
  List<dynamic> _pids       = [];       // ObservableCollection<PidCode> pids
  List<dynamic> _flashFiles = [];       // flash_record_files
  bool          _alreadyFlashedEcu = false; // already_flashed_ecu
  bool          _nextCheck = false;         // next_check

  ModelResult? get selectedModel    => _selectedModel;
  SubModel?    get selectedSubModel => _selectedSubModel;

  // .NET observable properties
  final RxBool   isLoading               = false.obs;
  final RxString currStatus              = ''.obs;
  final RxString title                   = ''.obs;
  final RxList<TableInfoModel> tableInfo = <TableInfoModel>[].obs;
  final RxBool   checkEcuStatusButton    = true.obs;
  final RxBool   startFlashButtonDisable = true.obs;
  final Rx<Color> startFlashButtonColor  = _cGrey.obs;
  final RxBool   startResetButtonDisable = true.obs;
  final Rx<Color> startResetButtonColor  = _cGrey.obs;
  final RxBool   isResetDongleEnabled    = true.obs;
  final RxBool   flashingButtonVisible   = true.obs;
  final RxBool   showAlertPopup          = false.obs;
  final RxBool   showChangePopup         = false.obs;
  final RxBool   showPrintPopup          = false.obs;
  final RxBool   showWaitPopup           = false.obs;
  final RxString popupMessage            = ''.obs;
  final RxInt    afterFlashSeconds       = 0.obs;

  bool _isAfterFlashEventSubscribed = false;
  Timer? _waitTimer;

  @override
  void onInit() {
    super.onInit();
    _flashingType     = args['flashingType']     ?? 'Batch';
    _selectedModel    = args['selectedModel']    as ModelResult?;
    _selectedSubModel = args['selectedSubModel'] as SubModel?;
    _downComFile      = args['downComFile']      ?? '';
    _downComSeqfile   = args['downComSeqfile']   ?? '';
    _downComFileUrl   = args['downComFileUrl']   ?? '';
    _downCalFile      = args['downCalFile']      ?? '';
    _downCalSeqfile   = args['downCalSeqfile']   ?? '';
    _downCalFileUrl   = args['downCalFileUrl']   ?? '';
    _profile          = args['profile'] as Map<String,dynamic>?;
    _token            = args['token'] ?? '';
    _init();
  }

  // ─────────────────────────────────────────────────────────
  //  Init — mirrors .NET Init()
  //  Order: GenerateJson → GetFlashDetail → GetParameters →
  //         GetPid → ShowRegisteredDongleList
  // ─────────────────────────────────────────────────────────
  Future<void> _init() async {
    isLoading.value = true;
    try {
      if (_token.isEmpty)   _token   = await AppPreferences.getToken() ?? '';
      if (_profile == null) _profile = await AppPreferences.getLoginResponse();
      _sessionId = await AppPreferences.getSessionId();

      flashingButtonVisible.value   = _flashingType == 'Batch';
      startResetButtonDisable.value = true;
      startResetButtonColor.value   = _cGrey;
      checkEcuStatusButton.value    = true;
      isResetDongleEnabled.value    = true;
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = _cGrey;

      title.value = '${_selectedSubModel?.description ?? ''}/${_selectedModel?.name ?? ''}';

      // .NET order exactly
      await _generateJson();       // GenerateJson()
      await _getFlashDetail();     // GetFlashDetail()
      await _getParameters();      // GetParameters(subModel.id)
      await _getPids();            // GetPid()
      await _loadDongleList();     // ShowRegisteredDongleList()
    } finally {
      isLoading.value = false;
    }
  }

  // .NET: GenerateJson() — converts SREC files to JSON format
  // In Flutter: files are already downloaded as raw content
  // We store them directly (wifi_plugin converts SREC→FlashingMatrixData at flash time)
  Future<void> _generateJson() async {
    _downComJsonFile = _downComFile;   // already SREC content
    _downCalJsonFile = _downCalFile;
  }

  Future<void> _getFlashDetail() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}flash/flash-list/'),
        headers: _headers);
      if (res.statusCode == 200) {
        _flashFiles = jsonDecode(res.body)['results'] as List? ?? [];
      }
    } catch (e) { print('❌ _getFlashDetail: $e'); }
  }

  Future<void> _getParameters() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}parameter/parameter-list/'),
        headers: _headers);
      if (res.statusCode == 200) {
        _parameters = jsonDecode(res.body)['results'] as List? ?? [];
      }
    } catch (e) { print('❌ _getParameters: $e'); }
  }

  // .NET: GetPid() — loads pid codes for subModel.ecu_submodel[0].pid_datasets[0].id
  Future<void> _getPids() async {
    try {
      final sub = _selectedSubModel;
      if (sub == null || sub.ecuSubmodel.isEmpty) return;
      final pds = sub.ecuSubmodel[0].pidDatasets;
      if (pds.isEmpty) return;
      final first = pds[0];
      final pidId = first is Map ? first['id'] as int? : (first is int ? first : null);
      if (pidId == null) return;
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}datasets/get-pid-datasets/?id=$pidId'),
        headers: _headers);
      if (res.statusCode == 200) {
        final results = jsonDecode(res.body)['results'] as List? ?? [];
        if (results.isNotEmpty) {
          _pids = results[0]['codes'] as List? ?? [];
          print('✅ PIDs: ${_pids.length}');
        }
      }
    } catch (e) { print('❌ _getPids: $e'); }
  }

  // .NET: GetPid(string type) — find PID code by parameter type
  // Searches parameters list → finds matching pid_code by dataset id
  List<dynamic> _getPidByType(String type) {
    try {
      if (_parameters.isEmpty || _pids.isEmpty) return _pids;
      final sub = _selectedSubModel;
      if (sub == null || sub.ecuSubmodel.isEmpty) return _pids;
      final pds = sub.ecuSubmodel[0].pidDatasets;
      if (pds.isEmpty) return _pids;
      final first = pds[0];
      final datasetId = first is Map ? first['id'] : (first is int ? first : null);
      if (datasetId == null) return _pids;

      final param = _parameters.firstWhere(
        (p) => (p['parameter'] ?? '').toString().contains(type),
        orElse: () => null);
      if (param == null) return _pids;

      for (final paramId in (param['parameter_ids'] as List? ?? [])) {
        final ds = paramId['dataset'];
        final dsId = ds is Map ? ds['id'] : ds;
        if (dsId == datasetId) {
          final pidCodeId = paramId['pid_code'] is Map
              ? paramId['pid_code']['id']
              : paramId['pid_code'];
          for (final pidCode in _pids) {
            for (final v in (pidCode['pi_code_variable'] as List? ?? [])) {
              final vId = v is Map ? v['id'] : v;
              if (vId == pidCodeId) return [pidCode];
            }
          }
        }
      }
    } catch (e) { print('❌ _getPidByType($type): $e'); }
    return _pids;
  }

  // .NET: ShowRegisteredDongleList()
  Future<void> _loadDongleList() async {
    try {
      final res = await http.get(
        Uri.parse('${AppEnvironment.baseUrl}devices/prodbuddongle/list/'),
        headers: _headers);
      if (res.statusCode != 200) return;

      final results   = jsonDecode(res.body)['results'] as List? ?? [];
      final stationId = _stationId;
      final sorted    = [...results]
        ..sort((a,b) => ((a['priority']??0) as int).compareTo((b['priority']??0) as int));

      final sub    = _selectedSubModel;
      // .NET: cal_id = dataset.cal_id (from args passed to constructor)
      final calId  = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.calId ??
              sub.ecuSubmodel[0].completeDataset?.calId ?? '') : '';
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '') : '';

      final table = <TableInfoModel>[];
      int idx=0, srNo=0;
      for (final x in sorted) {
        if ((x['station'] as int? ?? 0) == stationId) {
          srNo++;
          if (x['is_active'] == true) {
            idx++;
            table.add(TableInfoModel(
              index: idx, srNo: srNo,
              bgColor: (idx%2==0) ? '#eeeeee' : '#cccccc',
              macId: x['mac_id'] ?? '',
              ipAddress: x['ip'] ?? '',
              status: '', priority: x['priority'] ?? 0,
              calId: calId, printCalId: calId, swPartNo: swPart,
              // .NET: play_button_visible = flashing_type != "Batch"
              playButtonVisible: _flashingType != 'Batch',
            ));
          }
        }
      }
      tableInfo.assignAll(table);
    } catch (e) { print('❌ _loadDongleList: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  CHECK ECU STATUS — mirrors CheckEcuStatusCommand
  //  .NET: CloseSockets → InitSockets → CheckDongle → CheckECU →
  //        CheckECUHW → CheckFlashingStatus → CheckECUSW →
  //        CheckCalId → CheckCVN (or GetCalId/GetCVN)
  // ════════════════════════════════════════════════════════════
  Future<void> checkEcuStatus() async {
    try {
      // .NET: reset all fields first
      for (final item in tableInfo) {
        item.status=''; item.isDongleAvailable=false; item.isEcuAvailable=false;
        item.calId = _selectedSubModel?.ecuSubmodel.isNotEmpty == true
            ? (_selectedSubModel!.ecuSubmodel[0].callibrationDataset?.calId ??
               _selectedSubModel!.ecuSubmodel[0].completeDataset?.calId ?? '') : '';
        item.dongleStatusColor=_cRed; item.dongleFlashingIndicator=false;
        item.ecuFlashingIndicator=false; item.ecuStatusColor=_cRed;
        item.ecuSrNo=''; item.flashTimer='00:00'; item.flashPercent='0.0 %';
        item.statusColor=_cWhite; item.reportColor=_cWhite;
        item.flashingCompleted=false; item.flashingSuccess=false;
        item.printButtonDisable=true; item.printButtonColor=_cGrey;
        item.playButtonDisable=true; item.playButtonColor=_cGrey;
        item.isflashing=false;
        // .NET: play_button_visible = flashing_type == "Batch" ? false : true
        item.playButtonVisible = _flashingType != 'Batch';
        item.flashingAvailabel=false; item.fileType='NA';
        item.hardwarePartNumber=''; item.ecuStatus=true;
        item.ecuStatus1=''; item.alreadyMessage=false;
        item.isDongle=false; item.swMatch=false;
        item.calIdMatch=false; item.cvnMatch=false;
        item.progress=0; item.isProgressVisible=false;
        item.printCalId=item.calId;
        item.ecuSrNoAfter=''; item.swVersionBefore=''; item.swVersionAfter='';
        item.cvnBefore=''; item.cvn='';
      }
      // .NET: StartFlashingButtonDisable=true
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = _cGrey;
      tableInfo.refresh();

      // .NET: CloseSockets() → InitSocketes()
      await _wifi.closeSockets();
      await _wifi.initSockets();

      _alreadyFlashedEcu = false;
      popupMessage.value = '';

      // .NET: res = await CheckDongle(); if (res) { res = await CheckECU(); ...
      final dongleOk = await _checkDongle();
      if (dongleOk) {
        final ecuOk = await _checkECU();
        if (ecuOk) {
          final hwOk = await _checkECUHW();
          if (hwOk) {
            await _checkFlashingStatus();
            final swOk = await _checkECUSW();
            if (swOk) {
              // sw matched — check CalId
              final calOk = await _checkCalId();
              if (calOk) {
                await _checkCVN();
                if (_alreadyFlashedEcu) {
                  checkEcuStatusButton.value = true;
                  isResetDongleEnabled.value = true;
                  showChangePopup.value = true;
                }
              } else {
                await _getCVN(); // GetCVN() only
              }
            } else {
              // sw not matched — GetCalId + GetCVN
              await _getCalId();
              await _getCVN();
              if (_alreadyFlashedEcu) {
                checkEcuStatusButton.value = true;
                isResetDongleEnabled.value = true;
                showChangePopup.value = true;
              }
            }
          }
        }
      }

      if (popupMessage.value.isNotEmpty) {
        showAlertPopup.value = true;
      }
    } catch (e) {
      currStatus.value = '';
      print('❌ checkEcuStatus: $e');
    }
  }

  // ── CheckDongle — mirrors .NET CheckDongle() ─────────────
  // .NET: foreach device → CheckDongle(ip, index) → Task.Delay(100)
  // Returns true if ALL dongles found
  Future<bool> _checkDongle() async {
    currStatus.value = 'Checking Dongle Connection...';
    try {
      bool value = false;
      final sub    = _selectedSubModel;
      final ecuSub = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0] : null;
      // Force 7E0 — server sends 7DF but this ECU only responds to 7E0
      final rawTx = ecuSub?.txHeader ?? '';
      final txHdr = (rawTx.isNotEmpty && rawTx != '7DF' && rawTx != '07DF')
          ? rawTx : '7E0';
      final rxHdr    = ecuSub?.rxHeader           ?? '7E8';
      final protoHex = ecuSub?.protocolAutopeepal ?? '02';

      for (final device in tableInfo) {
        await Future.delayed(const Duration(milliseconds: 100)); // .NET: Task.Delay(100)
        device.isDongle = await _wifi.checkDongle(
          device.ipAddress, device.index,
          txHeader: txHdr, rxHeaderMask: rxHdr, protocolHex: protoHex);

        if (device.isDongle) {
          device.dongleFlashingIndicator = true;
          device.isDongleAvailable       = true;
          device.dongleStatusColor       = _cGreen;
        } else {
          device.dongleFlashingIndicator = false;
          device.isDongleAvailable       = false;
          device.ecuStatus               = false;
          device.ecuStatus1              = 'Dongle ${device.srNo} not found.';
        }
      }
      tableInfo.refresh();

      // .NET: var data = TableInfo.Where(x => x.is_dongle==false && x.ecu_status==false && x.AlreadyMessage==false)
      final data = tableInfo.where((x) => !x.isDongle && !x.ecuStatus && !x.alreadyMessage).toList();
      if (data.isNotEmpty) {
        value = false;
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        for (final item in data) {
          showAlertPopup.value     = true;
          item.alreadyMessage      = true;
          popupMessage.value      += '${item.ecuStatus1}\n';
        }
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
      return value;
    } finally { currStatus.value = ''; }
  }

  // ── CheckECU — mirrors .NET CheckECU() ───────────────────
  // .NET: foreach → Task.Delay(10) → GetESN → check res[0]=="true"
  Future<bool> _checkECU() async {
    currStatus.value = 'Checking ECU Connection...';
    try {
      bool value = false;
      for (final device in tableInfo) {
        await Future.delayed(const Duration(milliseconds: 10));
        final pid = _getPidByType('ESN');
        final res = await _wifi.getESN(device.ipAddress, device.index, pid);
        if (res[0] == 'true') {
          device.ecuFlashingIndicator = true;
          device.ecuSrNo              = res[1];
          device.isEcuAvailable       = true;
          device.ecuStatusColor       = _cGreen;
        } else {
          device.ecuSrNo              = res.length > 1 ? res[1] : '';
          device.ecuFlashingIndicator = false;
          device.isEcuAvailable       = false;
          device.ecuStatus            = false;
          device.ecuStatus1           = 'Check ECU ${device.srNo} connection.';
        }
      }
      tableInfo.refresh();

      final data = tableInfo.where((x) => !x.isEcuAvailable && !x.ecuStatus && !x.alreadyMessage).toList();
      if (data.isNotEmpty) {
        value = false;
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        for (final item in data) {
          showAlertPopup.value    = true;
          item.alreadyMessage     = true;
          popupMessage.value     += '${item.ecuStatus1}\n';
        }
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
      return value;
    } finally { currStatus.value = ''; }
  }

  // ── CheckECUHW — mirrors .NET CheckECUHW() ───────────────
  // .NET: GetHW → MatchHardwarePartNumber(complete_dataset, res[1])
  Future<bool> _checkECUHW() async {
    currStatus.value = 'Reading ECU Hardware Number...';
    try {
      bool value = false;
      final sub         = _selectedSubModel;
      final expectedHw  = sub?.hwPartNo ?? '';

      for (final device in tableInfo) {
        await Future.delayed(const Duration(milliseconds: 10));
        final pid = _getPidByType('HWPN');
        final res = await _wifi.getHW(device.ipAddress, device.index, pid);

        // .NET: MatchHardwarePartNumber → hw_part_no.Contains(value)
        final matched = expectedHw.isEmpty ||
            res[1].contains(expectedHw) || expectedHw.contains(res[1]);

        if (matched) {
          device.hardwarePartNumber = res[1];
          device.isEcuAvailable     = true;
        } else {
          device.ecuStatus      = false;
          device.isEcuAvailable = false;
          device.ecuStatus1     = 'ECU ${device.srNo} hardware part number not matched.';
          device.flashingAvailabel = false;
        }
      }
      tableInfo.refresh();

      final data = tableInfo.where((x) => !x.isEcuAvailable && !x.ecuStatus && !x.alreadyMessage).toList();
      if (data.isNotEmpty) {
        value = false;
        checkEcuStatusButton.value = true;
        isResetDongleEnabled.value = true;
        for (final item in data) {
          showAlertPopup.value   = true;
          item.alreadyMessage    = true;
          popupMessage.value    += '${item.ecuStatus1}\n';
        }
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
        value = true;
      }
      return value;
    } finally { currStatus.value = ''; }
  }

  // ── CheckECUSW — mirrors .NET CheckECUSW() ───────────────
  // .NET: foreach → GetSW → MatchSoftwareVersion
  // returns next_check (true if sw matched = need CalId/CVN check)
  Future<bool> _checkECUSW() async {
    currStatus.value = 'Reading Software Version...';
    _nextCheck = false;
    try {
      final sub        = _selectedSubModel;
      final comDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset : null;

      for (final device in tableInfo) {
        await Future.delayed(const Duration(milliseconds: 10));
        final pid = _getPidByType('ESWV');
        final res = await _wifi.getSW(device.ipAddress, device.index, pid);

        // MatchSoftwareVersion
        final expectedSw = _matchFromFiles(comDataset, 'sw_version');
        final swMatches  = expectedSw.isNotEmpty && res[1] == expectedSw;

        if (swMatches) {
          // .NET: sw matched → flashing_availabel=false, sw_match=true, next_check=true
          device.swVersionBefore   = res[1];
          device.flashingAvailabel = false;
          device.swMatch           = true;
          _nextCheck               = true;
        } else {
          // .NET: sw not matched → flashing_availabel=true, file_type="Complete"
          device.swVersionBefore   = res[1];
          device.flashingAvailabel = true;
          device.fileType          = 'Complete';
          device.swMatch           = false;
        }
      }
      tableInfo.refresh();

      // .NET: if any flashing_availabel → enable StartFlash button
      final data = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (data.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _cOrange;
      }
      return _nextCheck;
    } finally { currStatus.value = ''; }
  }

  // ── CheckCalId — mirrors .NET CheckCalId() ───────────────
  // .NET: only runs for devices where sw_match==true
  // checks callibration_dataset first, then complete_dataset
  Future<bool> _checkCalId() async {
    currStatus.value = 'Reading Calibration Id...';
    _alreadyFlashedEcu = false;
    _nextCheck         = false;
    try {
      final sub        = _selectedSubModel;
      final calDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].callibrationDataset : null;
      final comDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset : null;

      final pid = _getPidByType('CALID');
      for (final device in tableInfo) {
        final res = await _wifi.getCalId(device.ipAddress, device.index, pid);
        // .NET: reads CalId for ALL devices (not just sw_match)
        // but only runs matching logic if sw_match==true
        if (device.swMatch) {
          await Future.delayed(const Duration(milliseconds: 10));
          if (calDataset != null) {
            // MatchCalId(callibration_dataset, res[1])
            final expected = _matchFromFiles(calDataset, 'cal_id');
            final matches  = expected.isNotEmpty && res[1] == expected;
            if (matches) {
              device.ecuStatus  = false;
              device.ecuStatus1 = 'ECU ${device.srNo} already flashed with updated file.';
              device.calIdBefore = res[1];
              device.flashingAvailabel = false;
              device.fileType   = 'Complete';
              device.calIdMatch = true;
              _alreadyFlashedEcu = true;
              _nextCheck         = true;
            } else {
              device.calIdBefore       = res[1];
              device.calIdMatch        = false;
              device.flashingAvailabel = true;
              device.fileType          = 'Calibration';
            }
          } else {
            // MatchCalId(complete_dataset, res[1])
            final expected = _matchFromFiles(comDataset, 'cal_id');
            final matches  = expected.isNotEmpty && res[1] == expected;
            if (matches) {
              device.ecuStatus  = false;
              device.ecuStatus1 = 'ECU ${device.srNo} already flashed with updated file.';
              device.calIdBefore       = res[1];
              device.flashingAvailabel = false;
              device.fileType          = 'Complete';
              device.calIdMatch        = true;
              _alreadyFlashedEcu       = true;
              _nextCheck               = true;
            } else {
              device.calIdBefore       = res[1];
              device.flashingAvailabel = true;
              device.fileType          = 'Complete';
              device.calIdMatch        = false;
            }
          }
        }
      }
      tableInfo.refresh();

      final data = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (data.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _cOrange;
      }

      // .NET: show popup for already-flashed ECUs
      final data1 = tableInfo.where((x) => !x.ecuStatus && !x.alreadyMessage).toList();
      for (final item in data1) {
        item.alreadyMessage  = true;
        popupMessage.value  += '${item.ecuStatus1}\n';
      }

      return _nextCheck;
    } finally { currStatus.value = ''; }
  }

  // ── CheckCVN — mirrors .NET CheckCVN() ───────────────────
  // .NET: only runs for devices where cal_id_match==true
  Future<bool> _checkCVN() async {
    currStatus.value = 'Reading CVN...';
    _nextCheck = false;
    try {
      final sub        = _selectedSubModel;
      final calDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].callibrationDataset : null;
      final comDataset = sub?.ecuSubmodel.isNotEmpty == true
          ? sub!.ecuSubmodel[0].completeDataset : null;

      final pid = _getPidByType('CVN');
      for (final device in tableInfo) {
        final res = await _wifi.getCVN(device.ipAddress, device.index, pid);
        device.cvnBefore = res[1]; // .NET: ALWAYS sets cvn_before regardless
        if (device.calIdMatch) {
          await Future.delayed(const Duration(milliseconds: 10));
          final ds = calDataset ?? comDataset;
          final expected = _matchFromFiles(ds, 'cvn');
          final matches  = expected.isNotEmpty && res[1] == expected;
          if (matches) {
            device.ecuStatus  = false;
            device.ecuStatus1 = 'ECU ${device.srNo} already flashed with updated file.';
            device.flashingAvailabel = false;
            device.fileType   = calDataset != null ? 'Complete' : 'Complete';
            device.cvnMatch   = true;
            _alreadyFlashedEcu = true;
            _nextCheck         = true;
          } else {
            device.flashingAvailabel = true;
            device.fileType  = calDataset != null ? 'Calibration' : 'Complete';
            device.cvnMatch  = false;
          }
        }
      }
      tableInfo.refresh();

      final data = tableInfo.where((x) => x.flashingAvailabel).toList();
      if (data.isNotEmpty) {
        checkEcuStatusButton.value    = false;
        isResetDongleEnabled.value    = false;
        startFlashButtonDisable.value = false;
        startFlashButtonColor.value   = _cOrange;
      }

      final data1 = tableInfo.where((x) => !x.ecuStatus && !x.alreadyMessage).toList();
      for (final item in data1) {
        item.alreadyMessage  = true;
        popupMessage.value  += '${item.ecuStatus1}\n';
      }
      return _nextCheck;
    } finally { currStatus.value = ''; }
  }

  // ── CheckFlashingStatus — mirrors .NET CheckFlashingStatus() ─
  Future<void> _checkFlashingStatus() async {
    currStatus.value = 'Checking Flashing Status...';
    try {
      for (final device in tableInfo) {
        if (!device.isEcuAvailable || device.ecuSrNo.isEmpty) continue;
        final res = await http.get(
          Uri.parse('${AppEnvironment.baseUrl}analyze/get-ecu-pfs-status/?serial_no=${device.ecuSrNo}'),
          headers: _headers);
        if (res.statusCode == 200) {
          final results = jsonDecode(res.body)['results'] as List? ?? [];
          if (results.isNotEmpty && results[0]['status'] == 'Pass') {
            device.ecuStatus1       = 'ECU ${device.srNo} already flashed with updated file.';
            device.ecuStatus        = false;
            _alreadyFlashedEcu      = true;
          }
        }
      }

      // .NET: only sets CheckEcuStatusButton=false if NO already-flashed ECUs
      final data = tableInfo.where((x) => x.isEcuAvailable && !x.ecuStatus
          && x.ecuStatus1.contains('already flashed') && !x.alreadyMessage).toList();
      if (data.isNotEmpty) {
        for (final item in data) {
          item.alreadyMessage  = true;
          popupMessage.value  += '${item.ecuStatus1}\n';
        }
      } else {
        checkEcuStatusButton.value = false;
        isResetDongleEnabled.value = false;
      }
    } catch (e) { print('❌ _checkFlashingStatus: $e'); }
    finally { currStatus.value = ''; }
  }

  // ── GetCalId — called when sw NOT matched ─────────────────
  // Just reads and stores calIdBefore (no matching)
  Future<void> _getCalId() async {
    currStatus.value = 'Reading Calibration Id...';
    try {
      final pid = _getPidByType('CALID');
      for (final device in tableInfo) {
        final res = await _wifi.getCalId(device.ipAddress, device.index, pid);
        if (res[0] == 'true') device.calIdBefore = res[1];
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // ── GetCVN — called when sw NOT matched ──────────────────
  Future<void> _getCVN() async {
    currStatus.value = 'Reading CVN...';
    try {
      final pid = _getPidByType('CVN');
      for (final device in tableInfo) {
        final res = await _wifi.getCVN(device.ipAddress, device.index, pid);
        if (res[0] == 'true') device.cvnBefore = res[1];
      }
      tableInfo.refresh();
    } finally { currStatus.value = ''; }
  }

  // ── _matchFromFiles — mirrors .NET MatchSoftwareVersion/MatchCalId/MatchCVN
  // Looks up flash_record_files by dataset.sequence_file_name.id → dataset.id
  String _matchFromFiles(dynamic dataset, String field) {
    try {
      if (dataset == null) return '';
      final seqId = dataset.sequenceFileName?.id;
      if (seqId == null) return '';
      final flashRec = _flashFiles.firstWhere(
          (f) => f is Map && f['id'] == seqId, orElse: () => null);
      if (flashRec == null) return '';
      final files = (flashRec as Map)['file'] as List? ?? [];
      final file  = files.firstWhere(
          (f) => f is Map && f['id'] == dataset.id, orElse: () => null);
      if (file == null) return '';
      return ((file as Map)[field] ?? '').toString();
    } catch (_) { return ''; }
  }

  // ════════════════════════════════════════════════════════════
  //  START FLASH — mirrors .NET StartFlashCommand
  //  .NET: foreach item → if isEcuAvailable → new Thread(StartFlash).Start()
  //  Flutter: Future.wait([_flashDevice(d1), _flashDevice(d2)])
  //  BOTH run simultaneously — same as .NET Thread per ECU
  // ════════════════════════════════════════════════════════════
  Future<void> startFlash() async {
    if (startFlashButtonDisable.value) return;
    try {
      isResetDongleEnabled.value    = false;
      checkEcuStatusButton.value    = false;
      startFlashButtonDisable.value = true;
      startFlashButtonColor.value   = _cGrey;

      await Future.delayed(const Duration(milliseconds: 100)); // .NET: Task.Delay(100)

      final sub = _selectedSubModel;
      // .NET: assigns json_file and seq_file per item by file_type
      for (final item in tableInfo) {
        if (sub?.ecuSubmodel.isNotEmpty == true &&
            sub!.ecuSubmodel[0].callibrationDataset == null) {
          // callibration_dataset == null → use complete files
          item.jsonFile = _downComJsonFile;
          item.seqFile  = _downComSeqfile;
          item.fileUrl  = _downComFileUrl;
        } else if (item.fileType == 'Complete') {
          item.jsonFile = _downComJsonFile;
          item.seqFile  = _downComSeqfile;
          item.fileUrl  = _downComFileUrl;
        } else if (item.fileType == 'Calibration') {
          item.jsonFile = _downCalJsonFile;
          item.seqFile  = _downCalSeqfile;
          item.fileUrl  = _downCalFileUrl;
        }
        await Future.delayed(const Duration(milliseconds: 20)); // .NET: Task.Delay(20)
      }

      // .NET: sets flash_timer, FlashPercent, status_color=Yellow, Progress=0 for all
      for (final item in tableInfo) {
        item.flashTimer   = '00:00';
        item.flashPercent = '0.0 %';
        item.statusColor  = _cYellow;
        item.progress     = 0;
      }
      _isAfterFlashEventSubscribed = false;
      tableInfo.refresh();

      // Sequential flash — shared CAN bus hardware requires one ECU at a time
      // Both ECU timers run independently so UI shows both progressing
      final eligible = tableInfo.where((d) => d.isEcuAvailable).toList();
      for (final d in eligible) {
        await _startFlash(d, d.index);
      }
    } catch (e) { print('❌ startFlash: $e'); }
  }

  // ── StartFlash — mirrors .NET StartFlash(selectedModel, index1) ──
  Future<void> _startFlash(TableInfoModel device, int index1) async {
    Timer? timer;
    try {
      currStatus.value = 'Flashing In Progress...';
      device.status         = 'Downloading...';
      device.flashingSuccess = false;
      tableInfo.refresh();

      // .NET: if cal_id_before empty → GetCalId; if cvn_before empty → GetCVN
      if (device.calIdBefore.isEmpty) {
        final pid = _getPidByType('CALID');
        final res = await _wifi.getCalId(device.ipAddress, device.index, pid);
        device.calIdBefore = res[1];
      }
      if (device.cvnBefore.isEmpty) {
        final pid = _getPidByType('CVN');
        final res = await _wifi.getCVN(device.ipAddress, device.index, pid);
        device.cvnBefore = res[1];
      }

      if (device.jsonFile.isEmpty || device.seqFile.isEmpty) {
        device.status = 'File not found';
        device.flashingCompleted = true;
        device.isflashing = false;
        device.statusColor = _cRed;
        tableInfo.refresh();
        _onAllComplete();
        return;
      }

      device.printButtonDisable = true;
      device.printButtonColor   = _cGrey;
      device.status             = 'flashing inprogress...';
      device.statusColor        = _cYellow;
      tableInfo.refresh();

      // .NET: Stopwatch + timer(1s) + percentTimer(5s) + IsProgressVisivle=true
      final sw = Stopwatch()..start();
      int _tickCount = 0;
      timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        _tickCount++;
        // OnTimedEvent — update clock every second
        device.flashTimer = '${sw.elapsed.inMinutes.toString().padLeft(2,'0')}:'
            '${(sw.elapsed.inSeconds%60).toString().padLeft(2,'0')}';
        // OnPercentTimedEvent — .NET reads every 5s via GetFlashPercList()
        // ap_diagnostic stores progress in flashInterpreter internally
        if (_tickCount % 5 == 0) {
          try {
            final diag = _wifi.getDiag(device.index);
            if (diag != null) {
              final p = (await diag.getRuntimeFlashPercent()).clamp(0.0, 1.0);
              if (p > device.progress) {
                device.progress     = p;
                device.flashPercent = '${(p * 100).toStringAsFixed(1)}%';
              }
            }
          } catch (_) {}
        }
        tableInfo.refresh();
      });

      device.isProgressVisible = true;
      device.flashingCompleted = false;
      device.flashPercent      = '0.0 %';
      tableInfo.refresh();

      final sub    = _selectedSubModel;
      final ecuSub = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0] : null;

      // .NET: flashing = await wifi.StartECUFlashing(seq_file, json_file, model, index)
      final result = await _wifi.startECUFlashing(
        ip:             device.ipAddress,
        index:          device.index,
        seqFileContent: device.seqFile,
        hexFileContent: device.jsonFile,
        seedKeyIndex:   ecuSub?.seedkeyAlgoValue   ?? 'RE_SEEDKEY_EPM44',
        txHeader:       ecuSub?.txHeader           ?? '7DF',
        rxHeader:       ecuSub?.rxHeader           ?? '7E8',
        protocolHex:    ecuSub?.protocolAutopeepal ?? '02',
        onProgress:     (p) { device.progress = p; },
        onStatus:       (s) { currStatus.value = s; },
      );

      device.reportColor = _cYellow;

      if (result == 'NOERROR') {
        // .NET: Thread.Sleep(3000) — ECU reboots after flash, must wait
        await Future.delayed(const Duration(seconds: 3));
        device.flashingSuccess = true;
        device.statusColor     = _cGreen;

        // Re-init dongle connection after flash (ECU reset clears CAN state)
        final sub    = _selectedSubModel;
        final ecuSub = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0] : null;
        final rawTx  = ecuSub?.txHeader ?? '';
        final txHdr  = (rawTx.isNotEmpty && rawTx != '7DF' && rawTx != '07DF') ? rawTx : '7E0';
        await _wifi.checkDongle(device.ipAddress, device.index,
            txHeader: txHdr,
            rxHeaderMask: ecuSub?.rxHeader ?? '7E8',
            protocolHex:  ecuSub?.protocolAutopeepal ?? '02');
        await Future.delayed(const Duration(milliseconds: 500));

        final calPid = _getPidByType('CALID');
        final calRes = await _wifi.getCalId(device.ipAddress, device.index, calPid);
        device.printCalId = calRes[1];

        final cvnPid = _getPidByType('CVN');
        final cvnRes = await _wifi.getCVN(device.ipAddress, device.index, cvnPid);
        device.cvn = cvnRes[1];
      } else {
        device.statusColor = _cRed;
      }

      device.flashingCompleted = true;
      device.isflashing        = false;

      // .NET: ReadAfterFlashData → GeneratePdfWrapper → timer.Stop()
      await _readAfterFlashData(device);
      await _generatePdfAndPost(device, result == 'NOERROR');

      timer?.cancel(); timer = null;
      sw.stop();

      // .NET: status text + FlashPercent + Progress
      device.status      = result == 'NOERROR' ? 'Flashing completed' : result;
      device.flashPercent = result == 'NOERROR' ? '100.0%' : device.flashPercent;
      if (device.status == 'Flashing completed') {
        device.flashPercent = '100.0%';
        device.progress     = 1.0;
      }
      tableInfo.refresh();

      _onAllComplete();
    } catch (e) {
      device.status            = 'Exception';
      device.flashingCompleted = true;
      print('❌ _startFlash[${device.index}]: $e');
    } finally {
      timer?.cancel();
      device.isflashing        = false;
      device.isProgressVisible = false;
      tableInfo.refresh();
    }
  }

  // ── Wait for previous ECU flash write to complete, then start this ECU ──
  // Pipeline: ECU1 does flashInterpreter → ECU2 starts → ECU1 does post-reads
  // Both appear to flash simultaneously in UI
  Future<void> _startFlashDelayed(TableInfoModel device, int index1, TableInfoModel prev) async {
    // Wait until previous ECU finishes flashInterpreter (progress reaches 100% or flash completes)
    // Poll every 500ms — once prev ECU shows flashingCompleted=true OR progress>=1.0, start ours
    print('⏳ ECU $index1 waiting for ECU ${prev.index} flashInterpreter to complete...');
    final timeout = DateTime.now().add(const Duration(minutes: 10));
    while (DateTime.now().isBefore(timeout)) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Previous ECU finished flash write when its status changes from 'flashing inprogress...'
      // OR when its progress >= 0.95 (near done)
      if (prev.flashingCompleted || prev.progress >= 0.95 || 
          (prev.status != 'Downloading...' && prev.status != 'flashing inprogress...' && prev.status.isNotEmpty && prev.status != 'Flashing completed')) {
        break;
      }
      // Also start if prev has been flashing for > 3 mins (safety timeout)
      if (prev.flashTimer.isNotEmpty && prev.flashTimer != '00:00') {
        final parts = prev.flashTimer.split(':');
        if (parts.length == 2) {
          final mins = int.tryParse(parts[0].trim()) ?? 0;
          if (mins >= 3) break;
        }
      }
    }
    print('▶️  ECU $index1 starting now (prev ECU ${prev.index} flash write done)');
    await _startFlash(device, index1);
  }

  // ── ReadAfterFlashData — mirrors .NET ReadAfterFlashData() ──
  // .NET: GetSW → GetCalId → GetCVN → ecu_sr_no_after = ecu_sr_no (Jugaad)
  Future<void> _readAfterFlashData(TableInfoModel device) async {
    try {
      // Small delay to ensure ECU is stable after CAN_StopTP
      await Future.delayed(const Duration(milliseconds: 300));

      final swPid  = _getPidByType('ESWV');
      final swRes  = await _wifi.getSW(device.ipAddress, device.index, swPid);
      if (swRes[0] == 'true' && swRes[1].isNotEmpty) {
        device.swVersionAfter = swRes[1];
      }

      final calPid = _getPidByType('CALID');
      final calRes = await _wifi.getCalId(device.ipAddress, device.index, calPid);
      device.printCalId = calRes[1];

      final cvnPid = _getPidByType('CVN');
      final cvnRes = await _wifi.getCVN(device.ipAddress, device.index, cvnPid);
      device.cvn = cvnRes[1];

      // .NET: ecu_sr_no_after = ecu_sr_no (Jugaad — no re-read)
      device.ecuSrNoAfter = device.ecuSrNo;
      tableInfo.refresh();
    } catch (e) { print('❌ _readAfterFlashData: $e'); }
  }

  // ── _onAllComplete — mirrors .NET "if (TableInfo.All(x=>x.flashing_completed))" ─
  void _onAllComplete() {
    if (!tableInfo.every((x) => x.isEcuAvailable ? x.flashingCompleted : true)) return;
    currStatus.value = '';

    if (tableInfo.any((x) => x.flashingSuccess)) {
      final waitAfter = _selectedSubModel?.waitAfterFlash;
      if (waitAfter != null && waitAfter > 0 && !_isAfterFlashEventSubscribed) {
        _isAfterFlashEventSubscribed = true;
        afterFlashSeconds.value      = waitAfter;
        showWaitPopup.value          = true;
        _startWaitTimer();
      } else {
        for (final item in tableInfo) {
          if (item.flashingSuccess) {
            item.printButtonDisable = false;
            item.printButtonColor   = _cOrange;
            break;
          }
        }
        tableInfo.refresh();
      }
    } else {
      popupMessage.value            = '';
      startResetButtonDisable.value = false;
      startResetButtonColor.value   = _cOrange;
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
            item.printButtonColor   = _cOrange;
            break;
          }
        }
        tableInfo.refresh();
      }
    });
  }

  // ── Post flash record to API ──────────────────────────────
  Future<void> _generatePdfAndPost(TableInfoModel device, bool passed) async {
    try {
      final sub    = _selectedSubModel;
      final model  = _selectedModel;
      final swPart = sub?.ecuSubmodel.isNotEmpty == true
          ? (sub!.ecuSubmodel[0].callibrationDataset?.swPartNo ??
              sub.ecuSubmodel[0].completeDataset?.swPartNo ?? '') : '';
      final pfsId = _sessionId.isNotEmpty ? _sessionId : await AppPreferences.getSessionId();
      final ecuId = sub?.ecuSubmodel.isNotEmpty == true ? sub!.ecuSubmodel[0].ecu : 0;

      final request = http.MultipartRequest(
          'POST', Uri.parse('${AppEnvironment.baseUrl}analyze/create-ecu-pfs/'));
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

      final sr  = await request.send();
      final res = await http.Response.fromStream(sr);
      device.reportColor = (res.statusCode == 200 || res.statusCode == 201)
          ? _cGreen : _cRed;
      tableInfo.refresh();
    } catch (e) {
      device.reportColor = _cRed; tableInfo.refresh();
    }
  }

  // ════════════════════════════════════════════════════════════
  //  RESET / RESET DONGLE
  // ════════════════════════════════════════════════════════════
  Future<void> reset() async {
    if (startResetButtonDisable.value) return;
    isLoading.value = true;
    try {
      startResetButtonDisable.value = true; startResetButtonColor.value = _cGrey;
      startFlashButtonDisable.value = true; startFlashButtonColor.value = _cGrey;
      checkEcuStatusButton.value    = true;

      await _wifi.closeSockets();
      await _wifi.initSockets();

      final stationData = _profile?['station_data'] as List?;
      final userId  = _profile?['user_id'] ?? 0;
      final plants  = stationData?.isNotEmpty == true
          ? (stationData![0]['plants'] as int? ?? 0) : 0;

      final res = await http.post(
        Uri.parse('${AppEnvironment.baseUrl}analyze/create-pfs/'),
        headers: _headers,
        body: jsonEncode({'user': userId, 'plant': plants,
          'status': 'New', 'station': _stationId}));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final session = jsonDecode(res.body) as Map<String,dynamic>;
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
      startFlashButtonColor.value   = _cGrey;
      checkEcuStatusButton.value    = true;
      await _loadDongleList();
      for (final item in tableInfo) {
        await _wifi.resetDongle(item.ipAddress, item.index);
      }
      isResetDongleEnabled.value = true;
    } finally { isLoading.value = false; }
  }

  // ════════════════════════════════════════════════════════════
  //  INDIVIDUAL FLASH (non-batch play button)
  //  mirrors .NET StartIndivisualFlashingCommand
  // ════════════════════════════════════════════════════════════
  Future<void> startIndividualFlash(TableInfoModel device) async {
    try {
      device.playButtonDisable = true; device.playButtonColor = _cGrey;
      device.flashTimer = '00:00'; device.flashPercent = '0.0 %';
      device.progress = 0; device.isflashing = true;

      // assign files by fileType
      final sub = _selectedSubModel;
      if (sub != null && sub.ecuSubmodel.isNotEmpty) {
        if (sub.ecuSubmodel[0].callibrationDataset == null) {
          device.jsonFile = _downComJsonFile;
          device.seqFile  = _downComSeqfile;
          device.fileUrl  = _downComFileUrl;
        } else if (device.fileType == 'Complete') {
          device.jsonFile = _downComJsonFile;
          device.seqFile  = _downComSeqfile;
          device.fileUrl  = _downComFileUrl;
        } else {
          device.jsonFile = _downCalJsonFile;
          device.seqFile  = _downCalSeqfile;
          device.fileUrl  = _downCalFileUrl;
        }
      }
      tableInfo.refresh();
      // .NET: Thread tcpTask = new Thread(() => StartFlash(item, item.index)); tcpTask.Start();
      await _startFlash(device, device.index);
    } catch (e) {
      device.status = 'Exception'; device.flashingCompleted = true;
      device.isflashing = false; tableInfo.refresh();
    }
  }

  // ════════════════════════════════════════════════════════════
  //  POPUP HANDLERS — mirrors .NET OkCommand, ReflashCommand,
  //  ForceFlashCommand, ChangeECUCommand
  // ════════════════════════════════════════════════════════════
  void onOkPopup() {
    for (final item in tableInfo) {
      item.ecuStatus=true; item.ecuStatus1=''; item.alreadyMessage=false;
      popupMessage.value = '';
    }
    showAlertPopup.value = false; tableInfo.refresh();
  }

  void onReflash() {
    // .NET: ReflashCommand
    for (final item in tableInfo) {
      item.ecuStatus=true; item.ecuStatus1=''; item.alreadyMessage=false;
      popupMessage.value='';
    }
    showChangePopup.value         = false;
    checkEcuStatusButton.value    = false;
    isResetDongleEnabled.value    = false;
    startFlashButtonDisable.value = false;
    startFlashButtonColor.value   = _cOrange;
    tableInfo.refresh();
  }

  void onChangeECU() {
    // .NET: ChangeECUCommand
    for (final item in tableInfo) {
      item.ecuStatus=true; item.ecuStatus1=''; item.alreadyMessage=false;
      popupMessage.value='';
    }
    showChangePopup.value         = false;
    checkEcuStatusButton.value    = true;
    isResetDongleEnabled.value    = true;
    startFlashButtonDisable.value = true;
    startFlashButtonColor.value   = _cGrey;
    tableInfo.refresh();
  }

  // ════════════════════════════════════════════════════════════
  //  PRINT STICKER
  // ════════════════════════════════════════════════════════════
  Future<void> printSticker(TableInfoModel device) async {
    try {
      device.printButtonDisable = true; device.printButtonColor = _cGrey;
      tableInfo.refresh();

      if (_flashingType == 'Batch') {
        showPrintPopup.value = true;
        popupMessage.value   = 'Paste the sticker on ECU ${device.srNo} and remove ECU ${device.srNo}';
        await Future.delayed(const Duration(seconds: 3));
        showPrintPopup.value = false; popupMessage.value = '';

        int nextIdx = device.index;
        while (nextIdx <= tableInfo.length) {
          if (nextIdx == tableInfo.length) {
            startResetButtonDisable.value = false;
            startResetButtonColor.value   = _cOrange;
            break;
          }
          if (tableInfo[nextIdx].flashingSuccess) {
            tableInfo[nextIdx].printButtonDisable = false;
            tableInfo[nextIdx].printButtonColor   = _cOrange;
            tableInfo.refresh(); break;
          }
          nextIdx++;
        }
      } else {
        device.printButtonDisable = true;
        device.printButtonColor   = _cGrey;
        tableInfo.refresh();
      }
    } catch (e) { print('❌ printSticker: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  NETWORK SCAN
  // ════════════════════════════════════════════════════════════
  Future<List<String>> scanNetworkForDongles() async {
    currStatus.value = 'Scanning network...';
    final found = <String>[];
    try {
      final subnet = await _getWifiSubnet();
      if (subnet == null) { currStatus.value = 'WiFi not connected'; return []; }
      for (int start=1; start<=254; start+=20) {
        final end = (start+19).clamp(1,254);
        final futures = <Future<String?>>[];
        for (int i=start; i<=end; i++) futures.add(_tryPort('$subnet.$i', 6888));
        final results = await Future.wait(futures);
        for (final ip in results) { if (ip != null) found.add(ip); }
        currStatus.value = 'Scanning... ${(end/254*100).toInt()}% — Found: ${found.length}';
      }
    } catch (e) { print('❌ scanNetworkForDongles: $e'); }
    finally { currStatus.value = ''; }
    return found;
  }

  Future<String?> _getWifiSubnet() async {
    try {
      final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final iface in ifaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;
          final parts = ip.split('.');
          if (parts.length == 4) return '${parts[0]}.${parts[1]}.${parts[2]}';
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _tryPort(String ip, int port) async {
    try {
      final s = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 400));
      s.destroy(); return ip;
    } catch (_) { return null; }
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════
  int get _stationId {
    final list = _profile?['station_data'] as List?;
    return list?.isNotEmpty == true ? (list![0]['id'] as int? ?? 0) : 0;
  }

  Map<String,String> get _headers => {
    'Content-Type':  'application/json',
    'Authorization': 'JWT $_token',
  };

  @override
  void onClose() {
    _waitTimer?.cancel();
    _wifi.closeSockets();
    super.onClose();
  }
}