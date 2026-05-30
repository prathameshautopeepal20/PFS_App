import 'package:atpl_flashing_app/logic/controller/dashboard/testingController.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestingScreen extends StatelessWidget {
  TestingScreen({super.key});

  final ESNController controller = Get.put(ESNController());

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    final double titleFontSize = isDesktop ? 22 : 18;
    final double labelFontSize = isDesktop ? 18 : 14;
    final double valueFontSize = isDesktop ? 17 : 14;
    final double tableCellFontSize = isDesktop ? 16 : 13;

    return SafeArea(
      child: MainLayout(
        title: "ATPL Diagnostic Tool",
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 30 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. ESN VALIDATION SECTION ---
              Row(
                children: [
                  // Text("ESN Validation :",
                  //     style: TextStyle(
                  //         fontSize: titleFontSize,
                  //         fontWeight: FontWeight.bold)),
                  // const SizedBox(width: 20),
                  // Flexible(
                  //   flex: 3,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: TextField(
                  //       controller: controller.esnTextFieldController,
                  //       cursorColor: Colors.black,
                  //       decoration: _inputDecoration('Enter ESN......'),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 10),

                  // ElevatedButton(
                  //   onPressed: () => controller.validateESN(),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xFF0055BB),
                  //     shape: const RoundedRectangleBorder(),
                  //   ),
                  //   child: const Padding(
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //     child: Text("Validate",
                  //         style: TextStyle(color: Colors.white, fontSize: 18)),
                  //   ),
                  // ),
                  Text(
                    "ESN Validation :",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    flex: 3,
                    child: GetBuilder<ESNController>(
                      // MUST use GetBuilder
                      builder: (controller) {
                        return TextField(
                          controller: controller.esnTextFieldController,
                          //focusNode: controller.esnFocusNode,
                          //onSubmitted: (value) => controller.handleBarcodeSubmit(value),
                          decoration:
                              _inputDecoration('Enter ESN......').copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner,
                                  color: Color(0xFF0055BB)),
                              onPressed: () {
                                // Close keyboard and open camera
                                // controller.esnFocusNode.unfocus();
                                controller.sc();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () => controller.validateESN(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055BB),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Text(
                          "Validate",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),

                  const SizedBox(width: 10),

                  // --- START TESTING BUTTON ---
                  Obx(() => ElevatedButton(
                        onPressed: controller.isValidated.value &&
                                !controller.isTesting.value
                            ? () => controller.startTestingSequence()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            controller.isTesting.value
                                ? "Testing..."
                                : "Start Testing",
                            style: TextStyle(
                                color: controller.isValidated.value
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontSize: 18),
                          ),
                        ),
                      )),
                ],
              ),

              const SizedBox(height: 30),

              // --- 2. DEVICE INFO ROW (Reactive) ---
              Obx(() => Row(
                    children: [
                      Expanded(
                          child: _buildReadOnlyInfo(
                              "Serial Number",
                              controller.serialNumber.value,
                              labelFontSize,
                              valueFontSize)),
                      Expanded(
                          child: _buildReadOnlyInfo(
                              "Variant Code",
                              controller.variantCode.value,
                              labelFontSize,
                              valueFontSize)),
                      Expanded(
                          child: _buildReadOnlyInfo(
                              "Model Number",
                              controller.modelNumber.value,
                              labelFontSize,
                              valueFontSize)),
                    ],
                  )),

              const SizedBox(height: 40),

              // --- 3. TEST STEPS SECTION (Sequential Loop) ---
              Text("Test Steps",
                  style: TextStyle(
                      fontSize: titleFontSize, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Obx(() => Table(
              //       columnWidths: const {
              //         0: FlexColumnWidth(1), // Sr.
              //         1: FlexColumnWidth(4), // Component
              //         2: FlexColumnWidth(1.5), // Min
              //         3: FlexColumnWidth(1.5), // Max
              //         4: FlexColumnWidth(1.5),
              //         5: FlexColumnWidth(1.5), // Val
              //         6: FlexColumnWidth(2), // Result
              //       },
              //       border: TableBorder.all(color: Colors.black12),
              //       children: [
              //         // 1. HEADER ROW (Total 6 children)
              //         TableRow(
              //           decoration: BoxDecoration(color: Colors.grey[200]),
              //           children: [
              //             _buildCell("Register",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Component",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Min",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Max",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Unit",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Val",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //             _buildCell("Result",
              //                 isHeader: true, fontSize: tableCellFontSize),
              //           ],
              //         ),

              //         // 2. DATA ROWS (Must also have exactly 6 children)
              //         ...controller.sensorResults.map((sensor) {
              //           return TableRow(
              //             children: [
              //               _buildCell(sensor['reg'].toString(),
              //                   fontSize: tableCellFontSize), // 1
              //               _buildCell(sensor['part'],
              //                   fontSize: tableCellFontSize,
              //                   align: TextAlign.left), // 2
              //               _buildCell(sensor['min'].toString(),
              //                   fontSize: tableCellFontSize), // 3
              //               _buildCell(sensor['max'].toString(),
              //                   fontSize: tableCellFontSize), // 4
              //               _buildCell(sensor['unit'].toString(),
              //                   fontSize: tableCellFontSize),
              //               _buildCell(sensor['val'].toString(),
              //                   fontSize: tableCellFontSize), // 5
              //               _buildStatusBadge(
              //                   sensor['status'], tableCellFontSize), // 6
              //             ],
              //           );
              //         }).toList(),
              //       ],
              //     ))
              Obx(() => Column(
                    children: [
                      // ── HEADER ──
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        child: Row(
                          children: [
                            const SizedBox(width: 40), // expand icon space
                            _buildHeaderCell("Register", tableCellFontSize,
                                flex: 1),
                            _buildHeaderCell("Component", tableCellFontSize,
                                flex: 4),
                            _buildHeaderCell("Min", tableCellFontSize, flex: 2),
                            _buildHeaderCell("Max", tableCellFontSize, flex: 2),
                            _buildHeaderCell("Unit", tableCellFontSize,
                                flex: 2),
                            _buildHeaderCell("Val", tableCellFontSize, flex: 2),
                            _buildHeaderCell("Result", tableCellFontSize,
                                flex: 2),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.black12),

                      // ── ROWS ──
                      ...controller.sensorResults.map((sensor) {
                        final String key = sensor['part'] ?? '';
                        final bool isExpanded =
                            controller.expandedSensors.contains(key);
                        final List ops = sensor['operations'] ?? [];

                        return Column(
                          children: [
                            // Main sensor row
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  // ── Expand toggle ──
                                  SizedBox(
                                    width: 40,
                                    child: ops.isEmpty
                                        ? const SizedBox()
                                        : IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: AnimatedRotation(
                                              turns: isExpanded ? 0.25 : 0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: const Icon(
                                                  Icons.chevron_right,
                                                  color: Color(0xFF0055BB)),
                                            ),
                                            onPressed: () => controller
                                                .toggleSensorExpanded(key),
                                          ),
                                  ),
                                  _buildFlexCell(sensor['reg'].toString(),
                                      tableCellFontSize,
                                      flex: 1),
                                  _buildFlexCell(
                                      sensor['part'], tableCellFontSize,
                                      flex: 4, align: TextAlign.left),
                                  _buildFlexCell(sensor['min'].toString(),
                                      tableCellFontSize,
                                      flex: 2),
                                  _buildFlexCell(sensor['max'].toString(),
                                      tableCellFontSize,
                                      flex: 2),
                                  _buildFlexCell(sensor['unit'].toString(),
                                      tableCellFontSize,
                                      flex: 2),
                                  _buildFlexCell(sensor['val'].toString(),
                                      tableCellFontSize,
                                      flex: 2),
                                  Expanded(
                                    flex: 2,
                                    child: _buildStatusBadge(
                                        sensor['status'], tableCellFontSize),
                                  ),
                                ],
                              ),
                            ),

                            // ── Operations sub-table ──
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: ops.isEmpty
                                  ? const SizedBox.shrink()
                                  : Container(
                                      margin: const EdgeInsets.only(
                                          left: 40,
                                          right: 8,
                                          bottom: 8,
                                          top: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F8FF),
                                        border: Border.all(
                                            color: const Color(0xFFD0DFF8)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        children: [
                                          // Sub-header
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEAF0FB),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(6)),
                                            ),
                                            child: Row(
                                              children: [
                                                _buildOpsHeaderCell(
                                                    "Step", tableCellFontSize,
                                                    flex: 1),
                                                _buildOpsHeaderCell("Operation",
                                                    tableCellFontSize,
                                                    flex: 2),
                                                _buildOpsHeaderCell("Register",
                                                    tableCellFontSize,
                                                    flex: 2),
                                                _buildOpsHeaderCell(
                                                    "Value", tableCellFontSize,
                                                    flex: 2),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFD0DFF8)),

                                          // Op rows
                                          ...ops.asMap().entries.map((entry) {
                                            final int i = entry.key;
                                            final op = entry.value;
                                            final bool isWrite =
                                                op.operation == "WRITE";

                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12),
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xFFE8EEF8),
                                                      width: 0.5),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Step number
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text("${i + 1}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize:
                                                                tableCellFontSize -
                                                                    1,
                                                            color: Colors
                                                                .grey[600])),
                                                  ),
                                                  // Operation badge
                                                  Expanded(
                                                    flex: 2,
                                                    child: Center(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isWrite
                                                              ? Colors.orange
                                                                  .shade100
                                                              : Colors
                                                                  .blue.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Text(
                                                          op.operation,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize:
                                                                tableCellFontSize -
                                                                    1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isWrite
                                                                ? Colors.orange
                                                                    .shade900
                                                                : const Color(
                                                                    0xFF0055BB),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        op.registerAddress,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize:
                                                                tableCellFontSize -
                                                                    1)),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(op.value,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize:
                                                                tableCellFontSize -
                                                                    1,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                            ),

                            const Divider(height: 1, color: Colors.black12),
                          ],
                        );
                      }).toList(),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, double fontSize, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFlexCell(String text, double fontSize,
      {int flex = 1, TextAlign align = TextAlign.center}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child:
            Text(text, textAlign: align, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  Widget _buildOpsHeaderCell(String label, double fontSize, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fontSize - 1,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0055BB))),
    );
  }

  // --- Reusable UI Components ---

  Widget _buildReadOnlyInfo(
      String label, String value, double labelSize, double valueSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: labelSize - 5,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 1.1)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildStatusBadge(String status, double fontSize) {
    Color bgColor = Colors.grey.withOpacity(0.1);
    Color textColor = Colors.grey;

    if (status == "OK") {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade800;
    } else if (status == "NOT OK" || status == "TIMEOUT") {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade800;
    } else if (status == "TESTING...") {
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue.shade800;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(4)),
        child: Text(status,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fontSize - 2,
                fontWeight: FontWeight.bold,
                color: textColor)),
      ),
    );
  }

  // Widget _buildCell(String text,
  //     {required double fontSize,
  //     bool isHeader = false,
  //     TextAlign align = TextAlign.center}) {
  //   return Padding(
  //     padding: const EdgeInsets.all(12),
  //     child: Center(
  //       child: Text(text,
  //           textAlign: align,
  //           style: TextStyle(
  //               fontSize: fontSize,
  //               fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
  //     ),
  //   );
  // }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.blueGrey.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2)),
    );
  }
}
