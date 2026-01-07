# 🔬 MyLaboAccess - Système de Gestion d'Équipements de Laboratoire

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)
![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?logo=php)
![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?logo=mysql)

**MyLaboAccess** est une application multiplateforme développée avec Flutter permettant de gérer les emprunts et retours d'équipements de laboratoire. Le système offre une interface intuitive pour les utilisateurs et un panneau d'administration complet pour les gestionnaires.

---

## 📋 Table des Matières

- [Aperçu du Projet](#-aperçu-du-projet)
- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Technologies Utilisées](#-technologies-utilisées)
- [Structure du Projet](#-structure-du-projet)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Explication du Code](#-explication-du-code)
- [API Backend](#-api-backend)
- [Base de Données](#-base-de-données)

---

## 🎯 Aperçu du Projet

MyLaboAccess résout le problème de la gestion manuelle des équipements de laboratoire. L'application permet :

- 👤 **Aux utilisateurs** : d'emprunter et retourner du matériel facilement
- 👨‍💼 **Aux administrateurs** : de gérer les équipements, utilisateurs et demandes en temps réel
- 📊 **Au personnel** : de suivre l'inventaire et les disponibilités

### Cas d'Usage

1. **Emprunt de Matériel** : Un étudiant souhaite emprunter 2 écrans pour un projet
2. **Gestion Administrative** : Le gestionnaire valide les demandes et suit les stocks
3. **Retour d'Équipement** : L'utilisateur signale le retour via l'application
4. **Signalement** : Notification en cas de matériel défectueux

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Connexion sécurisée avec email/nom d'utilisateur et mot de passe
- Inscription avec validation des données
- Gestion des rôles (Invité, Utilisateur, Admin)

### 👥 Espace Utilisateur
- **Navigation par onglets** :
  - 📦 Vue des équipements disponibles
  - 📝 Historique des emprunts
- **Emprunts** :
  - Sélection d'équipement avec quantité
  - Demande en temps réel
  - Suivi du statut (En attente, Approuvé, Rejeté)
- **Retours** : Signalement de retour d'équipement
- **Signalements** : Notification de problèmes matériels

### 👨‍💼 Panneau Administrateur
- **Dashboard avec 4 onglets** :
  - 👥 Gestion des utilisateurs (ajout, suppression, modification)
  - 📦 Gestion de l'inventaire (stocks, quantités)
  - 📋 Gestion des demandes d'emprunt (approbation/rejet)
  - 🚨 Gestion des signalements
- **Actualisation automatique** : Rafraîchissement toutes les 5 secondes
- **Notifications** : Badge indiquant le nombre de nouvelles demandes

### 🎨 Interface Utilisateur
- Design Material moderne avec animations
- Thème personnalisé rouge et blanc
- Interface responsive (Web, Android, Windows, Linux)
- Cartes animées et icônes contextuelles

---

## 🏗️ Architecture

Le projet suit une architecture **client-serveur** avec séparation des préoccupations :

```
┌─────────────────┐
│  Flutter App    │  ← Frontend (Dart/Flutter)
│  (Client)       │
└────────┬────────┘
         │ HTTP/JSON
         │
┌────────▼────────┐
│  PHP API        │  ← Backend (PHP)
│  (Serveur)      │
└────────┬────────┘
         │ MySQL
         │
┌────────▼────────┐
│  Base de        │  ← Stockage (MySQL)
│  Données        │
└─────────────────┘
```

### Principes Architecturaux

1. **Séparation des couches** :
   - `lib/pages/` : Interface utilisateur (UI)
   - `lib/services/` : Logique métier et communication réseau
   - `lib/models/` : Modèles de données
   - `server-samples/` : API backend PHP

2. **Pattern de conception** :
   - **StatefulWidget** : Pour les pages avec état dynamique
   - **Service Layer** : ApiService centralise tous les appels réseau
   - **Model-View** : Séparation des données (models) et de l'affichage (pages)

---

## 🛠️ Technologies Utilisées

### Frontend
- **Flutter 3.5.4** : Framework UI multiplateforme
- **Dart 3.5.4** : Langage de programmation
- **http ^1.1.0** : Requêtes HTTP vers l'API
- **Material Design** : Composants UI

### Backend
- **PHP 8.x** : Logique serveur et API REST
- **MySQL 8.x** : Base de données relationnelle
- **Laragon/XAMPP** : Environnement de développement local

### Outils de Développement
- **VS Code** : Éditeur de code
- **Flutter DevTools** : Débogage et profiling
- **Postman** : Tests API (optionnel)

---

## 📁 Structure du Projet

```
mylaboacces/
│
├── lib/                          # Code source Flutter
│   ├── main.dart                 # Point d'entrée de l'application
│   ├── config.dart               # Configuration (URL API)
│   │
│   ├── models/                   # Modèles de données
│   │   └── user.dart             # Modèle User et enum UserRole
│   │
│   ├── pages/                    # Pages de l'application
│   │   ├── login_page.dart       # Page de connexion
│   │   ├── signup_page.dart      # Page d'inscription
│   │   ├── admin_panel.dart      # Panneau administrateur
│   │   └── borrow_request_page.dart  # Page d'emprunts
│   │
│   └── services/                 # Services et logique métier
│       └── api_service.dart      # Service API centralisé
│
├── server-samples/               # Backend PHP
│   └── mylabo_api/
│       ├── login.php             # Endpoint de connexion
│       ├── register.php          # Endpoint d'inscription
│       ├── borrow_request.php    # Gestion des emprunts
│       ├── get_borrow_requests.php   # Récupération emprunts
│       ├── get_all_borrow_requests.php  # Tous les emprunts
│       ├── report.php            # Signalements
│       ├── delete.php            # Suppression d'entités
│       └── setup_borrow_requests.sql  # Script BDD
│
├── test/                         # Tests unitaires
│   └── widget_test.dart
│
├── docs/                         # 🌐 Build Web (déployable sur GitHub Pages)
│   ├── index.html                # Page HTML principale
│   ├── main.dart.js              # Application compilée en JS
│   ├── flutter.js                # Runtime Flutter Web
│   ├── manifest.json             # Manifeste PWA
│   └── assets/                   # Assets compilés
│
├── android/                      # Configuration Android
├── web/                          # Configuration Web (sources)
├── windows/                      # Configuration Windows
├── linux/                        # Configuration Linux
│
├── pubspec.yaml                  # Dépendances Flutter
├── analysis_options.yaml         # Configuration linter Dart
└── README.md                     # Ce fichier
```

---

## 💻 Installation

### Prérequis

1. **Flutter SDK** (≥ 3.5.4)
   ```bash
   flutter --version
   ```

2. **Serveur local** (Laragon, XAMPP, WAMP)
   - Apache
   - MySQL/MariaDB
   - PHP 8.x

### Étapes d'Installation

#### 1. Cloner le Projet
```bash
git clone https://github.com/votre-username/mylaboacces.git
cd mylaboacces
```

#### 2. Installer les Dépendances Flutter
```bash
flutter pub get
```

#### 3. Configurer la Base de Données

**a) Créer la base de données** :
```sql
CREATE DATABASE mylaboipi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

**b) Exécuter le script SQL** :
```bash
mysql -u root -p mylaboipi < server-samples/mylabo_api/setup_borrow_requests.sql
```

**c) Créer les tables nécessaires** :
```sql
-- Table users
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  nom VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'utilisateur',
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table equipment
CREATE TABLE IF NOT EXISTS equipment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  available INT NOT NULL DEFAULT 0,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table reports
CREATE TABLE IF NOT EXISTS reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_email VARCHAR(255) NOT NULL,
  equipment_name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. Configurer le Backend PHP

**a) Copier les fichiers PHP** dans le répertoire serveur :
```bash
# Pour Laragon
cp -r server-samples/mylabo_api/ C:/laragon/www/

# Pour XAMPP
cp -r server-samples/mylabo_api/ C:/xampp/htdocs/
```

**b) Modifier les identifiants BDD** dans chaque fichier PHP si nécessaire :
```php
$dbHost = '127.0.0.1';
$dbName = 'mylaboipi';
$dbUser = 'root';
$dbPass = '';  // Votre mot de passe MySQL
```

#### 5. Configurer l'URL de l'API Flutter

Éditer [lib/config.dart](lib/config.dart) :
```dart
// Pour Web/Desktop
const String apiBaseUrl = 'http://localhost/mylabo_api';

// Pour Android Emulator
// const String apiBaseUrl = 'http://10.0.2.2/mylabo_api';

// Pour un appareil physique
// const String apiBaseUrl = 'http://192.168.x.x/mylabo_api';
```

---

## ⚙️ Configuration

### Environnement de Développement

**Pour Web** :
```bash
flutter run -d chrome
```

**Pour Android** :
```bash
flutter run -d android
```

**Pour Windows** :
```bash
flutter run -d windows
```

### Variables de Configuration

| Fichier | Variable | Description |
|---------|----------|-------------|
| [lib/config.dart](lib/config.dart) | `apiBaseUrl` | URL de l'API backend |
| `*.php` | `$dbHost` | Hôte MySQL |
| `*.php` | `$dbName` | Nom de la base |
| `*.php` | `$dbUser` | Utilisateur MySQL |
| `*.php` | `$dbPass` | Mot de passe MySQL |

---

## 🚀 Utilisation

### Démarrage

1. **Démarrer le serveur local** (Laragon/XAMPP)
2. **Lancer l'application** :
   ```bash
   flutter run -d chrome
   ```

### Comptes de Test

Créer un compte admin en BDD :
```sql
INSERT INTO users (email, nom, role, password) 
VALUES ('admin@labo.com', 'Admin', 'admin', '$2y$10$...');  -- Hash bcrypt
```

Ou se connecter avec :
- Email contenant "admin" + mot de passe quelconque (pour test)

### Workflow Utilisateur

1. **Inscription** → Créer un compte
2. **Connexion** → Accéder à l'application
3. **Parcourir** → Voir les équipements disponibles
4. **Emprunter** → Créer une demande d'emprunt
5. **Suivre** → Consulter l'historique

### Workflow Administrateur

1. **Connexion admin** → Accéder au panneau
2. **Gérer** → Valider/rejeter les demandes
3. **Inventaire** → Ajouter/modifier équipements
4. **Utilisateurs** → Gérer les comptes

---

## 🧩 Explication du Code

### 1. Point d'Entrée : [lib/main.dart](lib/main.dart)

```dart
void main() {
  runApp(MyApp());
}
```
- **`main()`** : Point d'entrée de l'application Dart
- **`runApp()`** : Lance l'application Flutter

#### Widget Principal : `MyApp`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(/* ... */),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => MyHomePage(title: 'MyLaboAccess'),
        '/admin': (context) => AdminPanel(),
      },
    );
  }
}
```

**Rôle** :
- Configure le thème de l'application (couleurs, polices, styles)
- Définit la navigation par routes nommées
- **Route initiale** : `/` → Page de connexion

#### Widget HomePage : `MyHomePage`

```dart
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> equipments = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEquipments();
  }
}
```

**Concepts clés** :
- **`StatefulWidget`** : Widget avec état mutable
- **`TickerProviderStateMixin`** : Nécessaire pour les animations (TabController)
- **`initState()`** : Appelé à la création du widget (équivalent à `constructor` + `componentDidMount`)
- **`TabController`** : Gère la navigation entre onglets

---

### 2. Service API : [lib/services/api_service.dart](lib/services/api_service.dart)

```dart
class ApiService {
  static Future<Map<String, dynamic>> _postWithFallback(
    String path, 
    Map<String, dynamic> payload
  ) async {
    final url = Uri.parse('$apiBaseUrl$path');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 3));
    
    return jsonDecode(response.body);
  }
}
```

**Fonctionnement** :
1. **Méthode statique** : Pas besoin d'instancier la classe
2. **Future** : Programmation asynchrone (équivalent à `Promise` en JS)
3. **HTTP POST** : Envoie des données JSON au backend
4. **Timeout** : Évite les requêtes infinies (3 secondes max)

**Méthodes disponibles** :
- `login(identifier, password)` → Authentification
- `register(email, nom, role, password)` → Inscription
- `getAllEquipment()` → Liste des équipements
- `sendBorrowRequest()` → Créer une demande d'emprunt
- `sendReport()` → Envoyer un signalement

---

### 3. Modèles de Données : [lib/models/user.dart](lib/models/user.dart)

```dart
enum UserRole { invite, utilisateur, admin }

