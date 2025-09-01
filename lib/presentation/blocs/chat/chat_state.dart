import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatConnecting extends ChatState {}

class ChatConnected extends ChatState {
  final String cityName;
  final List<ChatMessage> messages;

  const ChatConnected(this.cityName, this.messages);

  @override
  List<Object> get props => [cityName, messages];
}

class ChatDisconnected extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {}

class CachedMessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String cityName;

  const CachedMessagesLoaded(this.messages, this.cityName);

  @override
  List<Object> get props => [messages, cityName];
}