import '../../../../core/network/dio_client.dart';
import '../models/movie_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies();
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  final String _apiKey = '29abd42eba7291b24910383a3f80aef8';
  MovieRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    // Appel vers l'API TMDB
    final response = await dioClient.get(
      '/movie/popular',
      queryParameters: {
        'api_key': _apiKey,
        'language': 'fr-FR', // Pour obtenir les descriptions en français
        'page': 1,
      },
    );
    try {
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];

        return results.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: "Erreur lors de la récupération des films.",
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      // On retransmet l'exception déjà capturée et formatée par le DioClient
      rethrow;
    } catch (e) {
      // Sécurité pour toute autre exception inattendue
      throw ServerException(
        message: "Une erreur inconnue est survenue : $e",
        statusCode: response.statusCode,
      );
    }
  }
}
