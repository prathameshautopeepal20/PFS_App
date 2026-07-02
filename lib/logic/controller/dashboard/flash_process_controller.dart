// Prathmesh Girme
// lib/logic/controller/dashboard/flash_process_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';

// ─────────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────────

class SeqFileName {
  final int id;
  final String sequenceFile;
  final String callibrationDatasetSeq;

  SeqFileName({
    required this.id,
    required this.sequenceFile,
    required this.callibrationDatasetSeq,
  });

  factory SeqFileName.fromJson(Map<String, dynamic> j) => SeqFileName(
    id: j['id'] ?? 0,
    sequenceFile: j['sequence_file'] ?? '',
    callibrationDatasetSeq: j['callibration_dataset_seq'] ?? '',
  );
}

class DatasetFile {
  final int id;
  final String hexSrecFile;
  final String dataFileName;
  final String swPartNo;
  final String calId;
  final String cvn;
  final String swVersion;
  final SeqFileName? sequenceFileName;

  DatasetFile({
    required this.id,
    required this.hexSrecFile,
    required this.dataFileName,
    required this.swPartNo,
    required this.calId,
    required this.cvn,
    required this.swVersion,
    this.sequenceFileName,
  });

  factory DatasetFile.fromJson(Map<String, dynamic> j) => DatasetFile(
    id: j['id'] ?? 0,
    hexSrecFile: j['hex_srec_file'] ?? '',
    dataFileName: j['data_file_name'] ?? '',
    swPartNo: j['sw_part_no'] ?? '',
    calId: j['cal_id'] ?? '',
    cvn: j['cvn'] ?? '',
    swVersion: j['sw_version'] ?? '',
    sequenceFileName: j['sequence_file_name'] != null
        ? SeqFileName.fromJson(j['sequence_file_name'])
        : null,
  );
}

class EcuSubmodel {
  final int id;
  final int ecu;
  final DatasetFile? completeDataset;
  final DatasetFile? callibrationDataset;
  final String completeStatus;
  final String calibrationStatus;
  final List<dynamic> pidDatasets;
  final String txHeader;
  final String rxHeader;
  final String protocolName;
  final String protocolAutopeepal;
  final String seedkeyAlgoValue; // from ecu.seedkeyalgo_fn_index.value

  EcuSubmodel({
    required this.id,
    required this.ecu,
    this.completeDataset,
    this.callibrationDataset,
    required this.completeStatus,
    required this.calibrationStatus,
    this.pidDatasets = const [],
    this.txHeader = '7DF',
    this.rxHeader = '7E8',
    this.protocolName = 'ISO15765_500KB_11BIT_CAN',
    this.protocolAutopeepal = '02',
    this.seedkeyAlgoValue = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ecu': ecu,
    'txHeader': txHeader,
    'rxHeader': rxHeader,
    'protocolName': protocolName,
    'protocolAutopeepal': protocolAutopeepal,
    'seedkeyAlgoValue': seedkeyAlgoValue,
  };

  factory EcuSubmodel.fromJson(Map<String, dynamic> j) {
  final ecuObj = j['ecu'];
  final rawSeedkey = (ecuObj is Map) ? ecuObj['seedkeyalgo_fn_index'] : null;
  print('🔑🔑🔑 RAW = ' + rawSeedkey.toString());
  final seedVal =
      (rawSeedkey is Map
          ? rawSeedkey['value']?.toString()
          : rawSeedkey?.toString()) ?? '';   // ← empty string, no hardcode
  print('🔑🔑🔑 RESOLVED = ' + seedVal);

    final ecuMap = ecuObj is Map ? ecuObj as Map<String, dynamic> : null;
    final protocol = ecuMap?['protocol'];
    final protocolMap = protocol is Map
        ? protocol as Map<String, dynamic>
        : null;

    return EcuSubmodel(
      id: j['id'] ?? 0,
      ecu: ecuMap != null ? (ecuMap['id'] ?? 0) : (ecuObj ?? 0),
      completeDataset: j['complete_dataset'] != null
          ? DatasetFile.fromJson(j['complete_dataset'])
          : null,
      callibrationDataset: j['callibration_dataset'] != null
          ? DatasetFile.fromJson(j['callibration_dataset'])
          : null,
      completeStatus: j['complete_status'] ?? '',
      calibrationStatus: j['calibration_status'] ?? '',
      pidDatasets: j['pid_datasets'] as List? ?? [],
      txHeader: ecuMap?['tx_header'] ?? j['tx_header'] ?? '7DF',
      rxHeader: ecuMap?['rx_header'] ?? j['rx_header'] ?? '7E8',
      protocolName:
          protocolMap?['name'] ??
          j['protocol_name'] ??
          'ISO15765_500KB_11BIT_CAN',
      protocolAutopeepal:
          protocolMap?['autopeepal'] ?? j['protocol_autopeepal'] ?? '02',
      seedkeyAlgoValue: seedVal,
    );
  }
}

class StationInfo {
  final int id;
  final String stationsId;
  final int plants;
  final String ip;
  final String port;

