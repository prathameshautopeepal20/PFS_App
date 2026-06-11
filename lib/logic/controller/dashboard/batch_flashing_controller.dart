import 'package:get/get.dart';
import 'package:atpl_flashing_app/services/flash_engine_service.dart';

class BatchFlashingController extends GetxController {

  RxList<String> ecuList = <String>[].obs;
  RxList<String> selectedECUs = <String>[].obs;

  final FlashEngineService engine = Get.put(FlashEngineService());

  RxString model = "".obs;
  RxString regulation = "".obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    model.value = args["model"] ?? "";
    regulation.value = args["regulation"] ?? "";

    loadECUs();
  }

  void loadECUs() {
    ecuList.value = [
      "ECU_01",
      "ECU_02",
      "ECU_03",
    ];
  }

  void toggleECU(String ecu) {
    if (selectedECUs.contains(ecu)) {
      selectedECUs.remove(ecu);
    } else {
      selectedECUs.add(ecu);
    }
  }

  /// ================= START FLASH =================
  void startFlash() {

    if (selectedECUs.isEmpty) {
      Get.snackbar("Error", "Select ECU first");
      return;
    }

    engine.startBatchFlash(
      ecuList: selectedECUs,
      model: model.value,
      regulation: regulation.value,
    );
  }
}