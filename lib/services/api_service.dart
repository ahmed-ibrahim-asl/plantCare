//----------------------------- dart_core ------------------------------
import 'dart:convert';
import 'dart:io';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
//----------------------------------------------------------------------

class ApiService {
  // Base URL of your Flask server
  static const String baseUrl = '10.42.0.1:5000';

  static String? sessionCookie;

  /// ------------------------
  /// User Authentication
  /// ------------------------
  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = json.encode({'username': username, 'password': password});

      final response = await http.post(url, headers: headers, body: body);
      debugPrint("Login response status: ${response.statusCode}");
      debugPrint("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          sessionCookie = rawCookie.split(';').first;
          debugPrint("Session cookie saved: $sessionCookie");
        }
        final jsonData = json.decode(response.body);
        return jsonData['status'] == 'success';
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    await http.get(url, headers: _authHeader());
    sessionCookie = null;
  }

  // --- MODIFICATION: Updated register method ---
  static Future<http.Response> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final body = json.encode({
      "username": username,
      "full_name": fullName,
      "email": email,
      "password": password,
      "security_question": securityQuestion,
      "security_answer": securityAnswer,
    });

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
  }

  // --- ADDITION: Method to get the security question for a user ---
  static Future<http.Response> getSecurityQuestion(String username) async {
    final url = Uri.parse('$baseUrl/get_security_question');
    final body = json.encode({'username': username});

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
  }

  // --- ADDITION: Method to reset password using the security answer ---
  static Future<http.Response> resetPasswordWithAnswer({
    required String username,
    required String answer,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset_password_with_answer');
    final body = json.encode({
      'username': username,
      'answer': answer,
      'new_password': newPassword,
    });

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
  }

  /// ------------------------
  /// Sensor Data
  /// ------------------------
  static Future<http.Response> getSensorData() async {
    final url = Uri.parse('$baseUrl/sensor');
    return await http.get(url, headers: _authHeader());
  }

  /// ------------------------
  /// Camera Capture
  /// ------------------------
  static Future<File?> captureImageAndSave() async {
    try {
      final url = Uri.parse('$baseUrl/capture');
      final response = await http.get(url, headers: _authHeader());

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/captured_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return file;
      } else {
        debugPrint("Failed to capture image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error in captureImageAndSave: $e");
      return null;
    }
  }

  /// ------------------------
  /// Predictions
  /// ------------------------
  static Future<http.Response> predictFromCamera() async {
    if (sessionCookie == null) {
      throw Exception("User not logged in");
    }
    final url = Uri.parse('$baseUrl/predict-from-camera');
    return await http.get(url, headers: _authHeader());
  }

  static Future<http.Response> predictFromImage(File imageFile) async {
    final url = Uri.parse('$baseUrl/predict');
    var request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    if (sessionCookie != null) {
      request.headers['cookie'] = sessionCookie!;
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// ------------------------
  /// Live Feed
  /// ------------------------
  static String getLiveFeedUrl() {
    return '$baseUrl/live-feed';
  }

  /// ------------------------
  /// Helpers
  /// ------------------------
  static Map<String, String> _authHeader() {
    return {if (sessionCookie != null) 'cookie': sessionCookie!};
  }
}
