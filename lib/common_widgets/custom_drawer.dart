// lib/views/widgets/custom_drawer.dart
// Light Theme Drawer — fixed overflow + no overlap

import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';

// ── Light theme colors ────────────────────────────────────────
const Color _dBg      = Color(0xFFFFFFFF);
const Color _dSurface = Color(0xFFF8F9FA);
const Color _dBorder  = Color(0xFFE9ECEF);
const Color _dOrange  = Color(0xFFF97316);
const Color _dOrangD  = Color(0xFFEA580C);
const Color _dOrangDD = Color(0xFF9A3412);
const Color _dText    = Color(0xFF1E293B);
const Color _dText2   = Color(0xFF64748B);
const Color _dActive  = Color(0xFFFFF7ED);
const Color _dRed     = Color(0xFFEF4444);
const Color _dRedBg   = Color(0xFFFEF2F2);

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key}) : super(key: key);

  final DashboardController controller = Get.find();
  final RxBool isExpanded = true.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final w = isExpanded.value ? 260.0 : 72.0;
      return SizedBox(
        width: w,
        child: Material(
          color: _dBg,
          elevation: 4,
          shadowColor: Colors.black26,
          child: Column(children: [
            _Header(isExpanded: isExpanded),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: Routes.dashboardScreen,
                    isExpanded: isExpanded),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.bolt_rounded,
                    label: 'Flashing',
                    route: Routes.flashingScreen,
                    isExpanded: isExpanded),
                  const SizedBox(height: 16),
                  // Section label / divider
                  Obx(() => isExpanded.value
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 6),
                          child: Text('ACCOUNT',
                            style: TextStyle(
                              fontSize: 9,
                              color: _dText2.withOpacity(0.6),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5)))
                      : const Divider(color: _dBorder, height: 20)),
                  _NavItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    route: Routes.loginScreen,
                    isExpanded: isExpanded,
                    isLogout: true),
                ],
              ),
            ),
            _VersionInfo(
              controller: controller,
              isExpanded: isExpanded),
          ]),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Header — orange gradient, overflow-safe
// ════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final RxBool isExpanded;
  const _Header({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isExpanded.value;
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_dOrange, _dOrangD, _dOrangDD],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
          boxShadow: [BoxShadow(
            color: Color(0x30F97316),
            blurRadius: 6, offset: Offset(0, 3))]),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Logo circle — always visible
                  // Container(
                  //   width: 36, height: 36,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white24,
                  //     shape: BoxShape.circle,
                  //     border: Border.all(
                  //       color: Colors.white38, width: 1.5)),
                  //   child: const Center(child: Text('A',
                  //     style: TextStyle(
                  //       color: Colors.white, fontSize: 16,
                  //       fontWeight: FontWeight.w900)))),

                  // App name — only when expanded
                  if (expanded) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('ATPL-PFS',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white, fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                          Text('ECU Flash System',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color.fromARGB(222, 255, 255, 255),
                              fontSize: 9.5)),
                        ])),
                    const SizedBox(width: 4),
                  ] else
                    const Spacer(),

                  // Toggle button
                  GestureDetector(
                    onTap: () => isExpanded.toggle(),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(63, 255, 255, 255),
                        borderRadius: BorderRadius.circular(6)),
                      child: Icon(
                        expanded
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        color: Colors.white, size: 16))),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Nav Item — overflow-safe
// ════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   route;
  final RxBool   isExpanded;
  final bool     isLogout;

  const _NavItem({
    required this.icon,    required this.label,
    required this.route,   required this.isExpanded,
    this.isLogout = false,
  });

  bool   get _isActive    => Get.currentRoute == route;
  Color  get _iconColor   => isLogout ? _dRed    : _dOrange;
  Color  get _labelColor  => isLogout ? _dRed    : _dText;
  Color  get _activeBg    => isLogout ? _dRedBg  : _dActive;
  Color  get _activeAccent=> isLogout ? _dRed    : _dOrange;

  void _onTap() async {
    if (isLogout) {
      await AppPreferences.logout();
      Get.offAllNamed(route);
    } else {
      Get.toNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isExpanded.value;
      final active   = _isActive;

      return GestureDetector(
        onTap: _onTap,
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: active ? _activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(
                    color: _activeAccent.withOpacity(0.25),
                    width: 1)
                : null),
          child: expanded
              // ── Expanded row ────────────────────────────
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Left accent
                    Container(
                      width: 3,
                      margin: const EdgeInsets.only(left: 6, right: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? _activeAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2))),
                    // Icon box
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: active
                            ? _activeAccent.withOpacity(0.12)
                            : _dSurface,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: active
                              ? _activeAccent.withOpacity(0.2)
                              : _dBorder)),
                      child: Icon(icon,
                        color: active ? _iconColor : _dText2,
                        size: 15)),
                    const SizedBox(width: 8),
                    // Label — Flexible prevents overflow
                    Flexible(
                      child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active ? _iconColor : _labelColor))),
                    // Active dot
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 5, height: 5,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: _activeAccent,
                          shape: BoxShape.circle)),
                    ],
                  ])
              // ── Collapsed — icon only ────────────────────
              : Center(
                  child: Tooltip(
                    message: label,
                    preferBelow: false,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: active ? _activeBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: active
                            ? Border.all(
                                color: _activeAccent.withOpacity(0.3))
                            : null),
                      child: Icon(icon,
                        color: active ? _iconColor : _dText2,
                        size: 19)))),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Version Info — overflow-safe
// ════════════════════════════════════════════════════════════
class _VersionInfo extends StatelessWidget {
  final DashboardController controller;
  final RxBool isExpanded;
  const _VersionInfo({
    required this.controller,
    required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = isExpanded.value;
      return GestureDetector(
        onTap: () => Get.toNamed(Routes.devScreen),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: _dSurface,
            border: Border(top: BorderSide(color: _dBorder))),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 12 : 8,
            vertical: 10),
          child: expanded
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Icon
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_dOrange, _dOrangD]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(
                          color: Color(0x25F97316), blurRadius: 5)]),
                      child: const Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 15)),
                    const SizedBox(width: 8),
                    // Text — Flexible prevents overflow
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.appName.value
                                .replaceAll('_', ' ')
                                .isNotEmpty
                                ? controller.appName.value
                                    .replaceAll('_', ' ')
                                : 'ATPL Flashing App',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5, color: _dText,
                              fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            'v${controller.version.value} '
                            '(${controller.buildNumber.value})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5, color: _dText2)),
                        ])),
                  ])
              // Collapsed
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                      color: _dOrange, size: 15),
                    const SizedBox(height: 2),
                    Text(
                      controller.version.value.isNotEmpty
                          ? 'v${controller.version.value}'
                          : 'v1.0',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8, color: _dText2)),
                  ]),
        ),
      );
    });
  }
}