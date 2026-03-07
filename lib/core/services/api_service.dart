import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

/// API Service for making HTTP requests to the backend
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL from config
  String get baseUrl => ApiConfig.baseUrl;
  
  // Common headers
  Map<String, String> get _headers {
    // Start with base headers
    final base = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Merge auth headers if available
    try {
      final auth = AuthService.instance.getAuthHeaders();
      base.addAll(auth);
    } catch (_) {
      // ignore
    }

    return base;
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw ApiException('Bad request: ${response.body}');
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized');
    } else if (response.statusCode == 404) {
      throw ApiException('Not found');
    } else if (response.statusCode == 500) {
      try {
        final body = json.decode(response.body);
        final err = body['error'];
        throw ApiException(err != null ? 'Server error: $err' : 'Server error');
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Server error');
      }
    } else {
      throw ApiException('Error: ${response.statusCode}');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
