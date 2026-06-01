import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchFlashingPopup extends StatefulWidget {
  const BatchFlashingPopup({Key? key}) : super(key: key);

  @override
  State<BatchFlashingPopup> createState() => _BatchFlashingPopupState();
}

class _BatchFlashingPopupState extends State<BatchFlashingPopup> {
  String? selectedModel;
  String? selectedSubModel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Title
            Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  color: Color(0xFFF9772C),
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Batch Flashing",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const Divider(),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedModel,
              decoration: InputDecoration(
                labelText: "Select Model",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Model 1",
                  child: Text("Model 1"),
                ),
                DropdownMenuItem(
                  value: "Model 2",
                  child: Text("Model 2"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedModel = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedSubModel,
              decoration: InputDecoration(
                labelText: "Select Sub Model",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Sub Model 1",
                  child: Text("Sub Model 1"),
                ),
                DropdownMenuItem(
                  value: "Sub Model 2",
                  child: Text("Sub Model 2"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSubModel = value;
                });
              },
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Cancel"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9772C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () {
                    if (selectedModel == null ||
                        selectedSubModel == null) {
                      Get.snackbar(
                        "Validation",
                        "Please select Model and Sub Model",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    Get.back(
                      result: {
                        "model": selectedModel,
                        "subModel": selectedSubModel,
                      },
                    );
                  },
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}