// lib/features/auth/data/data_sources/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource({FirebaseAuth? firebaseAuth}) 
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // 1. Connexion avec Email et Mot de passe via Firebase
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Récupérer le jeton JWT généré par Firebase pour notre intercepteur
        final token = await user.getIdToken() ?? '';
        return UserModel(id: user.uid, email: user.email ?? '', token: token);
      } else {
        throw Exception("Impossible de récupérer l'utilisateur.");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e.code));
    }
  }

  // 2. Inscription d'un nouveau compte via Firebase
  Future<UserModel> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final token = await user.getIdToken() ?? '';
        return UserModel(id: user.uid, email: user.email ?? '', token: token);
      } else {
        throw Exception("Erreur lors de la création du compte.");
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e.code));
    }
  }

  // 3. Déconnexion
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Helper pour traduire les codes d'erreur Firebase en français lisible
  String _handleFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return "Aucun utilisateur trouvé avec cet email.";
      case 'wrong-password':
        return "Mot de passe incorrect.";
      case 'email-already-in-use':
        return "Cet email est déjà utilisé par un autre compte.";
      case 'weak-password':
        return "Le mot de passe choisi est trop faible.";
      case 'invalid-email':
        return "L'adresse email n'est pas valide.";
      default:
        return "Une erreur d'authentification est survenue ($code).";
    }
  }
}
