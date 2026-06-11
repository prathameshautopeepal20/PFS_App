// // import 'dart:io';
// // import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
// // import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
// // import 'package:atpl_flashing_app/logic/controller/dataSyncController.dart';
// // import 'package:atpl_flashing_app/routes/routes_string.dart';
// // import 'package:atpl_flashing_app/themes/app_colors.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:path_provider/path_provider.dart';

// // class CustomDrawer extends StatelessWidget {
// //   CustomDrawer({Key? key}) : super(key: key);

// //   final String drawerTitle = "CP-TMTL";
// //   final String drawerSubtitle = "Sensor Zig";
// //   final DashboardController controller = Get.find();
// //   final DataSyncController dataSyncController = Get.find();

// //   @override
// //   Widget build(BuildContext context) {
// //     final bool isDesktop = MediaQuery.of(context).size.width > 800;

// //     return Drawer(
// //       width: isDesktop ? 400 : MediaQuery.of(context).size.width * 0.85,
// //       child: Column(
// //         children: [
// //           // Header
// //           Container(
// //             width: double.infinity,
// //             padding: EdgeInsets.symmetric(horizontal: 24, vertical: isDesktop ? 50 : 64),
// //             decoration: BoxDecoration(
// //               color: AppColors.primaryColor,
// //               gradient: LinearGradient(
// //                 colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
// //                 begin: Alignment.topLeft, end: Alignment.bottomRight,
// //               ),
// //             ),
// //             child: Column(
// //               children: [
// //                 Text(drawerTitle, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 30 : 26, fontWeight: FontWeight.bold)),
// //                 const SizedBox(height: 10),
// //                 Text(drawerSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
// //               ],
// //             ),
// //           ),

// //           // Menu
// //           Expanded(
// //             child: Container(
// //               color: Colors.white,
// //               child: Scrollbar(
// //                 thumbVisibility: isDesktop,
// //                 child: ListView(
// //                   primary: true, // IMPORTANT: Fixes the Scrollbar exception
// //                   padding: const EdgeInsets.symmetric(vertical: 12),
// //                   children: [
// //                     _buildTile(Icons.analytics_outlined, "Dashboard", () => Get.back()),
// //                     buildDivider(),
// //                     _buildTile(Icons.assignment_turned_in_outlined, "Testing", () {
// //                       Get.back();
// //                       Get.toNamed(Routes.testingScreen);
// //                     }),
// //                     buildDivider(),
// //                     _buildTile(Icons.laptop_windows_outlined, "Test Recipe", () {
// //                       Get.back();
// //                       Get.toNamed(Routes.testRecipeScreen);
// //                     }),
// //                     buildDivider(),
// //                     _buildTile(Icons.settings_outlined, "Settings", () async {
// //                       await AppPreferences.clearExceptCredentials();
// //                       await _clearLocalData();
// //                       Get.offAllNamed(Routes.loginScreen);
// //                     }),
// //                     buildDivider(),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
// //     return ListTile(
// //       leading: Icon(icon, color: Colors.black87, size: 24),
// //       title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
// //       onTap: onTap,
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
// //       visualDensity: VisualDensity.comfortable,
// //     );
// //   }

// //   Future<void> _clearLocalData() async {
// //     final dir = await getApplicationDocumentsDirectory();
// //     final files = ['MODEL_LocalList.txt', 'IOR_LocalList.txt', 'Actuator_LocalList.txt', 'FreezeFrame_LocalList.txt', 'UserDetail_LocalData.txt', 'UserRequest_LocalData.txt'];
// //     for (var f in files) {
// //       final file = File('${dir.path}/$f');
// //       if (await file.exists()) await file.delete();
// //     }
// //   }

// //   Widget buildDivider() => Divider(color: Colors.grey.shade300, height: 1, indent: 20, endIndent: 20);
// // }

// import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:atpl_flashing_app/routes/routes_string.dart';
// import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';

// class CustomDrawer extends StatelessWidget {
//   CustomDrawer({Key? key}) : super(key: key);
// final DashboardController controller = Get.find();
//   // We use an RxBool so we can toggle it without a full StatefulWidget rebuild
//   final RxBool isExpanded = true.obs;

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: isExpanded.value ? 300 : 80, // Expanded vs Mini width
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(right: BorderSide(color: Colors.grey.shade300)),
//           ),
//           child: Column(
//             children: [
//               // --- HEADER / TOGGLE SECTION ---
//               _buildHeader(),

//               const Divider(height: 1),

//               // --- MENU ITEMS ---
//               Expanded(
//                 child: ListView(
//                   primary: true,
//                   children: [
//                     _buildSidebarTile(Icons.analytics_outlined, "Dashboard",
//                         Routes.dashboardScreen),
//                     _buildSidebarDivider(), // Line after Dashboard

//                     _buildSidebarTile(Icons.assignment_turned_in_outlined,
//                         "Testing", Routes.testingScreen),
//                     _buildSidebarDivider(), // Line after Testing

