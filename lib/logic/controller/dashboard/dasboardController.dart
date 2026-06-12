// lib/logic/controller/dashboard/dasboardController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DashboardController extends GetxController {

  // ── Navigation (which page is shown in content area) ──────
  final RxInt selectedIndex = 0.obs;

  // ── User info from LoginRespons ───────────────────────────
  final RxString firstName   = ''.obs;
  final RxString lastName    = ''.obs;
  final RxString fullName    = ''.obs;
  final RxString role        = ''.obs;
  final RxString stationName = ''.obs;
  final RxString stationId   = ''.obs;
  final RxString oemName     = ''.obs;
  final RxString userEmail   = ''.obs;

  // ── App info ──────────────────────────────────────────────
  final RxString appName     = ''.obs;
  final RxString version     = ''.obs;
  final RxString buildNumber = ''.obs;

  // ── Dashboard stats ───────────────────────────────────────
  final RxBool isLoading  = false.obs;
  final RxInt  totalPass  = 0.obs;
  final RxInt  totalFail  = 0.obs;
  final RxInt  shift1Pass = 0.obs;
  final RxInt  shift1Fail = 0.obs;
  final RxInt  shift2Pass = 0.obs;
  final RxInt  shift2Fail = 0.obs;
  final RxInt  shift3Pass = 0.obs;
  final RxInt  shift3Fail = 0.obs;

  String _token     = '';
  int    _stationId = 0;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadAppInfo();
  }

  Future<void> _loadUserInfo() async {
    isLoading.value = true;
    try {
      _token          = await AppPreferences.getToken() ?? '';
      final profile   = await AppPreferences.getLoginResponse();
      if (profile == null) return;

      // LoginRespons fields — handle both 'user' nested and flat
      firstName.value = profile['first_name']
          ?? profile['user']?['first_name'] ?? '';
      lastName.value  = profile['last_name']
          ?? profile['user']?['last_name']  ?? '';
      fullName.value  = '${firstName.value} ${lastName.value}'.trim();
      role.value      = profile['role']
          ?? profile['user']?['role'] ?? '';

      // Profile → oem — handle both structures
      final prof      = profile['profile'] as Map<String, dynamic>?
                     ?? profile['user']?['profile'] as Map<String, dynamic>?;
      oemName.value   = prof?['oem']?['name']
          ?? profile['oem']?['name'] ?? '';
      userEmail.value = prof?['email']
          ?? profile['email']
          ?? profile['user']?['email'] ?? '';

      // Station data
      final stations  = profile['station_data'] as List?;
      if (stations != null && stations.isNotEmpty) {
        _stationId        = stations[0]['id'] ?? 0;
        stationId.value   = stations[0]['stations_id']?.toString()
            ?? stations[0]['id']?.toString() ?? '';
        stationName.value = stations[0]['description']
            ?? stations[0]['name'] ?? '';
      }

      print('✅ User: ${fullName.value} | Role: ${role.value} | Station: ${stationName.value}');

      await _loadStats();
    } catch (e) {
      print('❌ DashboardController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      final info        = await PackageInfo.fromPlatform();
      appName.value     = info.appName;
      version.value     = info.version;
      buildNumber.value = info.buildNumber;
    } catch (_) {
      appName.value     = 'ATPL-PFS';
      version.value     = '1.0.0';
      buildNumber.value = '1';
    }
  }

  Future<void> _loadStats({
    String startDate = '2024-04-01',
    String endDate   = '',
    int subModelId   = 0,
  }) async {
    try {
      // Note: original .NET has a space in endpoint name — kept as-is
      var url =
          '${AppEnvironment.baseUrl}analyze/pfs_shift_wise status_count/'
          '?station_id=$_stationId&start_date=$startDate';
      if (endDate.isNotEmpty) url += '&end_date=$endDate';
      if (subModelId != 0)    url += '&sub_model_id=$subModelId';

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'JWT $_token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        totalPass.value = data['total_pass'] ?? 0;
        totalFail.value = data['total_fail'] ?? 0;

        final shifts = data['shift_counts'] as Map<String, dynamic>?;
        if (shifts != null) {
          shift1Pass.value = shifts['Shift 1']?['pass'] ?? 0;
          shift1Fail.value = shifts['Shift 1']?['fail'] ?? 0;
          shift2Pass.value = shifts['Shift 2']?['pass'] ?? 0;
          shift2Fail.value = shifts['Shift 2']?['fail'] ?? 0;
          shift3Pass.value = shifts['Shift 3']?['pass'] ?? 0;
          shift3Fail.value = shifts['Shift 3']?['fail'] ?? 0;
        }
      }
    } catch (e) {
      print('❌ DashboardController._loadStats: $e');
    }
  }

  Future<void> refreshStats({
    String startDate = '2024-04-01',
    String endDate   = '',
    int subModelId   = 0,
  }) async {
    isLoading.value = true;
    await _loadStats(
        startDate: startDate,
        endDate: endDate,
        subModelId: subModelId);
    isLoading.value = false;
  }

  int get totalCount => totalPass.value + totalFail.value;
}