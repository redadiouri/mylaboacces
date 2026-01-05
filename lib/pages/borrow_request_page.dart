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
    // Placeholder pour charger les demandes existantes
    // Dans un vrai cas, appeler l'API
  }

  void _showAddRequestDialog() {
    String? selectedEquipment;
    int quantity = 1;
    TextEditingController purposeController = TextEditingController();
    TextEditingController durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle demande d\'emprunt'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Matériel à emprunter',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedEquipment,
                  items: [
                    for (var eq in availableEquipments)
                      DropdownMenuItem(
                        value: eq.name,
                        child: Text(eq.name),
                      ),
                  ],
                  onChanged: (val) => setState(() => selectedEquipment = val),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  onChanged: (val) => setState(() => quantity = int.tryParse(val) ?? 1),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: purposeController,
                  decoration: const InputDecoration(
                    labelText: 'Objectif / Projet',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durée (ex: 1 jour, 2 semaines)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedEquipment == null || selectedEquipment!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez sélectionner un matériel')),
                );
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

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result['success'] == true ? 'Demande soumise' : 'Erreur'),
          content: Text(result['message'] ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (result['success'] == true) {
        // Ajouter la demande à la liste
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
  }

  void _showRequestDetails(BorrowRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${request.equipment}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Matériel', request.equipment),
            _buildDetailRow('Quantité', '${request.quantity}'),
            _buildDetailRow('Objectif', request.purpose),
            _buildDetailRow('Durée', request.duration),
            _buildDetailRow('Statut', request.status),
            _buildDetailRow('Soumis le', _formatDate(request.submittedAt)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes d\'emprunt'),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : borrowRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune demande d\'emprunt',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez par soumettre une nouvelle demande',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: borrowRequests.length,
                  itemBuilder: (context, index) {
                    final request = borrowRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.redAccent.shade700,
                          ),
                        ),
                        title: Text(
                          request.equipment,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Quantité: ${request.quantity} | Durée: ${request.duration}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            request.status,
                            style: TextStyle(
                              color: _getStatusColor(request.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () => _showRequestDetails(request),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "add_request",
        onPressed: _showAddRequestDialog,
        label: const Text('Nouvelle demande'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.redAccent.shade700,
      ),
    );
  }
}

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