//                     _buildSidebarTile(Icons.laptop_windows_outlined,
//                         "Test Recipe", Routes.testRecipeScreen),
//                     _buildSidebarDivider(), // Line after Test Recipe

//                     _buildSidebarTile(
//                         Icons.settings_outlined, "Settings", Routes.settingsScreen,
//                         isLogout: true),
//                     _buildSidebarDivider(),
//                     // No divider here if it's the last item, or add one if preferred
//                   ],
//                 ),
//               ),
//                Obx(() => SafeArea(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Column(
//                     children: [
//                       Text(
//                         controller.appName.value,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Version ${controller.version.value} (${controller.buildNumber.value})",
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ))
//             ],
//           ),
//         ));
//   }

//   Widget _buildSidebarDivider() {
//     return Divider(
//       color: Colors.blue.shade600
//           .withOpacity(0.3), // Lower opacity for subtler look
//       height: 1, // Space occupied by the divider widget
//       thickness: 1, // Actual line thickness
//       indent: 20, // Padding from the left
//       endIndent: 20, // Padding from the right
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 120,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       color: Colors.blue.shade600,
//       child: Row(
//         mainAxisAlignment: isExpanded.value
//             ? MainAxisAlignment.spaceBetween
//             : MainAxisAlignment.center,
//         children: [
//           if (isExpanded.value)
//             const Flexible(
//               child: Text(
//                 "CP-TMTL",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           IconButton(
//             icon: Icon(isExpanded.value ? Icons.menu_open : Icons.menu,
//                 color: Colors.white),
//             onPressed: () => isExpanded.toggle(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSidebarTile(IconData icon, String title, String route,
//       {bool isLogout = false}) {
//     final double iconSize = GetPlatform.isWindows ? 28 : 24;

//     return Obx(() {
//       // Check if the drawer is collapsed
//       if (!isExpanded.value) {
//         return InkWell(
//           onTap: () => _handleNavigation(route, isLogout),
//           child: Container(
//             height: 50, // Matches standard ListTile height
//             width: double.infinity,
//             alignment: Alignment.center,
//             child: Icon(
//               icon,
//               color: Colors.blue.shade600,
//               size: iconSize,
//             ),
//           ),
//         );
//       }

//       // Standard ListTile only when there is plenty of room (Expanded)
//       return ListTile(
//         minLeadingWidth: 0,
//         horizontalTitleGap: 16,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 24),
//         leading: Icon(
//           icon,
//           color: Colors.blue.shade600,
//           size: iconSize,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: GetPlatform.isWindows ? 16 : 14,
//             color: Colors.black87,
//           ),
//         ),
//         onTap: () => _handleNavigation(route, isLogout),
//       );
//     });
//   }

