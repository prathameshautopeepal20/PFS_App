
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';

class FlashingApiService {

  /// GET MODELS
  Future<List<dynamic>> getModels() async {
    final url = AppEnvironment.baseUrl + "flashing/models/";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  /// GET SUB MODELS
  Future<List<dynamic>> getSubModels(String modelId) async {
    final url = AppEnvironment.baseUrl + "flashing/submodels/$modelId/";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  /// GET ECUs
  Future<List<dynamic>> getEcus(String subModelId) async {
    final url = AppEnvironment.baseUrl + "flashing/ecus/$subModelId/";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  /// GET DONGLES (LIVE LIKE .NET)
  Future<List<dynamic>> getDongles() async {
    final url = AppEnvironment.baseUrl + "flashing/dongles/";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }
}