import 'package:isar_community/isar.dart';

// le fichier de support Isar via builder

part 'movie_model.g.dart';

@collection
class MovieModel {
  final Id id;

  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  // le Json de l'API en donees exploitable
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
 