class User {
  final String email;
  final String? password;  // ? = nullable
  final UserRole role;

  User({required this.email, this.password, required this.role});
}
```

**Concepts** :
- **`enum`** : Type énuméré pour les rôles
- **`final`** : Variable immutable (constante après initialisation)
- **`required`** : Paramètre obligatoire
- **Nullable** (`?`) : `password` peut être `null`

---

### 4. Page de Connexion : [lib/pages/login_page.dart](lib/pages/login_page.dart)

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    final result = await ApiService.login(email, password);
    
    if (result['success'] == true) {
      Navigator.pushNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = result['message'];
      });
    }
  }
}
```

**Flux d'exécution** :
1. Utilisateur saisit email/mot de passe
2. Clic sur "Se connecter" → Appel `_login()`
3. `ApiService.login()` envoie les données au backend PHP
4. Backend vérifie les identifiants dans la BDD
5. Si succès → Navigation vers `/home`
6. Si échec → Affichage du message d'erreur

**Widgets utilisés** :
- `TextField` : Champ de saisie
- `ElevatedButton` : Bouton stylisé
- `Navigator` : Gestion de la navigation

---

### 5. Panneau Admin : [lib/pages/admin_panel.dart](lib/pages/admin_panel.dart)

```dart
class _AdminPanelState extends State<AdminPanel> 
    with SingleTickerProviderStateMixin {
  
  List<Map<String, dynamic>> _borrowRequests = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    
    // Rafraîchissement automatique
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadBorrowRequests(),
    );
  }

  Future<void> _loadAllData() async {
    final users = await ApiService.getAllUsers();
    final equipment = await ApiService.getAllEquipment();
    final requests = await ApiService.getAllBorrowRequests();
    
    setState(() {
      _users = users['data'];
      _equipment = equipment['data'];
      _borrowRequests = requests['data'];
    });
  }
}
```

