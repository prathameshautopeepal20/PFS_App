import 'dart:convert';
import 'dart:io';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

Future<void> exportRecipes(List<Recipe> recipes) async {
  // 1. Convert list to JSON string
  String jsonString = jsonEncode(recipes.map((e) => e.toJson()).toList());

  // 2. Pick location to save
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Recipe JSON',
    fileName: 'recipes_export.json',
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (outputFile != null) {
    final file = File(outputFile);
    await file.writeAsString(jsonString);
    Get.snackbar("Success", "Recipes exported to $outputFile");
  }

  // ignore: unused_element
  Future<List<Recipe>> importRecipes() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    
    // Decode JSON
    List<dynamic> jsonData = jsonDecode(content);
    
    // Map to Objects
    return jsonData.map((e) => Recipe.fromJson(e)).toList();
  }
  return [];
}
}
