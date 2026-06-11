import 'package:get/get.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/batch_flashing_screen.dart';

class FlashProcessController extends GetxController {

  // ================= FLASH TYPE =================
  RxBool isBatch = true.obs;

  // ================= API DATA =================
  RxList<String> modelList = <String>[].obs;
  RxList<String> regulationList = <String>[].obs;

  // ================= SELECTED VALUES =================
  RxString selectedModel = "".obs;
  RxString selectedRegulation = "".obs;

  @override
  void onInit() {
    super.onInit();

    // 🔥 like .NET INIT LOAD
    loadInitialData();
  }

  // ================= INITIAL LOAD (.NET like Form_Load) =================
  Future<void> loadInitialData() async {

    // later API replace
    modelList.value = [
      "Hunter",
      "Classic",
      "Meteor",
    ];

    regulationList.value = [
      "BS4",
      "BS6",
    ];
  }

  // ================= FLASH TYPE =================
  void selectBatch() {
    isBatch.value = true;
  }

  void selectIndividual() {
    isBatch.value = false;
  }

  // ================= VALIDATION (.NET style validation layer) =================
  bool validateBatch() {

    if (selectedModel.value.isEmpty) {
      Get.snackbar("Error", "Select Model");
      return false;
    }

    if (selectedRegulation.value.isEmpty) {
      Get.snackbar("Error", "Select Regulation");
      return false;
    }

    return true;
  }

  // ================= NEXT FLOW (.NET NAVIGATION LAYER) =================
  void onNext() {

    if (isBatch.value) {

      if (!validateBatch()) return;

      // 🔥 MOVE TO BATCH MODULE (like .NET form open)
      Get.to(
        () => BatchFlashingScreen(),
        arguments: {
          "model": selectedModel.value,
          "regulation": selectedRegulation.value,
        },
      );

    } else {

      // Individual flow later
      Get.snackbar("Info", "Individual Flow Coming");
    }
  }
}