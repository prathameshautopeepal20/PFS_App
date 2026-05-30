import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/sensorAnalysisController.dart';

class SensorAnalysisScreen extends StatelessWidget {
  SensorAnalysisScreen({super.key});

  final SensorAnalysisController controller =
      Get.put(SensorAnalysisController());
  final _sensorFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double headerSize = isDesktop ? 22 : 18;
    final double headerFontSize = isDesktop ? 20 : 18;
    final double labelFontSize = isDesktop ? 20 : 14;
    final double inputFontSize = isDesktop ? 16 : 14;

    return SafeArea(
      child: MainLayout(
        //showDrawer: false,
        title: "Sensor Diagnostics & Analysis",
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SENSOR INVENTORY HEADER ---
              _buildSectionHeader(
                "Sensor Inventory",
                fontSize: headerSize,
                trailing: Row(
                  children: [
                    Obx(() => ElevatedButton.icon(
                          onPressed: () {
                            controller.isAddingSensor.toggle();
                            if (controller.isAddingSensor.value) {
                              controller.isChoosingFromRecipe.value = false;
                            }
                          },
                          icon: Icon(controller.isAddingSensor.value
                              ? Icons.close
                              : Icons.add),
                          label: Text(controller.isAddingSensor.value
                              ? "Cancel"
                              : "Add New Sensor"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0055BB),
                            foregroundColor: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),

              Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: controller.isAddingSensor.value
                        ? Form(
                            key: _sensorFormKey,
                            child: Column(
                              key: const ValueKey("ConfigForm"),
                              children: [
                                const SizedBox(height: 20),
                                _buildSectionHeader("Configure New Sensor",
                                    fontSize: headerFontSize),
                                const SizedBox(height: 20),
                                _buildResponsiveGrid(isDesktop, [
                                  _buildInputField(
                                      "Sensor Name", "e.g. Oil Pressure",
                                      labelSize: labelFontSize,
                                      textSize: inputFontSize,
                                      controller: controller.sensorName
                                          .value), // Corrected: removed .value
                                  _buildInputField("Sensor Type", "e.g. Analog",
                                      labelSize: labelFontSize,
                                      textSize: inputFontSize,
                                      controller: controller.sensorType
                                          .value), // Corrected: removed .value
                                ]),
                                const SizedBox(height: 20),
                                _buildResponsiveGrid(isDesktop, [
                                  _buildInputField("Register Address", "0x00",
                                      isNumeric: true,
                                      labelSize: labelFontSize,
                                      textSize: inputFontSize,
                                      controller: controller.registerNumber
                                          .value), // Corrected: removed .value
                                  _buildMinMaxField(
                                      isDesktop, labelFontSize, inputFontSize),
                                ]),
                                const SizedBox(height: 20),
                                _buildResponsiveGrid(isDesktop, [
                                  _buildInputField("Multiplier", "1.0",
                                      isNumeric: true,
                                      labelSize: labelFontSize,
                                      textSize: inputFontSize,
                                      controller: controller.multiplier
                                          .value), // Corrected: removed .value
                                  _buildInputField("Offset", "0",
                                      isNumeric: true,
                                      labelSize: labelFontSize,
                                      textSize: inputFontSize,
                                      controller: controller.offset
                                          .value), // Corrected: removed .value
                                ]),
                                const SizedBox(height: 20),
                                _buildResponsiveGrid(isDesktop, [
                                  _buildInputField(
                                    "Unit",
                                    "Ohms",
                                    labelSize: labelFontSize,
                                    textSize: inputFontSize,
                                    // controller: controller.unit, // Corrected: removed .value
                                  ),
                                ]),
                                const SizedBox(height: 30),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (_sensorFormKey.currentState!
                                          .validate()) {
                                        controller.saveSensorToTable();
                                        controller.isAddingSensor.value = false;
                                      }
                                    },
                                    icon: const Icon(Icons.check),
                                    label: Text("Save Sensor to Table",
                                        style:
                                            TextStyle(fontSize: labelFontSize)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12)),
                                  ),
                                ),
                                const Divider(height: 60),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  )),

              const SizedBox(height: 15),
              _buildSensorTable(),
              const SizedBox(height: 40),

              // --- 4. DYNAMIC ANALYSIS DASHBOARD ---
              Obx(() => controller.isAnalyzing.value
                  ? _buildAnalysisDashboard(isDesktop, context)
                  : _buildPlaceholder()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTable() {
    return Obx(() {
      if (controller.addedSensors.isEmpty) {
        return const Center(child: Text("No sensors in inventory."));
      }
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(
                label: Text('Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Register',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Range',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Sampling (s)',
                    style: TextStyle(fontWeight: FontWeight.bold))), // 🔥
            DataColumn(
                label: Text('Action',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.addedSensors.asMap().entries.map((entry) {
            int index = entry.key;
            var s = entry.value;
            return DataRow(cells: [
              DataCell(Text(s['name'] ?? '')),
              DataCell(Text(s['type'] ?? '')),
              DataCell(Text(s['register'] ?? '')),
              DataCell(Text("${s['min']} / ${s['max']} ${s['unit'] ?? ''}")),
              // 🔥 EDITABLE SAMPLING RATE CELL
              DataCell(
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: s['samplingRate'].toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    onChanged: (value) {
                      double? newVal = double.tryParse(value);
                      if (newVal != null && newVal > 0) {
                        // Update the sampling rate in the list
                        controller.addedSensors[index]['samplingRate'] = newVal;
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              DataCell(Row(
                children: [
                  // Inside your DataTable rows
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined,
                        color: Color(0xFF0055BB)),
                    onPressed: () {
                      // Stop any existing loop before starting a new one
                      controller.stopAnalysis();
                      // Start the new one
                      controller.startAnalysis(s);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => controller.addedSensors.removeAt(index),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LIVE DATA: ${controller.activeSensor['name'] ?? 'Unknown'}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0055BB),
              ),
            ),
            Obx(() => Text(
                  controller.isPaused.value ? "PAUSED" : "STREAMING...",
                  style: TextStyle(
                    color: controller.isPaused.value
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                )),
          ],
        ),
        Row(
          children: [
            // Play/Pause Button
            Obx(() => IconButton(
                  icon: Icon(
                    controller.isPaused.value
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 28,
                  ),
                  color: const Color(0xFF0055BB),
                  onPressed: () => controller.togglePause(),
                  tooltip: controller.isPaused.value ? "Resume" : "Pause",
                )),
            const SizedBox(width: 8),
            // Stop Button
            IconButton(
              icon: const Icon(Icons.stop_rounded, color: Colors.red, size: 28),
              onPressed: () => controller.stopAnalysis(),
              tooltip: "Stop & Clear",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisDashboard(bool isDesktop, BuildContext context) {
    const double pointSpacing = 35.0; // Fixed distance between points

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeaderRow(),
            const SizedBox(height: 24),

            // Container stays fixed size
            // 1. Padding widget handles the spacing around the graph card
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 2. Define height as a ratio (e.g., 40% of screen height)
                  // This is dynamic, not hardcoded!
                  final double dynamicHeight =
                      MediaQuery.of(context).size.height * 0.45;
                  final double availableWidth = constraints.maxWidth;

                  return Container(
                    height: dynamicHeight, // Fills the dynamic ratio
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Obx(() {
                        final double totalWidth =
                            controller.liveDataPoints.length * pointSpacing;
                        final double finalCanvasWidth =
                            totalWidth > availableWidth
                                ? totalWidth
                                : availableWidth;

                        return RawScrollbar(
                          controller: controller.chartScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 8,
                          thumbColor: const Color(0xFF0055BB).withOpacity(0.5),
                          radius: const Radius.circular(10),
                          child: SingleChildScrollView(
                            controller: controller.chartScrollController,
                            scrollDirection: Axis.horizontal,
                            reverse:
                                false, // Better to handle scrolling via Controller callback
                            child: SizedBox(
                              width: finalCanvasWidth,
                              height: dynamicHeight,
                              child: Padding(
                                // 3. Inner padding: keeps the graph lines from touching the container edges
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: CustomPaint(
                                  size: Size(finalCanvasWidth, dynamicHeight),
                                  painter: IndustrialPainter(
                                    points: controller.liveDataPoints.toList(),
                                    min: double.tryParse(controller
                                            .activeSensor['min']
                                            .toString()) ??
                                        0.0,
                                    max: double.tryParse(controller
                                            .activeSensor['max']
                                            .toString()) ??
                                        100.0,
                                    pointSpacing: pointSpacing,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildStatBar(),
          ],
        ),
      ),
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
                  AutovalidateMode.onUserInteraction),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Text("/")),
            Expanded(
              child: _buildInputFieldNoLabel(
                  "Max",
                  textSize,
                  controller.max.value,
                  "Max",
                  AutovalidateMode.onUserInteraction),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBar() {
    return Obx(() {
      // Extract unit from active sensor for the labels
      final String unit = controller.activeSensor['unit'] ?? "";

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              "CURRENT VALUE",
              "${controller.liveDataPoints.isEmpty ? '0.00' : controller.liveDataPoints.last.toStringAsFixed(2)} $unit",
              color: const Color(0xFF0055BB),
            ),

            // Dynamic Min recorded during this run
            _statItem(
              "MIN",
              controller.liveMin.value == double.infinity
                  ? "0.00"
                  : "${controller.liveMin.value.toStringAsFixed(1)} $unit",
              color: Colors.green,
            ),

            // Dynamic Max recorded during this run
            _statItem(
              "MAX",
              controller.liveMax.value == -double.infinity
                  ? "0.00"
                  : "${controller.liveMax.value.toStringAsFixed(1)} $unit",
              color: Colors.redAccent,
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.1)),
        Text(value,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color ?? const Color(0xFF0055BB))),
      ],
    );
  }

  Widget _buildSectionHeader(String title,
      {required double fontSize, Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0055BB))),
          if (trailing != null) trailing,
        ]),
        const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildInputField(String label, String hint,
      {required double labelSize,
      required double textSize,
      bool isNumeric = false,
      bool readOnly = false,
      TextEditingController? controller,
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

  Widget _buildInputFieldNoLabel(
      String hint,
      double textSize,
      TextEditingController? controller,
      String fieldName,
      AutovalidateMode autovalidatemode) {
    return TextFormField(
      autovalidateMode: autovalidatemode,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? "$fieldName required"
          : (double.tryParse(value) == null ? "Invalid" : null),
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
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.auto_graph, size: 60, color: Colors.black12),
          SizedBox(height: 10),
          Text("Select a sensor for analysis",
              style:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class IndustrialPainter extends CustomPainter {
  final List<double> points;
  final double min, max;
  final double pointSpacing;

  IndustrialPainter({
    required this.points,
    required this.min,
    required this.max,
    required this.pointSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double range = (max - min) == 0 ? 1 : (max - min);

    // --- 1. DRAW BACKGROUND & GRID ---
    final gridPaint = Paint()
      ..color = Colors.blueGrey.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      double labelValue = max - (i * (range / 4));
      _drawText(
          canvas,
          Offset(5, y - 12),
          labelValue.toStringAsFixed(1),
          const TextStyle(
              color: Colors.blueGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold));
    }

    // --- 2. NEW: DRAW DARK LIMIT LINES (MIN/MAX) ---
    // These lines stay fixed at the top (Max) and bottom (Min)
    final limitLinePaint = Paint()
      ..color = Colors.black.withOpacity(0.8) // High contrast dark line
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw Dark Max Limit Line (Top)
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), limitLinePaint);

    // Draw Dark Min Limit Line (Bottom)
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height),
        limitLinePaint);

    // Add labels for the dark lines so the tech knows the limit values
    final limitLabelStyle = TextStyle(
      color: Colors.black,
      fontSize: 9,
      fontWeight: FontWeight.w900,
      backgroundColor: Colors.white.withOpacity(0.8),
    );
    _drawText(canvas, const Offset(60, 2),
        "MAX LIMIT: ${max.toStringAsFixed(1)}", limitLabelStyle);
    _drawText(canvas, Offset(60, size.height - 14),
        "MIN LIMIT: ${min.toStringAsFixed(1)}", limitLabelStyle);

    // --- 3. CALCULATE PATHS & LIVE STATS ---
    final path = Path();
    final fillPath = Path();

    double currentMaxVal = -double.infinity;
    double currentMinVal = double.infinity;
    Offset maxPointOffset = Offset.zero;
    Offset minPointOffset = Offset.zero;
    List<Offset> peakOffsets = [];

    for (int i = 0; i < points.length; i++) {
      double dx = i * pointSpacing;
      // Normalizing data to fit between the dark lines
      double norm = ((points[i] - min) / range).clamp(0.0, 1.0);
      double dy = size.height - (norm * size.height);
      Offset currentOffset = Offset(dx, dy);

      if (i == 0) {
        path.moveTo(dx, dy);
        fillPath.moveTo(dx, size.height);
        fillPath.lineTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }

      // Track Live Run Min/Max
      if (points[i] >= currentMaxVal) {
        currentMaxVal = points[i];
        maxPointOffset = currentOffset;
      }
      if (points[i] <= currentMinVal) {
        currentMinVal = points[i];
        minPointOffset = currentOffset;
      }

      // Detect Local Peaks
      if (i > 0 && i < points.length - 1) {
        if (points[i] > points[i - 1] && points[i] > points[i + 1]) {
          peakOffsets.add(currentOffset);
        }
      }

      if (i == points.length - 1) {
        fillPath.lineTo(dx, size.height);
        fillPath.close();
      }
    }

    // --- 4. DRAW DATA VISUALS ---
    // Draw Area Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF0055BB).withOpacity(0.15), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw Main Live Line
    final linePaint = Paint()
      ..color = const Color(0xFF0055BB)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // --- 5. DRAW OVERLAYS (PEAKS & HIGHLIGHTS) ---
    // Peak Dots
    for (var offset in peakOffsets) {
      canvas.drawCircle(
          offset, 4, Paint()..color = Colors.redAccent.withOpacity(0.2));
      canvas.drawCircle(offset, 2.5, Paint()..color = Colors.redAccent);
    }

    // Live Min/Max Highlight Labels
    _drawHighlight(canvas, maxPointOffset,
        "RUN MAX: ${currentMaxVal.toStringAsFixed(1)}", Colors.redAccent);
    _drawHighlight(canvas, minPointOffset,
        "RUN MIN: ${currentMinVal.toStringAsFixed(1)}", Colors.green);
  }

  void _drawHighlight(Canvas canvas, Offset offset, String label, Color color) {
    canvas.drawCircle(offset, 6, Paint()..color = color.withOpacity(0.2));
    canvas.drawCircle(offset, 3, Paint()..color = color);
    _drawText(
        canvas,
        Offset(offset.dx - 20, offset.dy - 22),
        label,
        TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white.withOpacity(0.6)));
  }

  void _drawText(Canvas canvas, Offset offset, String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant IndustrialPainter old) => true;
}
