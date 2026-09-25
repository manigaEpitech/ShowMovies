# 🎬 ShowMovies – Application Flawless Clean Architecture & Multi-Platform Cache

## 📝 Présentation Générale du Projet
ShowMovies est une application Flutter de niveau production conçue pour offrir une expérience de visionnage fluide de films populaires via l'API REST de **TMDB (The Movie Database)**. Ce projet démontre l'application rigoureuse des standards de l'ingénierie logicielle mobile en résolvant la problématique de la connectivité réseau par un **Mode Hors Ligne transparent** alimenté par une base de données NoSQL locale ultra-rapide. L'accès utilisateur est entièrement sécurisé par un écosystème d'authentification robuste connecté à **Firebase Authentication**. 

L'intégralité du code source a été conçu de manière agnostique et modulaire pour cibler simultanément deux environnements d'exécution drastiquement différents sans altération du comportement applicatif : le système d'exploitation mobile **Android** (validé sur smartphones Tecno, etc.) et le compilateur **Web standard (Google Chrome, Microsoft Edge)**.

---

## 🏗️ Architecture Détaillée du Système (Feature-First Clean Architecture)
Le projet applique scrupuleusement les concepts de découpage par fonctionnalités (Feature-First) combinés aux principes d'isolation de la **Clean Architecture**. Chaque module fonctionnel possède son étanchéité propre découpée en 3 couches distinctes, garantissant qu'aucune modification de l'infrastructure technique (ex: changement de base de données ou de client HTTP) ne puisse corrompre les règles métier profondes.

### Représentation Schématique des Flux de Données
```text
  ┌────────────────────────────────────────────────────────┐
  │                   COUCHE PRESENTATION                  │
  │     [Widgets UI] ──(Événements)──> [Blocs (BLoC)]      │
  └─────────────────────────┬──────────────────────────────┘
                            │ (Appel de méthode)
                            ▼
  ┌────────────────────────────────────────────────────────┐
  │                     COUCHE DOMAINE                     │
  │  [Interfaces Repositories] <─── [Règles Métier / Pure] │
  └─────────────────────────▲──────────────────────────────┘
                            │ (Implémentation du contrat)
                            ▼
  ┌────────────────────────────────────────────────────────┐
  │                      COUCHE DATA                       │
  │           [MovieRepositoryImplementation]              │
  │                         │                              │
  │        ┌────────────────┴────────────────┐             │
  │        ▼ (Si connecté)                   ▼ (Si Offline)│
  │ [RemoteDataSource (Dio)]        [LocalDataSource(Isar)]│
  └────────────────────────────────────────────────────────┘
```

### Arborescence Structurelle des Fichiers du Projet
*   **`lib/core/`** : Contient le noyau d'infrastructure immuable de l'application partagée.
    *   `di/injection_container.dart` : Configuré via **GetIt**, il orchestre la localisation de service non-bloquante et prévient les fuites mémoires en injectant à la demande les singletons de nos couches techniques.
    *   `network/dio_client.dart` : Instancie le client HTTP Dio configuré avec des politiques de timeout strictes (10 secondes) pour préserver l'autonomie de la batterie de l'appareil.
    *   `network/auth_interceptor.dart` : Intercepteur de sécurité centralisé interceptant les requêtes pour y greffer les en-têtes OAuth/JWT et piéger les erreurs HTTP 401 pour rafraîchir les sessions.
    *   `routes/app_router.dart` : Moteur de navigation déclaratif propulsé par **GoRouter** exploitant un listenable couplé au cycle de vie d'authentification pour verrouiller l'accès aux données.
*   **`lib/features/auth/`** : Module autonome prenant en charge la gestion du cycle de vie des sessions utilisateurs.
*   **`lib/features/movies/`** : Module métier de gestion du catalogue cinématographique exploitant le dépôt synchrone pour basculer dynamiquement entre le cloud et le cache local.

---

## 🛠️ Stack Technique Exhaustive et Justifications

*   **Gestion d'état (`flutter_bloc`)** : Choix architectural stratégique pour imposer un flux unidirectionnel des données. Les interfaces graphiques n'ont aucune logique, elles se contentent d'émettre des événements discrets et de consommer passivement des états immuables.
*   **Persistance Locale Évoluée (`isar_community`)** : Base de données NoSQL asynchrone choisie en remplacement de Hive ou SQLite pour sa vitesse d'exécution. Elle intègre un mécanisme hybride de résolution d'infrastructure : elle écrit sur le stockage physique Android via l'accès disque, et se transforme en base de données virtuelle en mémoire SQLite/IndexedDB lors de l'exécution sur le navigateur Edge pour contourner les limitations de précision JavaScript sur les entiers 64 bits.
*   **Contrôle de Connectivité (`internet_connection_checker_plus`)** : Interroge directement les serveurs DNS de manière asynchrone pour valider un accès réel au réseau internet sous-jacent, évitant les faux-positifs des puces Wi-Fi connectées à des réseaux locaux sans accès internet.

---

## 🧪 Stratégie Globale de Tests et Couverture
L'application intègre une suite de tests unitaires hautement automatisée garantissant le non-régression de la logique métier critique. Conformément aux exigences réglementaires, la couche dépôt de stockage fait l'objet d'une couverture complète via le package `mocktail` pour simuler le comportement du matériel sans exécuter d'appels de sockets réseau réels.

### Tests Unitaires Implémentés
1.  **Vérification de la Trajectoire Réseau Nominal (Online Mode)** : Valide que le dépôt interroge la source de données distante, intercepte le tableau JSON et ordonne instantanément l'écrasement préventif de la base Isar locale avant de propager les modèles à l'écran.
2.  **Vérification du Système de Sauvegarde (Offline Mode)** : Simule l'isolation totale des interfaces radio (Wi-Fi/Données mobiles coupées) et valide que le dépôt extrait immédiatement les données d'Isar pour stabiliser l'affichage utilisateur.
3.  **Gestion de la Rupture d'Infrastructure (Cache Manquant)** : Valide le comportement de l'application lorsqu'elle est lancée pour la première fois hors ligne (cache local totalement vierge), en s'assurant qu'une exception utilisateur claire est propagée au lieu de faire planter le moteur graphique de Flutter.

Pour lancer l'exécution de la validation complète :
```bash
flutter test
```

---

## ⚙️ Directives de Configuration pour Validation Évaluative

1.  **Récupération de l'Écosystème** :
    ```bash
    git clone <votre-url-depot>
    cd showmovies
    flutter pub get
    ```
2.  **Compilation des Schémas de Stockage** :
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  **Lancement sur les Cibles Supportées** :
    *   **Exécution Mobile Android (Tecno)** : `flutter run -d android`
    *   **Exécution Web Assistée (Microsoft Edge)** : `flutter run -d edge`
