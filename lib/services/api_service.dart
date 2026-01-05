import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// ApiService centralise les appels réseau vers le backend PHP.
///
/// - Utiliser `ApiService.login(identifier, password)` pour la connexion.
/// - Utiliser `ApiService.register(...)` pour l'inscription.
/// - Utiliser `ApiService.sendReport(...)` pour poster un signalement.
class ApiService {
  /// Essaye plusieurs variantes d'URL (127.0.0.1 / localhost / 10.0.2.2)
  /// afin de réduire les erreurs lors du développement local.
  static Future<Map<String, dynamic>> _postWithFallback(String path, Map<String, dynamic> payload) async {
    // Pour le web, utilisez uniquement 127.0.0.1 qui fonctionne
    final variants = <String>[apiBaseUrl];
    
    Exception? lastEx;
    for (final base in variants) {
      final url = Uri.parse('$base$path');
      try {
        final response = await http
            .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 3));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        lastEx = e as Exception?;
        // essayer la variante suivante
      }
    }
    return {
      'success': false,
      'message': 'Impossible de joindre le serveur. Vérifiez Laragon/Apache et l’URL ${apiBaseUrl + path}. Détail: ${lastEx ?? 'erreur inconnue'}'
    };
  }

  /// Appel pour l'inscription
  static Future<Map<String, dynamic>> register(String email, String nom, String role, String password) async {
    return await _postWithFallback('/register.php', {
      'email': email,
      'nom': nom,
      'role': role,
      'password': password,
    });
  }

  /// Appel pour la connexion (identifiant = email ou nom)
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    return await _postWithFallback('/login.php', {'identifier': identifier, 'password': password});
  }

  /// Envoie un signalement au backend.
  static Future<Map<String, dynamic>> sendReport(String userEmail, String equipment, int quantity, String description) async {
    return await _postWithFallback('/report.php', {
      'user_email': userEmail,
      'equipment_name': equipment,
      'quantity': quantity,
      'description': description,
    });
  }

  /// Supprime le compte utilisateur après vérification du mot de passe.
  /// L'identifiant peut être l'email ou le nom (format Niveau_NOM.Prenom).
  static Future<Map<String, dynamic>> deleteAccount(String identifier, String password) async {
    return await _postWithFallback('/delete.php', {'identifier': identifier, 'password': password});
  }

  /// Soumet une demande d'emprunt de matériel.
  static Future<Map<String, dynamic>> sendBorrowRequest(
    String userEmail,
    String equipment,
    int quantity,
    String purpose,
    String duration,
  ) async {
    return await _postWithFallback('/borrow_request.php', {
      'user_email': userEmail,
      'equipment_name': equipment,
      'quantity': quantity,
      'purpose': purpose,
      'duration': duration,
    });
  }

  /// Récupère toutes les demandes d'emprunt de l'utilisateur ou TOUTES si userEmail = 'all'.
  static Future<Map<String, dynamic>> getBorrowRequests(String userEmail) async {
    final variants = <String>[apiBaseUrl];
    if (apiBaseUrl.contains('127.0.0.1')) {
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', 'localhost'));
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', '10.0.2.2'));
    } else if (apiBaseUrl.contains('localhost')) {
      variants.add(apiBaseUrl.replaceFirst('localhost', '127.0.0.1'));
      variants.add(apiBaseUrl.replaceFirst('localhost', '10.0.2.2'));
    }

    Exception? lastEx;
    for (final base in variants) {
      final url = userEmail == 'all'
          ? Uri.parse('$base/get_all_borrow_requests.php')
          : Uri.parse('$base/get_borrow_requests.php?user_email=${Uri.encodeComponent(userEmail)}');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        lastEx = e as Exception?;
      }
    }
    return {
      'success': false,
      'message': 'Impossible de récupérer les demandes. Détail: ${lastEx ?? 'erreur inconnue'}'
    };
  }

  /// Met à jour le statut d'une demande d'emprunt.
  static Future<Map<String, dynamic>> updateBorrowRequestStatus(int requestId, String status) async {
    return await _postWithFallback('/update_borrow_request.php', {
      'request_id': requestId,
      'status': status,
    });
  }

  // ===== ENDPOINTS ADMIN =====

  /// Récupère tous les utilisateurs
  static Future<Map<String, dynamic>> getAllUsers() async {
    final variants = <String>[apiBaseUrl];
    if (apiBaseUrl.contains('127.0.0.1')) {
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', 'localhost'));
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', '10.0.2.2'));
    }

    Exception? lastEx;
    for (final base in variants) {
      final url = Uri.parse('$base/get_users.php');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        lastEx = e as Exception?;
      }
    }
    return {'success': false, 'message': 'Erreur récupération utilisateurs'};
  }

  /// Modifie un utilisateur
  static Future<Map<String, dynamic>> updateUser(String email, String role, String nom) async {
    return await _postWithFallback('/update_user.php', {
      'email': email,
      'role': role,
      'nom': nom,
    });
  }

  /// Supprime un utilisateur
  static Future<Map<String, dynamic>> deleteUser(String email) async {
    return await _postWithFallback('/delete_user.php', {'email': email});
  }

  /// Récupère tous les équipements
  static Future<Map<String, dynamic>> getAllEquipment() async {
    final variants = <String>[apiBaseUrl];
    if (apiBaseUrl.contains('127.0.0.1')) {
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', 'localhost'));
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', '10.0.2.2'));
    }

    Exception? lastEx;
    for (final base in variants) {
      final url = Uri.parse('$base/get_equipment.php');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        lastEx = e as Exception?;
      }
    }
    return {'success': false, 'message': 'Erreur récupération équipements'};
  }

  /// Ajoute un équipement
  static Future<Map<String, dynamic>> addEquipment(String nom, int quantiteTotal) async {
    return await _postWithFallback('/add_equipment.php', {
      'nom': nom,
      'quantiteTotal': quantiteTotal,
    });
  }

  /// Modifie un équipement
  static Future<Map<String, dynamic>> updateEquipment(int id, String nom, int quantiteTotal) async {
    return await _postWithFallback('/update_equipment.php', {
      'id': id,
      'nom': nom,
      'quantiteTotal': quantiteTotal,
    });
  }

  /// Supprime un équipement
  static Future<Map<String, dynamic>> deleteEquipment(int id) async {
    return await _postWithFallback('/delete_equipment.php', {'id': id});
  }

  /// Récupère tous les signalements
  static Future<Map<String, dynamic>> getAllReports() async {
    final variants = <String>[apiBaseUrl];
    if (apiBaseUrl.contains('127.0.0.1')) {
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', 'localhost'));
      variants.add(apiBaseUrl.replaceFirst('127.0.0.1', '10.0.2.2'));
    }

    Exception? lastEx;
    for (final base in variants) {
      final url = Uri.parse('$base/get_reports.php');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 8));
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body;
      } catch (e) {
        lastEx = e as Exception?;
      }
    }
    return {'success': false, 'message': 'Erreur récupération signalements'};
  }

  /// Modifie un signalement
  static Future<Map<String, dynamic>> updateReport(int id, String statut, String priorite) async {
    return await _postWithFallback('/update_report.php', {
      'id': id,
      'statut': statut,
      'priorite': priorite,
    });
  }

  /// Supprime un signalement
  static Future<Map<String, dynamic>> deleteReport(int id) async {
    return await _postWithFallback('/delete_report.php', {'id': id});
  }
}
