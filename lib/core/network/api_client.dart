import 'dart:async';
import 'dart:convert';

import 'package:air_plane_ticketing/core/network/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected API response format.');
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from server.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json', ...?headers})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected API response format.');
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from server.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final baseUri = Uri.parse('${ApiConstants.baseUrl}$path');
    final uri = queryParameters == null
        ? baseUri
        : baseUri.replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json', ...?headers})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Unexpected API response format.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out. Please try again.');
    } on FormatException {
      throw const ApiException(
        message: 'Invalid response received from server.',
      );
    } on http.ClientException {
      throw const ApiException(
        message: 'Network error. Please check your connection.',
      );
    }
  }

  MediaType _getImageMediaType(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        throw const ApiException(
          message: 'Only JPEG, PNG, and WEBP images are allowed.',
        );
    }
  }

  Future<http.Response> uploadFile({
    required String path,
    required List<int> bytes,
    required String filename,
    required String accessToken,
    String fieldName = 'file',
  }) async {
    if (bytes.isEmpty) {
      throw const ApiException(message: 'The selected image is empty.');
    }

    if (accessToken.trim().isEmpty) {
      throw const ApiException(
        message: 'Your session has expired. Please sign in again.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri);

    try {
      final mediaType = _getImageMediaType(filename);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: 'Upload timed out. Please try again.');
    } on http.ClientException {
      throw const ApiException(message: 'Network error during file upload.');
    }
  }

  void dispose() {
    _client.close();
  }
}
