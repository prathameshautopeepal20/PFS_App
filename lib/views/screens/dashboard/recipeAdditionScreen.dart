import 'package:atpl_flashing_app/logic/controller/dashboard/AddrecipeController.dart';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipeAdditionScreen extends StatelessWidget {
  RecipeAdditionScreen({super.key});
  final AddRecipeController controller = Get.put(AddRecipeController());

  final _engineFormKey = GlobalKey<FormState>();
  final _sensorFormKey = GlobalKey<FormState>();

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
                child: Column(
                  children: [
                    // ── SECTION 1: ENGINE DETAILS ──────────────────────────
                    _buildSectionHeader(
                      "Engine Details",
                      fontSize: headerFontSize,
                      trailing: OutlinedButton.icon(
                        onPressed: () => controller.importRecipes(),
                        icon: Icon(Icons.file_upload_outlined,
                            size: isDesktop ? 20 : 18),
                        label: Text("Import JSON",
                            style: TextStyle(fontSize: labelFontSize)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0055BB),
                          side: const BorderSide(color: Color(0xFF0055BB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildResponsiveGrid(isDesktop, [
                      _buildInputField("Engine Model Number", "e.g. 6BT-5.9",
                          labelSize: labelFontSize,
                          textSize: inputFontSize,
                          controller: controller.modelController.value),
                      _buildInputField("Engine Type", "e.g. Diesel",
                          labelSize: labelFontSize,
                          textSize: inputFontSize,
                          controller: controller.typeController.value),
                    ]),
                    const SizedBox(height: 40),

                    // ── SECTION 2: SENSOR LIST ─────────────────────────────
                    _buildSectionHeader(
                      "Added Sensor List",
                      fontSize: headerFontSize,
                      trailing: Obx(() => !controller.isAddingSensor.value
                          ? ElevatedButton.icon(
                              onPressed: () =>
                                  controller.isAddingSensor.value = true,
                              icon: Icon(Icons.add, size: isDesktop ? 20 : 18),
                              label: Text("Add New Sensor",
                                  style: TextStyle(fontSize: labelFontSize)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0055BB),
                                  foregroundColor: Colors.white),
                            )
                          : TextButton(
                              onPressed: () =>
                                  controller.isAddingSensor.value = false,
                              child: Text("Cancel",
                                  style: TextStyle(
                                      fontSize: labelFontSize,
                                      color: Colors.red)),
                            )),
                    ),
                    const SizedBox(height: 10),

                    // ── SENSOR TABLE ───────────────────────────────────────
                    Obx(() => controller.addedSensors.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No sensors added yet.",
                                style: TextStyle(color: Colors.grey)),
                          )
                        : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(238, 238, 238, 1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                  ),
                                  child:
                                      _buildTableHeaderRow(tableHeaderFontSize),
                                ),
                                const Divider(
                                    height: 1,
                                    color: Color.fromRGBO(238, 238, 238, 1)),

                                // Rows
                                ...controller.addedSensors.map((sensor) {
                                  final String key = sensor.sensorName ?? '';
                                  final bool isExpanded =
                                      controller.expandedSensors.contains(key);

                                  // ✅ logs come directly from sensor.operations
                                  final List<OperationLog> logs =
                                      sensor.operations;

                                  return Column(
                                    children: [
                                      // Main row
                                      IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              child: IconButton(
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
                                            _buildTableCell(
                                                sensor.sensorName ?? '',
                                                tableCellFontSize,
                                                flex: 3),
                                            _buildTableCell(
                                                sensor.sensorType ?? '',
                                                tableCellFontSize,
                                                flex: 3),
                                            _buildTableCell(
                                                sensor.registerNumber
                                                    .toString(),
                                                tableCellFontSize,
                                                flex: 2),
                                            _buildTableCell(
                                                sensor.unit.toString(),
                                                tableCellFontSize,
                                                flex: 2),
                                            _buildTableCell(
                                                "${sensor.min} / ${sensor.max}",
                                                tableCellFontSize,
                                                flex: 2),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.blue,
                                                        size: isDesktop
                                                            ? 22
                                                            : 20),
                                                    onPressed: () => controller
                                                        .editSensor(sensor),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                        size: isDesktop
                                                            ? 22
                                                            : 20),
                                                    onPressed: () => controller
                                                        .addedSensors
                                                        .remove(sensor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Expandable log sub-table
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: logs.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 40,
                                                    bottom: 12,
                                                    top: 4),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "No operations logged yet.",
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize:
                                                            tableCellFontSize),
                                                  ),
                                                ),
                                              )
                                            : _buildLogSubTable(
                                                logs, tableCellFontSize),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 250),
                                      ),

                                      const Divider(
                                          height: 1,
                                          color:
                                              Color.fromRGBO(238, 238, 238, 1)),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          )),

                    //                   Obx(() => AnimatedSwitcher(
                    //                         duration: const Duration(milliseconds: 300),
                    //                         child: controller.isAddingSensor.value
                    //                             ? Form(
                    //                                 key: _sensorFormKey,
                    //                                 child: Column(
                    //                                   key: const ValueKey("ConfigForm"),
                    //                                   children: [
                    //                                     const SizedBox(height: 20),
                    //                                     _buildSectionHeader(
                    //                                         "Configure New Sensor",
                    //                                         fontSize: headerFontSize),
                    //                                     const SizedBox(height: 20),
                    //                                     _buildModeSwitcher(),
                    //                                     const SizedBox(height: 30),
                    //                                     _buildResponsiveGrid(isDesktop, [
                    //                                       _buildInputField(
                    //                                           "Sensor Name", "e.g. Oil Pressure",
                    //                                           controller:
                    //                                               controller.sensorName.value,
                    //                                           labelSize: labelFontSize,
                    //                                           textSize: inputFontSize,
                    //                                           readOnly:
                    //                                               controller.isWriteMode.value),
                    //                                       _buildInputField("Sensor Type",
                    //                                           "e.g. Resistance / Analog",
                    //                                           controller:
                    //                                               controller.sensorType.value,
                    //                                           labelSize: labelFontSize,
                    //                                           textSize: inputFontSize,
                    //                                           readOnly:
                    //                                               controller.isWriteMode.value,
                    //                                           onChanged: (val) => controller
                    //                                               .sensorType
                    //                                               .refresh()),
                    //                                     ]),
                    //                                     const SizedBox(height: 20),
                    //                                     _buildResponsiveGrid(isDesktop, [
                    //                                       _buildInputField(
                    //                                           "Register Address", "0x00",
                    //                                           isNumeric: true,
                    //                                           controller:
                    //                                               controller.registerNumber.value,
                    //                                           labelSize: labelFontSize,
                    //                                           textSize: inputFontSize),
                    //                                       _buildMinMaxField(isDesktop,
                    //                                           labelFontSize, inputFontSize),
                    //                                     ]),
                    //                                     const SizedBox(height: 20),

                    //                                     // ── DYNAMIC FORMULA SECTION ────────────────
                    //                                     Obx(() {
                    //                                       // if (controller.isWriteMode.value)
                    //                                       //   return const SizedBox.shrink();
                    //                                       if (controller.isWriteMode.value) {
                    //   // ✅ WRITE MODE: Only show Register + Value to Write
                    //   return _buildResponsiveGrid(isDesktop, [

                    //     _buildInputField(
                    //       "Value to Write", "e.g. 1",
                    //       isNumeric: true,
                    //       controller: controller.testResult.value, // reuse testResult for write value
                    //       labelSize: labelFontSize,
                    //       textSize: inputFontSize,
                    //     ),
                    //     _buildInputField(
                    //       "Unit", "e.g. ohm",
                    //       isNumeric: true,
                    //       controller: controller.unit.value, // reuse testResult for write value
                    //       labelSize: labelFontSize,
                    //       textSize: inputFontSize,
                    //     ),
                    //   ]);
                    // }

                    //                                       bool isResistance = [
                    //                                         "resistance",
                    //                                         "resistance(2200)",
                    //                                         "resistance(100)",
                    //                                         "current",
                    //                                       ].contains(controller
                    //                                           .sensorType.value.text
                    //                                           .toLowerCase());
                    //                                       return Column(
                    //                                         children: [
                    //                                           if (isResistance) ...[
                    //                                             _buildResponsiveGrid(isDesktop, [
                    //                                               _buildInputField(
                    //                                                   "R1 (Ref Resistor)", "1000",
                    //                                                   isNumeric: true,
                    //                                                   controller:
                    //                                                       controller.r1Controller,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                               _buildInputField(
                    //                                                   "Vin (Input Voltage)",
                    //                                                   "5.0",
                    //                                                   isNumeric: true,
                    //                                                   controller: controller
                    //                                                       .vinController,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                               _buildInputField(
                    //                                                   "Unit", "e.g. Bar",
                    //                                                   controller:
                    //                                                       controller.unit.value,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                               const SizedBox(),
                    //                                             ]),
                    //                                             // _buildResponsiveGrid(isDesktop, [

                    //                                             const SizedBox(height: 20),
                    //                                             // _buildResponsiveGrid(isDesktop, [
                    //                                             //   _buildInputField("Vout (Measured)", "2.5",
                    //                                             //       isNumeric: true,
                    //                                             //       controller: controller.voutController,
                    //                                             //       labelSize: labelFontSize,
                    //                                             //       textSize: inputFontSize),
                    //                                             //   _buildInputField("Unit", "Ohms",
                    //                                             //       controller: controller.unit.value,
                    //                                             //       labelSize: labelFontSize,
                    //                                             //       textSize: inputFontSize),
                    //                                             // ]),
                    //                                           ] else ...[
                    //                                             _buildResponsiveGrid(isDesktop, [
                    //                                               _buildInputField(
                    //                                                   "Multiplier (m)", "1.0",
                    //                                                   isNumeric: true,
                    //                                                   controller: controller
                    //                                                       .multiplier.value,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                               _buildInputField(
                    //                                                   "Offset (c)", "0",
                    //                                                   isNumeric: true,
                    //                                                   controller:
                    //                                                       controller.offset.value,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                             ]),
                    //                                             const SizedBox(height: 20),
                    //                                             _buildResponsiveGrid(isDesktop, [
                    //                                               _buildInputField(
                    //                                                   "Unit", "e.g. Bar",
                    //                                                   controller:
                    //                                                       controller.unit.value,
                    //                                                   labelSize: labelFontSize,
                    //                                                   textSize: inputFontSize),
                    //                                               const SizedBox(),
                    //                                             ]),
                    //                                           ],
                    //                                         ],
                    //                                       );
                    //                                     }),

                    //                                     const SizedBox(height: 30),
                    //                                     Row(
                    //                                       mainAxisAlignment:
                    //                                           MainAxisAlignment.end,
                    //                                       children: [
                    //                                         _buildTestSection(isDesktop,
                    //                                             labelFontSize, inputFontSize),
                    //                                         const SizedBox(width: 15),
                    //                                         _buildSaveButton(labelFontSize),
                    //                                       ],
                    //                                     ),
                    //                                     const SizedBox(height: 60),
                    //                                   ],
                    //                                 ),
                    //                               )
                    //                             : const SizedBox.shrink(),
                    //                       )),
                    Obx(() => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: controller.isAddingSensor.value
                              ? Form(
                                  key: _sensorFormKey,
                                  child: Column(
                                    key: const ValueKey("ConfigForm"),
                                    children: [
                                      const SizedBox(height: 20),
                                      _buildSectionHeader(
                                          "Configure New Sensor",
                                          fontSize: headerFontSize),
                                      const SizedBox(height: 20),
                                      _buildModeSwitcher(),
                                      const SizedBox(height: 30),

                                      // ── SINGLE Obx handles ALL fields based on mode ──
                                      Obx(() {
                                        final bool isWrite =
                                            controller.isWriteMode.value;
                                        final bool isResistance = [
                                          "resistance",
                                          "resistance(2200)",
                                          "resistance(100)",
                                          "current",
                                        ].contains(controller
                                            .sensorType.value.text
                                            .toLowerCase());

                                        if (isWrite) {
                                          // ══════════════════════════════════════
                                          // ✅ WRITE MODE
                                          // Shows: Name, Type, Register, Value, Unit
                                          // ══════════════════════════════════════
                                          return Column(
                                            children: [
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "Sensor Name",
                                                  "e.g. Oil Pressure",
                                                  controller: controller
                                                      .sensorName.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                _buildInputField(
                                                  "Sensor Type",
                                                  "e.g. Resistance / Analog",
                                                  controller: controller
                                                      .sensorType.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                              ]),
                                              const SizedBox(height: 20),
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "Register Address",
                                                  "0x00",
                                                  isNumeric: true,
                                                  controller: controller
                                                      .registerNumber.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                _buildInputField(
                                                  "Value to Write",
                                                  "e.g. 1",
                                                  isNumeric: true,
                                                  controller: controller
                                                      .testResult.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                              ]),
                                              const SizedBox(height: 20),
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "Unit",
                                                  "e.g. ohm",
                                                  controller:
                                                      controller.unit.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                const SizedBox(),
                                              ]),
                                            ],
                                          );
                                        }

                                        // ══════════════════════════════════════
                                        // ✅ READ MODE
                                        // Shows: Name, Type, Register, MinMax,
                                        //        R1+Vin (resistance) OR m+c (linear), Unit
                                        // ══════════════════════════════════════
                                        return Column(
                                          children: [
                                            _buildResponsiveGrid(isDesktop, [
                                              _buildInputField(
                                                "Sensor Name",
                                                "e.g. Oil Pressure",
                                                controller:
                                                    controller.sensorName.value,
                                                labelSize: labelFontSize,
                                                textSize: inputFontSize,
                                              ),
                                              _buildInputField(
                                                "Sensor Type",
                                                "e.g. Resistance / Analog",
                                                controller:
                                                    controller.sensorType.value,
                                                labelSize: labelFontSize,
                                                textSize: inputFontSize,
                                                onChanged: (val) => controller
                                                    .sensorType
                                                    .refresh(),
                                              ),
                                            ]),
                                            const SizedBox(height: 20),
                                            _buildResponsiveGrid(isDesktop, [
                                              _buildInputField(
                                                "Register Address",
                                                "0x00",
                                                isNumeric: true,
                                                controller: controller
                                                    .registerNumber.value,
                                                labelSize: labelFontSize,
                                                textSize: inputFontSize,
                                              ),
                                              _buildMinMaxField(isDesktop,
                                                  labelFontSize, inputFontSize),
                                            ]),
                                            const SizedBox(height: 20),

                                            // Resistance / Current → R1 + Vin
                                            if (isResistance) ...[
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "R1 (Ref Resistor)",
                                                  "1000",
                                                  isNumeric: true,
                                                  controller:
                                                      controller.r1Controller,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                _buildInputField(
                                                  "Vin (Input Voltage)",
                                                  "5.0",
                                                  isNumeric: true,
                                                  controller:
                                                      controller.vinController,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                _buildInputField(
                                                  "Unit",
                                                  "e.g. Bar",
                                                  controller:
                                                      controller.unit.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                const SizedBox(),
                                              ]),
                                            ] else ...[
                                              // Linear → Multiplier + Offset + Unit
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "Multiplier (m)",
                                                  "1.0",
                                                  isNumeric: true,
                                                  controller: controller
                                                      .multiplier.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                _buildInputField(
                                                  "Offset (c)",
                                                  "0",
                                                  isNumeric: true,
                                                  controller:
                                                      controller.offset.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                              ]),
                                              const SizedBox(height: 20),
                                              _buildResponsiveGrid(isDesktop, [
                                                _buildInputField(
                                                  "Unit",
                                                  "e.g. Bar",
                                                  controller:
                                                      controller.unit.value,
                                                  labelSize: labelFontSize,
                                                  textSize: inputFontSize,
                                                ),
                                                const SizedBox(),
                                              ]),
                                            ],
                                          ],
                                        );
                                      }),

                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          _buildTestSection(isDesktop,
                                              labelFontSize, inputFontSize),
                                          const SizedBox(width: 15),
                                          _buildSaveButton(labelFontSize),
                                        ],
                                      ),
                                      const SizedBox(height: 60),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        )),

                    const SizedBox(height: 40),
                    const Divider(thickness: 2, color: Colors.black),
                    const SizedBox(height: 20),

                    // ── FINAL ACTION BUTTONS ───────────────────────────────
                    Row(
                      mainAxisAlignment: isDesktop
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 50 : 40, vertical: 20),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: isDesktop ? 18 : 16)),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_engineFormKey.currentState!.validate()) {
                              controller.addRecipe();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A76C0),
                            padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 60 : 50, vertical: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Add Recipe",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isDesktop ? 18 : 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildSaveButton(double labelFontSize) {
    return ElevatedButton.icon(
      onPressed: () {
        if (_sensorFormKey.currentState!.validate()) {
          controller.saveSensorToList();
          controller.isAddingSensor.value = false;
          Get.snackbar(
            "Success",
            "Sensor added to table",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      },
      icon: const Icon(Icons.check, color: Colors.white),
      label: Text("Save Sensor to Table",
          style: TextStyle(fontSize: labelFontSize, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Obx(() {
      final bool isWrite = controller.isWriteMode.value;
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              controller.isWriteMode.value = false;
              _sensorFormKey.currentState?.reset();
            },
            icon: Icon(Icons.visibility,
                size: 18,
                color: !isWrite ? Colors.white : const Color(0xFF0055BB)),
            label: const Text("READ MODE"),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  !isWrite ? const Color(0xFF0055BB) : Colors.transparent,
              foregroundColor:
                  !isWrite ? Colors.white : const Color(0xFF0055BB),
              side: const BorderSide(color: Color(0xFF0055BB), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 15),
          OutlinedButton.icon(
            onPressed: () {
              controller.isWriteMode.value = true;
              controller.registerNumber.value.clear();
              controller.multiplier.value.clear();
              controller.offset.value.clear();
              controller.unit.value.clear();
              controller.min.value.clear();
              controller.max.value.clear();
              controller.testResult.value.clear();
              _sensorFormKey.currentState?.reset();
            },
            icon: Icon(Icons.edit,
                size: 18,
                color: isWrite ? Colors.white : Colors.orange.shade900),
            label: const Text("WRITE MODE"),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  isWrite ? Colors.orange.shade900 : Colors.transparent,
              foregroundColor: isWrite ? Colors.white : Colors.orange.shade900,
              side: BorderSide(color: Colors.orange.shade900, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTestSection(bool isDesktop, double labelSize, double textSize) {
    return Obx(() {
      final bool isWrite = controller.isWriteMode.value;
      final Color themeColor =
          isWrite ? Colors.orange.shade900 : const Color(0xFF0055BB);

      return OutlinedButton.icon(
        // onPressed: () async {
        //   if (_sensorFormKey.currentState!.validate()) {
        //     //controller.processSensorValue(); // 👈 ADD THIS FIRST

        //     final String sensorName = controller.sensorName.value.text;
        //     final String currentVal = controller.testResult.value.text;

        //     controller.logOperation(
        //       sensorName: sensorName,
        //       operation: controller.isWriteMode.value ? "WRITE" : "READ",
        //       value: currentVal,
        //     );
        //   }
        // },
        onPressed: () async {
          if (_sensorFormKey.currentState!.validate()) {
            final String sensorName = controller.sensorName.value.text;

            // ✅ Check sensor exists in list before logging
            final bool exists =
                controller.addedSensors.any((s) => s.sensorName == sensorName);

            if (!exists) {
              Get.snackbar(
                "Save First",
                "Click 'Save Sensor to Table' before logging operations",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            controller.logOperation(
              sensorName: sensorName,
              operation: controller.isWriteMode.value ? "WRITE" : "READ",
              value: controller.testResult.value.text, // ✅ passes current value
            );
          }
        },
        icon: Icon(isWrite ? Icons.edit_note : Icons.visibility,
            color: Colors.white),
        label: Text(isWrite ? "LOG WRITE DATA" : "LOG READ DATA"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: themeColor,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
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

  Widget _buildTableHeaderRow(double fontSize) {
    return Row(
      children: [
        const SizedBox(width: 40),
        _buildHeaderCell('Sensor Name', fontSize, flex: 3),
        _buildHeaderCell('Sensor Type', fontSize, flex: 3),
        _buildHeaderCell('Register', fontSize, flex: 2),
        _buildHeaderCell('Unit', fontSize, flex: 2),
        _buildHeaderCell('Range', fontSize, flex: 2),
        _buildHeaderCell('Action', fontSize, flex: 2),
      ],
    );
  }

  Widget _buildHeaderCell(String label, double fontSize, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTableCell(String value, double fontSize, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Text(value,
            textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  Widget _buildLogSubTable(List<OperationLog> logs, double fontSize) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 8, bottom: 12, top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        border: Border.all(color: const Color(0xFFD0DFF8)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Sub-header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                _buildLogCell('Operation', fontSize, bold: true, flex: 2),
                _buildLogCell('Register', fontSize, bold: true, flex: 2),
                _buildLogCell('Value', fontSize, bold: true, flex: 3),
                _buildLogCell('Time', fontSize, bold: true, flex: 2),
                _buildLogCell('Delete', fontSize, bold: true, flex: 2),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFD0DFF8)),

          // Log rows
          // Change .map to .asMap().entries.map
          ...logs.asMap().entries.map((entry) {
            final int logIndex =
                entry.key; // ✅ Now logIndex is defined (0, 1, 2...)
            final log = entry.value; // This is your OperationLog object
            final bool isWrite = log.operation == "WRITE";

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE8EEF8), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // 1. Operation badge (flex: 2)
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isWrite
                              ? Colors.orange.shade100
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          log.operation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize - 1,
                            fontWeight: FontWeight.bold,
                            color: isWrite
                                ? Colors.orange.shade900
                                : const Color(0xFF0055BB),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Data Cells using your existing helper
                  _buildLogCell(log.registerAddress, fontSize, flex: 2),
                  _buildLogCell(log.value, fontSize, bold: true, flex: 3),
                  _buildLogCell(log.timestamp, fontSize,
                      color: Colors.grey[600], flex: 2),

                  // 3. Delete Button (flex: 1)
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 18),
                      onPressed: () => controller.deleteOperationLog(
                          logIndex), // ✅ No longer undefined
                    ),
                  ),
                ],
              ),
            );
          }).toList(), // ✅ Add .toList() to convert the map entries back to a widget list
        ],
      ),
    );
  }

  Widget _buildLogCell(String value, double fontSize,
      {bool bold = false, Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  // Widget _buildInputField(String label, String hint,
  //     {required double labelSize,
  //     required double textSize,
  //     bool isNumeric = false,
  //     bool readOnly = false,
  //     TextEditingController? controller,
  //     AutovalidateMode autovalidatemode = AutovalidateMode.onUserInteraction}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label,
  //           style: TextStyle(
  //               fontSize: labelSize,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.black87)),
  //       const SizedBox(height: 8),
  //       TextFormField(
  //         readOnly: readOnly,
  //         cursorColor: Colors.black,
  //         autovalidateMode: autovalidatemode,
  //         controller: controller,
  //         style: TextStyle(
  //             color: readOnly ? Colors.blueGrey : Colors.black,
  //             fontWeight: readOnly ? FontWeight.bold : FontWeight.normal),
  //         keyboardType: isNumeric
  //             ? const TextInputType.numberWithOptions(decimal: true)
  //             : TextInputType.text,
  //         validator: (value) => (value == null || value.trim().isEmpty)
  //             ? "$label is required"
  //             : null,
  //         decoration: InputDecoration(
  //           hintText: hint,
  //           hintStyle: TextStyle(fontSize: textSize, color: Colors.grey),
  //           filled: true,
  //           fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
  //           contentPadding:
  //               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  //           enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: const BorderSide(color: Colors.black26)),
  //           focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: BorderSide(
  //                   color: readOnly ? Colors.black26 : Colors.blue, width: 2)),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildInputField(String label, String hint,
      {required double labelSize,
      required double textSize,
      bool isNumeric = false,
      bool readOnly = false,
      TextEditingController? controller,
      Function(String)? onChanged, // Add this
      AutovalidateMode autovalidatemode = AutovalidateMode.onUserInteraction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged, // Pass it here
          readOnly: readOnly,
          cursorColor: Colors.black,
          autovalidateMode: autovalidatemode,
          controller: controller,
          style: TextStyle(
              color: readOnly ? Colors.blueGrey : Colors.black,
              fontWeight: readOnly ? FontWeight.bold : FontWeight.normal),
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          validator: (value) => (value == null || value.trim().isEmpty)
              ? "$label is required"
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: textSize, color: Colors.grey),
            filled: true,
            fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black26)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: readOnly ? Colors.black26 : Colors.blue, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildMinMaxField(bool isDesktop, double labelSize, double textSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Range (Min / Max)",
            style: TextStyle(fontSize: labelSize, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildInputFieldNoLabel(
                    "Min",
                    textSize,
                    controller.min.value,
                    "Min",
                    AutovalidateMode.onUserInteraction)),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text("/")),
            Expanded(
                child: _buildInputFieldNoLabel(
                    "Max",
                    textSize,
                    controller.max.value,
                    "Max",
                    AutovalidateMode.onUserInteraction)),
          ],
        ),
      ],
    );
  }

  Widget _buildInputFieldNoLabel(
      String hint,
      double textSize,
      TextEditingController? controller,
      String fieldName,
      AutovalidateMode autovalidatemode) {
    return Obx(() {
      final bool isWriteActive =
          Get.find<AddRecipeController>().isWriteMode.value;
      final TextEditingController effectiveController = isWriteActive
          ? TextEditingController()
          : (controller ?? TextEditingController());

      return TextFormField(
        autovalidateMode: autovalidatemode,
        controller: effectiveController,
        validator: (value) {
          if (isWriteActive) return null;
          return (value == null || value.trim().isEmpty)
              ? "$fieldName required"
              : null;
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black26)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
        ),
      );
    });
  }
}
