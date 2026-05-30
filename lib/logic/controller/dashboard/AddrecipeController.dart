import 'dart:convert';
import 'dart:io';
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/testRecipeController.dart';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddRecipeController extends GetxController {
  // ── Mode ────────────────────────────────────────────────────────────────────
  var isWriteMode = false.obs;
  var isEditMode = false.obs;
  var isAddingSensor = false.obs;
  var hasTested = false.obs;
  var isEdit = false.obs;
  var editingSensorName = "".obs;

  // ── Sensor table state ───────────────────────────────────────────────────────
  RxList<SensorConfig> addedSensors = <SensorConfig>[].obs;
  final RxSet<String> expandedSensors = <String>{}.obs;
  // ── R2 SENSOR CONTROLLERS ─────────────────────
  final r1Controller = TextEditingController();
  final vinController = TextEditingController();
  final voutController = TextEditingController();
  final resultController = TextEditingController();

// ── LINEAR SENSOR CONTROLLERS ─────────────────
  final mController = TextEditingController();
  final xController = TextEditingController();
  final cController = TextEditingController();
  // final TextEditingController sensorType = TextEditingController();

  // ── Form controllers ─────────────────────────────────────────────────────────
  final modelController = TextEditingController().obs;
  final typeController = TextEditingController().obs;
  final sensorName = TextEditingController().obs;
  final sensorType = TextEditingController().obs;
  final registerNumber = TextEditingController().obs;
  final min = TextEditingController().obs;
  final max = TextEditingController().obs;
  final offset = TextEditingController(text: "1.0").obs;
  final multiplier = TextEditingController(text: "0.0").obs;
  final unit = TextEditingController().obs;
  final testResult = TextEditingController().obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadLocalData();
    // initListeners();
    if (Get.arguments != null && Get.arguments is Recipe) {
      final recipe = Get.arguments as Recipe;
      modelController.value.text = recipe.model ?? "";
      typeController.value.text = recipe.type ?? "";
      addedSensors.assignAll(
        recipe.sensors.map<SensorConfig>((s) => SensorConfig(
              sensorName: s.sensorName ?? "",
              sensorType: s.sensorType ?? "",
              registerNumber: s.registerNumber,
              min: s.min,
              max: s.max,
              multiplier: s.multiplier,
              offset: s.offset,
              unit: s.unit,
              testResult: s.testResult,
              operations: List.from(s.operations), // preserve logs
            )),
      );
      isEditMode.value = true;
    }
  }

  Future<void> _loadLocalData() async {
    // ✅ Change from getAllMapRecipes to the user-specific method
    List<Recipe> localRecipes = await AppPreferences.getRecipesForCurrentUser();

    // Find the controller that holds the main list
    final testController = Get.find<TestRecipeController>();

    // Fill the list so it displays on your dashboard
    // This ensures only the logged-in user's data is shown
    testController.recipeList.assignAll(localRecipes);
    testController.recipeList.refresh();

    print(
        "✅ Successfully loaded ${localRecipes.length} recipes for current user.");
  }

  @override
  void onClose() {
    modelController.value.dispose();
    typeController.value.dispose();
    sensorName.value.dispose();
    sensorType.value.dispose();
    registerNumber.value.dispose();
    min.value.dispose();
    max.value.dispose();
    multiplier.value.dispose();
    offset.value.dispose();
    unit.value.dispose();
    testResult.value.dispose();
    super.onClose();
  }

  // ── Expand / collapse ────────────────────────────────────────────────────────
  void toggleSensorExpanded(String name) {
    if (expandedSensors.contains(name)) {
      expandedSensors.remove(name);
    } else {
      expandedSensors.add(name);
    }
  }

  void saveSensorToList() async {
    if (sensorName.value.text.isEmpty) return;

    // 1. Parse common values
    final double minVal = double.tryParse(min.value.text) ?? 0.0;
    final double maxVal = double.tryParse(max.value.text) ?? 0.0;
    final String currentType = sensorType.value.text.toLowerCase();

    // 2. PRESERVE OPERATIONS (Logs)
    List<OperationLog> existingOps = [];
    if (editingSensorIndex.value != -1) {
      existingOps = (addedSensors[editingSensorIndex.value].operations)
          .cast<OperationLog>();
    }

    // 3. CREATE SENSOR CONFIG
    // We no longer calculate 'result' here because 'result' depends on live PLC data.
    // We just store the configuration constants.

    final updatedSensor = SensorConfig(
      sensorName: sensorName.value.text,
      sensorType: sensorType.value.text,
      registerNumber: int.tryParse(registerNumber.value.text),
      min: minVal,
      max: maxVal,
      unit: unit.value.text,
      operations: existingOps,

      // --- Logic for Formula Constants ---
      // If Resistance mode: Save R1 and Vin. Otherwise: Save M and C.
      multiplier: currentType.contains("resistance")
          ? (double.tryParse(r1Controller.text)) // Store R1 in multiplier field
          : (double.tryParse(multiplier.value.text)),

      offset: currentType.contains("resistance")
          ? (double.tryParse(vinController.text) ??
              5.0) // Store Vin in offset field
          : (double.tryParse(offset.value.text)),

      testResult: "Pending", // Calculation happens live in handlePlcData
    );

    // 4. LIST UPDATE
    if (editingSensorIndex.value != -1) {
      addedSensors[editingSensorIndex.value] = updatedSensor;
      editingSensorIndex.value = -1;
    } else {
      addedSensors.add(updatedSensor);
    }

    // 5. AUTO-SAVE & UI CLEANUP
    if (isEditMode.value) {
      await _updateCurrentRecipeInPrefs();
    }

    hasTested.value = false;
    isAddingSensor.value = false;
    // _clearSensorFields(); // Recommended to clear after save
  }

