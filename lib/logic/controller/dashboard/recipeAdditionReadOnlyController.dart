// import 'package:atpl_flashing_app/models/receipe_model.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';

// class recipeAdditionReadOnlyController extends GetxController {
//   final modelController = TextEditingController().obs;
//   final typeController = TextEditingController().obs;
//   final sensorName = TextEditingController().obs;
//   final sensorType = TextEditingController().obs;
//   final registerNumber = TextEditingController().obs;
//   final multiplier = TextEditingController().obs;
//   final offset = TextEditingController().obs;
//   final min = TextEditingController().obs;
//   final max = TextEditingController().obs;
//   RxList<SensorConfig> addedSensors = <SensorConfig>[].obs;
//   @override
//   void onInit() {
//     super.onInit();

//     if (Get.arguments != null && Get.arguments is Recipe) {
//       final recipe = Get.arguments as Recipe;
//       modelController.value.text = recipe.model ?? "";
//       typeController.value.text = recipe.type ?? "";

//       // FIX: Explicitly map to <SensorConfig>
//       if (recipe.sensors != null) {
//         addedSensors.assignAll(recipe.sensors!
//             .map<SensorConfig>((s) => SensorConfig(
//                 sensorName: s.sensorName ?? "",
//                 sensorType: s.sensorType ?? "",
//                 registerNumber: s.registerNumber,
//                 min: s.min,
//                 max: s.max,
//                 multiplier: s.multiplier,
//                 // offset: s.offset,
//                 unit: s.unit,
//                 testResult: s.testResult))
//             .toList());
//       }
//     }
//   }
// }
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RecipeAdditionReadOnlyController extends GetxController {
  // Use final for the Rx wrapper itself
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
  final testResult = TextEditingController().obs;

  RxList<SensorConfig> addedSensors = <SensorConfig>[].obs;
RxBool selectedSensor = false.obs;
  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }
  // Inside recipeAdditionReadOnlyController.dart

void selectSensor(SensorConfig sensor) {
  sensorName.value.text = sensor.sensorName ?? "";
  sensorType.value.text = sensor.sensorType ?? "";
  registerNumber.value.text = sensor.registerNumber?.toString() ?? "";
  multiplier.value.text = sensor.multiplier?.toString() ?? "1.0";
  offset.value.text = sensor.offset?.toString() ?? "0";
  min.value.text = sensor.min?.toString() ?? "0";
  max.value.text = sensor.max?.toString() ?? "0";
  // If you added these fields:
  // unit.value.text = sensor.unit ?? "";
  // testResult.value.text = sensor.testResult ?? "";
}

  void _loadArguments() {
    // Check if arguments exist
    if (Get.arguments == null) {
      debugPrint("Read-Only Controller: No arguments received");
      return;
    }

    Recipe? recipe;

    // Handle both direct object passing and Map passing
    if (Get.arguments is Recipe) {
      recipe = Get.arguments as Recipe;
    } else if (Get.arguments is Map && Get.arguments.containsKey('item')) {
      recipe = Get.arguments['item'] as Recipe;
    }

    if (recipe != null) {
      debugPrint("Loading Recipe for Read-Only: ${recipe.model}");

      // Update the text property of the controller inside the Rx wrapper
      modelController.value.text = recipe.model ?? "";
      typeController.value.text = recipe.type ?? "";

      if (recipe.sensors.isNotEmpty) {
        addedSensors.assignAll(recipe.sensors);

        // Optionally fill the "Current Sensor" fields with the first sensor data
        var firstSensor = recipe.sensors[0];
        sensorName.value.text = firstSensor.sensorName ?? "";
        sensorType.value.text = firstSensor.sensorType ?? "";
        registerNumber.value.text =
            firstSensor.registerNumber?.toString() ?? "";
        min.value.text = firstSensor.min?.toString() ?? "";
        max.value.text = firstSensor.max?.toString() ?? "";
        multiplier.value.text = firstSensor.multiplier?.toString() ?? "1.0";
        offset.value.text = firstSensor.offset?.toString() ?? "0";
        unit.value.text = firstSensor.unit?.toString() ??"";
        testResult.value.text = firstSensor.testResult??'';
      }
    }
  }
  // Inside recipeAdditionReadOnlyController.dart

void fillDetailsFromSensor(SensorConfig sensor) {
  sensorName.value.text = sensor.sensorName ?? "";
  sensorType.value.text = sensor.sensorType ?? "";
  registerNumber.value.text = sensor.registerNumber?.toString() ?? "";
  multiplier.value.text = sensor.multiplier?.toString() ?? "1.0";
  offset.value.text = sensor.offset?.toString() ?? "0";
  min.value.text = sensor.min?.toString() ?? "0";
  max.value.text = sensor.max?.toString() ?? "0";
  unit.value.text = sensor.unit ?? "";
  testResult.value.text = sensor.testResult ?? "N/A";
  
  debugPrint("Populated details for sensor: ${sensor.sensorName}");
}
}
