import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchFlashingScreen extends StatelessWidget {
  const BatchFlashingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data received from popup
    final Map<String, dynamic>? args =
        Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Flashing"),
        backgroundColor: const Color(0xFFF9772C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Selected Configuration",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildRow(
                      "Engine Model",
                      args?["engineModel"]?.toString() ?? "",
                    ),

                    _buildRow(
                      "Firmware",
                      args?["firmware"]?.toString() ?? "",
                    ),

                    _buildRow(
                      "Variant",
                      args?["variant"]?.toString() ?? "",
                    ),

                    _buildRow(
                      "Protocol",
                      args?["protocol"]?.toString() ?? "",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    "Batch Flashing",
                    "Flashing Started",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "START FLASHING",
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

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}