  StationInfo({
    required this.id,
    required this.stationsId,
    required this.plants,
    required this.ip,
    required this.port,
  });

  factory StationInfo.fromJson(Map<String, dynamic> j) => StationInfo(
    id: j['id'] ?? 0,
    stationsId: j['stations_id'] ?? '',
    plants: j['plants'] ?? 0,
    ip: j['ip'] ?? '',
    port: j['port'] ?? '',
  );
}

class SubModel {
  final int id;
  final String name;
  final String description;
  final String hwPartNo;
  final List<EcuSubmodel> ecuSubmodel;
  final List<StationInfo> station;
  final int? waitAfterFlash;
  final bool scanQrCode; // ← ADDED: scan_qr_code
  final String scanQrCodeData; // ← ADDED: scan_qr_code_data

  SubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.hwPartNo,
    required this.ecuSubmodel,
    required this.station,
    this.waitAfterFlash,
    this.scanQrCode = false,
    this.scanQrCodeData = '',
  });

  factory SubModel.fromJson(Map<String, dynamic> j) => SubModel(
    id: j['id'] ?? 0,
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    hwPartNo: j['hw_part_no'] ?? '',
    ecuSubmodel: (j['ecu_submodel'] as List? ?? [])
        .map((e) => EcuSubmodel.fromJson(e))
        .toList(),
    station: (j['station'] as List? ?? [])
        .map((e) => StationInfo.fromJson(e))
        .toList(),
    waitAfterFlash: j['wait_after_flash'] as int?,
    scanQrCode: j['scan_qr_code'] as bool? ?? false,
    scanQrCodeData: j['scan_qr_code_data'] as String? ?? '',
  );
}

class ModelResult {
  final int id;
  final int oem;
  final String name;
  final List<SubModel> subModels;

  ModelResult({
    required this.id,
    required this.oem,
    required this.name,
    required this.subModels,
  });

  factory ModelResult.fromJson(Map<String, dynamic> j) => ModelResult(
    id: j['id'] ?? 0,
    oem: j['oem'] ?? 0,
    name: j['name'] ?? '',
    subModels: (j['sub_models'] as List? ?? [])
        .map((e) => SubModel.fromJson(e))
        .toList(),
  );
}

class DongleRow {
  int index;
  int srNo;
  final String macId;
  final String ipAddress;
  final int priority;
  bool isDongleAvailable;
  bool isEcuAvailable;
  String ecuSrNo;
  String flashTimer;
  String flashPercent;
  bool flashingCompleted;
  bool isflashing;
  bool printButtonDisable;
  bool playButtonDisable;
  bool playButtonVisible;
  bool flashingAvailabel;
  String fileType;
  bool ecuStatus;
  String ecuStatus1;
  bool alreadyMessage;
  bool isDongle;
  double progress;
  bool isProgressVisible;
  String printCalId;
  String calId;
  String cvn;
  String cvnBefore;
  String calIdBefore;
  String swVersionBefore;
  String swVersionAfter;
  String ecuSrNoAfter;
  String swPartNo;
  String hardwarePartNumber;
  Color statusColor;
  Color reportColor;
  bool swMatch;
  bool calIdMatch;
  bool cvnMatch;
  // Individual selection extras
  ModelResult? selectedModel;
  SubModel? selectedSubModel;
  String downComFile;
  String downComSeqfile;
  String downComFileUrl;
  String downCalFile;
  String downCalSeqfile;
  String downCalFileUrl;

  DongleRow({
    required this.index,
    required this.srNo,
    required this.macId,
    required this.ipAddress,
    required this.priority,
    this.isDongleAvailable = false,
    this.isEcuAvailable = false,
    this.ecuSrNo = '',
    this.flashTimer = '00:00',
    this.flashPercent = '0.0 %',
    this.flashingCompleted = false,
    this.isflashing = false,
    this.printButtonDisable = true,
    this.playButtonDisable = true,
    this.playButtonVisible = false,
    this.flashingAvailabel = false,
    this.fileType = 'NA',
    this.ecuStatus = true,
    this.ecuStatus1 = '',
    this.alreadyMessage = false,
    this.isDongle = false,
    this.progress = 0,
    this.isProgressVisible = false,
    this.printCalId = '',
    this.calId = '',
    this.cvn = '',
    this.cvnBefore = '',
    this.calIdBefore = '',
    this.swVersionBefore = '',
    this.swVersionAfter = '',
    this.ecuSrNoAfter = '',
    this.swPartNo = '',
    this.hardwarePartNumber = '',
    this.statusColor = Colors.white,
    this.reportColor = Colors.white,
    this.swMatch = false,
    this.calIdMatch = false,
    this.cvnMatch = false,
    this.selectedModel,
    this.selectedSubModel,
    this.downComFile = '',
    this.downComSeqfile = '',
    this.downComFileUrl = '',
    this.downCalFile = '',
    this.downCalSeqfile = '',
    this.downCalFileUrl = '',
  });
}

