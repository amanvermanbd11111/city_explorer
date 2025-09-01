import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class ChatMessageModel extends ChatMessage {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String message;
  
  @HiveField(3)
  final String cityName;
  
  @HiveField(4)
  @JsonKey(fromJson: _dateTimeFromMilliseconds, toJson: _dateTimeToMilliseconds)
  final DateTime timestamp;
  
  @HiveField(5)
  final bool isOwnMessage;

  const ChatMessageModel({
    required this.id,
    required this.username,
    required this.message,
    required this.cityName,
    required this.timestamp,
    required this.isOwnMessage,
  }) : super(
          id: id,
          username: username,
          message: message,
          cityName: cityName,
          timestamp: timestamp,
          isOwnMessage: isOwnMessage,
        );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  static DateTime _dateTimeFromMilliseconds(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds);

  static int _dateTimeToMilliseconds(DateTime dateTime) =>
      dateTime.millisecondsSinceEpoch;

  factory ChatMessageModel.fromWebSocket(Map<String, dynamic> json, String currentUserId) {
    return ChatMessageModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      username: json['username'] ?? 'Anonymous',
      message: json['message'] ?? '',
      cityName: json['cityName'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      isOwnMessage: json['userId'] == currentUserId,
    );
  }

  factory ChatMessageModel.fromFirebase(Map<String, dynamic> json, String currentUserId) {
    return ChatMessageModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      username: json['username'] ?? 'Anonymous',
      message: json['message'] ?? '',
      cityName: json['cityName'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      isOwnMessage: json['userId'] == currentUserId,
    );
  }
}