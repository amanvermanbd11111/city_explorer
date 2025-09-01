import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class HttpClient {
  final http.Client client;

  HttpClient({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('Http error occurred');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException {
      throw NetworkException('Http error occurred');
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw ServerException('Invalid JSON response');
        }
      case 400:
        throw ServerException('Bad request');
      case 401:
        throw ServerException('Unauthorized');
      case 403:
        throw ServerException('Forbidden');
      case 404:
        throw ServerException('Resource not found');
      case 500:
        throw ServerException('Internal server error');
      default:
        throw ServerException('Server error: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}