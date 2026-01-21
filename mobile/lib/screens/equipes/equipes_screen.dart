import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../chat_screen.dart';

class EquipesScreen extends StatefulWidget {
  const EquipesScreen({super.key});

  @override
  State<EquipesScreen> createState() => _EquipesScreenState();
}

class _EquipesScreenState extends State<EquipesScreen> {
  List<Equipe> equipes = [];
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
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.user?.role ?? 'ADHERENT';
    final canManage = role == 'ADMIN' || role == 'ENCADRANT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Équipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: isLoading
            ? const LoadingWidget(message: 'Chargement des équipes...')
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
                            hintText: 'Rechercher équipe',
                            hintStyle: TextStyle(color: Colors.white38),
                          ),
                          onChanged: (v) => setState(() => search = v),
                        ),
                        const SizedBox(height: 12),
                        if (_filtered().isEmpty)
                          const EmptyState(title: 'Aucune équipe')
                        else
                          Column(
                            children: _filtered()
                                .map((e) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: AppTheme.containerDecoration(context),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: AppTheme.masYellow,
                                          child: Icon(Icons.groups, color: AppTheme.masBlack),
                                        ),
                                        title: Text(
                                          e.nom,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          e.categorie ?? '',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.chat, color: AppTheme.masYellow),
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                    teamId: e.id!,
                                                    teamName: e.nom,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (canManage) ...[
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: AppTheme.masYellow),
                                                onPressed: () => _showEdit(e, role),
                                              ),
                                              if (role == 'ADMIN')
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _delete(e, role),
                                                ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _showAdd(role),
              backgroundColor: AppTheme.masYellow,
              child: const Icon(Icons.add, color: AppTheme.masBlack),
            )
          : null,
    );
  }

  List<Equipe> _filtered() {
    if (search.isEmpty) return equipes;
    return equipes
        .where((e) => ('${e.nom} ${e.categorie}')
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();
  }

  void _showAdd(String role) {
    final form = GlobalKey<FormState>();
    String nom = '';
    String cat = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créer équipe'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => nom = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Catégorie'),
                onSaved: (v) => cat = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (form.currentState!.validate()) {
                form.currentState?.save();
                try {
                  await ApiService.createEquipe(
                    role,
                    Equipe(id: null, nom: nom, categorie: cat),
                  );
                  Navigator.pop(context);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Équipe créée')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEdit(Equipe e, String role) {
    final form = GlobalKey<FormState>();
    String nom = e.nom;
    String cat = e.categorie ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Éditer équipe'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: nom,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                onSaved: (v) => nom = v ?? '',
              ),
              TextFormField(
                initialValue: cat,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                onSaved: (v) => cat = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (form.currentState!.validate()) {
                form.currentState?.save();
                try {
                  await ApiService.updateEquipe(
                    role,
                    Equipe(id: e.id, nom: nom, categorie: cat),
                  );
                  Navigator.pop(context);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Équipe mise à jour')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _delete(Equipe e, String role) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Supprimer cette équipe ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteEquipe(role, e.id!);
                Navigator.pop(context);
                _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Équipe supprimée')),
                );
              } catch (ex) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $ex')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
