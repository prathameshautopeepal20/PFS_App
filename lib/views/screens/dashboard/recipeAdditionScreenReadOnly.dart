import 'package:atpl_flashing_app/logic/controller/dashboard/recipeAdditionReadOnlyController.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipeAdditionReadOnly extends StatelessWidget {
  RecipeAdditionReadOnly({super.key});

  final RecipeAdditionReadOnlyController controller =
      Get.put(RecipeAdditionReadOnlyController());

  final _engineFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    final double headerFontSize = isDesktop ? 20 : 18;
    final double labelFontSize = isDesktop ? 20 : 14;
    final double inputFontSize = isDesktop ? 16 : 14;
    final double tableHeaderFontSize = isDesktop ? 20 : 13;
    final double tableCellFontSize = isDesktop ? 16 : 12;

    return SafeArea(
      child: MainLayout(
        title: "Recipe Configuration",
        showDrawer: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 16, vertical: 30),
            child: SizedBox(
              width: double.infinity,
              child: Form(
                key: _engineFormKey,
                // 🔥 WRAP COLUMN IN OBX TO SHOW DATA AFTER onInit LOADS
                child: Obx(() => Column(
                      children: [
                        _buildSectionHeader(
                          "Engine Details",
                          fontSize: headerFontSize,
                        ),
                        const SizedBox(height: 20),
                        _buildResponsiveGrid(isDesktop, [
                          _buildInputField(
                              "Engine Model Number", "e.g. 6BT-5.9",
                              labelSize: labelFontSize,
                              textSize: inputFontSize,
                              readOnly: true, // Set to true for read-only
                              controller: controller.modelController.value),
                          _buildInputField("Engine Type", "e.g. Diesel",
                              labelSize: labelFontSize,
                              textSize: inputFontSize,
                              readOnly: true,
                              controller: controller.typeController.value),
                        ]),

                        const SizedBox(height: 40),

                        // Display the list of added sensors
                        _buildSectionHeader(
                          "Sensor Configuration",
                          fontSize: headerFontSize,
                        ),
                        const SizedBox(height: 20),
                        if (controller.addedSensors.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(238, 238, 238, 1),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DataTable(
                              columnSpacing: 24,
                              // 🔥 SET TO 0 to remove the default dark horizontal line
                              dividerThickness: 0,
                              horizontalMargin: 12,
                              showBottomBorder:
                                  false, // Set to false to use the custom border instead

                              // --- CUSTOM FAINT GRID ---
                              border: TableBorder(
                                // Faint horizontal lines
                                horizontalInside: BorderSide(
                                  color: Colors.grey
                                      .withOpacity(0.15), // Very transparent
                                  width: 0.5,
                                ),
                                // Faint vertical lines
                                verticalInside: BorderSide(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Very transparent
                                  width: 0.5,
                                ),
                                // Faint bottom border for the last row
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.15),
                                  width: 0.5,
                                ),
                              ),

                              headingRowColor:
                                  WidgetStateProperty.all(Colors.grey[100]),
                              headingRowHeight: 45,
                              dataRowMinHeight: 40,
                              dataRowMaxHeight: 60,

                              columns: [
                                _buildDataColumn(
                                    'Sensor Name', tableHeaderFontSize),
                                _buildDataColumn(
                                    'Sensor Type', tableHeaderFontSize),
                                // _buildDataColumn(
                                //     'Register Add', tableHeaderFontSize),
                                _buildDataColumn(
                                    'Multiplier', tableHeaderFontSize),
                                _buildDataColumn('Offset', tableHeaderFontSize),
                                _buildDataColumn('Min', tableHeaderFontSize),
                                _buildDataColumn('Max', tableHeaderFontSize),
                                _buildDataColumn('Unit', tableHeaderFontSize),
                                _buildDataColumn(
                                    'Test Result', tableHeaderFontSize),
                              ],
                              rows: controller.addedSensors.map((sensor) {
                                return DataRow(cells: [
                                  DataCell(Center(
                                    child: Text(sensor.sensorName ?? '',
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  DataCell(Center(
                                    child: Text(sensor.sensorType ?? '',
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  // DataCell(Center(
                                  //   child: Text(
                                  //       sensor.registerNumber.toString(),
                                  //       style: TextStyle(
                                  //           fontSize: tableCellFontSize)),
                                  // )),
                                  DataCell(Center(
                                    child: Text("${sensor.multiplier}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  DataCell(Center(
                                    child: Text("${sensor.offset}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  DataCell(Center(
                                    child: Text("${sensor.min}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  DataCell(Center(
                                    child: Text("${sensor.max}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize,),),
                                  )),
                                  DataCell(Center(
                                    child: Text("${sensor.unit}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                  DataCell(Center(
                                    child: Text("${sensor.testResult}",
                                        style: TextStyle(
                                            fontSize: tableCellFontSize)),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No sensors found.",
                                style: TextStyle(color: Colors.grey)),
                          ),

                        const SizedBox(height: 60),

                        // FINAL ACTION BUTTONS
                        Row(
                          mainAxisAlignment: isDesktop
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 50 : 40,
                                    vertical: 20),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text("Back",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isDesktop ? 18 : 16)),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper methods preserved exactly as requested ---
  DataColumn _buildDataColumn(String label, double fontSize) {
    return DataColumn(
    label: Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
  }

  Widget _buildSectionHeader(String title,
      {required double fontSize, Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0055BB))),
            if (trailing != null) trailing,
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildResponsiveGrid(bool isDesktop, List<Widget> children) {
    return Wrap(
      spacing: 30,
      runSpacing: 20,
      children: children
          .map((w) => SizedBox(
                width: isDesktop
                    ? (MediaQuery.of(Get.context!).size.width / 2) - 60
                    : double.infinity,
                child: w,
              ))
          .toList(),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    required double labelSize,
    required double textSize,
    bool isNumeric = false,
    bool readOnly = false,
    TextEditingController? controller,
    AutovalidateMode autovalidatemode = AutovalidateMode.onUserInteraction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: readOnly,
          cursorColor: Colors.black,
          autovalidateMode: autovalidatemode,
          controller: controller,
          style: TextStyle(
            color: readOnly ? Colors.blueGrey : Colors.black,
            fontWeight: readOnly ? FontWeight.bold : FontWeight.normal,
          ),
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: textSize, color: Colors.grey),
            filled: true,
            fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: readOnly ? Colors.black26 : Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
