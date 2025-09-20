import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exceptions.dart';
import '../models/token.dart';
import '../models/user.dart';

enum HttpMethod { get, post, put, delete, patch }

class ApiService {
  static const String _defaultServerIp = 'localhost'; // '172.16.0.31';
  static const String _defaultServerPort = '8001';
  static const Duration _timeout = Duration(seconds: 5);

  late http.Client _client;
  String? _accessToken;
  final String _baseUrl = 'http://$_defaultServerIp:$_defaultServerPort';

  factory ApiService() => _instance;

  ApiService._internal();

  static final ApiService _instance = ApiService._internal();

  static Future<void> init() async {
    await _instance._loadTokenFromStorage();
    _instance._client = http.Client();
  }

  // Token management
  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _accessToken = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _accessToken = null;
  }

  bool get isAuthenticated => _accessToken != null;

  // Helper methods for HTTP requests
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Map<String, String> get _formHeaders {
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    dynamic data;
    try {
      data = response.body.isNotEmpty ? json.decode(response.body) : null;
    } catch (e) {
      throw ApiException('Сервер вернул некорректный JSON ответ');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return data;
      case 401:
        await clearToken();
        throw UnauthorizedException('Неавторизованный доступ');
      case 422:
        final errors =
            data != null && data['detail'] != null
                ? (data['detail'] as List)
                    .map((e) => ValidationError.fromJson(e))
                    .toList()
                : <ValidationError>[];
        throw ValidationException('Ошибка валидации', errors: errors);
      default:
        throw ApiException(
          'Ошибка при выполнении запроса',
          statusCode: response.statusCode,
        );
    }
  }

  Future<dynamic> _makeRequest(
    HttpMethod method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool useFormData = false,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    late http.Response response;
    final headers = useFormData ? _formHeaders : _headers;

    switch (method) {
      case HttpMethod.get:
        response = await _client.get(uri, headers: headers).timeout(_timeout);
        break;
      case HttpMethod.post:
        if (useFormData) {
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body?.entries.map((e) => '${e.key}=${e.value}').join('&'),
              )
              .timeout(_timeout);
        } else {
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(_timeout);
        }
        break;
      case HttpMethod.put:
        response = await _client
            .put(
              uri,
              headers: headers,
              body: body != null ? json.encode(body) : null,
            )
            .timeout(_timeout);
        break;
      case HttpMethod.delete:
        response = await _client
            .delete(uri, headers: headers)
            .timeout(_timeout);
        break;
      case HttpMethod.patch:
        response = await _client
            .patch(
              uri,
              headers: headers,
              body: body != null ? json.encode(body) : null,
            )
            .timeout(_timeout);
        break;
    }

    return await _handleResponse(response);
  }

  Future<Token> login(String username, String password) async {
    final data = await _makeRequest(
      HttpMethod.post,
      '/login',
      body: {
        'username': username,
        'password': password,
        'grant_type': 'password',
      },
      useFormData: true,
    );

    final token = Token.fromJson(data);
    await _saveTokenToStorage(token.accessToken);
    return token;
  }

  Future<void> createUser(
    String username,
    String email,
    String password,
  ) async {
    try {
      await _makeRequest(
        HttpMethod.post,
        '/users/',
        body: {'username': username, 'login': email, 'password': password},
      );
    } on ApiException catch (e) {
      switch (e.statusCode) {
        case 409:
          throw UserEmailConflictException();
        case 422:
          throw ValidationException("Ошибка валидации данных пользователя");
        default:
          rethrow;
      }
    }
  }

  Future<User> getCurrentUser() async {
    final data = await _makeRequest(HttpMethod.get, '/users/me');

    return User.fromJson(data);
  }

  void dispose() {
    _client.close();
  }
}
