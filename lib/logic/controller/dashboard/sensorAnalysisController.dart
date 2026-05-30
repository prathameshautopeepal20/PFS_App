import 'dart:async';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensorAnalysisController extends GetxController {
  // --- FORM CONTROLLERS ---
  final modelController = TextEditingController().obs;
  final typeController = TextEditingController().obs;
  final sensorName = TextEditingController().obs;
  final sensorType = TextEditingController().obs;
  final registerNumber = TextEditingController().obs;
  final multiplier = TextEditingController().obs;
  final offset = TextEditingController().obs;
  final min = TextEditingController().obs;
  final max = TextEditingController().obs;
  final unit = TextEditingController().obs;

  // --- UI & SELECTION STATE ---
  var addedSensors = <Map<String, dynamic>>[].obs;
  var isAddingSensor = false.obs;
  var isAnalyzing = false.obs;

  // --- RECIPE LOGIC ---

  // --- ANALYSIS DATA ---
  var activeSensor = <String, dynamic>{}.obs;
  var liveDataPoints = <double>[].obs;
  Timer? _timer;

  void fillFormFromRecipeSensor(Map<String, dynamic> sensor) {
    sensorName.value.text = sensor['name'];
    sensorType.value.text = sensor['type'];
    registerNumber.value.text = sensor['register'];
    min.value.text = sensor['min'].toString();
    max.value.text = sensor['max'].toString();
    unit.value.text = sensor['unit'];
  }

  // void saveSensorToTable() {
  //   addedSensors.add({
  //     'name': sensorName.value.text,
  //     'type': sensorType.value.text,
  //     'register': registerNumber.value.text,
  //     'min': double.tryParse(min.value.text) ?? 0.0,
  //     'max': double.tryParse(max.value.text) ?? 100.0,
  //     'unit': unit.value.text,
  //     'samplingRate': 1.0,
  //   });
  //   _clearForm();
  //   isAddingSensor.value = false;
  // }
  void saveSensorToTable() {
  addedSensors.add({
    'name': sensorName.value.text,
    'type': sensorType.value.text,
    'register': registerNumber.value.text,
    'min': double.tryParse(min.value.text) ?? 0.0,
    'max': double.tryParse(max.value.text) ?? 100.0,
    'unit': unit.value.text,
    'multiplier': double.tryParse(multiplier.value.text) ?? 1.0, // ✅ m
    'offset': double.tryParse(offset.value.text) ?? 0.0,         // ✅ c
    'samplingRate': 1.0,
  });
  _clearForm();
  isAddingSensor.value = false;
}

  void _clearForm() {
    sensorName.value.clear();
    sensorType.value.clear();
    registerNumber.value.clear();
    min.value.clear();
    max.value.clear();
    unit.value.clear();
  }

  var isChoosingFromRecipe = false.obs;
  final ScrollController chartScrollController = ScrollController();

  var isPaused = false.obs;
  var isStreaming = false.obs; // Tracks if the connection is active
  var maxDataPoints = 5000.obs; // Controls the "scroll" window size

  // Call this method when new data arrives from your hardware/API
  void onDataReceived(double newValue) {
    if (isPaused.value || !isStreaming.value) return;

    liveDataPoints.add(newValue);

    // Creates the scrolling effect by removing old data
    // if (liveDataPoints.length > maxDataPoints) {
    //   liveDataPoints.removeAt(0);
    // }
  }

  var liveMin = 0.0.obs;
  var liveMax = 0.0.obs;

  // void startAnalysis(Map<String, dynamic> sensor) {
  //   activeSensor.value = sensor;
  //   isAnalyzing.value = true;
  //   isStreaming.value = true;
  //   isPaused.value = false;

  //   // Reset data and stats
  //   liveDataPoints.clear();
  //   liveMin.value = double.infinity;
  //   liveMax.value = -double.infinity;

  //   // 1. 🔥 EXTRACT DYNAMIC SAMPLING RATE
  //   // Pull from the sensor map (defaulting to 1.0 if null)
  //   double rateInSeconds = sensor['samplingRate'] ?? 1.0;

  //   // Convert seconds to milliseconds for the timer
  //   int intervalMs = (rateInSeconds * 1000).toInt();

  //   _timer?.cancel();

  //   // 2. 🔥 START TIMER WITH DYNAMIC INTERVAL
  //   _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
  //     if (isPaused.value) return;

  //     double sMin = double.tryParse(activeSensor['min'].toString()) ?? 0.0;
  //     double sMax = double.tryParse(activeSensor['max'].toString()) ?? 100.0;

  //     // Generate mock data (Replace this with your real Modbus/OBD2 call)
  //     double newValue = sMin + Random().nextDouble() * (sMax - sMin);

  //     liveDataPoints.add(newValue);

  //     // Update live peak statistics
  //     if (newValue < liveMin.value) liveMin.value = newValue;
  //     if (newValue > liveMax.value) liveMax.value = newValue;

  //     // 3. AUTO-SCROLL LOGIC
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (chartScrollController.hasClients) {
  //         chartScrollController.animateTo(
  //           chartScrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 200),
  //           curve: Curves.easeOut,
  //         );
  //       }
  //     });
  //   });
  // }
  // Inside SensorAnalysisController
  // void sendGeneratorDataRequest(int registerAddress) {
  //   // Expected: 1 argument
  //   final plcCtrl = Get.find<PLCController>();

  //   if (!plcCtrl.isConnected.value) {
  //     isStreaming.value = false;
  //     isAnalyzing.value = false;
  //     Get.dialog(
  //       CustomPopup(
  //         title: "PLC Connection Lost",
  //         message:
  //             "Hardware communication was interrupted. Please check your Modbus TCP settings and cable.",
  //         isError: true, // This will make the button red and add an icon
  //       ),
  //     );
  //   }
  //   // Your bit shifting logic
  //   int hiAddr = (registerAddress >> 8) & 0xFF;
  //   int loAddr = registerAddress & 0xFF;

  //   List<int> packet = [
  //     0x00,
  //     0x01,
  //     0x00,
  //     0x00,
  //     0x00,
  //     0x06,
  //     0x01,
  //     0x03,
  //     hiAddr,
  //     loAddr,
  //     0x00,
  //     0x01
  //   ];

  //   plcCtrl.sendPacket(packet);
  // }
 void sendGeneratorDataRequest(int registerAddress) {
  final plcCtrl = Get.find<PLCController>();

  if (!plcCtrl.isConnected.value) {
    // ✅ Just skip this tick — don't kill the loop
     Get.dialog(
        CustomPopup(
          title: "PLC Connection Lost",
          message:
              "Hardware communication was interrupted. Please check your Modbus TCP settings and cable.",
          isError: true, // This will make the button red and add an icon
        ),
      );
    print("⚠️ [ANALYSIS] PLC not connected — skipping this poll");
    return; // ❌ Was: isStreaming.value = false; isAnalyzing.value = false;
  }

  int hiAddr = (registerAddress >> 8) & 0xFF;
  int loAddr = registerAddress & 0xFF;

  List<int> packet = [
    0x00, 0x01, 0x00, 0x00, 0x00, 0x06,
    0x01, 0x03,
    hiAddr, loAddr,
    0x00, 0x01
  ];

  plcCtrl.currentRegister = registerAddress;
  plcCtrl.sendPacket(packet);
}

  void startAnalysis(Map<String, dynamic> sensor) {
  // ✅ Stop any previous loop cleanly first
  isStreaming.value = false;
  isAnalyzing.value = false;

  // ✅ Small delay to let previous loop exit before starting new one
  Future.delayed(const Duration(milliseconds: 200), () {
    activeSensor.value = sensor;
    liveDataPoints.clear();
    liveMin.value = double.infinity;
    liveMax.value = -double.infinity;
    isPaused.value = false;

    isAnalyzing.value = true;
    isStreaming.value = true; // ✅ Set BEFORE loop starts

    print("🚀 [ANALYSIS START] Sensor: ${sensor['name']} | Reg: ${sensor['register']}");
    _runAnalysisLoop();
  });
}

Future<void> _runAnalysisLoop() async {
  print("▶️ [LOOP] Started for: ${activeSensor['name']}");

  while (isStreaming.value) {
    if (!isPaused.value) {
      final plcCtrl = Get.find<PLCController>();

      // ✅ ADD THIS — shows PLC state each iteration
      print("🔄 [LOOP TICK] isStreaming=${isStreaming.value} | isAnalyzing=${isAnalyzing.value} | PLC=${plcCtrl.isConnected.value}");

      if (!plcCtrl.isConnected.value) {
        print("❌ [ANALYSIS] PLC disconnected — stopping loop");
        isStreaming.value = false;
        isAnalyzing.value = false;
        Get.dialog(CustomPopup(
          title: "PLC Connection Lost",
          message: "Hardware disconnected. Check Modbus TCP settings.",
          isError: true,
        ));
        break;
      }

      String regStr = activeSensor['register'].toString();
      int regAddress = regStr.startsWith("0x")
          ? int.tryParse(regStr.replaceFirst("0x", ""), radix: 16) ?? 0
          : int.tryParse(regStr) ?? 0;

      print("📤 [ANALYSIS POLL] Sending request for reg: $regAddress");
      sendGeneratorDataRequest(regAddress);
    }

    double rate = (activeSensor['samplingRate'] ?? 1.0).toDouble();
    int intervalMs = (rate * 1000).toInt();

    print("⏱️ [LOOP] Waiting ${intervalMs}ms | isStreaming=${isStreaming.value}");
    await Future.delayed(Duration(milliseconds: intervalMs));

    // ✅ ADD THIS — shows what killed the loop
    print("⏰ [LOOP] After delay | isStreaming=${isStreaming.value}");
  }

  print("🛑 [ANALYSIS LOOP] Exited | isStreaming=${isStreaming.value} | isAnalyzing=${isAnalyzing.value}");
}

void addRealHardwarePoint(int rawValue) {
  if (isPaused.value || !isAnalyzing.value) return;

  String typeStr = (activeSensor['type'] ?? "").toString().toLowerCase();
  double actualValue = 0.0;

  print("\n📊 [ANALYSIS] Sensor: ${activeSensor['name']} | Raw: $rawValue | Type: $typeStr");

  // =====================================================
  // ⚡ CURRENT SENSOR
  // =====================================================
  if (typeStr.contains("current")) {
    double vout = rawValue.toDouble() / 1000.0;
    actualValue = (vout - 2.5) / 0.185;
    print("⚡ [CURRENT] Vout=$vout | Result=$actualValue A");
  }

  // =====================================================
  // 🔌 RESISTANCE SENSOR
  // =====================================================
  else if (typeStr.contains("resistance")) {
    double r1 = double.tryParse(activeSensor['multiplier']?.toString() ?? "") ?? 1000.0;

    if (typeStr.contains("resistance(2200)")) r1 = 2200.0;
    else if (typeStr.contains("resistance(100)")) r1 = 100.0;

    double vin = double.tryParse(activeSensor['offset']?.toString() ?? "") ?? 5.0;
    double vout = (rawValue.toDouble() / 1000.0) - 0.0001;

    if (vout >= vin) vout = vin - 0.001;
    if (vout < 0) vout = 0;

    double denominator = vin - vout;
    actualValue = denominator == 0 ? 0 : (r1 * vout) / denominator;

    print("🔌 [RESISTANCE] R1=$r1 | Vin=$vin | Vout=$vout | Result=$actualValue Ω");
  }

  // =====================================================
  // 📊 LINEAR SENSOR
  // =====================================================
  else {
    int signedRaw = rawValue > 32767 ? rawValue - 65536 : rawValue;
    double m = double.tryParse(activeSensor['multiplier']?.toString() ?? "") ?? 0.001;
    double c = double.tryParse(activeSensor['offset']?.toString() ?? "") ?? 0.0;
    actualValue = (m * signedRaw) + c;

    print("📈 [LINEAR] signed=$signedRaw | m=$m | c=$c | Result=$actualValue");
  }

  // Add to chart
  liveDataPoints.add(actualValue);

  // Update Stats
  if (actualValue < liveMin.value) liveMin.value = actualValue;
  if (actualValue > liveMax.value) liveMax.value = actualValue;

  // Auto-scroll
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (chartScrollController.hasClients) {
      chartScrollController.jumpTo(
        chartScrollController.position.maxScrollExtent,
      );
    }
  });
}

  void togglePause() {
    isPaused.value = !isPaused.value;
    print("Is Paused: ${isPaused.value}"); // Debug to console
  }

  void stopAnalysis() {
  print("🔴 [ANALYSIS STOP] Stopping stream...");
  isStreaming.value = false;  // ✅ This kills the while loop
  isPaused.value = false;
  isAnalyzing.value = false;
  // ❌ Don't clear liveDataPoints here — let user see final chart
}

// ✅ Add separate clear method if needed
void clearChart() {
  liveDataPoints.clear();
  liveMin.value = double.infinity;
  liveMax.value = -double.infinity;
}

  

  void addSensorFromRecipe(Map<String, dynamic> recipe) {
    // Add a copy to the inventory table
    addedSensors.add(Map<String, dynamic>.from(recipe));
    Get.back(); // Close the popup
    Get.dialog(
      CustomPopup(
        title: "Success",
        message: "${recipe['name']} added to inventory",
        // This will make the button red and add an icon
      ),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
