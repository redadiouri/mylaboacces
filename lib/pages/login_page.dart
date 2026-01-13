import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  static const Color primaryColor = Color(0xFFB71C1C);

  Future<Map<String, dynamic>> register(
      String email, String nom, String role, String pwd) async {
    return ApiService.register(email, nom, role, pwd);
  }

  Future<Map<String, dynamic>> login(String identifier, String pwd) async {
    return ApiService.login(identifier, pwd);
  }

  // ===================== LOGIN =====================

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final result = await login(email, password);

    setState(() => isLoading = false);

    if (result['success'] == true) {
      UserRole role = UserRole.utilisateur;

      // Règle temporaire pour le test admin
      if (email.toLowerCase().contains('admin') || password == 'admin123') {
        role = UserRole.admin;
      }

      final user = User(
        email: result['email'] ?? email,
        role: role,
      );

      Navigator.pushReplacementNamed(context, '/home', arguments: user);
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Erreur de connexion.';
      });
    }
  }

  // ===================== SIGNUP =====================

  void _signup() {
    final emailCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    String localError = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Inscription'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _field(emailCtrl, 'Email', Icons.email),
                const SizedBox(height: 12),
                _field(
                  nomCtrl,
                  'Nom',
                  Icons.person,
                  hint: 'B2ipi_NOM.Prenom',
                ),
                const SizedBox(height: 12),
                _field(
                  pwdCtrl,
                  'Mot de passe',
                  Icons.lock,
                  obscure: true,
                ),
                if (localError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      localError,
                      style: const TextStyle(color: Colors.red),
                    ),
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final nom = nomCtrl.text.trim();
                final pwd = pwdCtrl.text;

                if (email.isEmpty || nom.isEmpty || pwd.isEmpty) {
                  setState(() =>
                      localError = 'Veuillez remplir tous les champs.');
                  return;
                }

                final pattern =
                    RegExp(r'^[A-Za-z0-9]+_[A-Za-z]+\.[A-Za-z]+$');
                if (!pattern.hasMatch(nom)) {
                  setState(() => localError =
                      'Format requis : Niveau_NOM.Prenom');
                  return;
                }

                // Normalisation du nom
                final parts = nom.split('_');
                final level = parts[0];
                final rest = parts.sublist(1).join('_');
                final dotIndex = rest.indexOf('.');
                final last =
                    rest.substring(0, dotIndex).toUpperCase();
                final firstRaw = rest.substring(dotIndex + 1);
                final first =
                    firstRaw[0].toUpperCase() +
                        firstRaw.substring(1).toLowerCase();

                final normalizedNom = '$level\_${last}.$first';

                final result = await register(
                    email, normalizedNom, 'utilisateur', pwd);

                if (result['success'] == true) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments:
                        User(email: email, role: UserRole.utilisateur),
                  );
                } else {
                  setState(() =>
                      localError = result['message'] ??
                          "Erreur lors de l'inscription.");
                }
              },
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== GUEST =====================

  void _guest() {
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: User(email: 'invité', role: UserRole.invite),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline,
                  size: 56, color: primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Connexion',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _field(emailController, 'Email', Icons.email),
              const SizedBox(height: 16),
              _field(passwordController, 'Mot de passe', Icons.lock,
                  obscure: true),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor),
                            onPressed: _login,
                            child: const Text('Connexion'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _signup,
                            child: const Text("Inscription"),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _guest,
                child: const Text('Accéder en tant qu’invité'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HELPERS =====================

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}