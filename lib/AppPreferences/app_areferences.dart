// lib/AppPreferences/app_areferences.dart
// FIXED: Added saveSession() + getSession() for pfs session id used in flash records

import 'dart:convert';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _currentUserIdKey = 'active_user_id';
  static const String _userRecipePrefix = 'recipes_for_user_';
  static const String _tokenKey         = 'auth_token';
  static const String _loginResponseKey = 'login_response';
  static const String _sessionKey       = 'pfs_session'; // ← NEW

  // ══════════════════════════════════════════════════════════
  //  SESSION — analyze/create-pfs/ response
  //  The session.id is used as the `pfs` field in every
  //  flash record POST (analyze/create-ecu-pfs/)
  // ══════════════════════════════════════════════════════════

  /// Save session after create-pfs/ call (called at login + on RESET)
  static Future<void> saveSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session));
    print('💾 [PREFS] Session saved — id: ${session['id']}');
  }

  /// Get the current PFS session
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Get just the session id (used as `pfs` field)
  static Future<String> getSessionId() async {
    final session = await getSession();
    return session?['id']?.toString() ?? '';
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ══════════════════════════════════════════════════════════
  //  LOGIN RESPONSE
  // ══════════════════════════════════════════════════════════

  static Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginResponseKey, jsonEncode(response));
    print('💾 [PREFS] Login response saved');
  }

  static Future<Map<String, dynamic>?> getLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_loginResponseKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<int> getOemId() async {
    final res = await getLoginResponse();
    return res?['profile']?['oem']?['id'] ?? 0;
  }

  static Future<int> getStationId() async {
    final res  = await getLoginResponse();
    final list = res?['station_data'] as List?;
    if (list != null && list.isNotEmpty) {
      return (list[0]['id'] as int? ?? 0);
    }
    return 0;
  }

  static Future<String> getRole() async {
    final res = await getLoginResponse();
    return res?['role'] ?? '';
  }

  static Future<int> getUserId() async {
    final res = await getLoginResponse();
    return res?['user_id'] ?? 0;
  }

  static Future<void> clearLoginResponse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginResponseKey);
  }

  // ══════════════════════════════════════════════════════════
  //  SESSION MANAGEMENT
  // ══════════════════════════════════════════════════════════

  static Future<void> setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, userId);
  }

  static Future<String?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_loginResponseKey);
    await prefs.remove(_sessionKey);
  }

  // ══════════════════════════════════════════════════════════
  //  RECIPES (unchanged)
  // ══════════════════════════════════════════════════════════

  static Future<void> saveRecipeForCurrentUser(Recipe recipe) async {
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserIdKey);
    if (userId == null) return;
    if (recipe.model == null) return;
    final storageKey = '$_userRecipePrefix$userId';
    final rawData    = prefs.getString(storageKey);
    final recipeMap  = rawData != null
        ? jsonDecode(rawData) as Map<String, dynamic>
        : <String, dynamic>{};
    recipeMap[recipe.model!] = recipe.toJson();
    await prefs.setString(storageKey, jsonEncode(recipeMap));
  }

  static Future<List<Recipe>> getRecipesForCurrentUser() async {
    final prefs      = await SharedPreferences.getInstance();
    final userId     = prefs.getString(_currentUserIdKey);
    final storageKey = '$_userRecipePrefix$userId';
    final rawData    = prefs.getString(storageKey);
    if (rawData == null || rawData.isEmpty) return [];
    try {
      final map = jsonDecode(rawData) as Map<String, dynamic>;
      return map.values.map((j) => Recipe.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteRecipeForCurrentUser(String recipeModel) async {
    final prefs      = await SharedPreferences.getInstance();
    final userId     = prefs.getString(_currentUserIdKey);
    if (userId == null) return;
    final storageKey = '$_userRecipePrefix$userId';
    final rawData    = prefs.getString(storageKey);
    if (rawData == null || rawData.isEmpty) return;
    final recipeMap  = jsonDecode(rawData) as Map<String, dynamic>;
    recipeMap.remove(recipeModel);
    await prefs.setString(storageKey, jsonEncode(recipeMap));
  }

  // ══════════════════════════════════════════════════════════
  //  TOKEN
  // ══════════════════════════════════════════════════════════

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('🔑 [PREFS] Token saved');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ══════════════════════════════════════════════════════════
  //  USERNAME / PASSWORD / STATION (unchanged)
  // ══════════════════════════════════════════════════════════

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
  }

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_username');
  }

  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_password', password);
  }

  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_password');
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
  }

  static Future<void> saveStationId(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stationId', stationId);
  }

  static Future<String?> getStationIdString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('stationId');
  }

  // ══════════════════════════════════════════════════════════
  //  MODBUS (unchanged)
  // ══════════════════════════════════════════════════════════

  static Future<void> setModbusSettings(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plc_ip', ip.trim());
    await prefs.setInt('plc_port', port);
  }

  static Future<Map<String, String>> getModbusSettings() async {
    final prefs   = await SharedPreferences.getInstance();
    final ip      = prefs.getString('plc_ip') ?? '192.168.1.1';
    final rawPort = prefs.get('plc_port');
    int portInt;
    if (rawPort is int)         portInt = rawPort;
    else if (rawPort is String) portInt = int.tryParse(rawPort) ?? 502;
    else                        portInt = 502;
    return {'ip': ip, 'port': portInt.toString()};
  }

  static Future<void> setUserRole(String value) async {}
}