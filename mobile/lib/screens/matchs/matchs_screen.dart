import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../models/models.dart';

class MatchsScreen extends StatefulWidget {
  const MatchsScreen({super.key});

  @override
  State<MatchsScreen> createState() => _MatchsScreenState();
}

class _MatchsScreenState extends State<MatchsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final role = context.read<AuthProvider>().user?.role ?? 'ADHERENT';
    context.read<MatchProvider>().fetchMatchs(role);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final matchProvider = context.watch<MatchProvider>();
    final role = authProvider.user?.role ?? '';
    final canManage = role == 'ADMIN' || role == 'ENCADRANT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: matchProvider.isLoading && matchProvider.matchs.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.masYellow))
            : matchProvider.error != null && matchProvider.matchs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur: ${matchProvider.error}', style: const TextStyle(color: Colors.red)),
                        ElevatedButton(onPressed: _loadData, child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: matchProvider.matchs.length,
                    itemBuilder: (context, index) {
                      final match = matchProvider.matchs[index];
                      return _buildMatchCard(context, match, canManage, role);
                    },
                  ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _showForm(context, role),
              backgroundColor: AppTheme.masYellow,
              child: const Icon(Icons.add, color: AppTheme.masBlack),
            )
          : null,
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match, bool canManage, String role) {
    final date = DateTime.parse(match.dateHeure);
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
          child: const Icon(Icons.stadium, color: AppTheme.masYellow),
        ),
        title: Text(
          '${match.adversaire} vs MAS',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateFormat.format(date)),
        trailing: _buildScoreBadge(match),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on, 'Lieu', match.lieu),
                _buildInfoRow(Icons.groups, 'Équipe', 'ID: ${match.equipeId}'),
                if (match.competition != null)
                  _buildInfoRow(Icons.emoji_events, 'Compétition', match.competition!),
                if (canManage) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showForm(context, role, match: match),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text('Modifier', style: TextStyle(color: Colors.blue)),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, role, match),
                        icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildScoreBadge(Match match) {
    if (match.scoreEquipe == null || match.scoreAdversaire == null) {
      return const Text('À venir', style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.masYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${match.scoreEquipe} - ${match.scoreAdversaire}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.masYellow),
      ),
    );
  }

  void _showForm(BuildContext context, String role, {Match? match}) {
    // This would ideally be a separate screen like EntrainementFormScreen
    // For brevity in this step, I'll describe it here but you should consider a full Form Screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulaire de match non implémenté (utiliser le backend pour l\'instant)')),
    );
  }

  void _confirmDelete(BuildContext context, String role, Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer ce match ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              context.read<MatchProvider>().deleteMatch(role, match.id!).then((success) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match supprimé')));
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
