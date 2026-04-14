import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _messages = [];
  List<User> _users = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Charger les messages et les utilisateurs en parallèle
      final futures = await Future.wait([
        ApiService.getAllAdminMessages(),
        ApiService.getAllUsers(),
        ApiService.getMessageStats(),
      ]);

      setState(() {
        _messages = futures[0] as List<dynamic>;
        _users = futures[1] as List<User>;
        _stats = futures[2] as Map<String, dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showSendMessageDialog({User? recipient}) async {
    final TextEditingController messageController = TextEditingController();
    User? selectedUser = recipient;
    bool isBroadcast = recipient == null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(
            isBroadcast ? '📢 Message à tous' : '✉️ Message privé',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle broadcast/private
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('📢 Broadcast'),
                        selected: isBroadcast,
                        onSelected: (selected) {
                          setDialogState(() {
                            isBroadcast = selected;
                            selectedUser = null;
                          });
                        },
                        selectedColor: AppTheme.masYellow,
                        labelStyle: TextStyle(
                          color: isBroadcast ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('✉️ Privé'),
                        selected: !isBroadcast,
                        onSelected: (selected) {
                          setDialogState(() {
                            isBroadcast = !selected;
                          });
                        },
                        selectedColor: AppTheme.masYellow,
                        labelStyle: TextStyle(
                          color: !isBroadcast ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // User selector (if private)
                if (!isBroadcast)
                  DropdownButtonFormField<User>(
                    value: selectedUser,
                    hint: const Text('Sélectionner un utilisateur', style: TextStyle(color: Colors.white54)),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                    ),
                    items: _users.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          '${user.nom} ${user.prenom} (${user.email})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (user) {
                      setDialogState(() {
                        selectedUser = user;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                // Message input
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Votre message...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: const OutlineInputBorder(),
                    counterText: '${messageController.text.length}/500',
                  ),
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le message ne peut pas être vide')),
                  );
                  return;
                }

                if (!isBroadcast && selectedUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner un utilisateur')),
                  );
                  return;
                }

                try {
                  Navigator.pop(context);
                  
                  if (isBroadcast) {
                    await ApiService.sendBroadcastMessage(
                      content: messageController.text.trim(),
                    );
                  } else {
                    await ApiService.sendPrivateMessage(
                      userId: selectedUser!.id!,
                      content: messageController.text.trim(),
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBroadcast 
                        ? '📢 Message envoyé à tous' 
                        : '✉️ Message privé envoyé à ${selectedUser!.nom} ${selectedUser!.prenom}'
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.masYellow,
              ),
              child: const Text('Envoyer', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages Admin'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.masYellow,
          labelColor: AppTheme.masYellow,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.all_inbox), text: 'Tous'),
            Tab(icon: Icon(Icons.send), text: 'Envoyés'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement des messages...')
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $_error', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllMessagesTab(),
                    _buildSentMessagesTab(),
                    _buildStatsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSendMessageDialog(),
        backgroundColor: AppTheme.masYellow,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Nouveau', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAllMessagesTab() {
    if (_messages.isEmpty) {
      return const EmptyState(
        title: 'Aucun message',
        subtitle: 'Envoyez votre premier message aux utilisateurs',
        icon: Icons.message_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildSentMessagesTab() {
    final sentMessages = _messages.where((m) {
      final senderId = m['senderId'];
      return senderId != null;
    }).toList();

    if (sentMessages.isEmpty) {
      return const EmptyState(
        title: 'Aucun message envoyé',
        subtitle: 'Vous n\'avez pas encore envoyé de messages',
        icon: Icons.send_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sentMessages.length,
      itemBuilder: (context, index) {
        final message = sentMessages[index];
        return _buildMessageCard(message, showRecipient: true);
      },
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return const Center(child: Text('Statistiques non disponibles', style: TextStyle(color: Colors.white)));
    }

    final totalMessages = _stats!['totalMessages'] ?? 0;
    final broadcastMessages = _stats!['broadcastMessages'] ?? 0;
    final privateMessages = _stats!['privateMessages'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total', totalMessages.toString(), Icons.message, Colors.blue),
              _buildStatCard('Broadcast', broadcastMessages.toString(), Icons.campaign, Colors.orange),
              _buildStatCard('Privés', privateMessages.toString(), Icons.person, Colors.green),
              _buildStatCard(
                'Utilisateurs',
                _users.length.toString(),
                Icons.people,
                AppTheme.masYellow,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick actions
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showSendMessageDialog(),
            icon: const Icon(Icons.campaign),
            label: const Text('Envoyer un message à tous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showSendMessageDialog(),
            icon: const Icon(Icons.person_add),
            label: const Text('Envoyer un message privé'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.masYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message, {bool showRecipient = false}) {
    final isBroadcast = message['recipientId'] == null;
    final senderName = message['senderName'] ?? 'Inconnu';
    final content = message['content'] ?? '';
    final timestamp = message['timestamp'] != null 
        ? DateTime.parse(message['timestamp'])
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isBroadcast ? Icons.campaign : Icons.person,
                  color: isBroadcast ? Colors.orange : AppTheme.masYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    senderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            // Recipient info
            if (showRecipient && !isBroadcast)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Destinataire: ID ${message['recipientId']}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            // Badge
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text(
                  isBroadcast ? '📢 Broadcast' : '✉️ Privé',
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: isBroadcast 
                    ? Colors.orange.withOpacity(0.2)
                    : AppTheme.masYellow.withOpacity(0.2),
                side: BorderSide(
                  color: isBroadcast 
                      ? Colors.orange.withOpacity(0.4)
                      : AppTheme.masYellow.withOpacity(0.4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
