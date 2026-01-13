import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class BorrowRequestPage extends StatefulWidget {
  final User? user;
  const BorrowRequestPage({super.key, this.user});

  @override
  State<BorrowRequestPage> createState() => _BorrowRequestPageState();
}

class _BorrowRequestPageState extends State<BorrowRequestPage> {
  final List<BorrowRequest> borrowRequests = [];
  bool isLoading = false;

  static const Color primaryColor = Color(0xFFB71C1C);

  final List<Equipment> availableEquipments = [
    Equipment('Écrans', 15),
    Equipment('Routeurs', 8),
    Equipment('Switches', 12),
    Equipment('Serveurs', 4),
    Equipment('Câbles réseau', 150),
    Equipment('Points d\'accès WiFi', 6),
  ];

  @override
  void initState() {
    super.initState();
    _loadBorrowRequests();
  }

  void _loadBorrowRequests() {
    // Placeholder API
  }

  // ===================== ADD REQUEST =====================

  void _showAddRequestDialog() {
    String? selectedEquipment;
    int quantity = 1;
    final purposeController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle demande d\'emprunt'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Matériel',
                  border: OutlineInputBorder(),
                ),
                items: availableEquipments
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.name,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedEquipment = val),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '1',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => quantity = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: purposeController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Objectif / Projet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée prévue',
                  border: OutlineInputBorder(),
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
            onPressed: () {
              if (selectedEquipment == null) {
                _showSnack('Veuillez sélectionner un matériel');
                return;
              }
              _submitBorrowRequest(
                selectedEquipment!,
                quantity,
                purposeController.text,
                durationController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBorrowRequest(
    String equipment,
    int quantity,
    String purpose,
    String duration,
  ) async {
    setState(() => isLoading = true);

    final result = await ApiService.sendBorrowRequest(
      widget.user?.email ?? 'utilisateur',
      equipment,
      quantity,
      purpose,
      duration,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result['success'] ? 'Succès' : 'Erreur'),
        content: Text(result['message'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result['success']) {
      setState(() {
        borrowRequests.add(
          BorrowRequest(
            equipment: equipment,
            quantity: quantity,
            purpose: purpose,
            duration: duration,
            status: 'En attente',
            submittedAt: DateTime.now(),
          ),
        );
      });
    }
  }

  // ===================== DETAILS =====================

  void _showRequestDetails(BorrowRequest request) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(request.equipment),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detail('Quantité', '${request.quantity}'),
            _detail('Durée', request.duration),
            _detail('Objectif', request.purpose),
            _detail('Statut', request.status),
            _detail('Soumis le', _formatDate(request.submittedAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label : ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes d\'emprunt'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowRequests.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: borrowRequests.length,
                  itemBuilder: (_, i) {
                    final r = borrowRequests[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _statusColor(r.status).withOpacity(0.2),
                          child: Icon(Icons.shopping_cart,
                              color: _statusColor(r.status)),
                        ),
                        title: Text(r.equipment,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Quantité: ${r.quantity} • Durée: ${r.duration}'),
                        trailing: Chip(
                          label: Text(r.status),
                          backgroundColor:
                              _statusColor(r.status).withOpacity(0.15),
                          labelStyle:
                              TextStyle(color: _statusColor(r.status)),
                        ),
                        onTap: () => _showRequestDetails(r),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: _showAddRequestDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucune demande',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  // ===================== HELPERS =====================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approuvée':
        return Colors.green;
      case 'rejetée':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} à ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ===================== MODELS =====================

class BorrowRequest {
  final String equipment;
  final int quantity;
  final String purpose;
  final String duration;
  final String status;
  final DateTime submittedAt;

  BorrowRequest({
    required this.equipment,
    required this.quantity,
    required this.purpose,
    required this.duration,
    required this.status,
    required this.submittedAt,
  });
}

class Equipment {
  final String name;
  final int quantity;
  Equipment(this.name, this.quantity);
}