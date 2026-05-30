// import 'package:cp_tmtl_sensor_zig/common_widgets/ui_helper_widgets.dart';
// import 'package:cp_tmtl_sensor_zig/views/screens/dashboard/mainLayoutScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:cp_tmtl_sensor_zig/logic/controller/dashboard/dasboardController.dart';

// class DashboardScreen extends StatelessWidget {
//   DashboardScreen({super.key});
//   final DashboardController controller = Get.put(DashboardController());

//   @override
//   Widget build(BuildContext context) {
//     return MainLayout(
//       title: "ATPL Diagnostic Tool",
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           bool isDesktop = constraints.maxWidth > 800;

//           return SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: EdgeInsets.symmetric(
//                 horizontal: isDesktop ? 80 : 20, vertical: isDesktop ? 60 : 20),
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 1200),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // --- HEADER SECTION ---

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Date Container
//                         Align(
//                           alignment: Alignment.topLeft,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: isDesktop ? 16 : 12,
//                               vertical: isDesktop ? 8 : 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade300
//                                   .withOpacity(0.1), // Subtle background
//                               borderRadius:
//                                   BorderRadius.circular(8), // Rounded corners
//                               // border: Border.all(
//                               //   color: Colors.blueGrey.shade100,
//                               //   width: 1,
//                               // ),
//                             ),
//                             child: Text(
//                               "Date: 09.04.2026",
//                               style: TextStyle(
//                                 fontFamily: "Roboto-Regular",
//                                 fontSize: isDesktop ? 20 : 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blue
//                                     .shade700, // Slightly darker for better contrast
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Icon Logic
//                         if (!isDesktop)
//                           const Icon(Icons.analytics_outlined,
//                               color: Colors.blue),
//                       ],
//                     ),
//                     C5(),

//                     Text(
//                       "Engine Test Zig",
//                       style: TextStyle(
//                           fontFamily: "Roboto-Regular",
//                           fontSize:
//                               isDesktop ? 44 : 24, // Large Header for Windows
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF1E293B),
//                           letterSpacing: 0.5),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Production Line Performance Overview",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: isDesktop ? 18 : 13, // Scaled for Windows
//                         fontFamily: "Roboto-Regular",
//                       ),
//                     ),

//                     SizedBox(height: isDesktop ? 70 : 5),

//                     // --- CHART SECTION ---
//                     Container(
//                       padding: EdgeInsets.all(isDesktop ? 15 : 2),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 30,
//                             offset: const Offset(0, 15),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             height: isDesktop
//                                 ? 500
//                                 : 280, // Much larger chart for Windows
//                             child: Stack(
//                               children: [
//                                 PieChart(
//                                   PieChartData(
//                                     sectionsSpace: isDesktop ? 6 : 4,
//                                     centerSpaceRadius:
//                                         isDesktop ? 140 : 60, // Wider Donut
//                                     sections: _getSections(isDesktop),
//                                   ),
//                                 ),
//                                 // Center Summary Text
//                                 Center(
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         "100",
//                                         style: TextStyle(
//                                           fontSize: isDesktop
//                                               ? 64
//                                               : 30, // Large Value
//                                           fontWeight: FontWeight.w900,
//                                           fontFamily: "Roboto-Regular",
//                                           color: const Color(0xFF1E293B),
//                                         ),
//                                       ),
//                                       Text("TOTAL TESTS",
//                                           style: TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: isDesktop ? 18 : 12,
//                                               letterSpacing: 2,
//                                               fontFamily: "Roboto-Regular",
//                                               fontWeight: FontWeight.bold)),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           // Legend
//                           Wrap(
//                             spacing: isDesktop ? 40 : 20,
//                             runSpacing: 15,
//                             alignment: WrapAlignment.center,
//                             children: [
//                               _buildLegend(
//                                   Colors.blue.shade600, "Test OK", isDesktop),
//                               _buildLegend(Colors.orange.shade800,
//                                   "Test Not Ok", isDesktop),
//                               _buildLegend(
//                                   Colors.grey.shade400, "Retest", isDesktop),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: isDesktop ? 80 : 20),

