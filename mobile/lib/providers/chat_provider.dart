import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnected => _chatService.isConnected;

  void connect(int teamId, int userId, String userName) async {
    final baseUrl = ApiConfig.baseUrl.replaceAll('http://', '').replaceAll('https://', '');
    // Split host and port if needed, but for now assuming direct replacement
    // Actually stomp_dart_client needs ws://host:port/ws
    
    // Construct WS URL from ApiConfig.baseUrl
    // If baseUrl is http://10.0.2.2:8082/api, we want ws://10.0.2.2:8082/ws
    // Removing /api and changing protocol
    final wsUrl = ApiConfig.baseUrl
        .replaceAll('http', 'ws')
        .replaceAll('/api', '/ws/websocket');

    _chatService.connect(
      url: wsUrl,
      onConnect: (frame) {
        // Subscribe to team topic
        _chatService.subscribe('/topic/team/$teamId', (frame) {
          if (frame.body != null) {
            final messageJson = json.decode(frame.body!);
            final message = ChatMessage.fromJson(messageJson);
            _addMessage(message);
          }
        });
        
        // Notify join (optional)
        // _chatService.send('/app/chat.addUser', ...);
        notifyListeners();
      },
      onWebSocketError: (error) {
        print('WebSocket Error: $error');
        notifyListeners();
      },
    );
  }

  Future<void> loadHistory(int teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.chatHistory}/$teamId'),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        print('Error loading history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sendMessage(String content, int teamId, int senderId, String senderName) {
    if (content.trim().isEmpty) return;

    final message = ChatMessage(
      content: content,
      senderId: senderId,
      senderName: senderName,
      teamId: teamId,
      type: 'CHAT',
      timestamp: DateTime.now(),
    );

    _chatService.send('/app/chat.sendMessage', message.toJson());
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void disconnect() {
    _chatService.disconnect();
  }
}
