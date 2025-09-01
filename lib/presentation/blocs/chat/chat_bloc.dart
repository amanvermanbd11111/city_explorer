import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription<ChatMessage>? _messageSubscription;
  final List<ChatMessage> _messages = [];
  String? _currentCity;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<ConnectToCityEvent>(_onConnectToCity);
    on<SendMessageEvent>(_onSendMessage);
    on<DisconnectEvent>(_onDisconnect);
    on<LoadCachedMessagesEvent>(_onLoadCachedMessages);
    on<MessageReceivedEvent>(_onMessageReceived);
  }

  Future<void> _onConnectToCity(
    ConnectToCityEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatConnecting());
      
      await _messageSubscription?.cancel();
      _messages.clear();
      
      await chatRepository.connectToCity(event.cityName);
      _currentCity = event.cityName;
      
      final cachedMessages = await chatRepository.getCachedMessages(event.cityName);
      _messages.addAll(cachedMessages);
      
      _messageSubscription = chatRepository.messageStream.listen(
        (message) {
          _messages.add(message);
          if (_messages.length > 20) {
            _messages.removeAt(0);
          }
          
          // Use add() instead of emit() to trigger a new event
          add(MessageReceivedEvent(message, event.cityName));
          
          chatRepository.cacheMessages(event.cityName, _messages);
        },
        onError: (error) {
          add(DisconnectEvent());
        },
      );
      
      emit(ChatConnected(event.cityName, List.from(_messages)));
    } on WebSocketFailure catch (e) {
      emit(ChatError(e.message));
    } catch (e) {
      emit(ChatError('Failed to connect: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatRepository.sendMessage(event.message, event.username, event.cityName);
    } on WebSocketFailure catch (e) {
      emit(ChatError(e.message));
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnect(
    DisconnectEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _messageSubscription?.cancel();
      await chatRepository.disconnect();
      _messages.clear();
      _currentCity = null;
      emit(ChatDisconnected());
    } catch (e) {
      emit(ChatError('Failed to disconnect: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCachedMessages(
    LoadCachedMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await chatRepository.getCachedMessages(event.cityName);
      emit(CachedMessagesLoaded(messages, event.cityName));
    } catch (e) {
      emit(ChatError('Failed to load cached messages: ${e.toString()}'));
    }
  }

  Future<void> _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) async {
    // The message is already added to _messages in the stream listener
    if (state is ChatConnected && _currentCity == event.cityName) {
      emit(ChatConnected(event.cityName, List.from(_messages)));
    }
  }

  @override
  Future<void> close() async {
    await _messageSubscription?.cancel();
    await chatRepository.disconnect();
    return super.close();
  }
}