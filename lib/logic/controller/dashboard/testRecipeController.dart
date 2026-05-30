// import 'dart:convert';
// import 'dart:io';
// import 'package:atpl_flashing_app/common_widgets/popup.dart';
// import 'package:atpl_flashing_app/models/receipe_model.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';

// class TestRecipeController extends GetxController {
//   var recipeList = <Recipe>[
//     Recipe(
//       sr: "1",
//       model: "AABBSSCC",
//       type: "WDWW",
//       sensors: [
//         // ✅ Correctly instantiating SensorConfig
//         SensorConfig(
//             sensorName: "Oil Pressure",
//             sensorType: "Analog",
//             registerNumber: 1, // ✅ Must be an int
//             min: 3.0,
//             max: 10.0,
//             multiplier: 1.0,
//             offset: 0.0,
//             unit: "ohm",
//             testResult: "ok"),
//         SensorConfig(
//             sensorName: "Oil Pressure",
//             sensorType: "Analog",
//             registerNumber: 1, // ✅ Must be an int
//             min: 3.0,
//             max: 10.0,
//             multiplier: 1.0,
//             offset: 0.0,
//             unit: "ohm",
//             testResult: "ok"),
//         SensorConfig(
//             sensorName: "Oil Pressure",
//             sensorType: "Analog",
//             registerNumber: 1, // ✅ Must be an int
//             min: 3.0,
//             max: 10.0,
//             multiplier: 1.0,
//             offset: 0.0,
//             unit: "ohm",
//             testResult: "ok"),
//       ],
//     ),
//     Recipe(
//       sr: "2",
//       model: "ASSSDFD",
//       type: "DWWD",
//       sensors: [
//         SensorConfig(
//             sensorName: "Coolant Temp",
//             sensorType: "Analog",
//             registerNumber: 2, // ✅ Must be an int
//             min: 0.0,
//             max: 10.0,
//             multiplier: 1.0,
//             offset: 0.0,
//             unit: "ohm",
//             testResult: "Not ok"),
//       ],
//     ),
//   ].obs;

//   Future<void> exportSingleRecipe(Recipe recipe) async {
//     try {
//       List<Map<String, dynamic>> singleData = [recipe.toJson()];
//       String jsonString = jsonEncode(singleData);

//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Export Recipe: ${recipe.model}',
//         fileName: 'recipe_${recipe.model!.replaceAll(' ', '_')}.json',
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//       );

//       if (outputFile != null) {
//         final file = File(outputFile);
//         await file.writeAsString(jsonString);
//         Get.dialog(
//           CustomPopup(
//             title: "Export Success",
//             message: "Recipe ${recipe.model} exported.",
//             // This will make the button red and add an icon
//           ),
//         );
//       }
//     } catch (e) {
//       Get.dialog(
//         CustomPopup(
//           title: "Export Failed",
//           message: "Error:$e",
//           isError: true, // This will make the button red and add an icon
//         ),
//       );
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class TestRecipeController extends GetxController {
  // 1. Remove the hardcoded List and initialize as an empty observable list
  var recipeList = <Recipe>[].obs;
  var selectedRecipe = Rxn<Recipe>();
  @override
  void onInit() {
    super.onInit();
    // 2. Load the actual data from local storage as soon as the app starts
    loadStoredRecipes();
  }

//   /// Fetches recipes from the SharedPreferences Map
//  Future<void> loadStoredRecipes() async {
//   try {
//     // 1. Fetch data specifically for the LOGGED-IN user
//     // This uses the "active_user_id" to find the right key
//     List<Recipe> storedRecipes = await AppPreferences.getRecipesForCurrentUser();

//     // 2. Clear the old memory list and assign the fresh data
//     recipeList.assignAll(storedRecipes);

//     // 3. Trigger Obx listeners
//     recipeList.refresh();

//     print("✅ Successfully synced ${recipeList.length} recipes for the current user.");
//   } catch (e) {
//     print("❌ Error loading stored recipes: $e");
//     // Optional: Clear the list if error occurs to prevent showing wrong user's data
//     recipeList.clear();
//   }
// }
  Future<void> loadStoredRecipes() async {
    try {
      List<Recipe> storedRecipes =
          await AppPreferences.getRecipesForCurrentUser();

      // ✅ ADD THIS — check if operations survive deserialization
      for (var recipe in storedRecipes) {
        print(
            "📦 [RECIPE] ${recipe.model} | Sensors: ${recipe.sensors.length}");
        for (var sensor in recipe.sensors) {
          print("  📡 ${sensor.sensorName} | Ops: ${sensor.operations.length}");
          for (var op in sensor.operations) {
            print(
                "    ▶️ ${op.operation} | Reg: ${op.registerAddress} | Val: ${op.value}");
          }
        }
      }

      recipeList.assignAll(storedRecipes);
      recipeList.refresh();
      print(
          "✅ Successfully synced ${recipeList.length} recipes for the current user.");
    } catch (e) {
      print("❌ Error loading stored recipes: $e");
      recipeList.clear();
    }
  }

  // --- Export Logic ---
  Future<void> exportSingleRecipe(Recipe recipe) async {
    try {
      List<Map<String, dynamic>> singleData = [recipe.toJson()];
      String jsonString = jsonEncode(singleData);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Recipe: ${recipe.model}',
        fileName: 'recipe_${recipe.model!.replaceAll(' ', '_')}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        Get.dialog(
          CustomPopup(
            title: "Export Success",
            message: "Recipe ${recipe.model} exported.",
          ),
        );
      }
    } catch (e) {
      Get.dialog(
        CustomPopup(
          title: "Export Failed",
          message: "Error:$e",
          isError: true,
        ),
      );
    }
  }

// ==========================================
// DELETE RECIPE
// ==========================================
  Future<void> deleteRecipe(
  Recipe recipe,
) async {
  try {
    // REMOVE FROM UI
    recipeList.remove(recipe);

    // REMOVE FROM STORAGE
    await AppPreferences
        .deleteRecipeForCurrentUser(
      recipe.model!,
    );

    // REFRESH UI
    recipeList.refresh();

    print(
      "🗑️ Recipe Deleted : ${recipe.model}",
    );

    Get.dialog(
      CustomPopup(
        title: "Delete Success",
        message:
            "Recipe deleted successfully.",
      ),
    );
  } catch (e) {
    print("❌ DELETE ERROR : $e");

    Get.dialog(
      CustomPopup(
        title: "Delete Failed",
        message: "Error : $e",
        isError: true,
      ),
    );
  }
}
}

