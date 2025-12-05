import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'auth_service.dart';

/// Model for uploaded file information
class UploadedFile {
  final String url;
  final String fileName;
  final String originalName;
  final String mimeType;
  final int size;

  UploadedFile({
    required this.url,
    required this.fileName,
    required this.originalName,
    required this.mimeType,
    required this.size,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      originalName: json['originalName'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fileName': fileName,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
    };
  }
}

/// Service for handling file uploads to the backend
class UploadService {
  UploadService._internal();
  static final UploadService _instance = UploadService._internal();
  static UploadService get instance => _instance;

  /// Upload a single file
  /// [file] - The file to upload
  /// [issueId] - Optional issue ID to associate the file with
  Future<UploadedFile> uploadFile(File file, {int? issueId}) async {
    final token = AuthService.instance.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/uploads/attachments');
    
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (issueId != null) {
      request.fields['issueId'] = issueId.toString();
    }

    // Determine mime type from file extension
    final mimeType = _getMimeType(file.path);
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return UploadedFile.fromJson(data['file']);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to upload file');
    }
  }

  /// Upload multiple files
  /// [files] - List of files to upload
  /// [issueId] - Optional issue ID to associate the files with
  Future<List<UploadedFile>> uploadMultipleFiles(List<File> files, {int? issueId}) async {
    final token = AuthService.instance.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    if (files.isEmpty) {
      return [];
    }

    if (files.length > 5) {
      throw Exception('Maximum 5 files allowed at once');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/uploads/attachments/multiple');
    
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (issueId != null) {
      request.fields['issueId'] = issueId.toString();
    }

    for (final file in files) {
      final mimeType = _getMimeType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final filesData = data['files'] as List<dynamic>;
      return filesData.map((f) => UploadedFile.fromJson(f)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to upload files');
    }
  }

  /// Delete a file from storage
  /// [fileUrl] - The URL of the file to delete
  Future<void> deleteFile(String fileUrl) async {
    final token = AuthService.instance.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/uploads/attachments');
    
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'fileUrl': fileUrl}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete file');
    }
  }

  /// Get MIME type from file path
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
