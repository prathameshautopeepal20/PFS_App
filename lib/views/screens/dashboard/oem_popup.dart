import 'package:atpl_flashing_app/logic/controller/dashboard/oem_popup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/popup/oem_popup_controller.dart';

class OEMPopup extends StatelessWidget {
  const OEMPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OEMPopupController());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // TITLE
            const Center(
              child: Text(
                "OEM Models",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // MODEL
            const Text(
              "Model",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedModel.value.isEmpty
                    ? null
                    : controller.selectedModel.value,

                decoration: InputDecoration(
                  hintText: "Please Select Model",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                items: controller.modelList.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),

                onChanged: (value) {
                  controller.selectedModel.value = value!;
                },
              ),
            ),

            const SizedBox(height: 25),

            // SUB MODEL
            const Text(
              "Sub Model",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedSubModel.value.isEmpty
                    ? null
                    : controller.selectedSubModel.value,

                decoration: InputDecoration(
                  hintText: "Please Select Sub Model",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                items: controller.subModelList.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),

                onChanged: (value) {
                  controller.selectedSubModel.value = value!;
                },
              ),
            ),

            const SizedBox(height: 35),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF9772C),

                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),

                    onPressed: controller.submit,

                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,

                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),

                    onPressed: controller.closePopup,

                    child: const Text(
                      "CLOSE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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