// Helper to sync the current form state to preferences
  Future<void> _updateCurrentRecipeInPrefs() async {
    // Ensure we have a model name before saving to the user's map
    if (modelController.value.text.trim().isEmpty) return;

    final Recipe updatedRecipe = Recipe(
      sr: isEditMode.value ? (Get.arguments as Recipe).sr : "temp",
      model: modelController.value.text.trim(),
      type: typeController.value.text.trim(),
      sensors: List.from(addedSensors),
    );

    // ✅ Fixed variable name: passing updatedRecipe instead of finalRecipe
    await AppPreferences.saveRecipeForCurrentUser(updatedRecipe);
  }

  var editingSensorIndex = (-1).obs;

  void editSensor(SensorConfig sensor) {
    // 1. Find the index for updating later
    editingSensorIndex.value = addedSensors.indexOf(sensor);
    isAddingSensor.value = true;

    // 2. Map Common Fields
    sensorName.value.text = sensor.sensorName ?? '';
    sensorType.value.text =
        sensor.sensorType ?? ''; // Matches your .obs controller
    registerNumber.value.text = (sensor.registerNumber ?? 0).toString();
    min.value.text = (sensor.min ?? 0.0).toString();
    max.value.text = (sensor.max ?? 0.0).toString();
    unit.value.text = sensor.unit ?? '';
    testResult.value.text = sensor.testResult ?? '';

    // 3. Map Formula-Specific Fields
    final String type = (sensor.sensorType ?? '').toLowerCase();

    if (type.contains("resistance")) {
      // If it's a Resistance sensor:
      // Stored 'multiplier' is actually R1
      // Stored 'offset' is actually Vin
      r1Controller.text = (sensor.multiplier ?? 10000.0).toString();
      vinController.text = (sensor.offset ?? 5.0).toString();

      // Clear the linear fields to avoid confusion
      multiplier.value.clear();
      offset.value.clear();
    } else {
      // If it's a Linear sensor (y = mx + c):
      multiplier.value.text = (sensor.multiplier ?? 1.0).toString();
      offset.value.text = (sensor.offset ?? 0.0).toString();

      // Clear the resistance fields
      r1Controller.clear();
      vinController.clear();
    }

    // 4. Trigger UI Refresh
    // This ensures the Obx in your UI shows the correct input fields immediately
    sensorType.refresh();
  }

  // ── Operation log (stored directly on SensorConfig) ──────────────────────────
  // void logOperation({
  //   required String sensorName,
  //   required String operation, // "READ" or "WRITE"
  //   required String value,
  // }) {
  //   final sensor =
  //       addedSensors.firstWhereOrNull((s) => s.sensorName == sensorName);
  //   if (sensor == null) return;

  //   sensor.addLog(
  //     operation: operation,
  //     registerAddress: registerNumber.value.text,
  //     value: value,
  //   );
  //   addedSensors.refresh(); // triggers Obx rebuild in view
  // }
  void logOperation({
    required String sensorName,
    required String operation,
    required String value,
  }) {
    // ✅ Find by name — works whether editing or not
    final int sensorIndex = addedSensors.indexWhere(
      (s) => s.sensorName == sensorName,
    );

    if (sensorIndex == -1) {
      print(
          "❌ [LOG] Sensor '$sensorName' not found in list. Save sensor first.");
      Get.snackbar(
        "Save First",
        "Please save the sensor to table before logging operations",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String reg = registerNumber.value.text.trim();

    // ✅ For WRITE: use testResult as value
    // ✅ For READ:  use passed value (or empty string)
    final String logValue =
        operation == "WRITE" ? testResult.value.text.trim() : value;

    if (reg.isEmpty) {
      Get.snackbar(
        "Missing Register",
        "Please enter a register address before logging",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    addedSensors[sensorIndex].operations.add(
          OperationLog(
            operation: operation,
            registerAddress: reg,
            value: logValue,
            timestamp: DateTime.now().toString().substring(11, 19),
            sensorName: sensorName,
          ),
        );

    addedSensors.refresh();

    print(
        "✅ [LOG] ${operation} logged for '$sensorName' | Reg: $reg | Val: $logValue");

    Get.snackbar(
      "Logged",
      "$operation added to $sensorName",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void deleteOperationLog(int logIndex) {
    // ✅ Use editingSensorIndex if available, otherwise find by expanded sensor
    int targetIndex = editingSensorIndex.value;

    // ✅ Fallback: find by expanded sensor name
    if (targetIndex == -1) {
      final String expandedName =
          expandedSensors.isNotEmpty ? expandedSensors.first : "";

      if (expandedName.isNotEmpty) {
        targetIndex = addedSensors.indexWhere(
          (s) => s.sensorName == expandedName,
        );
      }
    }

    if (targetIndex == -1) {
      Get.snackbar(
        "Error",
        "Could not find sensor to delete operation from",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final sensor = addedSensors[targetIndex];

    if (logIndex < 0 || logIndex >= sensor.operations.length) {
      print("❌ [DELETE] Invalid log index: $logIndex");
      return;
    }

    final String deletedOp = sensor.operations[logIndex].operation;
    sensor.operations.removeAt(logIndex);
    addedSensors[targetIndex] = sensor; // ✅ Force Obx update
    addedSensors.refresh();

    print(
        "🗑️ [DELETE] $deletedOp at index $logIndex deleted from ${sensor.sensorName}");
  }

  void addRecipe() async {
    if (modelController.value.text.trim().isEmpty) {
      Get.snackbar("Error", "Model name is required");
      return;
    }

    try {
      final String modelName = modelController.value.text.trim();
      final testController = Get.find<TestRecipeController>();

      // ✅ CRITICAL: Determine the ID
      // If editing, we MUST use the same 'sr' that was passed into the screen.
      // This ensures the Map replaces the old entry instead of adding a new one.
      final String uniqueId = isEditMode.value
          ? (Get.arguments as Recipe).sr! // Add the ! here
          : DateTime.now().millisecondsSinceEpoch.toString();

      final Recipe finalRecipe = Recipe(
        sr: uniqueId,
        model: modelName,
        type: typeController.value.text.trim(),
        sensors: List.from(addedSensors),
      );

      print(
          "🚀 [START SAVE] Operation: ${isEditMode.value ? 'UPDATE' : 'ADD NEW'}");
      print(
          "📦 [DATA CHECK] ID: $uniqueId | Model: $modelName | Sensors: ${addedSensors.length}");

      // 1. SAVE: This overwrites the previous entry in the Map if uniqueId exists
      await AppPreferences.saveRecipeForCurrentUser(finalRecipe);
      print("✅ [STEP 1] Recipe synced to storage for current user.");

      // 2. REFRESH
      // await testController.loadStoredRecipes();
      if (Get.isRegistered<TestRecipeController>()) {
    final testCtrl = Get.find<TestRecipeController>();
    await testCtrl.loadStoredRecipes();
    print("🔄 [SYNC] Recipes reloaded. Count: ${testCtrl.recipeList.length}");
  }
      print(
          "✅ [STEP 2] Dashboard refreshed. Count: ${testController.recipeList.length}");

      // 3. UI Cleanup
      _resetForm();
     // Get.back();

      Get.snackbar(
        "Success",
        isEditMode.value ? "Updated $modelName" : "Saved $modelName",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Get.toNamed(Routes.testRecipeScreen);
      Get.offAllNamed(Routes.testRecipeScreen);
    } catch (e) {
      print("❌ [CRITICAL ERROR] Failed to save recipe: $e");
      Get.snackbar("Error", "Failed to save recipe locally");
    }
  }

  // void deleteOperationLog(int logIndex) {
  //   if (editingSensorIndex.value != -1) {
  //     // 1. Get the current sensor
  //     var currentSensor = addedSensors[editingSensorIndex.value];

  //     // 2. Safety check for the index
  //     if (logIndex >= 0 && logIndex < (currentSensor.operations.length)) {
  //       // 3. Remove the item
  //       currentSensor.operations.removeAt(logIndex);

  //       // 4. Update the list with a COPY of the sensor to trigger Obx
  //       // This forces the UI to re-render the specific row
  //       addedSensors[editingSensorIndex.value] = currentSensor;
  //       addedSensors.refresh();

  //       print(
  //           "🗑️ Operation log at index $logIndex deleted from ${currentSensor.sensorName}");
  //     }
  //   } else {
  //     Get.snackbar("Notice", "Please select a sensor first",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.amber.shade700,
  //         colorText: Colors.white);
  //   }
  // }

  void _resetForm() {
    modelController.value.clear();
    typeController.value.clear();
    addedSensors.clear();
    expandedSensors.clear();
    isEditMode.value = false;
  }

  clearSensorFields() {
    hasTested.value = false;
    sensorName.value.clear();
    sensorType.value.clear();
    registerNumber.value.clear();
    min.value.clear();
    max.value.clear();
    multiplier.value.text = "0.0";
    offset.value.text = "1.0";
    unit.value.clear();
    testResult.value.clear();
  }

  // ── PLC communication ────────────────────────────────────────────────────────

  void _showErrorPopup() {
    Get.dialog(CustomPopup(
      title: "PLC Offline",
      message: "Hardware communication lost. Check connection.",
      isError: true,
    ));
  }

  sendGeneratorDataRequest1(int registerAddress) {
    final plcCtrl = Get.find<PLCController>();

    final int hiAddr = (registerAddress >> 8) & 0xFF;
    final int loAddr = registerAddress & 0xFF;

    final List<int> packet = [
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x06,
      0x01,
      0x03,
      hiAddr,
      loAddr,
      0x00,
      0x01,
    ];

    final String hexCommand = packet
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');

    print("DEBUG: [READ HIT] -> Register: $registerAddress");
    print("RAW HEX: [ $hexCommand ]");

    plcCtrl.sendPacket(packet);
    hasTested.value = true;
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

    plcCtrl.sendPacket(packet);
  }

  // ── Import JSON ──────────────────────────────────────────────────────────────
  Future<void> importRecipes() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;

      final File file = File(result.files.single.path!);
      final String jsonInput = await file.readAsString();
      final dynamic decodedData = jsonDecode(jsonInput);

      final Map<String, dynamic> recipeMap =
          (decodedData is List) ? decodedData.first : decodedData;
      final Recipe importedRecipe = Recipe.fromJson(recipeMap);

      modelController.value.text = importedRecipe.model ?? '';
      typeController.value.text = importedRecipe.type ?? '';

      addedSensors.assignAll(
        importedRecipe.sensors.map<SensorConfig>((s) => SensorConfig(
              sensorName: s.sensorName ?? "",
              sensorType: s.sensorType ?? "",
              registerNumber: s.registerNumber,
              min: s.min,
              max: s.max,
              multiplier: s.multiplier,
              offset: s.offset,
              unit: s.unit,
              testResult: s.testResult,
              operations: List.from(s.operations),
            )),
      );

      Get.dialog(CustomPopup(
        title: "Success",
        message: "Imported ${importedRecipe.model}",
      ));
    } catch (e) {
      Get.dialog(CustomPopup(
        title: "Import Failed",
        message: "Error: $e",
        isError: true,
      ));
    }
  }
}
