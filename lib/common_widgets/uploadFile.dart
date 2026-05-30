import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/common_widgets/label_value_widget.dart';
import 'package:atpl_flashing_app/themes/app_textstyles.dart';

Widget imagePickerField({
  required String label,
  Rx<File?>? imageFile,
  RxString? imageUrl,
  required RxBool isFocused,
  required VoidCallback onTap,
}) {
  Future<Uint8List?> fetchImageBytes(String url) async {
    try {
     // final String? token = await AppPreferences.getToken();
      final bool isPrivate = url.contains('/private/files/');
      final headers = <String, String>{};
      if (isPrivate) {
        //headers['Authorization'] = '$token';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("Failed to load image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return null;
  }

  return paddingWidget([
    LabelsWithMark(label: label, isRequired: true),
    Obx(() {
      bool hasImage =
          (imageFile?.value != null) || (imageUrl?.value.isNotEmpty ?? false);

      String displayText = "Upload";
      if (imageFile?.value != null) {
        displayText = imageFile!.value!.path.split('/').last;
      } else if (imageUrl?.value.isNotEmpty ?? false) {
        displayText = imageUrl!.value.split('/').last;
      }

      return Focus(
        onFocusChange: (hasFocus) {
          isFocused.value = hasFocus;
        },
        child: GestureDetector(
          onTap: () {
            if (hasImage) {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: imageFile?.value != null
                              ? Image.file(imageFile!.value!,
                                  fit: BoxFit.contain)
                              : FutureBuilder<Uint8List?>(
                                  future: fetchImageBytes(imageUrl!.value),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Center(
                                          child: Text("Image not available"));
                                    } else {
                                      return Image.memory(snapshot.data!,
                                          fit: BoxFit.contain);
                                    }
                                  },
                                ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              onTap();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isFocused.value ? Colors.grey : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyles.textfieldTextStyle,
                  ),
                ),
                if (hasImage)
                  GestureDetector(
                    onTap: () {
                      if (imageFile != null) imageFile.value = null;
                      if (imageUrl != null) imageUrl.value = '';
                    },
                    child: const Icon(Icons.delete, color: Colors.red,),
                  ),
              ],
            ),
          ),
        ),
      );
    }),
  ]);
}
