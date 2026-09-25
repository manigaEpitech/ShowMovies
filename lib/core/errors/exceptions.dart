import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, required this.statusCode});

  factory ServerException.fromDioError(DioException dioError) {
    String message = "Une erreur inattendue est surbenue.";

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Le serveur met trop de temps a repondre. Verifiez votre connexion.";
        break;
      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        if (status == 400) message = "Requête incorrecte.";
        if (status == 401) message = "Session expirée ou non autorisée.";
        if (status == 404) message = "Ressource introuvable.";
        if (status == 500) message = "Erreur interne du serveur.";
        break;
      case DioExceptionType.connectionError:
        message = "Impossible de se connecter au serveur. Verifiez internet.";
        break;
      default:
        message = "Erreur reseau. Veuillez reessayer.";
    }

    return ServerException(
      message: message,
      statusCode: dioError.response?.statusCode,
    );
  }
}

class CacheException implements Exception {
  final String message = "Impossible de charger les donnees locales.";
}
