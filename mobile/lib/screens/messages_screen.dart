import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import 'chat_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Equipe> equipes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEquipes();
  }

  Future<void> _loadEquipes() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final role = authProvider.user?.role ?? 'ADHERENT';
      
      final loaded = await ApiService.getAllEquipes(role);
      setState(() => equipes = loaded);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Messages'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getGradient(context),
        ),
        child: isLoading
            ? const LoadingWidget(message: 'Chargement des discussions...')
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.masYellow),
                        const SizedBox(height: 16),
                        Text('Erreur: $error', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadEquipes,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : equipes.isEmpty
                    ? const EmptyState(
                        title: 'Aucune discussion',
                        subtitle: 'Vous n\'êtes membre d\'aucune équipe.',
                      )
                    : ListWheelScrollView.useDelegate(
                        itemExtent: 150,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: equipes.length,
                          builder: (context, index) {
                            final equipe = equipes[index];
                            return _buildTeamCard(equipe);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildTeamCard(Equipe equipe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.containerDecoration(context).copyWith(
        border: Border.all(color: AppTheme.masYellow.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                teamId: equipe.id!,
                teamName: equipe.nom,
              ),
            ),
          );
        },
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: AppTheme.masYellow,
              child: Icon(Icons.groups, size: 40, color: AppTheme.masBlack),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipe.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    equipe.categorie ?? 'Discussion d\'équipe',
                    style: TextStyle(
                      color: AppTheme.masYellow.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.masYellow, size: 30),
          ],
        ),
      ),
    );
  }
}
