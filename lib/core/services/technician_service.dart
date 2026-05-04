import '../models/technician.dart';
import 'api_service.dart';

/// Service for Technician operations
class TechnicianService {
final ApiService _apiService = ApiService();

/// Get all technicians
Future<List<Technician>> getAllTechnicians() async {
  try {
    final response = await _apiService.get('/users/technicians');
    
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Technician.fromJson(json)).toList();
    }
    
    return [];
  } catch (e) {
    throw ApiException('Failed to fetch technicians: ${e.toString()}');
  }
}

/// Get technician by ID
Future<Technician> getTechnicianById(int id) async {
  try {
    final response = await _apiService.get('/users/technicians/$id');
    
    if (response['success'] == true && response['data'] != null) {
      return Technician.fromJson(response['data']);
    }
    
    throw ApiException('Technician not found');
  } catch (e) {
    throw ApiException('Failed to fetch technician: ${e.toString()}');
  }
}

/// Create a new technician
Future<Technician> createTechnician({
  required String name,
  required String email,
  String? phone,
  String? address,
  String? specialization,
  String? password,
}) async {
  try {
    final data = {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (specialization != null) 'specialization': specialization,
      if (password != null) 'password': password,
    };

    final response = await _apiService.post('/users/technicians', data);
    
    if (response['success'] == true && response['data'] != null) {
      return Technician.fromJson(response['data']);
    }
    
    throw ApiException('Failed to create technician');
  } catch (e) {
    throw ApiException('Failed to create technician: ${e.toString()}');
  }
}

/// Update technician
Future<Technician> updateTechnician({
  required int id,
  String? name,
  String? email,
  String? phone,
  String? address,
  String? specialization,
}) async {
  try {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (specialization != null) data['specialization'] = specialization;

    final response = await _apiService.put('/users/technicians/$id', data);
    
    if (response['success'] == true && response['data'] != null) {
      return Technician.fromJson(response['data']);
    }
    
    throw ApiException('Failed to update technician');
  } catch (e) {
    throw ApiException('Failed to update technician: ${e.toString()}');
  }
}

/// Delete technician
Future<bool> deleteTechnician(int id) async {
  try {
    final response = await _apiService.delete('/users/technicians/$id');
    return response['success'] == true;
  } catch (e) {
    throw ApiException('Failed to delete technician: ${e.toString()}');
  }
}
}