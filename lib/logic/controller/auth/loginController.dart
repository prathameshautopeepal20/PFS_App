// lib/logic/controller/auth/loginController.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';

class LoginController extends GetxController {

  // ── Text Controllers ──────────────────────────────────────
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ── Observables ───────────────────────────────────────────
  final isLoading    = false.obs;
  final hidePassword = true.obs;
  final rememberMe   = false.obs;
  final selectedRole = 'Admin'.obs;
  final serverStatus = 'Checking...'.obs;
  final serverColor  = Colors.grey.obs;

  final List<String> roles = ['User', 'Supervisor', 'Admin'];

  bool isPageVisible = true;

  static const String deviceType = 'windows';
  static const String macId      = '29:14:65:11:63:70';

  // ════════════════════════════════════════════════════════
  //  INIT
  // ════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
    startServerCheck();
  }

  // ── Load saved credentials if Remember Me was checked ────
  Future<void> _loadSavedCredentials() async {
    final saved = await AppPreferences.getSavedCredentials();
    if (saved != null) {
      usernameController.text = saved['username'] ?? '';
      passwordController.text = saved['password'] ?? '';
      selectedRole.value      = saved['role']     ?? 'Admin';
      rememberMe.value        = true;
    }
  }

  // ════════════════════════════════════════════════════════
  //  SERVER STATUS CHECK
  // ════════════════════════════════════════════════════════
  Future<bool> checkServerStatus() async {
    try {
      final res = await http
          .get(Uri.parse('${AppEnvironment.baseUrl}oem/oem/'))
          .timeout(const Duration(seconds: 6));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<void> startServerCheck() async {
    while (isPageVisible) {
      final ok = await checkServerStatus();
      if (ok) {
        serverStatus.value = 'Server reachable';
        serverColor.value  = Colors.green;
      } else {
        serverStatus.value = 'Server not reachable';
        serverColor.value  = Colors.red;
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  // ════════════════════════════════════════════════════════
  //  LOGIN
  // ════════════════════════════════════════════════════════
  Future<void> login() async {
    final user = usernameController.text.trim();
    final pass = passwordController.text.trim();
    final role = selectedRole.value;

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar('Error', 'Enter username & password');
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${AppEnvironment.baseUrl}${AppURLs.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        body: jsonEncode({
          'username':    user,
          'password':    pass,
          'role':        role,
          'device_type': deviceType,
          'mac_id':      macId,
        }),
      ).timeout(const Duration(seconds: 30));

      final res = jsonDecode(
        response.body.isEmpty ? '{}' : response.body,
      ) as Map<String, dynamic>;

      isLoading.value = false;

      if (response.statusCode == 200) {
        // ── Validate role ──────────────────────────────────
        final serverRole = res['role'] ?? '';
        if (!serverRole.toString().contains(role)) {
          Get.snackbar('Error', 'Please select a valid role',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // ── Validate station ───────────────────────────────
        final stationData = res['station_data'] as List?;
        if (stationData == null || stationData.isEmpty) {
          Get.snackbar('Error', 'Please assign a station for user.',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // ── Remember Me — save or clear credentials ────────
        if (rememberMe.value) {
          await AppPreferences.saveCredentials(user, pass, role);
        } else {
          await AppPreferences.clearCredentials();
        }

        // ── Save token + login response ────────────────────
        final token = res['token']?['access'] ?? '';
        await AppPreferences.setToken(token);
        await AppPreferences.setActiveUser(user);
        await AppPreferences.saveLoginResponse(res);

        print('✅ Login success — role: $serverRole | station: ${stationData[0]['id']}');

        // ── Create session then navigate ───────────────────
        await _createSession(res, token);

      } else {
        final error = res['error'] ?? 'Login failed';
        Get.snackbar('Login Failed', error.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }

    } on SocketException {
      isLoading.value = false;
      Get.snackbar('No Internet', 'Check your connection');
    } on TimeoutException {
      isLoading.value = false;
      Get.snackbar('Timeout', 'Server not responding');
    } catch (e) {
      isLoading.value = false;
      print('❌ Login error: $e');
      Get.snackbar('Error', 'Something went wrong');
    }
  }

  // ════════════════════════════════════════════════════════
  //  CREATE SESSION
  //  POST analyze/create-pfs/ → save session → navigate
  // ════════════════════════════════════════════════════════
  Future<void> _createSession(
      Map<String, dynamic> profile, String token) async {
    try {
      isLoading.value = true;

      final stationData = profile['station_data'] as List;
      final res = await http.post(
        Uri.parse('${AppEnvironment.baseUrl}analyze/create-pfs/'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode({
          'user':    profile['user_id'],
          'plant':   stationData[0]['plants'],
          'status':  'New',
          'station': stationData[0]['id'],
        }),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final session = jsonDecode(res.body) as Map<String, dynamic>;
        await AppPreferences.saveSession(session);
        print('✅ Session created — id: ${session['id']}');
        Get.offAllNamed(Routes.dashboardScreen);
      } else {
        Get.snackbar('Session Error',
            'Session create failed. Please try again.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('❌ CreateSession error: $e');
      Get.snackbar('Session Error', 'Could not create session.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════
  //  DISPOSE
  // ════════════════════════════════════════════════════════
  @override
  void onClose() {
    isPageVisible = false;
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}