//                     // --- STATS SECTION ---
//                     _buildStatsGrid(isDesktop),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatsGrid(bool isDesktop) {
//     if (isDesktop) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Expanded(
//               child: _buildStatCard(
//                   "Total Tested", "100", Icons.speed, Colors.blue, isDesktop)),
//           const SizedBox(width: 30),
//           Expanded(
//               child: _buildStatCard(
//                   "Tested Today", "52", Icons.today, Colors.orange, isDesktop)),
//           const SizedBox(width: 30),
//           Expanded(
//               child: _buildStatCard("Planned Today", "10", Icons.assignment,
//                   Colors.blueGrey, isDesktop)),
//         ],
//       );
//     } else {
//       return Column(
//         children: [
//           _buildStatCard(
//               "Total Tested", "100", Icons.speed, Colors.blue, isDesktop),
//           const SizedBox(height: 12),
//           _buildStatCard(
//               "Tested Today", "52", Icons.today, Colors.orange, isDesktop),
//           const SizedBox(height: 12),
//           _buildStatCard("Planned Today", "10", Icons.assignment,
//               Colors.blueGrey, isDesktop),
//         ],
//       );
//     }
//   }

//   Widget _buildStatCard(
//       String label, String value, IconData icon, Color color, bool isDesktop) {
//     return Container(
//       padding: EdgeInsets.all(isDesktop ? 24 : 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(isDesktop ? 14 : 10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Icon(icon, color: color, size: isDesktop ? 32 : 24),
//           ),
//           const SizedBox(width: 20),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: isDesktop ? 16 : 13,
//                       fontFamily: "Roboto-Regular",
//                       fontWeight: FontWeight.w600)),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: isDesktop ? 32 : 22,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: "Roboto-Regular",
//                       color: const Color(0xFF1E293B))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   List<PieChartSectionData> _getSections(bool isDesktop) {
//     double radius = isDesktop ? 80 : 45; // Thicker ring for Windows
//     return [
//       _section(Colors.blue.shade600, 65, '65%', radius, isDesktop),
//       _section(Colors.orange.shade800, 25, '25%', radius, isDesktop),
//       _section(Colors.grey.shade400, 10, '10%', radius, isDesktop),
//     ];
//   }

//   PieChartSectionData _section(
//       Color color, double val, String title, double rad, bool isDesktop) {
//     return PieChartSectionData(
//       color: color,
//       value: val,
//       title: title,
//       radius: rad,
//       titleStyle: TextStyle(
//           fontFamily: "Roboto-Regular",
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: isDesktop ? 18 : 12),
//     );
//   }

