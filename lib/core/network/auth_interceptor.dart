import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  String? _accessToken;
  String? _refreshToken;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Injection du token s'il existe
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Getion de l'expiration du token (code 401)
    if (err.response?.statusCode == 401 && _refreshToken != null) {
      try {
        dio.clone(); // bloquer temporairement les autres requettes pendant le rafraissement

        //Appelle de l'API pour rafraichir le jeton
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': _refreshToken},
        );

        if (response.statusCode == 200) {
          _accessToken = response.data['access_token'];
          _refreshToken = response.data['refresh_token'];

          // liberation du client dio
          dio.close();

          // Relancer la requette initial
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $_accessToken';

          final clonedRequest = await dio.fetch(options);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        dio.close();
        // Echec de rafraissement rediriger vers loginPage
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
