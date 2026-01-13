import 'package:flutter/material.dart';

/// Page d'inscription (version simple et cohérente avec le Login)
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static const Color primaryColor = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Inscription"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
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
              Icon(Icons.person_add,
                  size: 56, color: primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Créer un compte',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _field('Email', Icons.email),
              const SizedBox(height: 16),
              _field('Mot de passe', Icons.lock, obscure: true),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, IconData icon, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}