//   Widget _buildLegend(Color color, String text, bool isDesktop) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//             width: isDesktop ? 16 : 10,
//             height: isDesktop ? 16 : 10,
//             decoration: BoxDecoration(
//                 color: color, borderRadius: BorderRadius.circular(4))),
//         const SizedBox(width: 10),
//         Text(text,
//             style: TextStyle(
//                 fontFamily: "Roboto-Regular",
//                 fontSize: isDesktop ? 18 : 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blueGrey)),
//       ],
//     );
//   }
// }
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
//import 'package:cp_tmtl_sensor_zig/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unused_import
import 'package:fl_chart/fl_chart.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final DashboardController controller = Get.put(DashboardController());

  // @override
  // Widget build(BuildContext context) {
  //   bool isDesktop = MediaQuery.of(context).size.width > 800;

  //   return MainLayout(
  //     title: "ATPL Diagnostic Tool",
  //     child: Scaffold(
  //       backgroundColor: const Color(0xFFF8FAFC),
  //       body: SingleChildScrollView(
  //         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
  //         child: Obx(() {
  //           final data = controller.currentModel;

  //           return Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // --- 1. DATE HEADER ---
  //               _buildDateHeader(),
  //               const SizedBox(height: 30),

  //               // --- 2. MODEL SELECTOR (MATCHING YOUR IMAGE) ---
  //               _buildModelSelector(isDesktop),
  //               const SizedBox(height: 50),

  //               Text(
  //                 "Engine Model: ${data['name']}",
  //                 style: const TextStyle(
  //                     fontSize: 32,
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xFF1E293B)),
  //               ),
  //               const SizedBox(height: 10),
  //               const Text("Production Line Performance Overview",
  //                   style: TextStyle(color: Colors.grey, fontSize: 16)),

  //               const SizedBox(height: 50),

  //               // --- 3. CHART SECTION ---
  //               _buildChartSection(data, isDesktop),

  //               const SizedBox(height: 60),

  //               // --- 4. 5-METRIC STATS GRID ---
  //               _buildStatsGrid(data),
  //               const SizedBox(height: 50),
  //             ],
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDateHeader() {
  //   return Align(
  //     alignment: Alignment.topLeft,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: Colors.blue.shade300.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Text(
  //         "Date: 18.04.2026",
  //         style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.blue.shade700),
  //       ),
  //     ),
  //   );
  // }

  // // --- MODEL SELECTOR BAR (SAME AS YOUR IMAGE) ---
  // Widget _buildModelSelector(bool isDesktop) {
  //   return Container(
  //     height: 80,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFFFE4D6), // Peach color from your image
  //       borderRadius: BorderRadius.circular(4),
  //       border: Border.all(color: Colors.black, width: 1.2),
  //     ),
  //     child: Row(
  //       children: controller.engineModels.asMap().entries.map((entry) {
  //         int idx = entry.key;
  //         bool isSelected = controller.selectedModelIndex.value == idx;
  //         return Expanded(
  //           child: InkWell(
  //             onTap: () => controller.selectedModelIndex.value = idx,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color:
  //                     isSelected ? Colors.orange.shade100 : Colors.transparent,
  //                 border: idx != 0
  //                     ? const Border(
  //                         left: BorderSide(color: Colors.black, width: 1.2))
  //                     : null,
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Text("Model",
  //                       style: TextStyle(
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black)),
  //                   Text(entry.value['name'],
  //                       style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w900,
  //                           color: Colors.black)),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  // Widget _buildChartSection(Map<String, dynamic> data, bool isDesktop) {
  //   return Container(
  //     padding: const EdgeInsets.all(40),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(24),
  //       boxShadow: [
  //         BoxShadow(
  //             color: Colors.black.withOpacity(0.04),
  //             blurRadius: 30,
  //             offset: const Offset(0, 15))
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height: 400,
  //           child: Stack(
  //             children: [
  //               PieChart(
  //                 PieChartData(
  //                   sectionsSpace: 6,
  //                   centerSpaceRadius: 130,
  //                   sections: _getSections(data),
  //                 ),
  //               ),
  //               Center(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Text("${data['total']}",
  //                         style: const TextStyle(
  //                             fontSize: 64,
  //                             fontWeight: FontWeight.w900,
  //                             color: Color(0xFF1E293B))),
  //                     const Text("TOTAL TESTED",
  //                         style: TextStyle(
  //                             color: Colors.grey,
  //                             fontWeight: FontWeight.bold,
  //                             letterSpacing: 2)),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 30),
  //         _buildLegendRow(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _legendItem(Color color, String text) {
  //   return Row(
  //     children: [
  //       Container(
  //           width: 16,
  //           height: 16,
  //           decoration: BoxDecoration(
  //               color: color, borderRadius: BorderRadius.circular(4))),
  //       const SizedBox(width: 10),
  //       Text(text,
  //           style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.blueGrey)),
  //     ],
  //   );
  // }

  // Widget _buildStatsGrid(Map<String, dynamic> data) {
  //   return Row(
  //     children: [
  //       _statCard(
  //           "Total Tested", "${data['total']}", Icons.speed, Colors.indigo),
  //       const SizedBox(width: 20),
  //       _statCard("Today Tested", "${data['today']}", Icons.today, Colors.blue),
  //       const SizedBox(width: 20),
  //       _statCard(
  //           "Today Pass", "${data['pass']}", Icons.check_circle, Colors.green),
  //       const SizedBox(width: 20),
  //       _statCard("Today Failed", "${data['fail']}", Icons.cancel, Colors.red),
  //       const SizedBox(width: 20),
  //       // _statCard("Today Planned", "${data['plan']}", Icons.assignment,
  //       //     Colors.blueGrey),
  //     ],
  //   );
  // }

  // Widget _statCard(String label, String value, IconData icon, Color color) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: color.withOpacity(0.1), width: 2),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Icon(icon, color: color, size: 24),
  //           const SizedBox(height: 15),
  //           Text(label,
  //               style: const TextStyle(
  //                   color: Colors.grey,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.bold)),
  //           Text(value,
  //               style:
  //                   const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // // List<PieChartSectionData> _getSMap<String, dynamic> data)ections( {
  // //   // Null safety check to prevent toDouble() error
  // //   double pass = (data['pass'] ?? 0).toDouble();
  // //   double fail = (data['fail'] ?? 0).toDouble();
  // //   double plan = (data['plan'] ?? 0).toDouble();
  // //   double remaining = (plan - (pass + fail)).clamp(0, 1000).toDouble();

  // //   return [
  // //     PieChartSectionData(color: Colors.blue.shade600, value: pass, radius: 40, showTitle: false),
  // //     PieChartSectionData(color: Colors.orange.shade800, value: fail, radius: 40, showTitle: false),
  // //     PieChartSectionData(color: Colors.grey.shade200, value: remaining == 0 ? 1 : remaining, radius: 30, showTitle: false),
  // //   ];
  // // }
  // List<PieChartSectionData> _getSections(Map<String, dynamic> data) {
  //   double radius = 80; // Thicker ring for Windows Desktop

  //   // 1. Extract values from your JSON keys
  //   double totalTested = (data['total'] ?? 0).toDouble();
  //   double todayTested = (data['today'] ?? 0).toDouble();
  //   double todayPass = (data['pass'] ?? 0).toDouble();
  //   double todayFail = (data['fail'] ?? 0).toDouble();

  //   return [
  //     // TODAY PASS
  //     _section(
  //         Colors.green.shade600, todayPass, "${todayPass.toInt()}", radius),

  //     // TODAY FAIL
  //     _section(Colors.red.shade800, todayFail, "${todayFail.toInt()}", radius),

  //     // TOTAL (Optional: if you want to show overall lifetime units in the ring)
  //     _section(Colors.orange.shade800, totalTested, "${totalTested.toInt()}",
  //         radius),
  //     _section(
  //         Colors.blue.shade400, todayTested, "${todayTested.toInt()}", radius),

  //     // TOTAL (Optional: if you want to show overall lifetime units in the ring)
  //     // _section(Colors.orange.shade800, totalTested, "${todaysplanned.toInt()}",
  //     //     radius),
  //   ];
  // }

  // Widget _buildLegendRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       _legendItem(Colors.orange.shade600, "Total Tested"),

  //       const SizedBox(width: 30),
  //       _legendItem(Colors.red.shade400, "Today's Fail"),
  //       const SizedBox(width: 30),
  //       _legendItem(Colors.blue.shade600, "Today's Tested"),
  //       const SizedBox(width: 30),
  //       _legendItem(Colors.green.shade800, "Today's Pass"),
  //       // const SizedBox(width: 30),
  //       // _legendItem(Colors.grey.shade400, "Today's Test"),
  //     ],
  //   );
  // }

  // PieChartSectionData _section(
  //     Color color, double val, String title, double rad) {
  //   return PieChartSectionData(
  //     color: color,
  //     value: val,
  //     title: title,
  //     radius: rad,
  //     titlePositionPercentageOffset: 0.6, // Centers text in the ring
  //     titleStyle: const TextStyle(
  //         fontFamily: "Roboto-Regular",
  //         color: Colors.white,
  //         fontWeight: FontWeight.bold,
  //         fontSize: 14), // Adjusted for multiple labels
  //   );
  // }
  @override
