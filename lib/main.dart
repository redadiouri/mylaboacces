import 'package:flutter/material.dart';
import 'pages/login_page.dart' as mylogin;
import 'pages/signup_page.dart';
import 'pages/admin_panel.dart';
import 'pages/borrow_request_page.dart';
import 'models/user.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: Colors.black87),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
  '/': (context) => mylogin.LoginPage(),
        '/home': (context) => MyHomePage(title: 'MyLaboAccess'),
        '/signup': (context) => SignupPage(),
        '/admin': (context) => const AdminPanel(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> equipments = [];
  bool isLoadingEquipments = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEquipments();
  }

  /// Charge les équipements depuis la BDD via ApiService
  Future<void> _loadEquipments() async {
    try {
      final result = await ApiService.getAllEquipment();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          equipments = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoadingEquipments = false;
        });
      } else {
        setState(() => isLoadingEquipments = false);
      }
    } catch (e) {
      print('Erreur chargement équipements: $e');
      setState(() => isLoadingEquipments = false);
    }
  }

  /// Met à jour les quantités après un emprunt/retour
  Future<void> _refreshEquipments() async {
    await _loadEquipments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments;
    String userEmail = '';
    UserRole? role;
    if (user != null && user is User) {
      userEmail = user.email;
      role = user.role;
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (userEmail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(userEmail, style: TextStyle(fontSize: 16, color: Colors.black54)),
              ),
            Text(widget.title, style: const TextStyle(fontFamily: 'Roboto', fontSize: 22)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.redAccent.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.redAccent.shade700,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Équipements'),
            Tab(icon: Icon(Icons.request_page), text: 'Demandes'),
          ],
        ),
        actions: [
          // Bouton d'accès au panneau admin (visible uniquement pour les admins)
          if (role == UserRole.admin)
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: Colors.redAccent.shade700),
              tooltip: 'Panneau Administrateur',
              onPressed: () {
                Navigator.pushNamed(context, '/admin', arguments: user);
              },
            ),
              IconButton(
            icon: Icon(Icons.report_problem, color: Colors.redAccent.shade700),
            tooltip: 'Signaler dégradation matériel',
            onPressed: () {
              String? selectedEquipment;
                  int quantity = 1;
              TextEditingController descController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Signaler une dégradation'),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Matériel dégradé'),
                            initialValue: selectedEquipment,
                            items: [
                              for (var eq in equipments)
                                DropdownMenuItem(
                                  value: eq['nom'] ?? 'N/A',
                                  child: Text(eq['nom'] ?? 'N/A'),
                                ),
                            ],
                            onChanged: (val) => setState(() => selectedEquipment = val),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Quantité dégradée'),
                            keyboardType: TextInputType.number,
                            initialValue: '1',
                            onChanged: (val) => setState(() => quantity = int.tryParse(val) ?? 1),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: descController,
                            decoration: InputDecoration(labelText: 'Description / Situation'),
                            maxLines: 3,
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Envoi du signalement via ApiService centralisé
                        final result = await ApiService.sendReport(
                          userEmail,
                          selectedEquipment ?? '',
                          quantity,
                          descController.text,
                        );
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(result['success'] == true ? 'Signalement envoyé' : 'Erreur'),
                            content: Text(result['message'] ?? ''),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                          ),
                        );
                      },
                      child: Text('Envoyer'),
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.black87),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer le compte'),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Text('Modifier email/mot de passe'),
              ),
              PopupMenuItem(
                value: 'help',
                child: Text('Besoin d\'aide ?'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                // Supprimer le compte : demander le mot de passe pour vérification
                if (userEmail.isEmpty || userEmail == 'invité') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Erreur'),
                      content: Text('Aucun compte valide connecté.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                    ),
                  );
                } else {
                  TextEditingController pwdCtrl = TextEditingController();
                  bool isLoading = false;
                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Supprimer le compte'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Confirmez la suppression en saisissant votre mot de passe.'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: pwdCtrl,
                                decoration: InputDecoration(labelText: 'Mot de passe'),
                                obscureText: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final pwd = pwdCtrl.text;
                                      if (pwd.isEmpty) {
                                        // show inline error
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Erreur'),
                                            content: Text('Veuillez saisir votre mot de passe.'),
                                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() => isLoading = true);
                                      final result = await ApiService.deleteAccount(userEmail, pwd);
                                      setState(() => isLoading = false);
                                      Navigator.pop(context);
                                      if (result['success'] == true) {
                                        // rediriger vers l'écran de connexion
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Supprimé'),
                                            content: Text(result['message'] ?? 'Compte supprimé.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushReplacementNamed(context, '/');
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Erreur'),
                                            content: Text(result['message'] ?? 'Erreur lors de la suppression.'),
                                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                                          ),
                                        );
                                      }
                                    },
                              child: isLoading ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
              } else if (value == 'edit') {
                TextEditingController emailController = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Réinitialiser email/mot de passe'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Votre email'),
                        ),
                        SizedBox(height: 8),
                        Text('Un lien de réinitialisation sera envoyé à cette adresse.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Envoyer le lien de réinitialisation (front seulement)
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Lien envoyé'),
                              content: Text('Un lien de réinitialisation a été envoyé à ${emailController.text}.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Envoyer'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'help') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Besoin d\'aide ?'),
                    content: Text('Contactez le support ou consultez la FAQ.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Déconnexion',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Équipements
          _buildEquipmentTab(),
          // Tab 2: Demandes d'emprunt
          BorrowRequestPage(user: user is User ? user : null),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              heroTag: "return",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnEquipmentPage(),
                  ),
                );
              },
              label: const Text('Rendre du matériel'),
              icon: const Icon(Icons.assignment_return),
            )
          : FloatingActionButton.extended(
              heroTag: "return_standalone",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnEquipmentPage(),
                  ),
                );
              },
              label: const Text('Rendre du matériel'),
              icon: const Icon(Icons.assignment_return),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildEquipmentTab() {
    final user = ModalRoute.of(context)?.settings.arguments;
    UserRole? role;
    if (user != null && user is User) {
      role = user.role;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                child: const Text('Comment Emprunter ?'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Emprunter du Matériel'),
                      content: const Text(
                          'Vérifiez le nombre de matériels disponibles avant d\'en prendre, puis allez dans l\'onglet "Emprunter du matériel et scannez le QRcode de l\'objet à emprunter".'),
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: const Text('Comment Rendre ?'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Rendre du Matériel'),
                      content: const Text(
                          'Sélectionnez le matériel que vous souhaitez rendre dans l\'onglet "Rendre du matériel".'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Liste des équipements:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoadingEquipments
                ? const Center(child: CircularProgressIndicator())
                : equipments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Aucun équipement disponible'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshEquipments,
                        child: ListView.builder(
                          itemCount: equipments.length,
                          itemBuilder: (context, index) {
                            final eq = equipments[index];
                            final nomEquip = eq['nom'] ?? 'N/A';
                            final total = eq['quantite_total'] ?? 0;
                            final emprunte = eq['quantite_emprunte'] ?? 0;
                            final dispo = (total - emprunte).clamp(0, total);
                            final etat = eq['etat'] ?? 'Bon';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: ListTile(
                                leading: Icon(
                                  _getIconForEquipment(nomEquip),
                                  color: Colors.redAccent.shade700,
                                ),
                                title: Text(
                                  nomEquip,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total: $total | Dispo: $dispo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: dispo > 0 ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getEtatColor(etat),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        etat,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: dispo > 0 ? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$dispo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                enabled: role == UserRole.utilisateur && dispo > 0,
                                onTap: role == UserRole.utilisateur && dispo > 0
                                    ? () {
                                        // Action d'emprunt
                                        _showBorrowDialog(eq, nomEquip, dispo);
                                      }
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEquipment(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'écrans':
        return Icons.monitor;
      case 'routeurs':
        return Icons.router;
      case 'switches':
        return Icons.device_hub;
      case 'serveurs':
        return Icons.storage;
      case 'câbles réseau':
        return Icons.cable;
      case 'points d\'accès wifi':
        return Icons.wifi;
      default:
        return Icons.devices_other;
    }
  }

  Color _getEtatColor(String etat) {
    switch (etat.toLowerCase()) {
      case 'bon':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'mauvais':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBorrowDialog(Map<String, dynamic> equipment, String nomEquip, int dispo) {
    int quantityToBorrow = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('📦 Emprunter $nomEquip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Disponible: $dispo'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: quantityToBorrow > 1
                          ? () => setState(() => quantityToBorrow--)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                      ),
                      child: const Text('-'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$quantityToBorrow',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: quantityToBorrow < dispo
                          ? () => setState(() => quantityToBorrow++)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                      ),
                      child: const Text('+'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Raison de l\'emprunt',
                  hintText: 'ex: Projet personnel, Test...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ $quantityToBorrow x $nomEquip empruntés avec succès'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Rafraîchir les données après l'emprunt
                await _refreshEquipments();
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: Text('Emprunter ($quantityToBorrow)'),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowEquipmentPage extends StatelessWidget {
  const BorrowEquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emprunter du matériel'),
      ),
      body: Center(
        child: Text('Page pour emprunter du matériel.'),
      ),
    );
  }
}

class ReturnEquipmentPage extends StatelessWidget {
  const ReturnEquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendre du matériel'),
      ),
      body: Center(
        child: Text('Page pour rendre du matériel.'),
      ),
    );
  }
}

class Equipment {
  final String name;
  final int quantity;

  Equipment(this.name, this.quantity);
}
