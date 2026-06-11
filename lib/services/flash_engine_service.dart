import 'dart:async';
import 'package:get/get.dart';

class FlashEngineService extends GetxService {

  /// ================= FLASH CALLBACKS =================
  final RxString currentECU = "".obs;
  final RxDouble progress = 0.0.obs;
  final RxString status = "".obs;

  /// ================= START FLASH PROCESS =================
  Future<void> startBatchFlash({
    required List<String> ecuList,
    required String model,
    required String regulation,
  }) async {

    status.value = "Initializing Flash Engine...";
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < ecuList.length; i++) {

      String ecu = ecuList[i];

      currentECU.value = ecu;
      progress.value = 0;

      // ================= STEP 1: CONNECT =================
      status.value = "Connecting to $ecu...";
      await _simulateDelay();

      // ================= STEP 2: READ ECU =================
      status.value = "Reading ECU Info...";
      await _simulateProgress(20);

      // ================= STEP 3: VALIDATE FILE =================
      status.value = "Validating Firmware ($model / $regulation)...";
      await _simulateProgress(35);

      // ================= STEP 4: ERASE MEMORY =================
      status.value = "Erasing ECU Memory...";
      await _simulateProgress(55);

      // ================= STEP 5: WRITE FLASH =================
      status.value = "Writing Flash Data...";
      await _simulateProgress(80);

      // ================= STEP 6: VERIFY =================
      status.value = "Verifying Flash...";
      await _simulateProgress(95);

      // ================= DONE =================
      status.value = "ECU $ecu Flash Success";
      progress.value = 100;

      await Future.delayed(const Duration(milliseconds: 600));
    }

    status.value = "Batch Flash Completed";
    currentECU.value = "";
    progress.value = 0;
  }

  /// ================= SIMULATION HELPERS =================

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _simulateProgress(double target) async {

    while (progress.value < target) {
      await Future.delayed(const Duration(milliseconds: 150));
      progress.value += 5;
    }
  }
}