// // Separate navigation logic to keep code clean
//   void _handleNavigation(String route, bool isLogout) async {
//     if (isLogout) {
//       await AppPreferences.clearExceptCredentials();
//       Get.offAllNamed(route);
//     } else {
//       Get.toNamed(route);
//     }
//   }
// }
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
//import 'package:atpl_flashing_app/views/screens/dashboard/batch_flashing_popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key}) : super(key: key);
  final DashboardController controller = Get.find();
  final RxBool isExpanded = true.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isExpanded.value ? 300 : 80,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  primary: true,
                  children: [
                    _buildSidebarTile(Icons.analytics_outlined, "Dashboard",
                        Routes.dashboardScreen),
                    _buildSidebarDivider(),

                    // ListTile(
                    //   leading: Icon(
                    //     Icons.layers_outlined,
                    //     color: Colors.orange.shade600,
                    //   ),
                    //   title: const Text(
                    //     "Batch Flashing",
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    //   onTap: () async {
                    //     final result = await showDialog(
                    //       context: Get.context!,
                    //       barrierDismissible: false,
                    //       builder: (context) => const BatchFlashingPopup(),
                    //     );

                    //     if (result != null) {
                    //       Get.toNamed(
                    //         Routes.batchFlashingScreen,
                    //         arguments: result,
                    //       );
                    //     }
                    //   },
                    // ),

                    // _buildSidebarTile(Icons.flash_on_outlined,
                    //     "Individual Flashing", Routes.testRecipeScreen),
                    // _buildSidebarDivider(),

                    _buildSidebarTile(
                      Icons.flash_on_outlined,
                      " Flashing",
                      Routes.flashingScreen,
                    ),
                    // _buildSidebarDivider(),

                    // _buildSidebarTile(Icons.sync_outlined, "Data Sync",
                    //     Routes.datasyncscreen),
                    // _buildSidebarDivider(),

                    // --- SETTINGS SECTION WITH SUB-MENU ---
                    // _buildSettingsSection(),

                    // _buildSidebarDivider(),

                    // Logout Option
                    _buildSidebarTile(
                        Icons.logout_outlined, "Logout", Routes.loginScreen,
                        isLogout: true),
                  ],
                ),
              ),
              _buildVersionInfo(),
            ],
          ),
        ));
  }

  // --- NEW: SETTINGS EXPANSION SECTION ---
  Widget _buildSettingsSection() {
    final double iconSize = GetPlatform.isWindows ? 28 : 24;

    return Obx(() {
      if (!isExpanded.value) {
        // If collapsed, show a simple icon that opens a small menu or expands the drawer
        return IconButton(
          icon: Icon(Icons.settings_outlined,
              color: Colors.orange.shade600, size: iconSize),
          onPressed: () => isExpanded.value = true,
        );
      }

      return ExpansionTile(
        leading: Icon(Icons.settings_outlined,
            color: Colors.orange.shade600, size: iconSize),
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: GetPlatform.isWindows ? 16 : 14,
            color: Colors.black87,
          ),
        ),
        iconColor: Colors.orange.shade600,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 20), // Indent sub-items
        children: [
          _buildSubTile(Icons.electrical_services_outlined, "PLC Configuration",
              Routes.settingsScreen),
          _buildSubTile(Icons.analytics_outlined, "Sensor Analysis",
              Routes.sensorAnalysis),
        ],
      );
    });
  }

  Widget _buildSubTile(IconData icon, String title, String route) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: Colors.orange.shade400, size: 25),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto-Regular"),
      ),
      onTap: () => Get.toNamed(route),
    );
  }

  // Widget _buildHeader() {
  //   return Container(
  //     height: 120,
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     color: Colors.blue.shade600,
  //     child: Row(
  //       mainAxisAlignment: isExpanded.value
  //           ? MainAxisAlignment.spaceBetween
  //           : MainAxisAlignment.center,
  //       children: [

  //         if (isExpanded.value)
  //           const Flexible(
  //             child: Text(
  //               "CP-TMTL",
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold),
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //         IconButton(
  //           icon: Icon(isExpanded.value ? Icons.menu_open : Icons.menu,
  //               color: Colors.white),
  //           onPressed: () => isExpanded.toggle(),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildHeader() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF9772C),
      child: Row(
        mainAxisAlignment: isExpanded.value
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isExpanded.value)
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Aligns logo/name to the left
                children: [
                  Center(
                    // child: Image.asset(
                    //   'assets/new/autopeepal.png',
                    //   height: 75, // Adjust as needed
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Center(
                    child: const Text(
                      "ATPL-PFS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // The Toggle Button
          IconButton(
            icon: Icon(
              isExpanded.value ? Icons.menu_open : Icons.menu,
              color: Colors.white,
            ),
            onPressed: () => isExpanded.toggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(IconData icon, String title, String route,
      {bool isLogout = false}) {
    final double iconSize = GetPlatform.isWindows ? 28 : 24;

    return Obx(() {
      if (!isExpanded.value) {
        return InkWell(
          onTap: () => _handleNavigation(route, isLogout),
          child: Container(
            height: 50,
            width: double.infinity,
            alignment: Alignment.center,
            child: Icon(icon,
                color: isLogout ? Colors.red.shade400 : Colors.orange.shade600,
                size: iconSize),
          ),
        );
      }

      return ListTile(
        minLeadingWidth: 0,
        horizontalTitleGap: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(icon,
            color: isLogout ? Colors.red.shade400 : Colors.orange.shade600,
            size: iconSize),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: GetPlatform.isWindows ? 16 : 14,
            color: isLogout ? Colors.red.shade700 : Colors.black87,
          ),
        ),
        onTap: () => _handleNavigation(route, isLogout),
      );
    });
  }

  Widget _buildVersionInfo() {
    return Obx(() => SafeArea(
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.devScreen), // ✅ navigate on tap
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: isExpanded.value
                  ? Column(
                      children: [
                        Text(
                            "Sponsored By: ${controller.appName.value.replaceAll('_', ' ')}",
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            "Version ${controller.version.value} (${controller.buildNumber.value})",
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    )
                  : const Text("v1.1",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
        ));
  }

  // Widget _buildVersionInfo() {
  //   return Obx(() => SafeArea(
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(vertical: 12),
  //           child: isExpanded.value
  //               ? Column(
  //                   children: [
  //                     Text(
  //                         "Sponsored By: ${controller.appName.value.replaceAll('_', ' ')}",
  //                         style: const TextStyle(
  //                             fontSize: 13, fontWeight: FontWeight.w600)),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                         "Version ${controller.version.value} (${controller.buildNumber.value})",
  //                         style: const TextStyle(
  //                             color: Colors.grey,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w500)),
  //                   ],
  //                 )
  //               : const Text("v1.0",
  //                   style: TextStyle(fontSize: 10, color: Colors.grey)),
  //         ),
  //       ));
  // }

  Widget _buildSidebarDivider() {
    return Divider(
        color: Colors.blue.shade600.withOpacity(0.1),
        height: 1,
        thickness: 1,
        indent: 20,
        endIndent: 20);
  }

  void _handleNavigation(String route, bool isLogout) async {
    if (isLogout) {
      // ✅ ONLY remove the active session ID
      // Do NOT use clearAll()
      await AppPreferences.logout();

      Get.offAllNamed(route);
    } else {
      Get.toNamed(route);
    }
  }
}
