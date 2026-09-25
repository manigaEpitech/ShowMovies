import '../../data/models/movie_model.dart';

abstract class MovieState {
  const MovieState();
}

// Etat par defaut avant le chargement
class MovieInitial extends MovieState {}

// Charger les donnees
class MovieLoading extends MovieState {}

// Succes: les donnees sont telechargees
class MovieLoaded extends MovieState {
  final List<MovieModel> movies;
  final bool isOffline; // avetir l'utilisateur qu'il voit du cache

  const MovieLoaded({required this.movies, this.isOffline = false});
}

// Echec: Une erreur reseau ou cache est survenue
class MovieError extends MovieState {
  final String message;
  const MovieError({required this.message});
}