Widget build(BuildContext context) {
  return MainLayout(
    title: "ATPL Diagnostic Tool",
    child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ── LEFT SIDEBAR ─────────────────────────────────────────────
          Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text("Engine Models",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5)),
                ),
                // Expanded(
                //   child: Obx(() => ListView.separated(
                //         padding:
                //             const EdgeInsets.symmetric(horizontal: 10),
                //         itemCount: controller.engineModels.length,
                //         separatorBuilder: (_, __) =>
                //             const SizedBox(height: 6),
                //         itemBuilder: (context, idx) {
                //           final isSelected =
                //               controller.selectedModelIndex.value == idx;
                //           return GestureDetector(
                //             onTap: () =>
                //                 controller.selectModel(idx),
                //             child: Container(
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 12, vertical: 10),
                //               decoration: BoxDecoration(
                //                 color: isSelected
                //                     ? Colors.orange.shade50
                //                     : Colors.transparent,
                //                 border: Border.all(
                //                   color: isSelected
                //                       ? Colors.orange.shade400
                //                       : Colors.grey.shade200,
                //                   width: isSelected ? 1.5 : 0.5,
                //                 ),
                //                 borderRadius: BorderRadius.circular(8),
                //               ),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text("Model",
                //                       style: TextStyle(
                //                           fontSize: 11,
                //                           color: Colors.grey.shade500)),
                //                   Text(
                //                     controller.engineModels[idx]['name'],
                //                     style: TextStyle(
                //                       fontSize: 15,
                //                       fontWeight: FontWeight.w700,
                //                       color: isSelected
                //                           ? Colors.orange.shade800
                //                           : Colors.black87,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           );
                //         },
                //       )),
                // ),
              ],
            ),
          ),

          // ── RIGHT MAIN CONTENT ────────────────────────────────────────
        //   Expanded(
        //     child: Obx(() {
        //       final data = controller.selectedModel;
        //       return SingleChildScrollView(
        //         padding: const EdgeInsets.all(24),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             // Date badge
        //             _buildDateHeader(),
        //             const SizedBox(height: 12),

        //             // Title
        //             Text(
        //               "Engine Model: ${data['name']}",
        //               style: const TextStyle(
        //                   fontSize: 22, fontWeight: FontWeight.w600),
        //             ),
        //             const SizedBox(height: 4),
        //             Text(
        //               "Production Line Performance Overview",
        //               style: TextStyle(
        //                   fontSize: 13, color: Colors.grey.shade500),
        //             ),
        //             const SizedBox(height: 24),

        //             // ── Chart on top ──────────────────────────────────
        //             _buildChartSection(data, true),
        //             const SizedBox(height: 20),

        //             // ── Stats below chart ─────────────────────────────
        //             Row(
        //               children: [
        //                 Expanded(
        //                   child: _statCard(
        //                     "Total Tested",
        //                     "${data['total']}",
        //                     Icons.speed,
        //                     Colors.indigo,
        //                   ),
        //                 ),
        //                 const SizedBox(width: 12),
        //                 Expanded(
        //                   child: _statCard(
        //                     "Today Tested",
        //                     "${data['today']}",
        //                     Icons.calendar_today,
        //                     Colors.blue,
        //                   ),
        //                 ),
        //                 const SizedBox(width: 12),
        //                 Expanded(
        //                   child: _statCard(
        //                     "Today Pass",
        //                     "${data['pass']}",
        //                     Icons.check_circle,
        //                     Colors.green,
        //                   ),
        //                 ),
        //                 const SizedBox(width: 12),
        //                 Expanded(
        //                   child: _statCard(
        //                     "Today Fail",
        //                     "${data['fail']}",
        //                     Icons.cancel,
        //                     Colors.red,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ],
        //         ),
        //       );
        //     }),
        //   ),
        ],
      ),
    ),
  );
}

