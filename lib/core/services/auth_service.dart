import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;

  UserProfile({required this.id, required this.name, required this.email, required this.role, this.profilePicture});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }
}

/// Lightweight AuthService that holds a token and current user profile.
/// Uses simple in-memory token storage. For production, store token securely.
class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  String? _token;
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  /// Set token manually (e.g., after login) and optionally fetch current user
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void clearAuth() {
    _token = null;
    _currentUser = null;
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

  /// Fetch current user from backend using /users/me
  Future<void> fetchCurrentUser() async {
    if (_token == null) return;

    final uri = Uri.parse('${ApiConfig.baseUrl}/users/me');
    try {
      final resp = await http.get(uri, headers: getAuthHeaders());
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        // expecting { success: true, data: { ... } }
        final data = body['data'] as Map<String, dynamic>;
        _currentUser = UserProfile.fromJson(data);
        notifyListeners();
      } else {
        // treat as logout
        _currentUser = null;
        notifyListeners();
      }
    } catch (_) {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Login with credentials. Expects backend to return { success:true, data: user, token }
  Future<bool> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body) as Map<String, dynamic>;
        final token = body['token'] as String? ?? body['data']?['token'] as String?;
        final userJson = body['data'] as Map<String, dynamic>? ?? body['user'] as Map<String, dynamic>?;
        if (token != null && userJson != null) {
          _token = token;
          _currentUser = UserProfile.fromJson(userJson);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
