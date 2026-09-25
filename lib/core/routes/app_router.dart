// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports des écrans
import '../../../features/auth/presentation/pages/auth_page.dart';
import '../../../features/movies/presentation/pages/movie_list_page.dart';
import '../../../features/movies/presentation/pages/movie_detail_page.dart';
import '../../../features/movies/data/models/movie_model.dart';
// Import du Bloc d'Auth pour la protection des routes
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_state.dart';

import 'dart:async';

import '../di/injection_container.dart';

// À mettre dans lib/core/routes/app_router.dart (en dehors de la classe AppRouter)
class BlocListenable<B extends BlocBase<S>, S> extends ChangeNotifier {
  final B bloc;
  late final StreamSubscription<S> _subscription;

  BlocListenable(this.bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth',
    refreshListenable: BlocListenable<AuthBloc, AuthState>(sl<AuthBloc>()),

    // Optionnel : Gestion globale des redirections (ex: forcer la connexion)
    // redirect: (BuildContext context, GoRouterState state) {
    //   final authState = context.read<AuthBloc>().state;
    //   final isLoggingIn = state.matchedLocation == '/auth';

    //   // Si l'utilisateur n'est pas connecté et n'est pas sur la page d'auth, on le force à s'authentifier
    //   if (authState is AuthAuthenticated) {
    //     if (isLoggingIn) return '/movies';
    //     return null; // Laisse passer sur la page demandée
    //   }

    //   // Si l'utilisateur est déjà connecté et essaie d'aller sur l'auth, on le redirige vers l'accueil
    //   if (!isLoggingIn) {
    //     return '/auth';
    //   }

    //   return null;
    // },
    routes: [
      // Écran d'Authentification
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),

      // Écran de la Liste des Films
  GoRoute(
        path: '/movies',
        name: 'movies',
        builder: (context, state) => const MovieListPage(),
        routes: [
          // Écran Détail du Film (Sous-route de movies pour une navigation logique)
          GoRoute(
            path: 'detail',
            name: 'movie_detail',
            builder: (context, state) {
              // Récupérer l'objet MovieModel passé en paramètre extra
              final movie = state.extra as MovieModel;
              return MovieDetailPage(movie: movie);
            },
          ),
        ],
      ),
    ],

    // Page d'erreur par défaut en cas de mauvaise route
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text("Page introuvable"))),
  );
}
