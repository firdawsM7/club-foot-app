class ChatMessage {
  final String content;
  final int senderId;
  final String senderName;
  final int teamId;
  final String type;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.teamId,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? 'Unknown',
      teamId: json['teamId'] ?? 0,
      type: json['type'] ?? 'CHAT',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'teamId': teamId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
