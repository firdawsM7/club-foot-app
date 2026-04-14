import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/training_provider.dart';
import '../../models/models.dart';
import 'entrainement_form_screen.dart';

class EntrainementsScreen extends StatefulWidget {
  const EntrainementsScreen({super.key});

  @override
  State<EntrainementsScreen> createState() => _EntrainementsScreenState();
}

class _EntrainementsScreenState extends State<EntrainementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final role = context.read<AuthProvider>().user?.role ?? 'ADHERENT';
    context.read<TrainingProvider>().fetchTrainings(role);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final trainingProvider = context.watch<TrainingProvider>();
    final role = authProvider.user?.role ?? '';
    final canManage = role == 'ADMIN' || role == 'ENCADRANT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entraînements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: trainingProvider.isLoading && trainingProvider.trainings.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.masYellow))
            : trainingProvider.error != null && trainingProvider.trainings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur: ${trainingProvider.error}', style: const TextStyle(color: Colors.red)),
                        ElevatedButton(onPressed: _loadData, child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trainingProvider.trainings.length,
                    itemBuilder: (context, index) {
                      final training = trainingProvider.trainings[index];
                      return _buildTrainingCard(context, training, canManage);
                    },
                  ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _navigateToForm(context),
              backgroundColor: AppTheme.masYellow,
              child: const Icon(Icons.add, color: AppTheme.masBlack),
            )
          : null,
    );
  }

  Widget _buildTrainingCard(BuildContext context, Entrainement training, bool canManage) {
    final date = DateTime.parse(training.dateHeure);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.masYellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: AppTheme.masYellow),
        ),
        title: Text(
          'Équipe ${training.equipeId}', // Idéalement, on afficherait le nom de l'équipe
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateFormat.format(date)),
        trailing: _buildStatutBadge(training.statut),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on, 'Lieu', training.lieu),
                _buildInfoRow(Icons.timer, 'Durée', '${training.duree} min'),
                if (training.objectif != null)
                  _buildInfoRow(Icons.track_changes, 'Objectif', training.objectif!),
                if (training.notes != null)
                  _buildInfoRow(Icons.note, 'Notes', training.notes!),
                if (canManage) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _navigateToForm(context, training: training),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text('Modifier', style: TextStyle(color: Colors.blue)),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(context, training),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.masYellow),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color color;
    switch (statut) {
      case 'PLANIFIE':
        color = Colors.blue;
        break;
      case 'EN_COURS':
        color = Colors.orange;
        break;
      case 'TERMINE':
        color = Colors.green;
        break;
      case 'ANNULE':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        statut,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Entrainement? training}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntrainementFormScreen(training: training),
      ),
    ).then((_) => _loadData());
  }

  void _confirmDelete(BuildContext context, Entrainement training) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet entraînement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<TrainingProvider>().deleteTraining(training.id!).then((success) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entraînement supprimé')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${context.read<TrainingProvider>().error}')),
                  );
                }
              });
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