**Fonctionnalités clés** :
- **Timer.periodic** : Exécute une fonction à intervalle régulier
- **TabController** : Navigation entre 4 onglets (Users, Equipment, Requests, Reports)
- **setState()** : Met à jour l'interface après chargement des données

**Actions administrateur** :
- ✅ Approuver une demande → `ApiService.approveBorrowRequest(id)`
- ❌ Rejeter une demande → `ApiService.rejectBorrowRequest(id)`
- ➕ Ajouter équipement → `ApiService.addEquipment(...)`
- 🗑️ Supprimer utilisateur → `ApiService.deleteUser(id)`

---

### 6. Gestion d'État avec `setState()`

```dart
setState(() {
  equipments = newData;
  isLoading = false;
});
```

**Principe** :
- `setState()` notifie Flutter que l'état a changé
- Flutter redessine (rebuild) le widget
- L'interface se met à jour automatiquement

---

## 🌐 API Backend

### Endpoints Disponibles

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/login.php` | POST | Authentification |
| `/register.php` | POST | Inscription |
| `/borrow_request.php` | POST | Créer une demande |
| `/get_borrow_requests.php` | POST | Demandes d'un utilisateur |
| `/get_all_borrow_requests.php` | GET | Toutes les demandes |
| `/report.php` | POST | Envoyer un signalement |
| `/delete.php` | POST | Supprimer (user/equipment/request) |

### Exemple : `/login.php`

```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$input = json_decode(file_get_contents('php://input'), true);
$identifier = trim($input['identifier'] ?? '');
$password = $input['password'] ?? '';

