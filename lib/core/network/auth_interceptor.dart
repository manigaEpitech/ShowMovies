// lib/core/network/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Intercepteur personnalisé chargé d'injecter dynamiquement le jeton JWT
/// de l'utilisateur authentifié dans les en-têtes de requêtes sortantes.
class AuthInterceptor extends Interceptor {
  final FirebaseAuth _firebaseAuth;

  AuthInterceptor(this._firebaseAuth);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Extraction du jeton JWT natif obtenu par l'authentification OAuth/Firebase
      final String? token = await user.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Interception des erreurs de session expirée (HTTP 401 Unauthorized)
    if (err.response?.statusCode == 401) {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        try {
          // Force le rafraîchissement du Token JWT via OAuth/Firebase (Refresh Token)
          final String? newToken = await user.getIdToken(true);
          if (newToken != null) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            // Rejeu immédiat de la requête initiale avortée
            final dio = Dio();
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (_) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
