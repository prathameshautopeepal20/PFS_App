import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/vehicle_flashing_controller.dart';

class FlashProcessController extends GetxController {
  var isBatch = true.obs;
  var isIndividual = false.obs;

  var isBatchViewVisible = true.obs;
  var isIndividualViewVisible = false.obs;

  var selectedModel = "".obs;
  var selectedRegulation = "".obs;

  var showPopup = false.obs;
  var popupTitle = "".obs;

  var models = ["Model A", "Model B", "Model C"];
  var regs = ["EURO 4", "EURO 5"];

  var individualList = List.generate(5, (i) => i + 1);
}

class FlashProcessScreen extends StatelessWidget {
  FlashProcessScreen({super.key});

  final c = Get.put(FlashProcessController());

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Row(
        children: [
          // ================= LEFT ORANGE PANEL =================
          if (isDesktop)
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF9772C),
                      Color(0xFFE56717),
                      Color(0xFFCC5A0F),
                    ],
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/new/atorange.png",
                    width: 180,
                  ),
                ),
              ),
            ),

          // ================= RIGHT PANEL =================
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: Obx(() => SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _title(),

                            const SizedBox(height: 20),

                            _flashType(),

                            const SizedBox(height: 20),

                            if (c.isBatchViewVisible.value) _batchView(),
                            if (c.isIndividualViewVisible.value)
                              _individualView(),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: const Row(
        children: [
          Icon(Icons.flash_on, color: Colors.orange),
          SizedBox(width: 10),
          Text(
            "ECU Flashing Process",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _title() {
    return const Text(
      "Select Flashing Configuration",
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  // ================= FLASH TYPE =================
  Widget _flashType() {
    return Obx(() => Row(
          children: [
            _radio(
              "Batch Flashing",
              c.isBatch.value,
              () {
                c.isBatch.value = true;
                c.isIndividual.value = false;
                c.isBatchViewVisible.value = true;
                c.isIndividualViewVisible.value = false;
              },
            ),
            const SizedBox(width: 20),
            _radio(
              "Individual Flashing",
              c.isIndividual.value,
              () {
                c.isBatch.value = false;
                c.isIndividual.value = true;
                c.isBatchViewVisible.value = false;
                c.isIndividualViewVisible.value = true;
              },
            ),
          ],
        ));
  }

  Widget _radio(String text, bool value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            value ? Icons.radio_button_checked : Icons.radio_button_off,
            color: Colors.orange,
          ),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  // ================= BATCH VIEW =================
  Widget _batchView() {
    return Column(
      children: [
        _dropdown("Model", c.models, c.selectedModel),
        const SizedBox(height: 15),
        _dropdown("Regulation", c.regs, c.selectedRegulation),
        const SizedBox(height: 25),
        _nextButton(),
      ],
    );
  }

  // ================= INDIVIDUAL VIEW =================
  Widget _individualView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade200,
          child: const Row(
            children: [
              Expanded(child: Text("Sr No")),
              Expanded(child: Text("Model")),
              Expanded(child: Text("Regulation")),
              Expanded(child: Text("Dongle")),
            ],
          ),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: c.individualList.length,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(child: Text("${index + 1}")),
                    const Expanded(child: Text("Model")),
                    const Expanded(child: Text("Reg")),
                    const Expanded(child: Text("Dongle")),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        _nextButton(),
      ],
    );
  }

  // ================= DROPDOWN =================
  Widget _dropdown(String label, List<String> items, RxString value) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value.isEmpty ? null : value.value,
              hint: Text("Select $label"),
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => value.value = v ?? "",
            ),
          ),
        ));
  }

  // ================= NEXT BUTTON =================
  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.all(14),
        ),
        onPressed: () {},
        child: const Text("NEXT"),
      ),
    );
  }
}