import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'joueur_detail_screen.dart';

class JoueursScreen extends StatefulWidget {
  const JoueursScreen({super.key});

  @override
  State<JoueursScreen> createState() => _JoueursScreenState();
}

class _JoueursScreenState extends State<JoueursScreen> {
  List<Joueur> joueurs = [];
  bool isLoading = true;
  String? error;
  String search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loaded = await ApiService.getAllJoueurs(authProvider.user?.role ?? 'USER');
      setState(() => joueurs = loaded);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Joueurs')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: isLoading
            ? const LoadingWidget(message: 'Chargement des joueurs...')
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: AppTheme.masYellow),
                        const SizedBox(height: 8),
                        Text('Erreur: $error', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, color: AppTheme.masYellow),
                            hintText: 'Rechercher un joueur',
                            hintStyle: TextStyle(color: Colors.white38),
                          ),
                          onChanged: (v) => setState(() => search = v),
                        ),
                        const SizedBox(height: 12),
                        if (_filtered().isEmpty)
                          const EmptyState(title: 'Aucun joueur trouvé')
                        else
                          Column(
                            children: _filtered()
                                .map((j) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: AppTheme.containerDecoration(context),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: AppTheme.masYellow,
                                          child: Icon(Icons.person, color: AppTheme.masBlack),
                                        ),
                                        title: Text(
                                          '${j.prenom} ${j.nom}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          j.poste,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => JoueurDetailScreen(joueur: j),
                                            ),
                                          );
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  List<Joueur> _filtered() {
    if (search.isEmpty) return joueurs;
    return joueurs
        .where((j) => '${j.prenom} ${j.nom} ${j.poste}'
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();
  }
}
