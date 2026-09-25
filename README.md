# 🎬 ShowMovies – Clean Architecture & Offline Mode

Une application Flutter moderne et robuste connectée à l'API **TMDB (The Movie Database)** et propulsée par **Firebase** pour la gestion des utilisateurs. Ce projet met en œuvre une architecture découplée par fonctionnalités (**Feature-First Clean Architecture**), une gestion d'état réactive avec **BLoC**, une persistance locale haute performance avec **Isar** (via `isar_community`) pour un mode hors ligne transparent, et un routage sécurisé via **GoRouter**.

L'application est entièrement optimisée pour fonctionner de manière fluide sur **Android** (téléphones Tecno, etc.) et sur le **Web / Edge**.

---

## 🚀 Fonctionnalités Clés
*   **Authentification Firebase Sécurisée** : Système complet de Connexion, Inscription et Déconnexion adossé à Firebase Auth.
*   **Mode Hors Ligne Intelligent** : En cas de coupure réseau, l'application bascule automatiquement et de manière transparente sur les données locales mises en cache dans la base Isar, accompagnée d'une bannière de notification `OfflineBanner`.
*   **Gestion Réseau Avancée** : Utilisation de **Dio** pour centraliser les timeouts, intercepter les requêtes et traduire les exceptions HTTP brutes en messages conviviaux en français pour l'utilisateur final.
*   **Persistance Multiplateforme Hybride** : Configuration adaptative d'Isar v3 (`isar_community`) qui utilise le stockage physique sur mobile et bascule automatiquement sur la base virtuelle `IndexedDB` du navigateur sur le Web (Edge) pour éviter les crashs d'entiers JavaScript.
*   **Navigation Déclarative** : Routage d'écrans sécurisé et fluide géré par **GoRouter**.

---

## 🏗️ Architecture du Projet
Le projet respecte scrupuleusement les principes de la **Clean Architecture** combinés à une approche par fonctionnalités (**Feature-First**) :

```text
lib/
├── core/                         # Noyau partagé de l'application
│   ├── di/                       # Injection de dépendances (GetIt / Service Locator)
│   ├── errors/                   # Exceptions et pannes centralisées
│   ├── network/                  # Client Dio et NetWorkInfo
│   ├── routes/                   # Configuration du routage (GoRouter)
│   └── widgets/                  # Composants UI atomiques et réutilisables (Boutons, Champs)
└── features/                     # Modules applicatifs (Features)
    ├── auth/                     # Module d'Authentification (Firebase)
    │   ├── data/                 # Modèles de données, Repositories & Source Firebase Auth
    │   ├── domain/               # Entités pures et règles métier
    │   └── presentation/         # Gestion d'état (AuthBloc) & Formulaires (AuthPage)
    └── movies/                   # Module de Gestion des Films (TMDB)
        ├── data/                 # Modèles Isar, Source distante (Dio) & Cache local
        ├── domain/               # Interfaces des Dépôts (Repositories)
        └── presentation/         # Écrans (MovieListPage, MovieDetailPage) & MovieBloc
```

---

## 🛠️ Stack Technique & Dépendances

L'application s'appuie sur l'écosystème Flutter de production :

| Composant | Package | Rôle |
| :--- | :--- | :--- |
| **Gestion d'état** | `flutter_bloc` | Séparation stricte de la logique métier et de l'UI |
| **Authentification** | `firebase_auth` & `firebase_core` | Inscription et connexion sécurisées des utilisateurs |
| **Réseau HTTP** | `dio` | Requêtes asynchrones vers l'API TMDB et gestion des timeouts |
| **Base de Données** | `isar_community` | Cache local NoSQL multiplateforme hautes performances |
| **Routage** | `go_router` | Routage d'écrans typé et modulaire |
| **Injection (DI)** | `get_it` | Service Locator pour le découplage des dépendances au démarrage |
| **Connectivité** | `internet_connection_checker_plus` | Détection en temps réel de l'accès à internet |

---

## 🧪 Tests Unitaires
La logique métier est couverte par des tests automatisés robustes utilisant `bloc_test` et `mocktail` (pour le mock des dépôts de données).

Trois scénarios critiques sont testés sur le bloc d'authentification :
1.  **Vérification de l'état initial** du Bloc d'authentification (`AuthInitial`).
2.  **Succès de la connexion** : Émission séquentielle de `[AuthLoading, AuthAuthenticated]` avec validation de l'entité utilisateur.
3.  **Échec de la connexion** : Émission séquentielle de `[AuthLoading, AuthFailure]` avec capture du message d'erreur utilisateur.

Pour exécuter la suite de tests, lancez la commande suivante :
```bash
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart
```

---

## ⚙️ Installation et Configuration

### Prérequis
*   Flutter SDK (version `>=3.3.0`)
*   Un projet configuré sur la [Console Firebase](https://google.com) avec l'authentification Email/Mot de passe activée.
*   Une clé d'API valide sur [The Movie Database (TMDB)](https://themoviedb.org).

### Configuration Multiplateforme (Android & Web)

1.  **Cloner le dépôt** :
    ```bash
    git clone <url-du-depot>
    cd showmovies
    ```
2.  **Installer les dépendances** :
    ```bash
    flutter pub get
    ```
3.  **Lier Firebase à l'application** :
    *   **Pour Android** : Télécharge ton fichier `google-services.json` depuis la console Firebase et place-le manuellement dans `android/app/google-services.json`.
    *   **Pour le Web** : Initialise Firebase pour le Web en ajoutant tes clés de configuration dans le fichier `index.html` ou via l'outil d'initialisation FlutterFire.
4.  **Générer les fichiers Isar de persistance** :
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  **Ajouter votre clé API TMDB** :
    Ouvrez le fichier `lib/features/movies/data/datasources/movie_remote_data_sorce.dart` et injectez votre clé personnelle dans la variable dédiée.
6.  **Exécuter l'application** :
    *   **Sur ton téléphone Tecno (Android)** : `flutter run -d android`
    *   **Sur ton navigateur Edge (Web)** : `flutter run -d edge`

---

## 📝 Licence & Auteurs
*   **Votre Nom / Nom d'équipe** - *Développement Applicatif & Architecture*
