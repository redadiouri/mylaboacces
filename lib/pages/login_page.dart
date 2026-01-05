import 'package:flutter/material.dart';

// Importer le service API centralisé et le modèle User depuis leur dossier
import '../services/api_service.dart';
import '../models/user.dart';

/// Page de connexion principale.
///
/// Cette page gère la connexion et l'inscription (via une boîte de dialogue).
/// La logique réseau est déléguée à `ApiService` pour garder le widget léger.
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<Map<String, dynamic>> register(String email, String nom, String role, String pwd) async {
    return await ApiService.register(email, nom, role, pwd);
  }

  Future<Map<String, dynamic>> login(String identifier, String pwd) async {
    return await ApiService.login(identifier, pwd);
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir les champs.';
      });
      return;
    }
    setState(() => errorMessage = '');
    final result = await login(email, password);
    if (result['success'] == true) {
      final returnedEmail = result['email'] ?? email;
      setState(() => errorMessage = '');
      
      // Déterminer le rôle : si email contient 'admin', c'est un admin (temporaire pour test)
      UserRole userRole = UserRole.utilisateur;
      if (email.toLowerCase().contains('admin') || password == 'admin123') {
        userRole = UserRole.admin;
      }
      
      final user = User(email: returnedEmail, role: userRole);
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } else {
      setState(() => errorMessage = result['message'] ?? 'Erreur de connexion.');
    }
  }

  void _signup() {
    TextEditingController emailCtrl = TextEditingController();
    TextEditingController nomCtrl = TextEditingController();
    TextEditingController pwdCtrl = TextEditingController();
    String localError = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Inscription'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        hintText: 'Niveau_NOM.Prenom',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pwdCtrl,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                    ),
                    if (localError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(localError, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    final nom = nomCtrl.text.trim();
                    final pwd = pwdCtrl.text;
                    if (email.isEmpty || nom.isEmpty || pwd.isEmpty) {
                      setState(() {
                        localError = 'Veuillez remplir tous les champs.';
                      });
                      return;
                    }
                    // Validation simple du format attendu : Niveau_NOM.Prenom
                    final pattern = RegExp(r'^[A-Za-z0-9]+_[A-Za-z]+\.[A-Za-z]+$');
                    if (!pattern.hasMatch(nom)) {
                      setState(() {
                        localError = 'Le nom doit être au format "Niveau_NOM.Prenom" (ex: B2ipi_DIOURI.Reda).';
                      });
                      return;
                    }

                    // Normalisation avant envoi
                    final parts = nom.split('_');
                    final level = parts[0];
                    final rest = parts.sublist(1).join('_');
                    final dotIndex = rest.indexOf('.');
                    if (dotIndex <= 0) {
                      setState(() {
                        localError = 'Format du nom invalide.';
                      });
                      return;
                    }
                    final rawLast = rest.substring(0, dotIndex);
                    final rawFirst = rest.substring(dotIndex + 1);
                    final lastUpper = rawLast.toUpperCase();
                    final firstCap = rawFirst.isEmpty
                        ? rawFirst
                        : (rawFirst[0].toUpperCase() + rawFirst.substring(1).toLowerCase());
                    final normalizedNom = '$level\_${lastUpper}.$firstCap';
                    setState(() => localError = '');
                    final result = await register(email, normalizedNom, 'utilisateur', pwd);
                    if (result['success'] == true) {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home', arguments: User(email: email, role: UserRole.utilisateur));
                    } else {
                      setState(() {
                        localError = result['message'] ?? "Erreur lors de l'inscription.";
                      });
                    }
                  },
                  child: const Text("S'inscrire"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _guest() {
    setState(() {
      errorMessage = '';
    });
    final user = User(email: 'invité', role: UserRole.invite);
    Navigator.pushReplacementNamed(context, '/home', arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.redAccent.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Colors.redAccent.shade700),
              const SizedBox(height: 16),
              const Text('Bienvenue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signup,
                      child: const Text("S'inscrire"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _guest,
                child: const Text("Accéder en tant qu'invité"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
