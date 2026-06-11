
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
