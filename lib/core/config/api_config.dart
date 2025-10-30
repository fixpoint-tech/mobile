/// API Configuration
/// 
/// Update the baseUrl with your actual backend API URL
class ApiConfig {
  // Backend server (Node.js + Sequelize running on port 5000)
  static const String baseUrl = 'http://localhost:5000/api/v1';
  
  // API endpoints
  static const String issuesEndpoint = '/issues';
  
  // Timeout duration for API requests
  static const Duration timeout = Duration(seconds: 30);
}
