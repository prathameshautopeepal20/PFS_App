import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchFlashingScreen extends StatelessWidget {
  BatchFlashingScreen({super.key});

  final args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Flashing"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ================= HEADER INFO =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model: ${args["model"]}"),
                    Text("Regulation: ${args["regulation"]}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= ECU LIST (LIKE .NET GRID VIEW) =================
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {

                  return Card(
                    child: ListTile(
                      title: Text("ECU ${index + 1}"),
                      subtitle: const Text("Status: Pending"),

                      trailing: ElevatedButton(
                        onPressed: () {

                          // 🔥 THIS IS NEXT STEP → FLASH ENGINE
                          Get.snackbar("Flash", "Start ECU ${index + 1}");
                        },
                        child: const Text("FLASH"),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================= START ALL =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  Get.snackbar("Start", "Batch Flash Started");

                  // NEXT → Progress Screen (we build next)
                },
                child: const Text("START ALL FLASHING"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}