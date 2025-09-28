import 'package:dio/dio.dart';
import '../models/w3w_models.dart';

class W3WApiService {
  static const String _baseUrl = 'https://api.what3words.com/v3';
  late final Dio _dio;
  final String _apiKey;

  W3WApiService({required String apiKey}) : _apiKey = apiKey {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for logging (optional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('W3W API: $obj'),
    ));
  }

  /// Convert coordinates to What3words address
  Future<W3WAddress> convertToWords({
    required double lat,
    required double lng,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.get('/convert-to-3wa', queryParameters: {
        'coordinates': '$lat,$lng',
        'language': language,
        'key': _apiKey,
      });

      if (response.statusCode == 200) {
        return W3WAddress.fromJson(response.data);
      } else {
        throw W3WError.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Convert What3words address to coordinates
  Future<W3WAddress> convertToCoordinates({
    required String words,
  }) async {
    try {
      final response =
          await _dio.get('/convert-to-coordinates', queryParameters: {
        'words': words,
        'key': _apiKey,
      });

      if (response.statusCode == 200) {
        return W3WAddress.fromJson(response.data);
      } else {
        throw W3WError.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get AutoSuggest suggestions
  Future<List<W3WSuggestion>> autoSuggest({
    required String input,
    String language = 'en',
    int nResults = 10,
    W3WCoordinates? focus,
    String? clipToCountry,
    String? clipToBoundingBox,
    String? clipToCircle,
    String? clipToPolygon,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'input': input,
        'language': language,
        'n-results': nResults,
        'key': _apiKey,
      };

      // Add optional parameters
      if (focus != null) {
        queryParams['focus'] = '${focus.lat},${focus.lng}';
      }
      if (clipToCountry != null) {
        queryParams['clip-to-country'] = clipToCountry;
      }
      if (clipToBoundingBox != null) {
        queryParams['clip-to-bounding-box'] = clipToBoundingBox;
      }
      if (clipToCircle != null) {
        queryParams['clip-to-circle'] = clipToCircle;
      }
      if (clipToPolygon != null) {
        queryParams['clip-to-polygon'] = clipToPolygon;
      }

      final response =
          await _dio.get('/autosuggest', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final suggestions = (response.data['suggestions'] as List<dynamic>)
            .map((suggestion) => W3WSuggestion.fromJson(suggestion))
            .toList();
        return suggestions;
      } else {
        throw W3WError.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get grid section for map overlay
  Future<W3WGridSection> getGridSection({
    required String boundingBox,
  }) async {
    try {
      final response = await _dio.get('/grid-section', queryParameters: {
        'bounding-box': boundingBox,
        'key': _apiKey,
      });

      if (response.statusCode == 200) {
        return W3WGridSection.fromJson(response.data);
      } else {
        throw W3WError.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get available languages
  Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    try {
      final response = await _dio.get('/available-languages', queryParameters: {
        'key': _apiKey,
      });

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['languages']);
      } else {
        throw W3WError.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  W3WError _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return W3WError(
          code: 'timeout',
          message: 'Request timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          return W3WError.fromJson(e.response!.data);
        }
        return W3WError(
          code: 'bad_response',
          message: 'Server error: ${e.response?.statusCode}',
        );
      case DioExceptionType.cancel:
        return W3WError(code: 'cancelled', message: 'Request was cancelled');
      case DioExceptionType.connectionError:
        return W3WError(
          code: 'connection_error',
          message: 'No internet connection available.',
        );
      case DioExceptionType.badCertificate:
        return W3WError(
          code: 'bad_certificate',
          message: 'Certificate verification failed.',
        );
      case DioExceptionType.unknown:
        return W3WError(
          code: 'unknown',
          message: 'An unknown error occurred: ${e.message}',
        );
    }
  }
}
