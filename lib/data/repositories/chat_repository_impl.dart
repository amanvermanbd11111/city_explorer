import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/websocket_service.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final WebSocketService webSocketService;
  final HiveService hiveService;

  ChatRepositoryImpl({
    required this.webSocketService,
    required this.hiveService,
  });

  @override
  Stream<ChatMessage> get messageStream =>
      webSocketService.messageStream.cast<ChatMessage>();

  @override
  bool get isConnected => webSocketService.isConnected;

  @override
  Future<void> connectToCity(String cityName) async {
    try {
      await webSocketService.connect(cityName);
    } on WebSocketException catch (e) {
      throw WebSocketFailure(e.message);
    } catch (e) {
      throw WebSocketFailure('Failed to connect to city chat: $e');
    }
  }

  @override
  Future<void> sendMessage(String message, String username, String cityName) async {
    try {
      await webSocketService.sendMessage(message, username, cityName);
    } on WebSocketException catch (e) {
      throw WebSocketFailure(e.message);
    } catch (e) {
      throw WebSocketFailure('Failed to send message: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await webSocketService.disconnect();
    } catch (e) {
      throw WebSocketFailure('Failed to disconnect: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getCachedMessages(String cityName) async {
    try {
      final messages = hiveService.getChatMessages(cityName);
      return messages.cast<ChatMessage>();
    } catch (e) {
      throw CacheFailure('Failed to get cached messages: $e');
    }
  }

  @override
  Future<void> cacheMessages(String cityName, List<ChatMessage> messages) async {
    try {
      final messageModels = messages
          .cast<ChatMessageModel>()
          .toList();
      await hiveService.saveChatMessages(cityName, messageModels);
    } catch (e) {
      throw CacheFailure('Failed to cache messages: $e');
    }
  }
}