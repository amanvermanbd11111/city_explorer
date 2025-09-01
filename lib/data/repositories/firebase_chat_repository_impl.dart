import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firebase_chat_service.dart';
import '../models/chat_message_model.dart';

class FirebaseChatRepositoryImpl implements ChatRepository {
  final FirebaseChatService firebaseChatService;
  final HiveService hiveService;

  FirebaseChatRepositoryImpl({
    required this.firebaseChatService,
    required this.hiveService,
  });

  @override
  Stream<ChatMessage> get messageStream =>
      firebaseChatService.messageStream.cast<ChatMessage>();

  @override
  bool get isConnected => firebaseChatService.isConnected;

  @override
  Future<void> connectToCity(String cityName) async {
    try {
      await firebaseChatService.connectToCity(cityName);
    } on WebSocketException catch (e) {
      throw WebSocketFailure(e.message);
    } catch (e) {
      throw WebSocketFailure('Failed to connect to city chat: $e');
    }
  }

  @override
  Future<void> sendMessage(String message, String username, String cityName) async {
    try {
      await firebaseChatService.sendMessage(message, username, cityName);
    } on WebSocketException catch (e) {
      throw WebSocketFailure(e.message);
    } catch (e) {
      throw WebSocketFailure('Failed to send message: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await firebaseChatService.disconnect();
    } catch (e) {
      throw WebSocketFailure('Failed to disconnect: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getCachedMessages(String cityName) async {
    try {
      // First try to get from Firebase (recent messages)
      final firebaseMessages = await firebaseChatService.getPreviousMessages(cityName);
      
      // Also get local cached messages as fallback
      final cachedMessages = hiveService.getChatMessages(cityName);
      
      // If we have Firebase messages, cache them locally and return them
      if (firebaseMessages.isNotEmpty) {
        await cacheMessages(cityName, firebaseMessages);
        return firebaseMessages.cast<ChatMessage>();
      }
      
      // Otherwise return local cached messages
      return cachedMessages.cast<ChatMessage>();
    } catch (e) {
      // Fallback to local cache if Firebase fails
      return hiveService.getChatMessages(cityName).cast<ChatMessage>();
    }
  }

  @override
  Future<void> cacheMessages(String cityName, List<ChatMessage> messages) async {
    try {
      final messageModels = messages.map((msg) {
        if (msg is ChatMessageModel) {
          return msg;
        } else {
          // Convert ChatMessage to ChatMessageModel
          return ChatMessageModel(
            id: msg.id,
            username: msg.username,
            message: msg.message,
            cityName: msg.cityName,
            timestamp: msg.timestamp,
            isOwnMessage: msg.isOwnMessage,
          );
        }
      }).toList();
      
      await hiveService.saveChatMessages(cityName, messageModels);
    } catch (e) {
      // Don't throw error for caching failure, just log it
      // Logger.error('Failed to cache messages', e);
    }
  }
}