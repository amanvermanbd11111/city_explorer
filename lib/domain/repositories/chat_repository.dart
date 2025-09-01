import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<ChatMessage> get messageStream;
  Future<void> connectToCity(String cityName);
  Future<void> sendMessage(String message, String username, String cityName);
  Future<void> disconnect();
  Future<List<ChatMessage>> getCachedMessages(String cityName);
  Future<void> cacheMessages(String cityName, List<ChatMessage> messages);
  bool get isConnected;
}