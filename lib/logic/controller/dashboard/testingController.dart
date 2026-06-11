import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';
import 'package:atpl_flashing_app/api/dev/dev_service.dart';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/testRecipeController.dart';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/services/log_file.dart';
import 'package:atpl_flashing_app/themes/app_textstyles.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:zxing_lib/zxing.dart';
import 'package:zxing_lib/common.dart';

class ESNController extends GetxController {
  final esnTextFieldController = TextEditingController();
  final FocusNode esnFocusNode = FocusNode();

  // Reactive States
  var isValidated = false.obs;
  var isTesting = false.obs;
  var isScanning = false.obs;
  var testCount = "-".obs;
  var serialNumber = "-".obs;
  var variantCode = "-".obs;
  var modelNumber = "-".obs;
  var recipeId = "-".obs;
  var testId = "-".obs;
  var modelValidationId = "-".obs;
  var selectedRecipe = Rxn<Recipe>();
  CameraController? cameraController;
  var sensorResults = <Map<String, dynamic>>[].obs;

  // ✅ ADD these to TestRecipeController (where recipeList is defined)
// In ESNController
  var expandedSensors = <String>{}.obs;

  void toggleSensorExpanded(String key) {
    if (expandedSensors.contains(key)) {
      expandedSensors.remove(key);
    } else {
      expandedSensors.add(key);
    }
  }

  @override
  void onInit() {
    super.onInit();
// add this line to existing onInit
  }

  // loadSensorsFromRecipe() {
  //   final testCtrl = Get.find<TestRecipeController>();

  //   print("🔍 [LOAD] Requested model: ${modelNumber.value}");
  //   print("📦 [AVAILABLE RECIPES]: ${testCtrl.recipeList.length}");

  //   final recipe = testCtrl.recipeList.firstWhereOrNull(
  //     (r) => r.model == modelNumber.value,
  //   );

  //   if (recipe == null) {
  //     print("❌ [LOAD FAILED] No recipe found for model: ${modelNumber.value}");
  //     Get.snackbar("Error", "No matching recipe found for model");
  //     return;
  //   }

  //   selectedRecipe.value = recipe;

  //   print("✅ [RECIPE FOUND]");
  //   print("➡️ Model: ${recipe.model}");
  //   print("➡️ Sensor count: ${recipe.sensors.length}");

  //   sensorResults.assignAll(
  //     recipe.sensors.map((s) {
  //       final map = {
  //         "reg": s.registerNumber,
  //         "part": s.sensorName,
  //         "type": s.sensorType,
  //         //"reg": s.registerNumber,
  //         "m": s.multiplier,
  //         "c": s.offset,
  //         "min": s.min,
  //         "max": s.max,
  //         "unit": s.unit,
  //         "val": "-",
  //         "status": "PENDING"
  //       };

  //       print("📡 [SENSOR LOADED] $map"); // 👈 important debug per sensor
  //       return map;
  //     }).toList(),
  //   );

  //   print("🎯 [FINAL] Total sensors mapped: ${sensorResults.length}");
  //   print("🚀 Sensors successfully loaded for model: ${recipe.model}");
  // }
  loadSensorsFromRecipe() {
    final testCtrl = Get.find<TestRecipeController>();

    print("🔍 [LOAD] Requested model: ${modelNumber.value}");
    LogFile.write("🔍 [LOAD] Requested model: ${modelNumber.value}");

    print("📦 [AVAILABLE RECIPES]: ${testCtrl.recipeList.length}");
    LogFile.write("📦 [AVAILABLE RECIPES]: ${testCtrl.recipeList.length}");

    final recipe = testCtrl.recipeList.firstWhereOrNull(
      (r) => r.model == modelNumber.value,
    );

    if (recipe == null) {
      print("❌ [LOAD FAILED] No recipe found for model: ${modelNumber.value}");
      LogFile.write(
          "❌ [LOAD FAILED] No recipe found for model: ${modelNumber.value}");
      Get.snackbar("Error", "No matching recipe found for model");
      return;
    }

    selectedRecipe.value = recipe;

    print("✅ [RECIPE FOUND]");
    print("➡️ Model: ${recipe.model}");
    print("➡️ Sensor count: ${recipe.sensors.length}");
    LogFile.write("✅ [RECIPE FOUND]");
    LogFile.write("➡️ Model: ${recipe.model}");
    LogFile.write("➡️ Sensor count: ${recipe.sensors.length}");

    sensorResults.assignAll(
      recipe.sensors.map((s) {
        final map = {
          "reg": s.registerNumber,
          "part": s.sensorName,
          "type": s.sensorType,
          "m": s.multiplier,
          "c": s.offset,
          "min": s.min,
          "max": s.max,
          "unit": s.unit,
          "val": "-",
          "status": "PENDING",
          "operations": s.operations, // ✅ ADD THIS
        };

        print(
            "📡 [SENSOR LOADED] reg=${map['reg']} | part=${map['part']} | ops=${(map['operations'] as List).length}");
        LogFile.write(
            "📡 [SENSOR LOADED] reg=${map['reg']} | part=${map['part']} | ops=${(map['operations'] as List).length}");

        return map;
      }).toList(),
    );

    print("🎯 [FINAL] Total sensors mapped: ${sensorResults.length}");
    LogFile.write("🎯 [FINAL] Total sensors mapped: ${sensorResults.length}");

    print("🚀 Sensors successfully loaded for model: ${recipe.model}");
    LogFile.write("🚀 Sensors successfully loaded for model: ${recipe.model}");
  }

  RxBool isLoading = false.obs;

