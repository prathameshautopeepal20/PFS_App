// lib/logic/controller/auth/loginController.dart
// FIXED: Creates session (analyze/create-pfs/) after login — same as .NET LoginViewModel.CreateSession()

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
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading    = false.obs;
  final hidePassword = true.obs;
  final selectedRole = 'Admin'.obs;
  final roles        = ['User', 'Supervisor', 'Admin'];

  final serverStatus = 'Checking...'.obs;
  final serverColor  = Colors.grey.obs;

  bool isPageVisible = true;

  static const String deviceType = 'windows';
  static const String macId      = '29:14:65:11:63:70';

  @override
  void onInit() {
    super.onInit();
    startServerCheck();
  }

  // ── Server check ──────────────────────────────────────────
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

  // ── LOGIN ─────────────────────────────────────────────────
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

      final url  = '${AppEnvironment.baseUrl}${AppURLs.login}';
      final body = {
        'username':    user,
        'password':    pass,
        'role':        role,
        'device_type': deviceType,
        'mac_id':      macId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final res = jsonDecode(
        response.body.isEmpty ? '{}' : response.body,
      ) as Map<String, dynamic>;

      isLoading.value = false;

      // ── SUCCESS ───────────────────────────────────────────
      if (response.statusCode == 200) {
        final token = res['token']?['access'] ?? '';

        // Validate role
        final serverRole = res['role'] ?? '';
        if (!serverRole.toString().contains(role)) {
          Get.snackbar('Error', 'Please select a valid role',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // Validate station
        final stationData = res['station_data'] as List?;
        if (stationData == null || stationData.isEmpty) {
          Get.snackbar('Error', 'Please assign a station for user.',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // Save token + user + full login response
        await AppPreferences.setToken(token);
        await AppPreferences.setActiveUser(user);
        await AppPreferences.saveLoginResponse(res);

        print('✅ Login success — role: $serverRole | station: ${stationData[0]['id']}');

        // ── CREATE SESSION (analyze/create-pfs/) ─────────────
        // Mirrors .NET LoginViewModel.CreateSession()
        await _createSession(res, token);

      } else {
        final error = res['error'] ?? 'Login failed';
        Get.snackbar('Login Failed', error.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } on SocketException {
      isLoading.value = false;
      Get.snackbar('No Internet', 'Check connection');
    } on TimeoutException {
      isLoading.value = false;
      Get.snackbar('Timeout', 'Server not responding');
    } catch (e) {
      isLoading.value = false;
      print('❌ Login error: $e');
      Get.snackbar('Error', 'Something went wrong');
    }
  }

  // ── CREATE SESSION after login ────────────────────────────
  // Mirrors .NET: LoginViewModel.CreateSession()
  // POST analyze/create-pfs/ → save session → navigate to drawer
  Future<void> _createSession(Map<String, dynamic> profile, String token) async {
    try {
      isLoading.value = true;

      final stationData = (profile['station_data'] as List);
      final body = {
        'user':    profile['user_id'],
        'plant':   stationData[0]['plants'],
        'status':  'New',
        'station': stationData[0]['id'],
      };

      print('🔗 Creating session → POST analyze/create-pfs/');
      print('📦 Body: ${jsonEncode(body)}');

      final res = await http.post(
        Uri.parse('${AppEnvironment.baseUrl}analyze/create-pfs/'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'JWT $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 Session response ${res.statusCode}: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final session = jsonDecode(res.body) as Map<String, dynamic>;

        // Save session for later use in flash record creation (pfs field)
        await AppPreferences.saveSession(session);
        print('✅ Session created — id: ${session['id']}');

        // Navigate to dashboard/drawer
        Get.offAllNamed(Routes.dashboardScreen);
      } else {
        // Session failed — show alert, go back to login
        // Mirrors .NET: page.DisplayAlert("Session create failed", ...)
        Get.snackbar('Session Error',
            'Session create failed. Please try again.',
            backgroundColor: Colors.red, colorText: Colors.white);
        // Don't navigate — user stays on login
      }
    } catch (e) {
      print('❌ CreateSession error: $e');
      Get.snackbar('Session Error', 'Could not create session.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    isPageVisible = false;
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}