$pdo = new PDO("mysql:host=127.0.0.1;dbname=mylaboipi", "root", "");

$stmt = $pdo->prepare("
  SELECT * FROM users 
  WHERE email = :identifier OR nom = :identifier
");
$stmt->execute(['identifier' => $identifier]);
$user = $stmt->fetch();

if ($user && password_verify($password, $user['password'])) {
  echo json_encode([
    'success' => true,
    'email' => $user['email'],
    'role' => $user['role']
  ]);
} else {
  echo json_encode([
    'success' => false,
    'message' => 'Identifiants incorrects'
  ]);
}
?>
```

**Flux** :
1. Réception JSON (`php://input`)
2. Connexion à MySQL via PDO
3. Requête préparée (protection SQL injection)
4. Vérification mot de passe (hash bcrypt)
5. Réponse JSON

---

## 🗄️ Base de Données

### Schéma Relationnel

```
┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│   users     │       │ borrow_requests  │       │  equipment   │
├─────────────┤       ├──────────────────┤       ├──────────────┤
│ id (PK)     │       │ id (PK)          │       │ id (PK)      │
│ email       │◄──────┤ user_email (FK)  │       │ name         │
│ nom         │       │ equipment_name   │──────►│ quantity     │
│ role        │       │ quantity         │       │ available    │
│ password    │       │ status           │       │ description  │
│ created_at  │       │ created_at       │       │ created_at   │
└─────────────┘       └──────────────────┘       └──────────────┘

         │
         │
         ▼
┌─────────────┐
│   reports   │
├─────────────┤
│ id (PK)     │
│ user_email  │
│ equipment_  │
│   name      │
│ description │
│ created_at  │
└─────────────┘
```

### Tables Principales

#### `users`
- Stocke les comptes utilisateurs
- Mot de passe hashé avec bcrypt
- Rôles : invite, utilisateur, admin

#### `equipment`
- Inventaire des équipements
- `quantity` : Stock total
- `available` : Quantité disponible

#### `borrow_requests`
- Demandes d'emprunt
- Statuts : "En attente", "Approuvé", "Rejeté"
- Lien avec `users` via `user_email`

#### `reports`
- Signalements de problèmes
- Associés à un équipement et un utilisateur

---

## 📱 Plateformes Supportées

- ✅ Web (Chrome, Firefox, Edge)
- ✅ Android (API 21+)
- ✅ Windows (Win 10+)
- ✅ Linux
- ⚠️ iOS/macOS (nécessite configuration supplémentaire)

---

## 🌐 Déploiement Web (GitHub Pages)

Le dossier [docs/](docs/) contient le build web compilé de l'application. Pour le déployer sur GitHub Pages :

### Option 1 : Via les Paramètres GitHub

1. Pousser le projet sur GitHub
2. Aller dans **Settings** → **Pages**
3. Source : **Deploy from a branch**
4. Branch : **main** → Folder : **/docs**
5. Sauvegarder → L'app sera accessible à `https://votre-username.github.io/mylaboacces/`

### Option 2 : Rebuild Manuel

Si vous modifiez le code, recompilez pour le web :

```bash
# Compiler en mode release pour le web
flutter build web --release --web-renderer html --output=docs

# Ou en mode debug
flutter build web --output=docs
```

**Note** : Assurez-vous que l'URL de l'API backend est accessible publiquement ou configurez CORS correctement.

---

## 🐛 Débogage

### Problèmes Courants

**1. Erreur de connexion API**
```
Solution : Vérifier que Laragon est démarré et que l'URL est correcte
```

**2. CORS Errors (Web)**
```php
// Ajouter dans tous les fichiers PHP :
header('Access-Control-Allow-Origin: *');
```

**3. Base de données introuvable**
```sql
-- Vérifier que la BDD existe :
SHOW DATABASES LIKE 'mylaboipi';
```

**4. Fichiers en rouge dans VS Code**
```bash
flutter pub get
Ctrl+Shift+P → "Dart: Restart Analysis Server"
```

---

## 🔒 Sécurité

### Bonnes Pratiques Implémentées

✅ Mots de passe hashés (bcrypt)  
✅ Requêtes préparées (PDO) contre SQL injection  
✅ Validation des entrées côté serveur  
✅ Timeout sur les requêtes HTTP  

### Améliorations Recommandées

- [ ] JWT pour l'authentification
- [ ] HTTPS en production
- [ ] Rate limiting sur l'API
- [ ] Validation côté client renforcée
- [ ] Logs d'audit

---

## 📈 Évolutions Futures

- [ ] Notifications push
- [ ] Export PDF des rapports
- [ ] Gestion des réservations
- [ ] Scan QR code pour les équipements
- [ ] Statistiques et graphiques
- [ ] Mode hors ligne avec synchronisation
- [ ] Support multilingue (i18n)

---

## 👨‍💻 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier `LICENSE` pour plus de détails.

---

## 📞 Contact

- **Auteur** : Reda
- **Email** : votre-email@example.com
- **GitHub** : [@votre-username](https://github.com/votre-username)

---

## 🙏 Remerciements

- Flutter & Dart Team
- Communauté Flutter
- Stack Overflow
- Material Design

---

**Développé avec ❤️ et Flutter**
