// import 'package:cp_tmtl_sensor_zig/common_widgets/custom_drawer.dart';
// import 'package:cp_tmtl_sensor_zig/logic/controller/dashboard/settingsController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MainLayout extends StatelessWidget {
//   final Widget child;
//   final String title;
//   final bool showDrawer;

//   const MainLayout({
//     super.key,
//     required this.child,
//     required this.title,
//     this.showDrawer = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.of(context).size.width < 800;
//     // Find the permanent PLC Controller
//     final PLCController plcController = Get.find<PLCController>();

//     // Helper widget for the status dot to avoid code duplication
//     Widget connectionStatusDot() {
//       return Obx(() => Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: plcController.isConnected.value
//                           ? Colors.green
//                           : Colors.red,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: (plcController.isConnected.value
//                                   ? Colors.green
//                                   : Colors.red)
//                               .withOpacity(0.4),
//                           blurRadius: 4,
//                           spreadRadius: 2,
//                         )
//                       ],
//                     ),
//                   ),
//                   // if (!isMobile) const SizedBox(width: 8),
//                   // if (!isMobile)
//                   //   Text(
//                   //     plcController.isConnected.value ? "ONLINE" : "",
//                   //     style: TextStyle(
//                   //       color: plcController.isConnected.value ? Colors.green : Colors.red,
//                   //       fontSize: 12,
//                   //       fontWeight: FontWeight.bold,
//                   //     ),
//                   //   ),
//                 ],
//               ),
//             ),
//           ));
//     }

