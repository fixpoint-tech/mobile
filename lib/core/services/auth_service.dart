import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'profilePicture': profilePicture,
    };
  }
}

/// AuthService that holds authentication state and manages tokens
/// Uses SharedPreferences for persistent token storage
class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  String? _token;
  UserProfile? _currentUser;
  bool _isInitialized = false;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Initialize auth service from stored credentials
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (_token != null && userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = UserProfile.fromJson(userMap);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
      _isInitialized = true;
    }
  }

  /// Save token and user to persistent storage
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }
      if (_currentUser != null) {
        await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  /// Clear stored credentials
  Future<void> _clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  /// Set token manually (e.g., after login)
  void setToken(String token) {
    _token = token;
    _saveCredentials();
    notifyListeners();
  }

  /// Clear authentication state
  Future<void> clearAuth() async {
    _token = null;
    _currentUser = null;
    await _clearCredentials();
    notifyListeners();
  }

  /// Returns headers including Authorization if token is present
  Map<String, String> getAuthHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Fetch current user from backend using /auth/me
  Future<UserProfile?> fetchCurrentUser() async {
    if (_token == null) return null;

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    try {
      final resp = await http
          .get(uri, headers: getAuthHeaders())
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        // expecting { success: true, data: { ... } }
        final data = body['data'] as Map<String, dynamic>;
        _currentUser = UserProfile.fromJson(data);
        await _saveCredentials();
        notifyListeners();
        return _currentUser;
      } else {
        // treat as logout on auth failure
        await clearAuth();
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      return null;
    }
  }

  /// Login with credentials. Expects backend to return { success:true, token, data: user }
  Future<bool> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        final userJson =
            body['data'] as Map<String, dynamic>? ?? body['user'] as Map<String, dynamic>?;

        if (token != null && userJson != null) {
          _token = token;
          _currentUser = UserProfile.fromJson(userJson);
          await _saveCredentials();
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  /// Register new user with email, password, name, and role
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    try {
      final resp = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode({
              'email': email,
              'password': password,
              'name': name,
              'role': role,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = json.decode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final token = body['token'] as String?;
        final userJson = body['data'] as Map<String, dynamic>?;

        if (token != null && userJson != null) {
          _token = token;
          _currentUser = UserProfile.fromJson(userJson);
          await _saveCredentials();
          notifyListeners();
          return {'success': true, 'message': body['message'] ?? 'Registration successful'};
        }
      }

      // Return error message from server
      return {
        'success': false,
        'message': body['message'] ?? 'Registration failed. Please try again.'
      };
    } catch (e) {
      debugPrint('Registration error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
