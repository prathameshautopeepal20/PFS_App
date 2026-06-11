import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/flash_process_controller.dart';

const Color primary = Colors.orange;
const Color bg = Color(0xFFF5F6FA);
const Color cardBg = Colors.white;
const Color border = Color(0xFFE0E0E0);

class FlashProcessScreen extends StatelessWidget {
  FlashProcessScreen({super.key});

  final FlashProcessController controller =
      Get.put(FlashProcessController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: const Text("ECU Flashing Process"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Select Flashing Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),


            // Batch / Individual Buttons
            Obx(
              () => Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isBatch.value
                            ? primary
                            : Colors.grey,
                      ),

                      onPressed: () {
                        controller.selectBatch();
                      },

                      child: const Text(
                        "Batch",
                      ),
                    ),
                  ),


                  const SizedBox(width: 10),


                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !controller.isBatch.value
                            ? primary
                            : Colors.grey,
                      ),

                      onPressed: () {
                        controller.selectIndividual();
                      },

                      child: const Text(
                        "Individual",
                      ),
                    ),
                  ),

                ],
              ),
            ),


            const SizedBox(height: 30),


            // Batch Selection
            Obx(() {

              if (!controller.isBatch.value) {
                return const SizedBox();
              }


              return Column(
                children: [

                  DropdownButtonFormField<String>(

                    value: controller.selectedModel.value.isEmpty
                        ? null
                        : controller.selectedModel.value,

                    decoration: const InputDecoration(
                      labelText: "Model",
                      border: OutlineInputBorder(),
                    ),

                    items: controller.modelList
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),

                    onChanged: (value) {

                      controller.selectedModel.value =
                          value ?? "";
                    },
                  ),


                  const SizedBox(height: 20),


                  DropdownButtonFormField<String>(

                    value:
                        controller.selectedRegulation.value.isEmpty
                        ? null
                        : controller.selectedRegulation.value,

                    decoration: const InputDecoration(
                      labelText: "Regulation",
                      border: OutlineInputBorder(),
                    ),

                    items: controller.regulationList
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),

                    onChanged: (value) {

                      controller.selectedRegulation.value =
                          value ?? "";
                    },
                  ),

                ],
              );

            }),


            const SizedBox(height: 40),


            // NEXT Button
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.all(15),
                ),

                onPressed: () {

                  controller.onNext();

                },

                child: const Text(
                  "NEXT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}