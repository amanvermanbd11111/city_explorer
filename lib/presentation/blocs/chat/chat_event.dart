import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ConnectToCityEvent extends ChatEvent {
  final String cityName;

  const ConnectToCityEvent(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String username;
  final String cityName;

  const SendMessageEvent(this.message, this.username, this.cityName);

  @override
  List<Object> get props => [message, username, cityName];
}

class DisconnectEvent extends ChatEvent {}

class LoadCachedMessagesEvent extends ChatEvent {
  final String cityName;

  const LoadCachedMessagesEvent(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class MessageReceivedEvent extends ChatEvent {
  final ChatMessage message;
  final String cityName;

  const MessageReceivedEvent(this.message, this.cityName);

  @override
  List<Object> get props => [message, cityName];
}