  Future<void> validateESN() async {
    String esn = esnTextFieldController.text.trim();
    if (esn.isEmpty) {
      Get.snackbar("Error", "Please enter an ESN",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final String formattedEsn = "SN-$esn";
    final requestBody = {"engine_serial_no": formattedEsn};

    try {
      isLoading.value = true;
      print("📡 [ESN VALIDATION] Sending: $formattedEsn");
      LogFile.write("📡 [ESN VALIDATION] Sending: $formattedEsn");

      String? savedToken = await AppPreferences.getToken();
      final String validateUrl =
          "${AppEnvironment.baseUrl}${AppURLs.engineNumberCheck}";

      final response = await http.post(
        Uri.parse(validateUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "JWT $savedToken",
        },
        body: jsonEncode(requestBody),
      );

      print("📡 [RESPONSE] Status: ${response.statusCode}");
      LogFile.write("📡 [RESPONSE] Status: ${response.statusCode}");

      print("📡 [RESPONSE] Body: ${response.body}");
      LogFile.write("📡 [RESPONSE] Body: ${response.body}");

      // ✅ Log to DevScreen
      Map<String, dynamic> parsedResponse = {};
      try {
        parsedResponse = jsonDecode(response.body);
      } catch (_) {
        parsedResponse = {"raw": response.body};
      }
      parsedResponse['statusCode'] = response.statusCode;

      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST ${response.statusCode}',
        path: AppURLs.engineNumberCheck,
        dateTime: DateTime.now(),
        data: requestBody,
        response: parsedResponse,
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];

          serialNumber.value = formattedEsn;
          modelNumber.value = data['model_no']?.toString() ?? "Unknown Model";
          variantCode.value =
              data['variant_code']?.toString() ?? "Unknown Variant";
          modelValidationId.value = data['id']?.toString() ?? "";

          print(
              "✅ [ESN DATA] Model: ${modelNumber.value}, Variant: ${variantCode.value}");
          LogFile.write(
              "✅ [ESN DATA] Model: ${modelNumber.value}, Variant: ${variantCode.value}");

          await loadSensorsFromRecipe();
          isValidated.value = true;

          Get.snackbar("Success", "ESN Validated",
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar(
            "Invalid ESN",
            responseData['message'] ?? "No data found for this ESN",
            backgroundColor: Colors.orange,
          );
        }
      } else if (response.statusCode == 401) {
        print("🚨 [UNAUTHORIZED] Token is invalid or expired.");
        LogFile.write("🚨 [UNAUTHORIZED] Token is invalid or expired.");

        await AppPreferences.clearToken();
        Get.snackbar("Session Expired", "Please login again",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        Get.offAllNamed(Routes.loginScreen);
      } else {
        Get.snackbar(
          "Server Error",
          "Something went wrong (${response.statusCode})",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } on SocketException {
      // ✅ Log network error
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST ERROR',
        path: AppURLs.engineNumberCheck,
        dateTime: DateTime.now(),
        data: requestBody,
        response: {
          "error": "SocketException",
          "message": "No internet connection"
        },
      ));
      Get.snackbar("No Connection", "Check your internet and try again",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } on TimeoutException {
      // ✅ Log timeout
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.engineNumberCheck,
        dateTime: DateTime.now(),
        data: requestBody,
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      Get.snackbar("Timeout", "Server took too long to respond",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      // ✅ Log exception
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST EXCEPTION',
        path: AppURLs.engineNumberCheck,
        dateTime: DateTime.now(),
        data: requestBody,
        response: {"error": "Exception", "message": e.toString()},
      ));
      print("❌ [ESN VALIDATION ERROR] $e");
      LogFile.write("❌ [ESN VALIDATION ERROR] $e");

      Get.snackbar("Error", "Failed to connect to server");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 1. THE DECODING ENGINE (Pure Dart) ---
  bool _decodeFromBytes(Uint8List bytes) {
    try {
      final img.Image? baseImage = img.decodeImage(bytes);
      if (baseImage == null) {
        print("SCAN_DEBUG: Decoder failed to process image bytes.");
        return false;
      }

      final img.Image processedImage = img.grayscale(baseImage);
      final Int32List pixels =
          Int32List(processedImage.width * processedImage.height);

      int index = 0;
      for (final pixel in processedImage) {
        pixels[index++] = pixel.r.toInt();
      }

      LuminanceSource source = RGBLuminanceSource(
        processedImage.width,
        processedImage.height,
        pixels,
      );

      BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));
      final reader = MultiFormatReader();
      final Result result = reader.decode(bitmap);

      if (result.text.isNotEmpty) {
        print("SCAN_DEBUG: Successfully decoded text: ${result.text}");
        LogFile.write("SCAN_DEBUG: Successfully decoded text: ${result.text}");
        esnTextFieldController.text = result.text;
        return true;
      }
    } catch (e) {
      // Normal: ZXing throws an exception if no barcode is found in the image
    }
    return false;
  }

  Future<void> sc() async {
    if (isScanning.value) return;
    _isProcessing = false; // ✅ Reset guard
    _isHandlingSuccess = false; // ✅ Reset flag

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showPopup("Hardware Error", "No webcam found.", true);
        return;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.low, // ✅ LOW = smallest file = fastest delete
        enableAudio: false,
        imageFormatGroup: Platform.isWindows
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isScanning.value = true;

      // ... rest of your dialog code unchanged ...
      Get.dialog(
        Obx(() => AlertDialog(
              title: const Text("Scan Engine Barcode"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: (isScanning.value &&
                            cameraController != null &&
                            cameraController!.value.isInitialized)
                        ? CameraPreview(cameraController!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 15),
                  const Text("Align barcode and hold steady (20cm)"),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: Text("Select from Gallery",
                        style: TextStyles.textfieldTextStyle),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _closeScannerUI,
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                )
              ],
            )),
        barrierDismissible: false,
      );

      _runScanLoop();
    } catch (e) {
      _showPopup("Camera Error", "Hardware access denied.", true);
    }
  }

  Future<void> _runScanLoop() async {
    _isHandlingSuccess = false;

    try {
      // ✅ Try streaming first (works on mobile + newer Windows camera plugin)
      await cameraController!.startImageStream((CameraImage cameraImage) async {
        if (_isHandlingSuccess) return;

        try {
          final Uint8List bytes = _convertCameraImageToBytes(cameraImage);
          if (_decodeFromBytes(bytes)) {
            _isHandlingSuccess = true;
            await cameraController?.stopImageStream();
            _handleAutoClose();
          }
        } catch (e) {
          // Skip bad frames silently
        }
      });

      print("✅ [SCAN] Image stream started successfully.");
      LogFile.write("✅ [SCAN] Image stream started successfully.");
    } catch (e) {
      // ✅ Stream not supported — use frame grab loop (no file saving)
      print("⚠️ [SCAN] Stream failed ($e). Using frame grab fallback.");
      LogFile.write("⚠️ [SCAN] Stream failed ($e). Using frame grab fallback.");
      _runCaptureFallbackLoop();
    }
  }

  bool _isProcessing = false; // ✅ Prevent overlapping decode calls

  Future<void> _runCaptureFallbackLoop() async {
    while (isScanning.value && !_isHandlingSuccess) {
      if (cameraController == null || !cameraController!.value.isInitialized)
        break;
      if (_isProcessing) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      _isProcessing = true;

      try {
        final XFile file = await cameraController!.takePicture();
        final String filePath = file.path;
        final Uint8List bytes = await File(filePath).readAsBytes();

        // ✅ Delete immediately before decoding
        try {
          await File(filePath).delete();
        } catch (_) {}

        if (_decodeFromBytes(bytes)) {
          _isHandlingSuccess = true;
          _handleAutoClose();
          break;
        }
      } catch (e) {
        print("📸 Frame grab: $e");
        LogFile.write("📸 Frame grab: $e");
      } finally {
        _isProcessing = false;
      }

      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

// Helper: Convert YUV CameraImage to JPEG/PNG-like bytes
  Uint8List _convertCameraImageToBytes(CameraImage cameraImage) {
    final img.Image image = img.Image(
      width: cameraImage.width,
      height: cameraImage.height,
    );

    final plane = cameraImage.planes[0]; // Y plane (luminance)
    final bytes = plane.bytes;

    for (int y = 0; y < cameraImage.height; y++) {
      for (int x = 0; x < cameraImage.width; x++) {
        final int pixelValue = bytes[y * plane.bytesPerRow + x];
        image.setPixelRgb(x, y, pixelValue, pixelValue, pixelValue);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image));
  }

  // Inside ESNController
  bool _isHandlingSuccess = false;

  void _handleAutoClose() {
    print("DEBUG: _handleAutoClose called.");
    isScanning.value = false;
    _isProcessing = false;

    // ✅ Clean up any leftover camera temp files on Windows
    if (Platform.isWindows) {
      _cleanWindowsTempImages();
    }

    bool isOpen = Get.isDialogOpen ?? false;
    if (isOpen) {
      Get.back();
      print("DEBUG: Get.back() executed.");
    }

    if (cameraController != null) {
      cameraController?.dispose();
      cameraController = null;
    }
  }

  void _cleanWindowsTempImages() {
    try {
      // Windows camera plugin saves to %TEMP% folder
      final tempDir = Directory(Platform.environment['TEMP'] ?? '');
      if (!tempDir.existsSync()) return;

      tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.jpeg'))
          .forEach((f) {
        try {
          f.deleteSync();
        } catch (_) {}
      });

      print("🧹 Temp images cleaned.");
    } catch (e) {
      print("⚠️ Cleanup error: $e");
    }
  }

  void _closeScannerUI() {
    _isHandlingSuccess = true;
    isScanning.value = false;

    _safeStopStream().then((_) {
      if (Get.isDialogOpen ?? false) Get.back();
      Future.delayed(const Duration(milliseconds: 300), () => _disposeCamera());
    });
  }

  Future<void> _safeStopStream() async {
    try {
      if (cameraController != null &&
          cameraController!.value.isInitialized &&
          cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
    } catch (e) {
      print("⚠️ stopImageStream error (safe): $e");
    }
  }

  Future<void> pickFromGallery() async {
    try {
      await _safeStopStream();
      isScanning.value = false;

      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.single.path != null) {
        final bytes = await File(result.files.single.path!).readAsBytes();

        if (_decodeFromBytes(bytes)) {
          _handleAutoClose();
        } else {
          print("❌ No barcode found in selected image");
          LogFile.write("❌ No barcode found in selected image");
          isScanning.value = true;
          _runScanLoop();
        }
      } else {
        // User cancelled — restart
        isScanning.value = true;
        _runScanLoop();
      }
    } catch (e) {
      print("Gallery Error: $e");
      LogFile.write("Gallery Error: $e");
    }
  }

  void _disposeCamera() {
    if (cameraController != null) {
      cameraController!.dispose();
      cameraController = null;
    }
  }

  var responseMap = <int, bool>{}.obs;

  void handlePlcData(int reg, int rawX) {
    int index = sensorResults.indexWhere((s) => s['reg'] == reg);
    if (index == -1) {
      print("❌ [DEBUG] No sensor found for Register: $reg");
      LogFile.write("❌ [DEBUG] No sensor found for Register: $reg");
      return;
    }

    var s = sensorResults[index];
    s['raw'] = rawX;

    String typeStr = (s['type'] ?? s['formula'] ?? "").toString().toLowerCase();
    String name = s['sensorName'] ?? "Unknown Sensor";

    double actualValue = 0.0;

    print("\n===================================================");
    print("🔍 [PROCESSING] Name: $name | Register: $reg");
    print("📥 [PLC RAW] Value: $rawX");
    LogFile.write("\n===================================================");
    LogFile.write("🔍 [PROCESSING] Name: $name | Register: $reg");
    LogFile.write("📥 [PLC RAW] Value: $rawX");

    // =====================================================
    // ⚡ CURRENT SENSOR
    // =====================================================
    if (typeStr.contains("current")) {
      print("⚡ [MODE] CURRENT SENSOR");

      LogFile.write("⚡ [MODE] CURRENT SENSOR");

      // Print typeStr

      print("🧩 typeStr = $typeStr");

      LogFile.write("🧩 typeStr = $typeStr");

      // STEP 1: Raw Input

      print("🧩 STEP 1: Raw Input");
      print("   -> Raw PLC Value: $rawX");

      LogFile.write("🧩 STEP 1: Raw Input");
      LogFile.write("   -> Raw PLC Value: $rawX");

      // STEP 2: Voltage conversion

      double vout = rawX.toDouble() / 1000.0;

      print("🧩 STEP 2: Voltage Conversion");
      print("   -> Vout = rawX / 1000 = $vout V");

      LogFile.write("🧩 STEP 2: Voltage Conversion");
      LogFile.write("   -> Vout = rawX / 1000 = $vout V");

      // STEP 3: Offset

      double offset = 2.5;

      print("🧩 STEP 3: Offset Removal");
      print("   -> Offset = $offset V");
      print("   -> Vout - Offset = ${vout - offset}");

      LogFile.write("🧩 STEP 3: Offset Removal");
      LogFile.write("   -> Offset = $offset V");
      LogFile.write("   -> Vout - Offset = ${vout - offset}");

      // STEP 4: Current Formula

      print("🧩 STEP 4: Current Calculation");
      print("   -> Formula: I = (Vout - 2.5) / 0.185");
      print("   -> Substitution: ($vout - $offset) / 0.185");

      LogFile.write("🧩 STEP 4: Current Calculation");
      LogFile.write("   -> Formula: I = (Vout - 2.5) / 0.185");
      LogFile.write("   -> Substitution: ($vout - $offset) / 0.185");

      actualValue = (vout - offset) / 0.185;

      print(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );

      LogFile.write(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );
    }

    // current  5A
    else if (typeStr.contains("currentta")) {
      print("⚡ [MODE] CURRENT SENSOR");

      LogFile.write("⚡ [MODE] CURRENT SENSOR");

      // Print typeStr

      print("🧩 typeStr = $typeStr");

      LogFile.write("🧩 typeStr = $typeStr");

      // STEP 1: Raw Input

      print("🧩 STEP 1: Raw Input");
      print("   -> Raw PLC Value: $rawX");

      LogFile.write("🧩 STEP 1: Raw Input");
      LogFile.write("   -> Raw PLC Value: $rawX");

      // STEP 2: Voltage conversion

      double vout = rawX.toDouble() / 1000.0;

      print("🧩 STEP 2: Voltage Conversion");
      print("   -> Vout = rawX / 1000 = $vout V");

      LogFile.write("🧩 STEP 2: Voltage Conversion");
      LogFile.write("   -> Vout = rawX / 1000 = $vout V");

      // STEP 3: Offset

      double offset = 2.5;

      print("🧩 STEP 3: Offset Removal");
      print("   -> Offset = $offset V");
      print("   -> Vout - Offset = ${vout - offset}");

      LogFile.write("🧩 STEP 3: Offset Removal");
      LogFile.write("   -> Offset = $offset V");
      LogFile.write("   -> Vout - Offset = ${vout - offset}");

      // STEP 4: Current Formula

      print("🧩 STEP 4: Current Calculation");
      print("   -> Formula: I = (Vout - 2.5) / 0.185");
      print("   -> Substitution: ($vout - $offset) / 0.185");

      LogFile.write("🧩 STEP 4: Current Calculation");
      LogFile.write("   -> Formula: I = (Vout - 2.5) / 0.185");
      LogFile.write("   -> Substitution: ($vout - $offset) / 0.185");

      actualValue = (vout - offset) / 0.185;

      print(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );

      LogFile.write(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );
    }

    // cureent 20A
    else if (typeStr.contains("currentfa")) {
      print("⚡ [MODE] CURRENT SENSOR");

      LogFile.write("⚡ [MODE] CURRENT SENSOR");

      // Print typeStr

      print("🧩 typeStr = $typeStr");

      LogFile.write("🧩 typeStr = $typeStr");

      // STEP 1: Raw Input

      print("🧩 STEP 1: Raw Input");
      print("   -> Raw PLC Value: $rawX");

      LogFile.write("🧩 STEP 1: Raw Input");
      LogFile.write("   -> Raw PLC Value: $rawX");

      // STEP 2: Voltage conversion

      double vout = rawX.toDouble() / 1000.0;

      print("🧩 STEP 2: Voltage Conversion");
      print("   -> Vout = rawX / 1000 = $vout V");

      LogFile.write("🧩 STEP 2: Voltage Conversion");
      LogFile.write("   -> Vout = rawX / 1000 = $vout V");

      // STEP 3: Offset

      double offset = 2.5;

      print("🧩 STEP 3: Offset Removal");
      print("   -> Offset = $offset V");
      print("   -> Vout - Offset = ${vout - offset}");

      LogFile.write("🧩 STEP 3: Offset Removal");
      LogFile.write("   -> Offset = $offset V");
      LogFile.write("   -> Vout - Offset = ${vout - offset}");

      // STEP 4: Current Formula

      print("🧩 STEP 4: Current Calculation");
      print("   -> Formula: I = (Vout - 2.5) / 0.100");
      print("   -> Substitution: ($vout - $offset) / 0.100");

      LogFile.write("🧩 STEP 4: Current Calculation");
      LogFile.write("   -> Formula: I = (Vout - 2.5) / 0.100");
      LogFile.write("   -> Substitution: ($vout - $offset) / 0.100");

      actualValue = (vout - offset) / 0.100;

      print(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );

      LogFile.write(
        "   -> Result Current: ${actualValue.toStringAsFixed(4)} A",
      );
    }
    // =====================================================
    // 🔌 RESISTANCE SENSOR
    // =====================================================
    else if (typeStr.contains("resistance")) {
      print("⚙️ [MODE] RESISTANCE");

      LogFile.write("⚙️ [MODE] RESISTANCE");

      // Print typeStr

      print("🧩 typeStr = $typeStr");

      LogFile.write("🧩 typeStr = $typeStr");

      double defaultR1 = 1000.0;

      if (typeStr.contains("resistance(2200)")) {
        defaultR1 = 2200.0;
      } else if (typeStr.contains("resistance(100)")) {
        defaultR1 = 100.0;
      }

      // STEP 1: R1

      double r1 = (s['multiplier'] as num?)?.toDouble() ?? defaultR1;

      print("🧩 STEP 1: R1 = $r1");

      LogFile.write("🧩 STEP 1: R1 = $r1");

      // STEP 2: Vin

      double vin = (s['offset'] as num?)?.toDouble() ?? 5.0;

      print("🧩 STEP 2: Vin = $vin");

      LogFile.write("🧩 STEP 2: Vin = $vin");

      // STEP 3: Vout

      double vout = (rawX.toDouble() / 1000.0) - 0.0001;

      print("🧩 STEP 3: Vout = $vout");

      LogFile.write("🧩 STEP 3: Vout = $vout");

      if (vout >= vin) {
        vout = vin - 0.001;
      }

      if (vout < 0) {
        vout = 0;
      }

      // STEP 4: Formula

      double denominator = vin - vout;

      print(
        "🧩 STEP 4: Denominator = $denominator",
      );

      LogFile.write(
        "🧩 STEP 4: Denominator = $denominator",
      );

      // STEP 5: Final Resistance Value

      actualValue = ((r1 * vout) / denominator).round().toDouble();

      print(
        "🧩 STEP 5: Resistance Result = $actualValue Ω",
      );

      LogFile.write(
        "🧩 STEP 5: Resistance Result = $actualValue Ω",
      );
    }
    // =====================================================
    // 📊 LINEAR SENSOR
    // =====================================================
    else {
      print("⚙️ [MODE] LINEAR");

      LogFile.write("⚙️ [MODE] LINEAR");

      // STEP 1: Raw

      print("🧩 STEP 1: Raw = $rawX");

      LogFile.write("🧩 STEP 1: Raw = $rawX");

      // STEP 2: Signed conversion

      int signedRaw = rawX > 32767 ? rawX - 65536 : rawX;

      print("🧩 STEP 2: Signed = $signedRaw");

      LogFile.write(
        "🧩 STEP 2: Signed = $signedRaw",
      );

      // STEP 3: Params

      double m = (s['multiplier'] as num?)?.toDouble() ?? 0.001;

      double c = (s['offset'] as num?)?.toDouble() ?? 0.0;

      print("🧩 STEP 3: m = $m, c = $c");

      LogFile.write(
        "🧩 STEP 3: m = $m, c = $c",
      );

      // STEP 4: Formula

      print("🧩 STEP 4: y = (m × x) + c");

      LogFile.write(
        "🧩 STEP 4: y = (m × x) + c",
      );

      actualValue = (m * signedRaw) + c;

      print("   -> Result = $actualValue");

      LogFile.write(
        "   -> Result = $actualValue",
      );
    }

    // =====================================================
    // 🖥 UI UPDATE
    // =====================================================
    s['val'] = actualValue.toStringAsFixed(2);

    print("🧩 STEP 5: UI Value = ${s['val']}");
    LogFile.write("🧩 STEP 5: UI Value = ${s['val']}");

    // =====================================================
    // 📊 RANGE CHECK (optional logic kept)
    // =====================================================
    double minL = (s['min'] as num?)?.toDouble() ?? 0.0;
    double maxL = (s['max'] as num?)?.toDouble() ?? 0.0;

    bool isOk = (actualValue >= minL && actualValue <= maxL);

    s['status'] = isOk ? "OK" : "NOT OK";

    print("🧩 STEP 6: Range Check");
    print("   -> Min: $minL");
    print("   -> Max: $maxL");
    print("   -> Status: ${s['status']}");
    print("===================================================\n");
    LogFile.write("🧩 STEP 6: Range Check");
    LogFile.write("   -> Min: $minL");
    LogFile.write("   -> Max: $maxL");
    LogFile.write("   -> Status: ${s['status']}");
    LogFile.write("===================================================\n");

    sensorResults.refresh();
  }

  void sendGeneratorDataRequest(int registerAddress) {
    final plcCtrl = Get.find<PLCController>();
    if (!plcCtrl.isConnected.value) return;

    int hi = (registerAddress >> 8) & 0xFF;
    int lo = registerAddress & 0xFF;

    List<int> packet = [
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x06,
      0x01,
      0x03,
      hi,
      lo,
      0x00,
      0x01
    ];

    plcCtrl.currentRegister = registerAddress; // ⭐ ADD THIS
    plcCtrl.sendPacket(packet);
  }

  void _handleAbort(String msg) {
    print("❌ TEST WARNING => $msg");
  }

  void _showPopup(String title, String msg, bool isError) {
    Get.dialog(CustomPopup(title: title, message: msg, isError: isError));
  }

  void _showErrorPopup() {
    Get.dialog(CustomPopup(
      title: "PLC Offline",
      message: "Hardware communication lost. Check connection.",
      isError: true,
    ));
  }

  writeGeneratorDataRequest(int registerAddress, int valueToWrite) {
    final plcCtrl = Get.find<PLCController>();
    if (!plcCtrl.isConnected.value) {
      _showErrorPopup();
      return;
    }

    final int hiAddr = (registerAddress >> 8) & 0xFF;
    final int loAddr = registerAddress & 0xFF;
    final int hiVal = (valueToWrite >> 8) & 0xFF;
    final int loVal = valueToWrite & 0xFF;

    final List<int> packet = [
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x06,
      0x01,
      0x06,
      hiAddr,
      loAddr,
      hiVal,
      loVal,
    ];

    final String hexCommand = packet
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');

    print("DEBUG: Sending Write Command to PLC");
    print("HEX DATA: [ $hexCommand ]");
    print("TARGET REGISTER: $registerAddress | VALUE: $valueToWrite");

    LogFile.write("DEBUG: Sending Write Command to PLC");
    LogFile.write("HEX DATA: [ $hexCommand ]");
    LogFile.write("TARGET REGISTER: $registerAddress | VALUE: $valueToWrite");

    plcCtrl.sendPacket(packet);
  }
//>>>>>
  // Future<void> runEgrTestSequence() async {
  //   final plcCtrl = Get.find<PLCController>();

  //   if (!plcCtrl.isConnected.value) {
  //     _showErrorPopup();
  //     return;
  //   }

  //   const int readRegister = 36; // EGR current register
  //   const int writeRegister = 317; // EGR control register

  //   print("🚀 [TEST START] EGR Sequence initiated");

  //   // STEP 1: Initial Read
  //   print("📥 STEP 1: Reading initial EGR value");
  //   sendGeneratorDataRequest(readRegister);

  //   await _waitForResponse(readRegister);

  //   // STEP 2: Activate EGR
  //   print("✍️ STEP 2: Activating EGR");
  //   writeGeneratorDataRequest(writeRegister, 1);

  //   await Future.delayed(const Duration(seconds: 1));

  //   // STEP 3: Read after activation
  //   print("📥 STEP 3: Reading after activation");
  //   sendGeneratorDataRequest(readRegister);

  //   await _waitForResponse(readRegister);

  //   // STEP 4: Deactivate EGR
  //   print("🔄 STEP 4: Deactivating EGR");
  //   writeGeneratorDataRequest(writeRegister, 0);

  //   await Future.delayed(const Duration(seconds: 1));

  //   // STEP 5: Final Read
  //   print("📥 STEP 5: Final read after reset");
  //   sendGeneratorDataRequest(readRegister);

  //   await _waitForResponse(readRegister);

  //   print("✅ [TEST COMPLETE] EGR sequence finished");
  // }
  //>>>>>

  //new code
  Future<void> runEgrTestSequence() async {
    final plcCtrl = Get.find<PLCController>();

    if (!plcCtrl.isConnected.value) {
      print("❌ PLC NOT CONNECTED");
      return;
    }

    const int readRegister = 36;
    const int writeRegister = 317;

    print("🚀 [TEST START] EGR Sequence initiated");
    LogFile.write("🚀 [TEST START] EGR Sequence initiated");

    // ============================================
    // STEP 1 : INITIAL READ
    // ============================================

    print("📥 STEP 1: Reading initial EGR value");
    LogFile.write("📥 STEP 1: Reading initial EGR value");

    double? initialAvg = await _readWithTimeout(readRegister);

    print(
      "📊 INITIAL AVG VALUE => ${initialAvg?.toStringAsFixed(2)}",
    );

    LogFile.write(
      "📊 INITIAL AVG VALUE => ${initialAvg?.toStringAsFixed(2)}",
    );
    // ============================================
    // STEP 2 : ACTIVATE EGR
    // ============================================

    print("✍️ STEP 2: Activating EGR");
    LogFile.write("✍️ STEP 2: Activating EGR");

    writeGeneratorDataRequest(writeRegister, 1);

    await Future.delayed(
      const Duration(seconds: 1),
    );

    // ============================================
    // STEP 3 : READ AFTER ACTIVATION
    // ============================================

    print("📥 STEP 3: Reading after activation");
    LogFile.write("📥 STEP 3: Reading after activation");

    double? activeAvg = await _readWithTimeout(readRegister);

    print(
      "📊 ACTIVE AVG VALUE => ${activeAvg?.toStringAsFixed(2)}",
    );

    LogFile.write(
      "📊 ACTIVE AVG VALUE => ${activeAvg?.toStringAsFixed(2)}",
    );

    // ============================================
    // STEP 4 : DEACTIVATE EGR
    // ============================================

    print("🔄 STEP 4: Deactivating EGR");
    LogFile.write("🔄 STEP 4: Deactivating EGR");

    writeGeneratorDataRequest(writeRegister, 0);

    await Future.delayed(
      const Duration(seconds: 1),
    );

    // ============================================
    // STEP 5 : FINAL READ
    // ============================================

    print("📥 STEP 5: Final read after reset");
    LogFile.write("📥 STEP 5: Final read after reset");

    double? finalAvg = await _readWithTimeout(readRegister);

    print(
      "📊 FINAL AVG VALUE => ${finalAvg?.toStringAsFixed(2)}",
    );

    LogFile.write(
      "📊 FINAL AVG VALUE => ${finalAvg?.toStringAsFixed(2)}",
    );

    print("✅ [TEST COMPLETE] EGR sequence finished");
    LogFile.write("✅ [TEST COMPLETE] EGR sequence finished");
  }

//   Future<void> sendResultsToServer() async {
//   if (sensorResults.isEmpty) {
//     print("⚠️ [SAVE] Aborted: sensorResults list is empty.");
//     Get.snackbar("No Data", "No test results to save",
//         backgroundColor: Colors.orange);
//     return;
//   }

//   if (modelValidationId.value.isEmpty) {
//     print("⚠️ [SAVE] Aborted: modelValidationId is empty.");
//     Get.snackbar("Error", "Validation ID missing. Re-validate ESN.",
//         backgroundColor: Colors.redAccent);
//     return;
//   }

//   try {
//     isLoading.value = true;
//     print("🚀 [SAVE START] Preparing payload for ID: ${modelValidationId.value}");

//     // 1. Map data
//     List<Map<String, dynamic>> payload = sensorResults.map((s) => {
//           "register": int.tryParse(s['reg'].toString()) ?? 0,
//           "component": s['part'].toString(),
//           "min": double.tryParse(s['min'].toString()) ?? 0.0,
//           "max": double.tryParse(s['max'].toString()) ?? 0.0,
//           "value": double.tryParse(s['val'].toString()) ?? 0.0,
//           "result": s['status'].toString(),
//         }).toList();

//     // Verification Print: See exactly what JSON is going out
//     String jsonPayload = jsonEncode(payload);
//     print("📦 [PAYLOAD]: $jsonPayload");

//     // 2. Setup URL and Token
//     final String url = "http://139.59.76.174:8080/api/v1/support/create/${modelValidationId.value}/model-validation-session/";
//     String? token = await AppPreferences.getToken();

//     print("🌐 [URL]: $url");
//     print("🔑 [AUTH]: JWT ${token?.substring(0, 10)}..."); // Printing only start of token for security

//     // 3. Make Request
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         "Content-Type": "application/json",
//         "Authorization": "JWT $token",
//       },
//       body: jsonPayload,
//     );

//     // 4. Response Logs
//     print("📡 [RESPONSE STATUS]: ${response.statusCode}");
//     print("📡 [RESPONSE BODY]: ${response.body}");

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       print("✅ [SAVE SUCCESS] Data accepted by server.");
//       Get.snackbar("Success", "Test results saved successfully",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } else {
//       print("❌ [SAVE FAILED] Server returned an error.");
//       Get.snackbar("Error", "Failed to save data. (${response.statusCode})",
//           backgroundColor: Colors.redAccent, colorText: Colors.white);
//     }
//   } catch (e) {
//     print("🔥 [EXCEPTION] Error in sendResultsToServer: $e");
//     Get.snackbar("Error", "An unexpected error occurred");
//   } finally {
//     isLoading.value = false;
//     print("🏁 [SAVE END] isLoading set to false.");
//   }
// }

  // Future<void> sendResultsToServer() async {
  //   if (sensorResults.isEmpty) return;

  //   // 1. Prepare payload exactly like before
  //   List<Map<String, dynamic>> payload = sensorResults
  //       .map((s) => {
  //             "register": int.tryParse(s['reg'].toString()) ?? 0,
  //             "component": s['part'].toString(),
  //             "min": double.tryParse(s['min'].toString()) ?? 0.0,
  //             "max": double.tryParse(s['max'].toString()) ?? 0.0,
  //             "value": double.tryParse(s['val'].toString()) ?? 0.0,
  //             "result": s['status'].toString(),
  //           })
  //       .toList();

  //   final String url =
  //       "http://139.59.76.174:8080/api/v1/support/create/${modelValidationId.value}/model-validation-session/";

  //   try {
  //     isLoading.value = true;
  //     String? token = await AppPreferences.getToken();

  //     final response = await http
  //         .post(
  //           Uri.parse(url),
  //           headers: {
  //             "Content-Type": "application/json",
  //             "Authorization": "JWT $token"
  //           },
  //           body: jsonEncode(payload),
  //         )
  //         .timeout(const Duration(seconds: 10));

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       Get.snackbar("Success", "Data synced to server",
  //           backgroundColor: Colors.green);
  //     } else {
  //       throw HttpException("Server Error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     // 🔴 OFFLINE DETECTED or SERVER DOWN
  //     print("📡 [OFFLINE] Saving to sync queue: $e");
  //     await _saveToSyncQueue(url, payload);

  //     Get.snackbar(
  //         "Offline Mode", "Results saved locally. Will sync when online.",
  //         backgroundColor: Colors.orange, duration: const Duration(seconds: 5));
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

// Save a failed request to a local file
  Future<void> saveToSyncQueue(
      String url, List<Map<String, dynamic>> payload) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sync_queue.json');

      List<dynamic> queue = [];
      if (await file.exists()) {
        queue = jsonDecode(await file.readAsString());
      }

      // Add this request to the list
      queue.add({
        "url": url,
        "payload": payload,
        "timestamp": DateTime.now().toIso8601String(),
      });

      await file.writeAsString(jsonEncode(queue));
      print("📦 [QUEUE] Total pending items: ${queue.length}");
      LogFile.write("📦 [QUEUE] Total pending items: ${queue.length}");
    } catch (e) {
      print("❌ [QUEUE ERROR] $e");
      LogFile.write("❌ [QUEUE ERROR] $e");
    }
  }

// Background task to push data when server is active
  Future<void> syncOfflineData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sync_queue.json');

      if (!await file.exists()) return;

      List<dynamic> queue = jsonDecode(await file.readAsString());
      if (queue.isEmpty) return;

      print("🔄 [SYNC] Attempting to push ${queue.length} pending items...");
      LogFile.write(
          "🔄 [SYNC] Attempting to push ${queue.length} pending items...");
      String? token = await AppPreferences.getToken();
      List<dynamic> remainingItems = [];

      for (var item in queue) {
        try {
          final response = await http
              .post(
                Uri.parse(item['url']),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "JWT $token"
                },
                body: jsonEncode(item['payload']),
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode != 200 && response.statusCode != 201) {
            remainingItems.add(item); // Keep it in queue if server still errors
          }
        } catch (e) {
          remainingItems.add(item); // Keep it in queue if still offline
        }
      }

      // Update the file with whatever didn't sync
      await file.writeAsString(jsonEncode(remainingItems));

      if (remainingItems.length < queue.length) {
        Get.snackbar("Sync Complete", "Offline records updated on server",
            backgroundColor: Colors.blue);
      }
    } catch (e) {
      print("❌ [SYNC ERROR] $e");
      LogFile.write("❌ [SYNC ERROR] $e");
    }
  }

