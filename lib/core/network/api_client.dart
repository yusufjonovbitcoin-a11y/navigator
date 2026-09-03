import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'api_response.dart';

class ApiClient {
  late final Dio _dio;
  String _baseUrl;

  ApiClient({String? baseUrl, String? authToken})
      : _baseUrl = baseUrl ?? ApiEndpoints.defaultBaseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log or modify request before sending
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final customError = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: customError,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Dio get dio => _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final rawData = response.data;
      final parsedData = fromJson != null ? fromJson(rawData) : rawData as T;
      return ApiResponse.success(parsedData, statusCode: response.statusCode ?? 200);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      final rawData = response.data;
      final parsedData = fromJson != null ? fromJson(rawData) : rawData as T;
      return ApiResponse.success(parsedData, statusCode: response.statusCode ?? 200);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timed out. Check network connection.');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final msg = error.response?.data?['message'] ?? 'Server error occurred.';
        return ApiException(statusCode: code, message: msg.toString());
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      default:
        return ApiException(message: error.message ?? 'Unexpected network error occurred.');
    }
  }
}
