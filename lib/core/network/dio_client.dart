// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: 'https://themoviedb.org', // URL de l'API TMDB
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    // Note : L'intercepteur AuthInterceptor est ajouté dynamiquement
    // depuis le fichier injection_container.dart pour éviter les dépendances cycliques.
    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
  }

  Dio get dio => _dio;

  /// Wrapper sécurisé pour exécuter des requêtes GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  /// Wrapper sécurisé pour exécuter des requêtes POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