//

  Future<void> sendTestResultAPI() async {
    if (sensorResults.isEmpty) {
      Get.snackbar(
        "No Data",
        "No sensor data available",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      return;
    }

    try {
      isLoading.value = true;

      // ==========================================================
      // TOKEN
      // ==========================================================
      String? token = await AppPreferences.getToken();

      // ==========================================================
      // STATION ID
      // ==========================================================
     // String? stationId = await AppPreferences.getStationId();

      // ==========================================================
      // URL
      // ==========================================================
      final String url = "${AppEnvironment.baseUrl}${AppURLs.receipeData}";

      // ==========================================================
      // SENSOR LIST
      // ==========================================================
      List<Map<String, dynamic>> sensors = sensorResults.map((s) {
        return {
          "sensorName": s['part'].toString(),
          "value": s['val'].toString(),
          "test": s['status'].toString(),
          "min": double.tryParse(
                s['min'].toString(),
              ) ??
              0,
          "max": double.tryParse(
                s['max'].toString(),
              ) ??
              0,
          "unit": s['unit']?.toString() ?? "",
        };
      }).toList();

      // ==========================================================
      // OVERALL RESULT
      // ==========================================================
      bool isPass = sensorResults.every(
        (s) => s['status'] == "OK",
      );

      // ==========================================================
      // DATE TIME
      // ==========================================================
      final now = DateTime.now();

      final String currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final String currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      // ==========================================================
      // RECIPE ID
      // ==========================================================

      try {
        recipeId.value = selectedRecipe.value?.model?.toString() ?? "";
      } catch (e) {
        print("❌ Recipe ID Error : $e");
        LogFile.write("❌ Recipe ID Error : $e");
      }

      // ==========================================================
      // REQUEST BODY
      // ==========================================================
      final Map<String, dynamic> requestBody = {
        "type": "SENSOR_TEST",
        "testtype": "Live",
        //"stationId": stationId ?? "OP 10",
        "testNotStarted": "false",
        "payload": {
          "date": currentDate,
          "time": currentTime,
          "testCount": int.tryParse(
                testCount.value.toString(),
              ) ??
              0,
          "engineSerialNumber": serialNumber.value,
          "recipeID": recipeId.value,
          "modelNo": modelNumber.value,
          "variantCode": variantCode.value,
          "testId": testId.value,
          "numberOfTestAttempts": 1,
          "test_attempt_info": [
            {
              "testattemptId": "TEST-${DateTime.now().millisecondsSinceEpoch}",
              "testResult": isPass ? "Pass" : "Failed",
              "sensors": sensors,
            }
          ]
        }
      };

      print("📤 =========================");
      print("📤 RESULT API REQUEST");
      print("📤 URL : $url");
      print("📤 BODY : ${jsonEncode(requestBody)}");
      print("📤 =========================");
      LogFile.write("📤 =========================");
      LogFile.write("📤 RESULT API REQUEST");
      LogFile.write("📤 URL : $url");
      LogFile.write("📤 BODY : ${jsonEncode(requestBody)}");
      LogFile.write("📤 =========================");

      // ==========================================================
      // API CALL
      // ==========================================================
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "JWT $token",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 =========================");
      print("📥 STATUS : ${response.statusCode}");
      print("📥 RESPONSE : ${response.body}");
      print("📥 =========================");
      LogFile.write("📥 =========================");
      LogFile.write("📥 STATUS : ${response.statusCode}");
      LogFile.write("📥 RESPONSE : ${response.body}");
      LogFile.write("📥 =========================");

      // ==========================================================
      // RESPONSE PARSE
      // ==========================================================
      Map<String, dynamic> responseData = {};

      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON ERROR : $e");
        LogFile.write("❌ JSON ERROR : $e");
      }

      // ==========================================================
      // DEV LOG
      // ==========================================================
      DevService.instance.insertAPICall(
        AppAPIsCall(
          id: "${DateTime.now().millisecondsSinceEpoch}_${DateTime.now()}",
          type: "POST ${response.statusCode}",
          path: AppURLs.receipeData,
          dateTime: DateTime.now(),
          data: requestBody,
          response: responseData,
        ),
      );

      // ==========================================================
      // SESSION EXPIRED
      // ==========================================================
      if (response.statusCode == 401) {
        await AppPreferences.clearToken();

        Get.snackbar(
          "Session Expired",
          "Please login again",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );

        Future.delayed(
          const Duration(seconds: 1),
          () {
            Get.offAllNamed(
              Routes.loginScreen,
            );
          },
        );

        return;
      }

      // ==========================================================
      // SUCCESS / FAILED
      // ==========================================================
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseStatus =
            responseData['responseStatus']?.toString().toUpperCase();

        if (responseStatus == "SUCCESS" || responseStatus == "200") {
          Get.snackbar(
            "Success",
            responseData['messages']?[0]?['message'] ??
                "Test Result Uploaded Successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            responseData['responseStatusDetails']?.toString() ??
                "MES Processing Failed",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          responseData['messages']?[0]?['message'] ?? "Result Upload Failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    // ==========================================================
    // INTERNET ERROR
    // ==========================================================
    on SocketException {
      Get.snackbar(
        "No Internet",
        "Check internet connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================
    on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Server timeout",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    // ==========================================================
    // EXCEPTION
    // ==========================================================
    catch (e) {
      print("❌ RESULT API ERROR : $e");
      LogFile.write("❌ RESULT API ERROR : $e");

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> _readWithTimeout(int regAddr) async {
  //   final plcCtrl = Get.find<PLCController>();

  //   sendGeneratorDataRequest(regAddr);

  //   int timeout = 0;

  //   while (timeout < 30) {
  //     await Future.delayed(const Duration(milliseconds: 100));

  //     if (!plcCtrl.isConnected.value) {
  //       return false;
  //     }

  //     int index = sensorResults.indexWhere((s) => s['reg'] == regAddr);

  //     if (index != -1 && sensorResults[index]['val'] != "-") {
  //       return true;
  //     }

  //     timeout++;
  //   }

  //   return false;
  // }

  // Future<bool> _readWithTimeout(int regAddr) async {
  //   final plcCtrl = Get.find<PLCController>();

  //   print(
  //       "📤 [READ REQUEST] Reg: $regAddr | PLC Connected: ${plcCtrl.isConnected.value}");

  //   // ✅ Guard: don't even try if PLC offline
  //   if (!plcCtrl.isConnected.value) {
  //     print("❌ [READ SKIP] PLC not connected for reg: $regAddr");
  //     return false;
  //   }

  //   sendGeneratorDataRequest(regAddr);

  //   int timeout = 0;

  //   while (timeout < 50) {
  //     // ✅ Increased from 30 to 50 (5 seconds total)
  //     await Future.delayed(const Duration(milliseconds: 100));

  //     int index = sensorResults.indexWhere((s) => s['reg'] == regAddr);

  //     if (index != -1 && sensorResults[index]['val'] != "-") {
  //       print(
  //           "✅ [READ OK] Reg: $regAddr | Val: ${sensorResults[index]['val']} | Attempts: $timeout");
  //       return true;
  //     }

  //     timeout++;
  //     if (timeout % 10 == 0) {
  //       print("⏳ [WAITING] Reg: $regAddr | Attempt: $timeout/50");
  //     }
  //   }

  //   print("⌛ [TIMEOUT] No response for reg: $regAddr after ${timeout * 100}ms");
  //   return false;
  // }

  //>>>>>>>

  // Future<bool> _readWithTimeout(int regAddr) async {
  //   final plcCtrl = Get.find<PLCController>();

  //   print(
  //       "📤 [READ REQUEST] Reg: $regAddr | PLC Connected: ${plcCtrl.isConnected.value}");

  //   if (!plcCtrl.isConnected.value) {
  //     print("❌ [READ SKIP] PLC not connected");
  //     return false;
  //   }

  //   sendGeneratorDataRequest(regAddr);

  //   int timeout = 0;
  //   while (timeout < 50) {
  //     // 5 seconds total
  //     await Future.delayed(const Duration(milliseconds: 100));

  //     // We look for the sensor that is currently assigned this register
  //     int index = sensorResults.indexWhere((s) => s['reg'] == regAddr);

  //     if (index != -1 && sensorResults[index]['val'] != "-") {
  //       print(
  //           "✅ [READ OK] Reg: $regAddr | Val: ${sensorResults[index]['val']}");
  //       return true;
  //     }

  //     timeout++;
  //     if (timeout % 10 == 0) {
  //       print("⏳ [WAITING] Reg: $regAddr | Attempt: $timeout/50");
  //     }
  //   }

  //   print("⌛ [TIMEOUT] No response for reg: $regAddr");
  //   return false;
  // }

  // READ 10 TIMES

  Future<double?> _readWithTimeout(int regAddr) async {
    final plcCtrl = Get.find<PLCController>();

    print(
      "📤 [READ REQUEST] Reg: $regAddr | PLC Connected: ${plcCtrl.isConnected.value}",
    );
    LogFile.write(
      "📤 [READ REQUEST] Reg: $regAddr | PLC Connected: ${plcCtrl.isConnected.value}",
    );

    if (!plcCtrl.isConnected.value) {
      print("❌ [READ SKIP] PLC not connected");
      LogFile.write("❌ [READ SKIP] PLC not connected");

      return null;
    }

    List<double> readings = [];

    // =====================================
    // READ 10 TIMES
    // =====================================

    for (int i = 0; i < 5; i++) {
      print("▶️ Step ${i + 1}: READ | Reg: $regAddr");
      LogFile.write("▶️ Step ${i + 1}: READ | Reg: $regAddr");

      // CLEAR OLD VALUE

      int index = sensorResults.indexWhere(
        (s) => s['reg'] == regAddr,
      );

      if (index != -1) {
        sensorResults[index]['val'] = "-";
      }

      // SEND REQUEST

      sendGeneratorDataRequest(regAddr);

      int timeout = 0;

      while (timeout < 8) {
        await Future.delayed(
          const Duration(milliseconds: 80),
        );

        int index = sensorResults.indexWhere(
          (s) => s['reg'] == regAddr,
        );

        if (index != -1 && sensorResults[index]['val'] != "-") {
          final value = double.tryParse(
                sensorResults[index]['val'].toString(),
              ) ??
              0.0;

          readings.add(value);

          print(
            "✅ [READ OK] Reg: $regAddr | Val: $value",
          );
          LogFile.write(
            "✅ [READ OK] Reg: $regAddr | Val: $value",
          );

          break;
        }

        timeout++;
      }

      await Future.delayed(
        const Duration(milliseconds: 200),
      );
    }

    // =====================================
    // NO VALUES
    // =====================================

    if (readings.isEmpty) {
      print(
        "⌛ [TIMEOUT] No response for reg: $regAddr",
      );

      return null;
    }

    // =====================================
    // CALCULATE AVG
    // =====================================

    double total = 0;

    for (double value in readings) {
      total += value;
    }

    double avg = total / readings.length;

    String finalAvg = avg.toStringAsFixed(2);

    // =====================================
    // UPDATE RESULT
    // =====================================

    int index = sensorResults.indexWhere(
      (s) => s['reg'] == regAddr,
    );

    if (index != -1) {
      sensorResults[index]['val'] = finalAvg;

      sensorResults[index]['avg'] = finalAvg;

      sensorResults[index]['allValues'] = readings
          .map(
            (e) => e.toStringAsFixed(2),
          )
          .toList();

      sensorResults[index]['totalReads'] = readings.length;
    }

    // =====================================
    // FINAL OUTPUT
    // =====================================

    print("");
    print("===================================================");

    print(
      "📊 [AVG RESULT] Register: $regAddr",
    );

    print(
      "📥 All Values => ${sensorResults[index]['allValues']}",
    );

    print(
      "🔢 Total Reads => ${readings.length}",
    );

    print(
      "✅ Final AVG => $finalAvg",
    );

    print("===================================================");
    print("");
    LogFile.write("");
    LogFile.write("===================================================");

    LogFile.write(
      "📊 [AVG RESULT] Register: $regAddr",
    );

    LogFile.write(
      "📥 All Values => ${sensorResults[index]['allValues']}",
    );

    LogFile.write(
      "🔢 Total Reads => ${readings.length}",
    );

    LogFile.write(
      "✅ Final AVG => $finalAvg",
    );

    LogFile.write("===================================================");
    LogFile.write("");

    return avg;
  }
  // Future<void> startTestingSequence() async {
  //   final plcCtrl = Get.find<PLCController>();

  //   if (!plcCtrl.isConnected.value) {
  //     _showPopup("Hardware Offline", "Connect PLC first", true);
  //     return;
  //   }

  //   if (isTesting.value) return;
  //   isTesting.value = true;

  //   for (var sensor in sensorResults) {
  //     List operations = sensor['operations'] ?? [];

  //     print("\n🚀 [SENSOR START] ${sensor['part']}");

  //     for (int i = 0; i < operations.length; i++) {
  //       var op = operations[i];

  //       String operation = op.operation; // READ / WRITE
  //       int reg = int.tryParse(op.registerAddress) ?? sensor['reg'];
  //       int value = int.tryParse(op.value) ?? 0;

  //       print("▶️ Step ${i + 1}: $operation | Reg: $reg | Val: $value");

  //       // UI update
  //       sensor['status'] = "TESTING...";
  //       sensorResults.refresh();

  //       // =========================
  //       // 🔵 READ
  //       // =========================
  //       if (operation == "READ") {
  //         bool received = await _readWithTimeout(reg);

  //         if (!received) {
  //           sensor['status'] = "TIMEOUT";
  //           sensorResults.refresh();

  //           _handleAbort("Timeout at ${sensor['part']}");
  //           return;
  //         }
  //       }

  //       // =========================
  //       // 🟠 WRITE
  //       // =========================
  //       else if (operation == "WRITE") {
  //         writeGeneratorDataRequest(reg, value);

  //         await Future.delayed(const Duration(milliseconds: 500));
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //     }

  //     // ✅ After all operations for this specific sensor are done
  //     sensor['status'] = "OK";
  //     sensorResults.refresh();
  //   }

  //   // ✅ SEQUENCE COMPLETE
  //   isTesting.value = false;

  //   // --- AUTOMATIC API CALL ---
  //   print("📡 [AUTO-SAVE] Sequence complete. Sending data to server...");
  //   await sendResultsToServer();

  //   _showPopup(
  //       "Complete", "Sequence executed and data saved successfully", false);
  // }

  Future<void> startTestingSequence() async {
    final plcCtrl = Get.find<PLCController>();

    if (!plcCtrl.isConnected.value) {
      _showPopup("Hardware Offline", "Connect PLC first", true);
      return;
    }

    if (isTesting.value) return;
    isTesting.value = true;

    for (var sensor in sensorResults) {
      List operations = sensor['operations'] ?? [];
      print("\n🚀 [SENSOR START] ${sensor['part']}");
      LogFile.write("\n🚀 [SENSOR START] ${sensor['part']}");

      // ✅ Store the original primary register to restore it later
      final int originalPrimaryReg = sensor['reg'] ?? 0;
      bool sensorPassed = true;

      for (int i = 0; i < operations.length; i++) {
        var op = operations[i];
        String operation = op.operation;
        int currentStepReg =
            int.tryParse(op.registerAddress) ?? originalPrimaryReg;
        int value = int.tryParse(op.value) ?? 0;

        print("▶️ Step ${i + 1}: $operation | Reg: $currentStepReg");
        LogFile.write("▶️ Step ${i + 1}: $operation | Reg: $currentStepReg");

        sensor['status'] = "TESTING...";
        sensorResults.refresh();

        // --- WRITE OPERATION ---
        if (operation == "WRITE") {
          writeGeneratorDataRequest(currentStepReg, value);
          await Future.delayed(const Duration(milliseconds: 600));
        }

        // --- READ OPERATION ---
        else if (operation == "READ") {
          // 🛡️ TEMP REG ASSIGN

          sensor['reg'] = currentStepReg;

          sensor['val'] = "-";

          sensorResults.refresh();

          // =====================================
          // READ + AVG
          // =====================================

          double? received = await _readWithTimeout(currentStepReg);

          // =====================================
          // TIMEOUT
          // =====================================

          if (received == null) {
            sensor['reg'] = originalPrimaryReg;

            sensor['status'] = "TIMEOUT";

            sensorResults.refresh();

            _handleAbort(
              "Timeout at register $currentStepReg",
            );

            return;
          }

          // Logic Comparison (Pass/Fail check)
          double? actual = double.tryParse(sensor['val'].toString());
          double? min = (sensor['min'] as num?)?.toDouble();
          double? max = (sensor['max'] as num?)?.toDouble();

          if (actual != null && min != null && max != null) {
            if (actual < min || actual > max) {
              sensorPassed = false;
            }
          }
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // ✅ CRITICAL: Restore the original primary register after all steps are done
      sensor['reg'] = originalPrimaryReg;

      // Final result for this sensor
      sensor['status'] = sensorPassed ? "OK" : "NOT OK";
      sensorResults.refresh();
      print("🏁 [SENSOR DONE] ${sensor['part']} -> ${sensor['status']}");
      LogFile.write("🏁 [SENSOR DONE] ${sensor['part']} -> ${sensor['status']}");
    }

    isTesting.value = false;
    await sendTestResultAPI();
    _showPopup(
        "Complete", "Sequence executed and data saved successfully", false);
  }

  Future<void> startTestingSequence1() async {
    final plcCtrl = Get.find<PLCController>();

    // ==========================================================
    // PLC CONNECTION CHECK
    // ==========================================================
    if (!plcCtrl.isConnected.value) {
      _showPopup(
        "Hardware Offline",
        "Connect PLC first",
        true,
      );

      return;
    }

    if (isTesting.value) return;

    try {
      isTesting.value = true;
      isLoading.value = true;

      // ==========================================================
      // STATION ID
      // ==========================================================
    // String? stationId = await AppPreferences.getStationId();

      // ==========================================================
      // TOKEN
      // ==========================================================
      String? token = await AppPreferences.getToken();

      // ==========================================================
      // URL
      // ==========================================================
      final String url = "${AppEnvironment.baseUrl}${AppURLs.receipeData}";

      // ==========================================================
      // REQUEST BODY
      // ==========================================================
      final Map<String, dynamic> requestBody = {
        "type": "SENSOR_TEST",
       // "stationID": stationId ?? "SENSOR_1",
        "requestParameters": {
          "engineSerialNumber": serialNumber.value,
        }
      };

      print("📤 =============================");
      print("📤 SCHEDULE API REQUEST");
      print("📤 URL : $url");
      print("📤 BODY : ${jsonEncode(requestBody)}");
      print("📤 =============================");

      LogFile.write("📤 =============================");
      LogFile.write("📤 SCHEDULE API REQUEST");
      LogFile.write("📤 URL : $url");
      LogFile.write("📤 BODY : ${jsonEncode(requestBody)}");
      LogFile.write("📤 =============================");

      // ==========================================================
      // API CALL
      // ==========================================================
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "JWT $token",
        },
        body: jsonEncode(requestBody),
      );

      print("📥 =============================");
      print("📥 STATUS : ${response.statusCode}");
      print("📥 RESPONSE : ${response.body}");
      print("📥 =============================");

      LogFile.write("📥 =============================");
      LogFile.write("📥 STATUS : ${response.statusCode}");
      LogFile.write("📥 RESPONSE : ${response.body}");
      LogFile.write("📥 =============================");


      // ==========================================================
      // RESPONSE PARSE
      // ==========================================================
      Map<String, dynamic> responseData = {};

      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print("❌ JSON PARSE ERROR : $e");
        LogFile.write("❌ JSON PARSE ERROR : $e");
      }

      // ==========================================================
      // DEV LOG
      // ==========================================================
      DevService.instance.insertAPICall(
        AppAPIsCall(
          id: "${DateTime.now().millisecondsSinceEpoch}_${DateTime.now()}",
          type: "POST ${response.statusCode}",
          path: AppURLs.receipeData,
          dateTime: DateTime.now(),
          data: requestBody,
          response: responseData,
        ),
      );

      // ==========================================================
      // SESSION EXPIRED
      // ==========================================================
      if (response.statusCode == 401) {
        print("🚨 TOKEN EXPIRED");
        LogFile.write("🚨 TOKEN EXPIRED");

        await AppPreferences.clearToken();

        Get.snackbar(
          "Session Expired",
          "Please login again",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );

        Future.delayed(
          const Duration(seconds: 1),
          () {
            Get.offAllNamed(
              Routes.loginScreen,
            );
          },
        );

        return;
      }

      // ==========================================================
      // API FAILED
      // ==========================================================
      if (response.statusCode != 200 && response.statusCode != 201) {
        Get.snackbar(
          "Error",
          responseData['messages']?[0]?['message'] ?? "Schedule API Failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        isTesting.value = false;

        return;
      }

      // ==========================================================
      // RESPONSE VALIDATION
      // ==========================================================
      final responseStatus =
          responseData['responseStatus']?.toString().toUpperCase();

      if (responseStatus != "SUCCESS") {
        Get.snackbar(
          "Error",
          responseData['responseStatusDetails']?.toString() ??
              "MES Rejected Request",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        isTesting.value = false;

        return;
      }

      // ==========================================================
      // RESPONSE DATA
      // ==========================================================
      final data = responseData['data'] ?? {};

      final responseParameter = data['responseParameter'] ?? {};

      testId.value = data['testID']?.toString() ?? "";

      final String recipeId = responseParameter['recipeid']?.toString() ?? "";

      final String modelNo = responseParameter['modelno']?.toString() ?? "";

      final String varientCode =
          responseParameter['varientCode']?.toString() ?? "";

      print("✅ TEST ID : $testId");
      print("✅ RECIPE ID : $recipeId");
      print("✅ MODEL : $modelNo");
      print("✅ VARIANT : $varientCode");

      LogFile.write("✅ TEST ID : $testId");
      LogFile.write("✅ RECIPE ID : $recipeId");
      LogFile.write("✅ MODEL : $modelNo");
      LogFile.write("✅ VARIANT : $varientCode");

      // ==========================================================
      // UPDATE VALUES
      // ==========================================================
      modelNumber.value = modelNo;

      variantCode.value = varientCode;

      selectedRecipe.value?.model = recipeId;

      print("✅ SCHEDULE API SUCCESS");
      LogFile.write("✅ SCHEDULE API SUCCESS");

      // ==========================================================
      // START SENSOR TESTING
      // ==========================================================
      for (var sensor in sensorResults) {
        List operations = sensor['operations'] ?? [];

        print(
          "\n🚀 [SENSOR START] ${sensor['part']}",
        );
         LogFile.write(
          "\n🚀 [SENSOR START] ${sensor['part']}",
        );

        final int originalPrimaryReg = sensor['reg'] ?? 0;

        bool sensorPassed = true;

        for (int i = 0; i < operations.length; i++) {
          var op = operations[i];

          String operation = op.operation.toString();

          int currentStepReg = int.tryParse(
                op.registerAddress.toString(),
              ) ??
              originalPrimaryReg;

          int value = int.tryParse(
                op.value.toString(),
              ) ??
              0;

          print(
            "▶️ Step ${i + 1}: "
            "$operation | "
            "Reg: $currentStepReg | "
            "Value: $value",
          );

          LogFile.write(
            "▶️ Step ${i + 1}: "
            "$operation | "
            "Reg: $currentStepReg | "
            "Value: $value",
          );


          sensor['status'] = "TESTING...";

          sensorResults.refresh();

          // ======================================================
          // WRITE OPERATION
          // ======================================================
          if (operation == "WRITE") {
            writeGeneratorDataRequest(
              currentStepReg,
              value,
            );

            await Future.delayed(
              const Duration(
                milliseconds: 600,
              ),
            );
          }

          // ======================================================
          // READ OPERATION
          // ======================================================
          else if (operation == "READ") {
            sensor['reg'] = currentStepReg;

            sensor['val'] = "-";

            sensorResults.refresh();

            double? received = await _readWithTimeout(
              currentStepReg,
            );

            if (received != null) {
              sensor['reg'] = originalPrimaryReg;
              sensor['status'] = "OK";

              sensor['val'] = received.toStringAsFixed(2);

              sensorResults.refresh();

              print("");

              print("===================================");

              print(
                "✅ FINAL AVG VALUE => "
                "${received.toStringAsFixed(2)}",
              );
              LogFile.write(
                "✅ FINAL AVG VALUE => "
                "${received.toStringAsFixed(2)}",
              );

              print("===================================");

              print("");
            }

            double? actual = double.tryParse(
              sensor['val'].toString(),
            );

            double? min = (sensor['min'] as num?)?.toDouble();

            double? max = (sensor['max'] as num?)?.toDouble();

            if (actual != null && min != null && max != null) {
              if (actual < min || actual > max) {
                sensorPassed = false;
              }
            }
          }

          await Future.delayed(
            const Duration(
              milliseconds: 300,
            ),
          );
        }

        sensor['reg'] = originalPrimaryReg;

        sensor['status'] = sensorPassed ? "OK" : "NOT OK";

        sensorResults.refresh();

        print(
          "🏁 [SENSOR DONE] "
          "${sensor['part']} "
          "-> ${sensor['status']}",
        );

        LogFile.write(
          "🏁 [SENSOR DONE] "
          "${sensor['part']} "
          "-> ${sensor['status']}",
        );
      }

      // ==========================================================
      // TEST COMPLETE
      // ==========================================================
      isTesting.value = false;

      print("📡 AUTO RESULT API CALL");
      LogFile.write("📡 AUTO RESULT API CALL");

      await sendTestResultAPI();

      _showPopup(
        "Complete",
        "Sequence executed successfully",
        false,
      );
    }

    // ==========================================================
    // INTERNET ERROR
    // ==========================================================
    on SocketException {
      Get.snackbar(
        "No Internet",
        "Check internet connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================
    on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Server timeout",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    // ==========================================================
    // EXCEPTION
    // ==========================================================
    catch (e) {
      print(
        "❌ startTestingSequence ERROR : $e",
      );

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;

      isTesting.value = false;
    }
  }

  // Future<void> startTestingSequence() async {
  //   final plcCtrl = Get.find<PLCController>();

  //   if (!plcCtrl.isConnected.value) {
  //     _showPopup("Hardware Offline", "Connect PLC first", true);
  //     return;
  //   }

  //   if (isTesting.value) return;
  //   isTesting.value = true;

  //   for (var sensor in sensorResults) {
  //     List operations = sensor['operations'] ?? [];

  //     print("\n🚀 [SENSOR START] ${sensor['part']}");

  //     for (int i = 0; i < operations.length; i++) {
  //       var op = operations[i];

  //       String operation = op.operation; // READ / WRITE
  //       int reg = int.tryParse(op.registerAddress) ?? sensor['reg'];
  //       int value = int.tryParse(op.value) ?? 0;

  //       print("▶️ Step ${i + 1}: $operation | Reg: $reg | Val: $value");

  //       // UI update
  //       sensor['status'] = "TESTING...";
  //       sensorResults.refresh();

  //       // =========================
  //       // 🔵 READ
  //       // =========================
  //       if (operation == "READ") {
  //         bool received = await _readWithTimeout(reg);

  //         if (!received) {
  //           sensor['status'] = "TIMEOUT";
  //           sensorResults.refresh();

  //           _handleAbort("Timeout at ${sensor['part']}");
  //           return;
  //         }
  //       }

  //       // =========================
  //       // 🟠 WRITE
  //       // =========================
  //       else if (operation == "WRITE") {
  //         writeGeneratorDataRequest(reg, value);

  //         await Future.delayed(const Duration(milliseconds: 500));
  //       }

  //       await Future.delayed(const Duration(milliseconds: 300));
  //     }

  //     // ✅ After all operations
  //     sensor['status'] = "OK";
  //     sensorResults.refresh();
  //   }

  //   isTesting.value = false;

  //   _showPopup("Complete", "Sequence executed successfully", false);
  // }
}
