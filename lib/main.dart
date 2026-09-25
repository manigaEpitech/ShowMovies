import 'package:firebase_core/firebase_core.dart';
import 'package:isar_community/isar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showmovies/core/routes/app_router.dart';

import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/movies/presentation/blocs/movie_bloc.dart';

late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Injection
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<MovieBloc>(create: (_) => di.sl<MovieBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Flutter Movie App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        routerConfig: AppRouter.router, // Écran de démarrage obligatoire
      ),
    );
  }
}
