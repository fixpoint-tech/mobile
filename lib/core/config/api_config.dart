import 'package:flutter/foundation.dart';

/// API Configuration
/// 
/// Update the baseUrl with your actual backend API URL
class ApiConfig {
  // TODO: Replace this with your actual backend URL
  // Examples:
  // - Local development: 'http://localhost:5000/api/v1'
  // - Production: 'https://api.yourdomain.com/api/v1'
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    // Android emulator uses 10.0.2.2 to access host localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    // iOS simulator and others use localhost
    return 'http://localhost:5000/api/v1';
  }
  
  // API endpoints
  static const String issuesEndpoint = '/issues';
  
  // Timeout duration for API requests
  static const Duration timeout = Duration(seconds: 30);
}