class IndividualRow {
  final int index;
  List<ModelResult> modelList;
  List<DongleRow> tableInfo;
  ModelResult? selectedModel;
  SubModel? selectedSubModel;
  DongleRow? selectedDongle;

  IndividualRow({
    required this.index,
    required this.modelList,
    required this.tableInfo,
    this.selectedModel,
    this.selectedSubModel,
    this.selectedDongle,
  });
}

// ─────────────────────────────────────────────────────────────
//  CONTROLLER
// ─────────────────────────────────────────────────────────────

class FlashProcessController extends GetxController {
  // ── Observable state ──────────────────────────────────────
  final RxBool isBatch = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool individualVisible = false.obs;

  // Batch
  final Rx<ModelResult?> selectedModel = Rx<ModelResult?>(null);
  final Rx<SubModel?> selectedSubModel = Rx<SubModel?>(null);
  final RxList<ModelResult> modelList = <ModelResult>[].obs;

  // Popup
  final RxBool showPopup = false.obs;
  final RxString popupTitle = ''.obs;

  // Individual
  final RxList<IndividualRow> individualList = <IndividualRow>[].obs;
  final RxList<DongleRow> tableInfo = <DongleRow>[].obs;

  // Backward compat — old screen used these
  RxList<String> regulationList = <String>[].obs;
  RxString selectedRegulation = ''.obs;

  // Internal
  Map<String, dynamic>? _profile;
  String _token = '';

  // ── Init ──────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      _token = await AppPreferences.getToken() ?? '';
      _profile = await AppPreferences.getLoginResponse();

      print('🔑 [FlashProcess] token: $_token');
      print('👤 [FlashProcess] role: ${_profile?['role']}');
      print('🏭 [FlashProcess] station: $_stationId');
      print('🏢 [FlashProcess] oem: ${_profile?['profile']?['oem']?['id']}');

      individualVisible.value = (_profile?['role'] ?? '') != 'User';

