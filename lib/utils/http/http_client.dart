import 'dart:convert';
import 'dart:io';

import 'package:gateway_mobile/common/widgets/loaders/loaders.dart';
import 'package:gateway_mobile/features/authentication/screens/login/login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gateway_mobile/utils/constants/api_constants.dart';

class APPHttpHelper {
  static Future<Map<String, dynamic>> get(String endpoint, String token) async {
    final response = await http
        .get(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            HttpHeaders.acceptHeader: "application/json",
          },
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMaster(
    String endpoint,
    String token,
  ) async {
    final response = await http
        .get(
          Uri.parse("${APIConstants.trackUrl}/$endpoint"),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            HttpHeaders.acceptHeader: "application/json",
          },
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .post(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> postMaster(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .post(
          Uri.parse("${APIConstants.trackUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> postwt(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .post(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .put(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .patch(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint,
    String token,
  ) async {
    final response = await http
        .delete(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    // print(response.body);
    // print("Response Status: ${response.statusCode}");
    // print("Response Body: '${response.body}'");

    if (response.body.isEmpty) {
      throw const FormatException("Empty response body");
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 408) {
      APPLoaders.warningSnackBar(
        title: "Session Expired",
        message:
            "Your security token has expired (10 min limit). Please log in again to continue.",
      );
      Get.offAll(() => const LoginScreen());
      return {
        "status": "failure",
        "code": "401",
        "error": "Session Expired",
        "message": "Please log in again.",
      };
    } else {
      var data = json.decode(response.body);
      return data;
      //throw Exception('${data["error"]}');
    }
  }

  static Future<List<dynamic>> getList(String endpoint, String token) async {
    final response = await http
        .get(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleListResponse(response);
  }

  static Future<List<dynamic>> postList(
    String endpoint,
    String token,
    dynamic data,
  ) async {
    final response = await http
        .post(
          Uri.parse("${APIConstants.baseUrl}/$endpoint"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: json.encode(data),
        )
        .timeout(
          const Duration(seconds: 40),
          onTimeout: () {
            return http.Response("Error", 408);
          },
        );
    return _handleListResponse(response);
  }

  static List<dynamic> _handleListResponse(http.Response response) {
    //print(json.decode(response.body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 408) {
      return [
        {"status": "Timeout"},
      ];
    } else {
      var data = json.decode(response.body);
      throw Exception('${data["error"]}');
    }
  }
}
