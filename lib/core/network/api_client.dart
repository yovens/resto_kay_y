import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  String? _token;

  Future<void> initialize() async {
    _token = await _storage.read(key: 'auth_token');
  }

  bool get isAuthenticated => _token != null;

  Future<void> saveToken(String token) async {
    _token = token;

    await _storage.write(
      key: 'auth_token',
      value: token,
    );
  }

  Future<void> clearToken() async {
    _token = null;

    await _storage.delete(
      key: 'auth_token',
    );
  }

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null)
        'Authorization': 'Bearer $_token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}$endpoint',
      );

      print('API GET: $uri');

      final response = await http
          .get(
            uri,
            headers: _headers,
          )
          .timeout(
            AppConfig.requestTimeout,
          );

      print('API GET STATUS: ${response.statusCode}');
      print('API GET BODY: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Sèvè a pran twòp tan pou reponn.',
      );
    } on http.ClientException catch (e) {
      print('HTTP CLIENT ERROR: $e');

      throw ApiException(
        'Koneksyon ak sèvè a echwe: ${e.message}',
      );
    } catch (e) {
      print('GET ERROR: $e');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Erè koneksyon: $e',
      );
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}$endpoint',
      );

      print('API POST: $uri');
      print('API POST BODY: ${jsonEncode(body ?? {})}');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(
            AppConfig.requestTimeout,
          );

      print('API POST STATUS: ${response.statusCode}');
      print('API POST BODY RESPONSE: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Sèvè a pran twòp tan pou reponn.',
      );
    } on http.ClientException catch (e) {
      print('HTTP CLIENT ERROR: $e');

      throw ApiException(
        'Koneksyon ak sèvè a echwe: ${e.message}',
      );
    } catch (e) {
      print('POST ERROR: $e');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Erè koneksyon: $e',
      );
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}$endpoint',
      );

      print('API PUT: $uri');

      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(
            AppConfig.requestTimeout,
          );

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Sèvè a pran twòp tan pou reponn.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Koneksyon ak sèvè a echwe: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Erè koneksyon: $e',
      );
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}$endpoint',
      );

      final response = await http
          .delete(
            uri,
            headers: _headers,
          )
          .timeout(
            AppConfig.requestTimeout,
          );

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Sèvè a pran twòp tan pou reponn.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Koneksyon ak sèvè a echwe: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Erè koneksyon: $e',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;

    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      clearToken();
    }

    String message = 'Yon erè rive.';

    if (body is Map<String, dynamic>) {
      if (body['errors'] is Map) {
        final errors = body['errors'] as Map;

        if (errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List &&
              firstError.isNotEmpty) {
            message = firstError.first.toString();
          } else {
            message = firstError.toString();
          }
        }
      } else if (body['message'] != null) {
        message = body['message'].toString();
      }
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }
}