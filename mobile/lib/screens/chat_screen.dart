import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/models.dart';

class ChatScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  const ChatScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.connect(widget.teamId, user.id!, '${user.prenom} ${user.nom}');
        chatProvider.loadHistory(widget.teamId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Ideally we might disconnect or leave channel, but provider manages it
    // Provider.of<ChatProvider>(context, listen: false).disconnect();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        _messageController.text,
        widget.teamId,
        user.id!,
        '${user.prenom} ${user.nom}',
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    // Defines MAS Colors
    const Color masYellow = Color(0xFFE8D21D);
    const Color masBlack = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName, style: TextStyle(color: masYellow)),
        backgroundColor: masBlack,
        iconTheme: IconThemeData(color: masYellow),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chat, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  chat.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: chat.isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          )
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              Expanded(
                child: chatProvider.isLoading
                    ? Center(child: CircularProgressIndicator(color: masBlack))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          final isMe = message.senderId == currentUser?.id;
                          return _buildMessageBubble(message, isMe, masYellow, masBlack);
                        },
                      ),
              ),
              _buildMessageComposer(masYellow, masBlack),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(var message, bool isMe, Color masYellow, Color masBlack) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? masBlack : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: isMe ? Border.all(color: masYellow, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(Color masYellow, Color masBlack) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo),
            color: masBlack,
            onPressed: () {
              // TODO: Implement file upload
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Envoyer un message...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: masBlack,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
