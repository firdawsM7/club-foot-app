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
      final role = authProvider.user?.role ?? 'USER';
      final loaded = await ApiService.getAllJoueurs(role);
      setState(() => joueurs = loaded);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.user?.role ?? 'USER';
    final canManage = role == 'ADMIN' || role == 'ENCADRANT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Joueurs'),
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
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (canManage) ...[
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: AppTheme.masYellow),
                                                onPressed: () => _showForm(role, joueur: j),
                                              ),
                                              if (role == 'ADMIN')
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _delete(role, j),
                                                ),
                                            ],
                                            const Icon(Icons.chevron_right, color: Colors.white54),
                                          ],
                                        ),
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
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _showForm(role),
              backgroundColor: AppTheme.masYellow,
              child: const Icon(Icons.add, color: AppTheme.masBlack),
            )
          : null,
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

  void _showForm(String role, {Joueur? joueur}) {
    final form = GlobalKey<FormState>();
    String nom = joueur?.nom ?? '';
    String prenom = joueur?.prenom ?? '';
    String poste = joueur?.poste ?? '';
    String numLicence = joueur?.numLicence ?? '';
    int? equipeId = joueur?.equipeId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(joueur == null ? 'Ajouter joueur' : 'Modifier joueur'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: prenom,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                  onSaved: (v) => prenom = v ?? '',
                ),
                TextFormField(
                  initialValue: nom,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                  onSaved: (v) => nom = v ?? '',
                ),
                TextFormField(
                  initialValue: poste,
                  decoration: const InputDecoration(labelText: 'Poste'),
                  onSaved: (v) => poste = v ?? '',
                ),
                TextFormField(
                  initialValue: numLicence,
                  decoration: const InputDecoration(labelText: 'N° Licence'),
                  onSaved: (v) => numLicence = v ?? '',
                ),
                // Equipe ID simplification (should ideally be a dropdown)
                TextFormField(
                  initialValue: equipeId?.toString(),
                  decoration: const InputDecoration(labelText: 'ID Équipe'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => equipeId = int.tryParse(v ?? ''),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (form.currentState!.validate()) {
                form.currentState?.save();
                try {
                  final j = Joueur(
                    id: joueur?.id,
                    nom: nom,
                    prenom: prenom,
                    poste: poste,
                    numLicence: numLicence,
                    equipeId: equipeId ?? 1, // Defaulting if missing
                    dateNaissance: joueur?.dateNaissance ?? '2000-01-01',
                    photoUrl: joueur?.photoUrl,
                  );
                  if (joueur == null) {
                    await ApiService.createJoueur(role, j);
                  } else {
                    await ApiService.updateJoueur(role, j);
                  }
                  Navigator.pop(context);
                  _load();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: Text(joueur == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _delete(String role, Joueur j) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${j.prenom} ${j.nom} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteJoueur(role, j.id!);
                Navigator.pop(context);
                _load();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
