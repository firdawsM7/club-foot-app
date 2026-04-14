import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatService {
  StompClient? _stompClient;
  bool _isConnected = false;
  String? _currentUrl;

  bool get isConnected => _isConnected;

  void connect({
    required String url,
    required Function(StompFrame) onConnect,
    required Function(dynamic) onWebSocketError,
  }) {
    if (_currentUrl == url && (_stompClient?.connected ?? false)) {
      return;
    }

    disconnect();
    _currentUrl = url;

    _stompClient = StompClient(
      config: StompConfig(
        url: url,
        reconnectDelay: const Duration(seconds: 3),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        onConnect: (frame) {
          _isConnected = true;
          onConnect(frame);
        },
        onWebSocketError: (error) {
          _isConnected = false;
          onWebSocketError(error);
        },
        onDisconnect: (frame) {
          _isConnected = false;
        },
      ),
    );

    _stompClient?.activate();
  }

  void subscribe(String destination, Function(StompFrame) callback) {
    _stompClient?.subscribe(
      destination: destination,
      callback: callback,
    );
  }

  void send(String destination, Map<String, dynamic> body) {
    _stompClient?.send(
      destination: destination,
      body: json.encode(body),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _currentUrl = null;
    _isConnected = false;
  }
}
