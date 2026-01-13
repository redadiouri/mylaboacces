import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:async';

/// AdminPanel ULTRA-MODERNE synchronisé avec la BDD
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Données depuis BDD
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _equipment = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _borrowRequests = [];

  bool _isLoading = true;
  String _errorMessage = '';
  int _newBorrowCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
    // Rafraîchir les emprunts toutes les 5 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadBorrowRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Charge toutes les données depuis l'API
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Charge utilisateurs
      final usersResult = await ApiService.getAllUsers();
      if (usersResult['success'] == true) {
        _users = List<Map<String, dynamic>>.from(usersResult['data'] ?? []);
      }

      // Charge équipements
      final equipResult = await ApiService.getAllEquipment();
      if (equipResult['success'] == true) {
        _equipment = List<Map<String, dynamic>>.from(equipResult['data'] ?? []);
      }

      // Charge signalements
      final reportsResult = await ApiService.getAllReports();
      if (reportsResult['success'] == true) {
        _reports = List<Map<String, dynamic>>.from(reportsResult['data'] ?? []);
      }

      // Charge emprunts
      await _loadBorrowRequests();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBorrowRequests() async {
    try {
      final borrowResult = await ApiService.getBorrowRequests('all');
      if (borrowResult['success'] == true) {
        final newRequests = List<Map<String, dynamic>>.from(borrowResult['data'] ?? []);
        
        // Compte les demandes en attente
        int newCount = newRequests.where((b) => b['status'] == 'En attente').length;
        
        // Si le nombre augmente, affiche une notification
        if (newCount > _newBorrowCount && mounted) {
          _showBorrowNotification(newCount - _newBorrowCount);
        }
        
        setState(() {
          _borrowRequests = newRequests;
          _newBorrowCount = newCount;
        });
      }
    } catch (e) {
      // Silencieux en cas d'erreur pour le rafraîchissement automatique
    }
  }

  void _showBorrowNotification(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$count nouvelle(s) demande(s) d\'emprunt !')),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () {
            _tabController.animateTo(3);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)?.settings.arguments;
    UserRole? role;
    if (user != null && user is User) {
      role = user.role;
    }

    // Vérification des droits admin
    if (role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
          backgroundColor: Colors.redAccent.shade700,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.redAccent.shade700),
              const SizedBox(height: 24),
              const Text('Accès réservé aux administrateurs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Panneau Administrateur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.redAccent.shade700,
        elevation: 8,
        shadowColor: Colors.redAccent.withOpacity(0.5),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            const Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            const Tab(icon: Icon(Icons.devices), text: 'Équipements'),
            const Tab(icon: Icon(Icons.warning), text: 'Signalements'),
            Tab(
              child: Stack(
                children: [
                  const Tab(icon: Icon(Icons.shopping_cart), text: 'Emprunts'),
                  if (_newBorrowCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_newBorrowCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text('Chargement des données...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadAllData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersTab(),
                    _buildEquipmentTab(),
                    _buildReportsTab(),
                    _buildBorrowsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadAllData,
        backgroundColor: Colors.redAccent.shade700,
        icon: const Icon(Icons.refresh),
        label: const Text('Actualiser'),
        elevation: 8,
      ),
    );
  }

  // ===== TAB 1: UTILISATEURS (MODERNE) =====
  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barre d'action supérieure
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent.shade700, Colors.redAccent.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucun utilisateur trouvé',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isAdmin = user['role'] == 'admin';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isAdmin
                                    ? [Colors.redAccent.shade700, Colors.redAccent.shade400]
                                    : [Colors.grey[400]!, Colors.grey[300]!],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['nom']?[0]?.toUpperCase() ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(user['nom'] ?? 'N/A',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(user['email'] ?? 'N/A'),
                          trailing: Chip(
                            label: Text(
                              user['role']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            backgroundColor: isAdmin
                                ? Colors.redAccent.shade700
                                : Colors.grey[500],
                          ),
                          onTap: () => _showEditUserDialog(user),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ===== TAB 2: ÉQUIPEMENTS =====
  Widget _buildEquipmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barre d'action
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher du matériel...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddEquipmentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table des équipements
          Expanded(
            child: _equipment.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucun équipement trouvé'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                        headingRowHeight: 56,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 56,
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Emprunté', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Disponible', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('État', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Créé', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _equipment.map((eq) {
                          final total = eq['quantite_total'] ?? 0;
                          final emprunte = eq['quantite_emprunte'] ?? 0;
                          final dispo = (total - emprunte).clamp(0, total);
                          final etat = eq['etat'] ?? 'Bon';
                          final createdAt = (eq['created_at'] ?? '').toString().split(' ')[0];

                          return DataRow(
                            color: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.blue.withOpacity(0.05);
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(Text('${eq['id']}')),
                              DataCell(Text(eq['nom'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text('$total', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                              DataCell(Text('$emprunte', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                              DataCell(Text('$dispo', style: TextStyle(
                                color: dispo > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ))),
                              DataCell(_buildEtatBadge(etat)),
                              DataCell(Text(createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                              DataCell(
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('✏️ Modifier'),
                                      onTap: () => _showEditEquipmentDialog(eq),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('🗑️ Supprimer'),
                                      onTap: () => _showDeleteEquipmentDialog(eq),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtatBadge(String etat) {
    Color color;
    IconData icon;
    switch (etat.toLowerCase()) {
      case 'bon':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'moyen':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'mauvais':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(etat, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  // ===== TAB 3: SIGNALEMENTS (MODERNE) =====
  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text('Aucun signalement',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final priority = report['priorite'] ?? 'Moyenne';
                final status = report['statut'] ?? 'En attente';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPriorityIcon(priority),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      report['equipment_name'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Par: ${report['user_email'] ?? 'N/A'}'),
                    trailing: Chip(
                      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: status == 'Résolu' ? Colors.green : Colors.orange,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description:\n${report['description'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _showEditReportDialog(report),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Modifier'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _deleteReport(report['id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ===== TAB 4: EMPRUNTS (MODERNE AVEC NOTIFICATIONS) =====
  Widget _buildBorrowsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _borrowRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 80, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  const Text('Aucune demande d\'emprunt',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _borrowRequests.length,
              itemBuilder: (context, index) {
                final borrow = _borrowRequests[index];
                final status = borrow['status'] ?? 'En attente';
                final isWaiting = status == 'En attente';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  color: isWaiting ? Colors.yellow[50] : null,
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isWaiting
                              ? [Colors.orange.shade600, Colors.orange.shade400]
                              : [Colors.green.shade600, Colors.green.shade400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isWaiting ? Icons.hourglass_empty : Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      borrow['equipment_name'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('Utilisateur: ${borrow['user_email'] ?? 'N/A'}'),
                    trailing: Chip(
                      label: Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: status == 'Approuvée'
                          ? Colors.green
                          : status == 'Rejetée'
                              ? Colors.red
                              : Colors.orange,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantité: ${borrow['quantity'] ?? 0}',
                                    style: const TextStyle(fontSize: 14)),
                                Text('Date: ${(borrow['created_at'] ?? '').toString().split(' ')[0]}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isWaiting)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await _updateBorrowStatus(borrow['id'], 'Approuvée');
                                      _showBorrowAction('✅ Demande approuvée!', Colors.green);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approuver'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await _updateBorrowStatus(borrow['id'], 'Rejetée');
                                      _showBorrowAction('❌ Demande rejetée!', Colors.red);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Rejeter'),
                                  ),
                                ],
                              )
                            else
                              Center(
                                child: Text(
                                  'Statut: $status',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showBorrowAction(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===== DIALOGUES MODERNES =====

  void _showAddUserDialog() {
    TextEditingController emailCtrl = TextEditingController();
    TextEditingController nomCtrl = TextEditingController();
    String role = 'utilisateur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('Ajouter utilisateur', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['admin', 'utilisateur', 'invite']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => role = v!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton.icon(
            onPressed: () async {
              if (emailCtrl.text.isEmpty || nomCtrl.text.isEmpty) {
                _showError('⚠️ Veuillez remplir tous les champs');
                return;
              }
              Navigator.pop(context);
              _showSuccess('✅ Utilisateur ajouté');
              await _loadAllData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    TextEditingController nomCtrl = TextEditingController(text: user['nom']);
    String role = user['role'] ?? 'utilisateur';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.redAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Modifier ${user['nom']}', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['admin', 'utilisateur', 'invite']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => role = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.updateUser(user['email'], role, nomCtrl.text);
              _showSuccess('✅ Utilisateur modifié');
              await _loadAllData();
            },
            icon: const Icon(Icons.save),
            label: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showAddEquipmentDialog() {
    TextEditingController nomCtrl = TextEditingController();
    TextEditingController qtCtrl = TextEditingController();
    String selectedEtat = 'Bon';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.devices, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text('➕ Ajouter équipement', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom du matériel',
                    hintText: 'ex: Routeurs, Écrans...',
                    prefixIcon: const Icon(Icons.devices),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtCtrl,
                  decoration: InputDecoration(
                    labelText: 'Quantité totale',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedEtat,
                  decoration: InputDecoration(
                    labelText: 'État initial',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bon', child: Text('✅ Bon')),
                    DropdownMenuItem(value: 'Moyen', child: Text('⚠️ Moyen')),
                    DropdownMenuItem(value: 'Mauvais', child: Text('❌ Mauvais')),
                  ],
                  onChanged: (value) => setState(() => selectedEtat = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton.icon(
              onPressed: () async {
                if (nomCtrl.text.isEmpty || qtCtrl.text.isEmpty) {
                  _showError('⚠️ Veuillez remplir tous les champs');
                  return;
                }
                Navigator.pop(context);
                await ApiService.addEquipment(nomCtrl.text, int.parse(qtCtrl.text));
                _showSuccess('✅ Équipement ajouté');
                await _loadAllData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEquipmentDialog(Map<String, dynamic> eq) {
    TextEditingController nomCtrl = TextEditingController(text: eq['nom']);
    TextEditingController qtCtrl = TextEditingController(text: '${eq['quantite_total']}');
    String selectedEtat = eq['etat'] ?? 'Bon';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text('✏️ Modifier ${eq['nom']}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom du matériel',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtCtrl,
                  decoration: InputDecoration(
                    labelText: 'Quantité totale',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedEtat,
                  decoration: InputDecoration(
                    labelText: 'État du matériel',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bon', child: Text('✅ Bon')),
                    DropdownMenuItem(value: 'Moyen', child: Text('⚠️ Moyen')),
                    DropdownMenuItem(value: 'Mauvais', child: Text('❌ Mauvais')),
                  ],
                  onChanged: (value) => setState(() => selectedEtat = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton.icon(
              onPressed: () async {
                if (nomCtrl.text.isEmpty || qtCtrl.text.isEmpty) {
                  _showError('⚠️ Veuillez remplir tous les champs');
                  return;
                }
                Navigator.pop(context);
                await ApiService.updateEquipment(eq['id'], nomCtrl.text, int.parse(qtCtrl.text));
                _showSuccess('✅ Équipement modifié');
                await _loadAllData();
              },
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReportDialog(Map<String, dynamic> report) {
    String statut = report['statut'] ?? 'En attente';
    String priorite = report['priorite'] ?? 'Moyenne';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: _getPriorityColor(priorite), size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Modifier ${report['equipment_name']}', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: statut,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['En attente', 'En cours', 'Résolu']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => statut = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priorite,
                decoration: InputDecoration(
                  labelText: 'Priorité',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['Basse', 'Moyenne', 'Haute']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => priorite = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.updateReport(report['id'], statut, priorite);
              _showSuccess('✅ Signalement modifié');
              await _loadAllData();
            },
            icon: const Icon(Icons.save),
            label: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showDeleteEquipmentDialog(Map<String, dynamic> eq) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('⚠️ Supprimer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${eq['nom']}" ?\n\nCette action est irréversible et affectera toutes les données associées.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ApiService.deleteEquipment(eq['id']);
              if (result['success'] == true) {
                _showSuccess('✅ Équipement supprimé');
              } else {
                _showError('❌ Erreur: ${result['error'] ?? 'Suppression échouée'}');
              }
              await _loadAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ===== OPÉRATIONS =====

  Future<void> _deleteUser(String email) async {
    final result = await ApiService.deleteUser(email);
    if (result['success'] == true) {
      _showSuccess('✅ Utilisateur supprimé');
      await _loadAllData();
    } else {
      _showError('❌ Erreur lors de la suppression');
    }
  }

  Future<void> _deleteReport(int id) async {
    final result = await ApiService.deleteReport(id);
    if (result['success'] == true) {
      _showSuccess('✅ Signalement supprimé');
      await _loadAllData();
    } else {
      _showError('❌ Erreur lors de la suppression');
    }
  }

  Future<void> _updateBorrowStatus(int id, String status) async {
    final result = await ApiService.updateBorrowRequestStatus(id, status);
    if (result['success'] == true) {
      await _loadBorrowRequests();
    } else {
      _showError('❌ Erreur lors de la mise à jour');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'haute':
        return Icons.error;
      case 'moyenne':
        return Icons.warning;
      case 'basse':
        return Icons.info;
      default:
        return Icons.help;
    }
  }
}