// ── Date Header ───────────────────────────────────────────────────────────
// Widget _buildDateHeader() {
//   final now = DateTime.now();
//   final formatted =
//       "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//     decoration: BoxDecoration(
//       color: Colors.blue.shade50,
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Text(
//       "Date: $formatted",
//       style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//           color: Colors.blue.shade700),
//     ),
//   );
// }

// // ── Chart Section ─────────────────────────────────────────────────────────
// Widget _buildChartSection(Map<String, dynamic> data, bool isDesktop) {
//   return Container(
//     padding: const EdgeInsets.all(24),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: Colors.grey.shade100),
//     ),
//     child: Column(
//       children: [
//         SizedBox(
//           height: 320,
//           child: Stack(
//             children: [
//               PieChart(
//                 PieChartData(
//                   sectionsSpace: 6,
//                   centerSpaceRadius: 110,
//                   sections: _getSections(data),
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "${data['total']}",
//                       style: const TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.w900,
//                           color: Color(0xFF1E293B)),
//                     ),
//                     const Text(
//                       "TOTAL TESTED",
//                       style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 2,
//                           fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         // Legend
//         Wrap(
//           spacing: 24,
//           runSpacing: 10,
//           alignment: WrapAlignment.center,
//           children: [
//             _legendItem(Colors.green.shade600, "Today Pass"),
//             _legendItem(Colors.red.shade800, "Today Fail"),
//             _legendItem(Colors.blue.shade400, "Today Tested"),
//             _legendItem(Colors.orange.shade800, "Total Tested"),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// ── Stat Card ─────────────────────────────────────────────────────────────
// Widget _statCard(String label, String value, IconData icon, Color color) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: Colors.grey.shade100),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 18),
//         ),
//         const SizedBox(height: 10),
//         Text(label,
//             style:
//                 TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//         const SizedBox(height: 2),
//         Text(value,
//             style: const TextStyle(
//                 fontSize: 22, fontWeight: FontWeight.w700)),
//       ],
//     ),
//   );
// }

// ── Legend Item ───────────────────────────────────────────────────────────
// Widget _legendItem(Color color, String text) {
//   return Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//               color: color, borderRadius: BorderRadius.circular(3))),
//       const SizedBox(width: 6),
//       Text(text,
//           style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: Colors.blueGrey)),
//     ],
//   );
// }

// // ── Pie Chart Sections ────────────────────────────────────────────────────
// List<PieChartSectionData> _getSections(Map<String, dynamic> data) {
//   const double radius = 60;
//   return [
//     _section(Colors.green.shade600, (data['pass'] ?? 0).toDouble(),
//         "${data['pass']}", radius),
//     _section(Colors.red.shade800, (data['fail'] ?? 0).toDouble(),
//         "${data['fail']}", radius),
//     _section(Colors.blue.shade400, (data['today'] ?? 0).toDouble(),
//         "${data['today']}", radius),
//     _section(Colors.orange.shade800, (data['total'] ?? 0).toDouble(),
//         "${data['total']}", radius),
//   ];
// }

// PieChartSectionData _section(
//     Color color, double val, String title, double rad) {
//   return PieChartSectionData(
//     color: color,
//     value: val,
//     title: title,
//     radius: rad,
//     titlePositionPercentageOffset: 0.6,
//     titleStyle: const TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//         fontSize: 13),
//   );
// }
 }
