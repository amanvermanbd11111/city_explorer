import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String username;
  final String message;
  final String cityName;
  final DateTime timestamp;
  final bool isOwnMessage;

  const ChatMessage({
    required this.id,
    required this.username,
    required this.message,
    required this.cityName,
    required this.timestamp,
    required this.isOwnMessage,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        message,
        cityName,
        timestamp,
        isOwnMessage,
      ];

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}