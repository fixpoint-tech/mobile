/// API Configuration
/// 
/// Update the baseUrl with your actual backend API URL
class ApiConfig {
  // TODO: Replace this with your actual backend URL
  // Examples:
  // - Local development: 'http://localhost:5000/api/v1'
  // - Production: 'https://api.yourdomain.com/api/v1'
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // API endpoints
  static const String issuesEndpoint = '/issues';
  
  // Timeout duration for API requests
  static const Duration timeout = Duration(seconds: 30);
}
