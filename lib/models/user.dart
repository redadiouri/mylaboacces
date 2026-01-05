/// Modèles utilisés par l'application
///
/// Ce fichier contient la classe `User` et l'enum `UserRole`.
/// Il est placé dans `lib/models/` pour clarifier l'architecture.

enum UserRole { invite, utilisateur, admin }

class User {
  /// Email de l'utilisateur (utilisé comme identifiant principal)
  final String email;

  /// Mot de passe (optionnel, ne devrait pas être stocké en clair)
  final String? password;

  /// Rôle de l'utilisateur (invite/utilisateur)
  final UserRole role;

  User({required this.email, this.password, required this.role});
}