      await _loadModels();
      if (individualVisible.value) {
        await _loadDongles();
      }
    } catch (e) {
      print('❌ [FlashProcess] loadInitialData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Type toggle ───────────────────────────────────────────
  void selectBatch() => isBatch.value = true;
  void selectIndividual() => isBatch.value = false;

  // ── Popup ─────────────────────────────────────────────────
  void openPopup(String type) {
    if (type == 'Regulation' && selectedModel.value == null) {
      _warn('Please select model description first');
      return;
    }
    popupTitle.value = type == 'ModelDescription'
        ? 'Model Descriptions'
        : 'Regulations';
    showPopup.value = true;
  }

  void closePopup() => showPopup.value = false;

  void selectPopupItem(dynamic item) {
    if (popupTitle.value == 'Model Descriptions') {
      selectedModel.value = item as ModelResult;
      selectedSubModel.value = null;
      regulationList.assignAll(
        (item as ModelResult).subModels.map((s) => s.name).toList(),
      );
    } else {
      selectedSubModel.value = item as SubModel;
      selectedRegulation.value = (item as SubModel).name;
    }
    showPopup.value = false;
  }

  // ── Individual row ────────────────────────────────────────
  void onModelSelected(int i, ModelResult m) {
    individualList[i].selectedModel = m;
    individualList[i].selectedSubModel = null;
    individualList[i].selectedDongle = null;
    individualList.refresh();
  }

  void onSubModelSelected(int i, SubModel s) {
    individualList[i].selectedSubModel = s;
    individualList.refresh();
  }

  void onDongleSelected(int i, DongleRow d) {
    individualList[i].selectedDongle = d;
    individualList.refresh();
  }

  // ── NEXT (backward compat) ────────────────────────────────
  void onNext() => onBatchNext();

  // ── NEXT Batch ────────────────────────────────────────────
  Future<void> onBatchNext() async {
    if (selectedModel.value == null || selectedSubModel.value == null) {
      _warn('Please select all fields first.');
      return;
    }

    final ecu0 = selectedSubModel.value!.ecuSubmodel.isNotEmpty
        ? selectedSubModel.value!.ecuSubmodel[0]
        : null;

    if (ecu0 == null ||
        (ecu0.completeDataset == null && ecu0.callibrationDataset == null)) {
      _err('Dataset file not found');
      return;
    }

    final approved =
        (ecu0.completeDataset != null && ecu0.completeStatus == 'Approved') ||
        (ecu0.callibrationDataset != null &&
            ecu0.calibrationStatus == 'Approved');

    if (!approved) {
      _err('Flash dataset is not approved');
      return;
    }

    isLoading.value = true;
    try {
      String dCF = '', dCS = '', dCU = '';
      String dKF = '', dKS = '', dKU = '';

      if (ecu0.completeDataset != null) {
        dCF = await _readFile(ecu0.completeDataset!.hexSrecFile) ?? '';
        dCS =
            await _readFile(
              ecu0.completeDataset!.sequenceFileName?.sequenceFile ?? '',
            ) ??
            '';
        dCU = ecu0.completeDataset!.hexSrecFile;
        if (dCF.isEmpty) {
          _err('Could not download dataset file');
          return;
        }
        if (dCS.isEmpty) {
          _err('Could not download flashing sequence');
          return;
        }
      }

      if (ecu0.callibrationDataset != null) {
        dKF = await _readFile(ecu0.callibrationDataset!.hexSrecFile) ?? '';
        dKS =
            await _readFile(
              ecu0
                      .callibrationDataset!
                      .sequenceFileName
                      ?.callibrationDatasetSeq ??
                  '',
            ) ??
            '';
        dKU = ecu0.callibrationDataset!.hexSrecFile;
        if (dKF.isEmpty) {
          _err('Could not download calibration file');
          return;
        }
        if (dKS.isEmpty) {
          _err('Could not download calibration sequence');
          return;
        }
      }

      Get.toNamed(
        '/home-page',
        arguments: {
          'selectedModel': selectedModel.value,
          'selectedSubModel': selectedSubModel.value,
          'profile': _profile,
          'flashingType': 'Batch',
          'token': _token,
          'downComFile': dCF,
          'downComSeqfile': dCS,
          'downComFileUrl': dCU,
          'downCalFile': dKF,
          'downCalSeqfile': dKS,
          'downCalFileUrl': dKU,
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── NEXT Individual ───────────────────────────────────────
  Future<void> onIndividualNext() async {
    final hasAny = individualList.any((r) => r.selectedSubModel != null);
    if (!hasAny) {
      _warn("You haven't selected any Model and Regulation.");
      return;
    }

    final complete = individualList
        .where((r) => r.selectedSubModel != null && r.selectedDongle != null)
        .toList();

    if (complete.isEmpty) {
      _warn('Please select a dongle for each row.');
      return;
    }

    isLoading.value = true;
    try {
      final finalList = <DongleRow>[];

      for (final row in complete) {
        final ecu0 = row.selectedSubModel!.ecuSubmodel.isNotEmpty
            ? row.selectedSubModel!.ecuSubmodel[0]
            : null;
        if (ecu0 == null) continue;

        final approved =
            (ecu0.completeDataset != null &&
                ecu0.completeStatus == 'Approved') ||
            (ecu0.callibrationDataset != null &&
                ecu0.calibrationStatus == 'Approved');

        if (!approved) {
          _err(
            'Flash dataset is not approved for\n'
            '${row.selectedModel?.name} ${row.selectedSubModel?.name}',
          );
          return;
        }

        String dCF = '', dCS = '', dCU = '', calId = '';
        String dKF = '', dKS = '', dKU = '';

        if (ecu0.completeDataset != null) {
          dCF = await _readFile(ecu0.completeDataset!.hexSrecFile) ?? '';
          dCS =
              await _readFile(
                ecu0.completeDataset!.sequenceFileName?.sequenceFile ?? '',
              ) ??
              '';
          dCU = ecu0.completeDataset!.hexSrecFile;
          calId = ecu0.completeDataset!.calId;
        }
        if (ecu0.callibrationDataset != null) {
          dKF = await _readFile(ecu0.callibrationDataset!.hexSrecFile) ?? '';
          dKS =
              await _readFile(
                ecu0
                        .callibrationDataset!
                        .sequenceFileName
                        ?.callibrationDatasetSeq ??
                    '',
              ) ??
              '';
          dKU = ecu0.callibrationDataset!.hexSrecFile;
          calId = ecu0.callibrationDataset!.calId;
        }

        final d = row.selectedDongle!;
        d.selectedModel = row.selectedModel;
        d.selectedSubModel = row.selectedSubModel;
        d.isDongleAvailable = false;
        d.isEcuAvailable = false;
        d.flashTimer = '00:00';
        d.flashPercent = '0.0 %';
        d.flashingCompleted = false;
        d.isflashing = false;
        d.printButtonDisable = true;
        d.playButtonDisable = true;
        d.playButtonVisible = true;
        d.progress = 0;
        d.calId = calId;
        d.printCalId = calId;
        d.downComFile = dCF;
        d.downComSeqfile = dCS;
        d.downComFileUrl = dCU;
        d.downCalFile = dKF;
        d.downCalSeqfile = dKS;
        d.downCalFileUrl = dKU;
        finalList.add(d);
      }

      finalList.sort((a, b) => a.srNo.compareTo(b.srNo));
      for (int i = 0; i < finalList.length; i++) finalList[i].index = i + 1;

      Get.toNamed(
        '/individual-flash',
        arguments: {
          'profile': _profile,
          'flashingType': 'Individual',
          'finalList': finalList,
          'token': _token,
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── API: models ───────────────────────────────────────────
  Future<void> _loadModels() async {
    try {
      final oemId = _profile?['profile']?['oem']?['id'] ?? 0;
      final url = '${AppEnvironment.baseUrl}models/get-models/?oem=$oemId';
      print('🌐 [FlashProcess] GET models: $url');

      final res = await http.get(Uri.parse(url), headers: _headers);
      if (res.statusCode != 200) {
        print('❌ [FlashProcess] models ${res.statusCode}: ${res.body}');
        return;
      }

      final all = ((jsonDecode(res.body)['results']) as List? ?? [])
          .map((e) => ModelResult.fromJson(e))
          .toList();

      final stId = _stationId;
      final filtered = <ModelResult>[];

      for (final m in all) {
        final subs = m.subModels
            .where((s) => s.station.any((st) => st.id == stId))
            .toList();
        if (subs.isNotEmpty) {
          filtered.add(
            ModelResult(id: m.id, oem: m.oem, name: m.name, subModels: subs),
          );
        }
      }

      modelList.assignAll(filtered);
      print('✅ [FlashProcess] ${filtered.length} models (station $stId)');
    } catch (e) {
      print('❌ [FlashProcess] _loadModels: $e');
    }
  }

  // ── API: dongles ──────────────────────────────────────────
  Future<void> _loadDongles() async {
    try {
      final url = '${AppEnvironment.baseUrl}devices/prodbuddongle/list/';
      print('🌐 [FlashProcess] GET dongles: $url');

      final res = await http.get(Uri.parse(url), headers: _headers);
      if (res.statusCode != 200) {
        print('❌ [FlashProcess] dongles ${res.statusCode}');
        return;
      }

      final results = (jsonDecode(res.body)['results'] as List? ?? []);
      final stId = _stationId;
      final sorted = [...results]
        ..sort(
          (a, b) => ((a['priority'] ?? 0) as int).compareTo(
            (b['priority'] ?? 0) as int,
          ),
        );

      final table = <DongleRow>[];
      int idx = 0, srNo = 0;

      for (final x in sorted) {
        if ((x['station'] as int? ?? 0) == stId) {
          srNo++;
          if (x['is_active'] == true) {
            idx++;
            table.add(
              DongleRow(
                index: idx,
                srNo: srNo,
                macId: x['mac_id'] ?? '',
                ipAddress: x['ip'] ?? '',
                priority: x['priority'] ?? 0,
              ),
            );
          }
        }
      }

      tableInfo.assignAll(table);
      individualList.assignAll(
        List.generate(
          4,
          (i) => IndividualRow(
            index: i + 1,
            modelList: modelList,
            tableInfo: table,
          ),
        ),
      );

      print('✅ [FlashProcess] ${table.length} dongles (station $stId)');
    } catch (e) {
      print('❌ [FlashProcess] _loadDongles: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  Future<String?> _readFile(String url) async {
    if (url.isEmpty) return null;
    try {
      final res = await http.get(Uri.parse(url));
      return res.statusCode == 200 ? res.body : null;
    } catch (_) {
      return null;
    }
  }

  void _warn(String msg) => Get.snackbar(
    'Alert!',
    msg,
    backgroundColor: Colors.orange,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  void _err(String msg) => Get.snackbar(
    'Error',
    msg,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  int get _stationId {
    final list = _profile?['station_data'] as List?;
    if (list != null && list.isNotEmpty) {
      return (list[0]['id'] as int? ?? 0);
    }
    return 0;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'JWT $_token',
  };
}