//     return Scaffold(
//       drawer: (isMobile && showDrawer) ? CustomDrawer() : null,
//       appBar: isMobile
//           ? AppBar(
//               title: Text(title,
//                   style: const TextStyle(
//                       fontFamily: "Roboto-Regular", color: Colors.white)),
//               backgroundColor: const Color(0xFF0055BB),
//               leading: !showDrawer
//                   ? IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Get.back())
//                   : null,
//               // --- MOBILE ACTION BUTTON ---
//               actions: [connectionStatusDot()],
//             )
//           : null,
//       body: Row(
//         children: [
//           if (!isMobile && showDrawer) CustomDrawer(),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: (isMobile || !showDrawer)
//                     ? null
//                     : Border.all(color: const Color(0xFF0055BB), width: 8),
//               ),
//               child: Scaffold(
//                 backgroundColor: Colors.transparent,
//                 appBar: !isMobile
//                     ? AppBar(
//                         backgroundColor: Colors.transparent,
//                         elevation: 0,
//                         title: Text(title,
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold)),
//                         leading: !showDrawer
//                             ? IconButton(
//                                 icon: const Icon(Icons.arrow_back,
//                                     color: Colors.black),
//                                 onPressed: () => Get.back())
//                             : null,
//                         // --- DESKTOP ACTION BUTTON ---
//                         actions: [connectionStatusDot()],
//                       )
//                     : null,
//                 body: child,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:atpl_flashing_app/common_widgets/custom_drawer.dart';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showDrawer;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final PLCController plcController = Get.find<PLCController>();

    // 1. Status Indicator & Connect Button Logic
    List<Widget> buildAppBarActions() {
      return [
        Obx(() {
          bool connected = plcController.isConnected.value;
          return Row(
            children: [
              // Show "Connect PLC" button ONLY when disconnected
              if (!connected)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: () => _showQuickConnect(plcController),
                    icon: const Icon(Icons.cast_connected,
                        size: 18, color: Colors.orangeAccent),
                    label: const Text("Connect PLC",
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),

              // Simple Status Dot (No longer clickable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: connected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (connected ? Colors.green : Colors.red)
                            .withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: (isMobile && showDrawer) ? CustomDrawer() : null,
      appBar: isMobile
          ? AppBar(
              title: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              backgroundColor: const Color(0xFF0055BB),
              actions: buildAppBarActions(),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile && showDrawer) CustomDrawer(),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: !isMobile
                  ? AppBar(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      title: Text(title,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      actions: buildAppBarActions(),
                    )
                  : null,
              body: child,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Larger and Custom Dialog
  void _showQuickConnect(PLCController controller) {
    controller.loadSettings();

    // Get.dialog(
    //   Dialog(
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //     child: Container(
    //       width: 450,
    //       padding: const EdgeInsets.all(30),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           const Row(
    //             children: [
    //               Icon(Icons.settings_input_component,
    //                   color: Color(0xFF0055BB), size: 28),
    //               SizedBox(width: 15),
    //               Text("PLC Quick Connection",
    //                   style:
    //                       TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    //             ],
    //           ),
    //           const Divider(height: 40),

    //           // --- EDITABLE IP ADDRESS FIELD ---
    //           const Align(
    //             alignment: Alignment.centerLeft,
    //             child: Text("Edit Target IP Address",
    //                 style: TextStyle(
    //                     color: Colors.blueGrey, fontWeight: FontWeight.w500)),
    //           ),
    //           const SizedBox(height: 10),
    //           TextFormField(
    //             controller: controller.ipController,
    //             keyboardType: TextInputType.number,
    //             decoration: InputDecoration(
    //               filled: true,
    //               fillColor: Colors.grey[100],
    //               border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(8)),
    //               hintText: "e.g. 192.168.1.10",
    //             ),
    //           ),

              // const Align(
              //   alignment: Alignment.centerLeft,
              //   child: Text("Port",
              //       style: TextStyle(
              //           color: Colors.blueGrey, fontWeight: FontWeight.w500)),
              // ),
              // const SizedBox(height: 10),
              // TextFormField(
              //   controller: controller.portController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: Colors.grey[100],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     hintText: "e.g. 502", // ✅ Correct
              //   ),
              // ),

              // Note: Port is kept invisible but exists in controller.portController.text

    //           const SizedBox(height: 30),
    //           const Text(
    //             "Ensure the PLC is reachable on the local network before attempting to connect.",
    //             textAlign: TextAlign.center,
    //             style: TextStyle(color: Colors.grey, fontSize: 13),
    //           ),
    //           const SizedBox(height: 40),

    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               TextButton(
    //                 onPressed: () => Get.back(),
    //                 child: const Text("Cancel",
    //                     style: TextStyle(color: Colors.grey)),
    //               ),
    //               const SizedBox(width: 15),
    //               Obx(() => ElevatedButton(
    //                     style: ElevatedButton.styleFrom(
    //                         backgroundColor: const Color(0xFF0055BB),
    //                         foregroundColor: Colors.white,
    //                         padding: const EdgeInsets.symmetric(
    //                             horizontal: 30, vertical: 15),
    //                         shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(8))),
    //                     onPressed: controller.isConnecting.value
    //                         ? null
    //                         : () async {
    //                             // 1. Attempt connection
    //                             await controller.connectToPLC(
    //                                 controller.ipController.text,
    //                                  // 🔥 hardcoded port
    //                                 );

    //                             // 2. Handle Outcome
    //                             if (controller.isConnected.value) {
    //                               // Success: Close the settings/connect dialog
    //                               Get.back();
    //                               Get.dialog(
    //                                 CustomPopup(
    //                                   title: "Connected",
    //                                   message:
    //                                       " Established connection to ${controller.ipController.text}",
    //                                    // Uses that red accent we discussed
    //                                   confirmText: "Okay",
    //                                   onConfirm: () => Get
    //                                       .back(), // Closes popup to let them try again
    //                                 ),
    //                                 barrierDismissible: false,
    //                               );
    //                             } else {
    //                               // Failure: Show the Windows-friendly CustomPopup
    //                               Get.dialog(
    //                                 CustomPopup(
    //                                   title: "Connection Failed",
    //                                   message:
    //                                       "Unable to reach the PLC at ${controller.ipController.text}. "
    //                                       "Please verify the IP address and ensure the hardware is powered on.",
    //                                   isError:
    //                                       true, // Uses that red accent we discussed
    //                                   confirmText: "Retry",
    //                                   onConfirm: () => Get
    //                                       .back(), // Closes popup to let them try again
    //                                 ),
    //                                 barrierDismissible: false,
    //                               );
    //                             }
    //                           },
    //                     child: controller.isConnecting.value
    //                         ? const SizedBox(
    //                             width: 20,
    //                             height: 20,
    //                             child: CircularProgressIndicator(
    //                                 strokeWidth: 2, color: Colors.white))
    //                         : const Text("Connect Device"),
    //                   )),
    //             ],
    //           )
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
