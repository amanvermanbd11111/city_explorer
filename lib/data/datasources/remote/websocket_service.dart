import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../models/chat_message_model.dart';
import '../local/hive_service.dart';

abstract class WebSocketService {
  Stream<ChatMessageModel> get messageStream;
  Future<void> connect(String cityName);
  Future<void> sendMessage(String message, String username, String cityName);
  Future<void> disconnect();
  bool get isConnected;
}

class WebSocketServiceImpl implements WebSocketService {
  final HiveService hiveService;
  WebSocketChannel? _channel;
  StreamController<ChatMessageModel>? _messageController;
  String? _currentCity;
  String? _currentUserId;
  bool _isConnected = false;

  WebSocketServiceImpl({required this.hiveService});

  @override
  Stream<ChatMessageModel> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(String cityName) async {
    try {
      Logger.debug('Connecting to WebSocket for city: $cityName');
      await disconnect();

      _currentCity = cityName;
      _currentUserId = DateTime.now().millisecondsSinceEpoch.toString();
      _messageController = StreamController<ChatMessageModel>.broadcast();

      // Load and emit previous messages for this city
      await _loadAndEmitPreviousMessages(cityName);

      Logger.debug('Connecting to: ${ApiConstants.websocketUrl}');
      _channel = WebSocketChannel.connect(Uri.parse(ApiConstants.websocketUrl));
      _isConnected = true;

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      final joinMessage = {
        'type': 'join',
        'cityName': cityName,
        'userId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      Logger.debug('Sending join message: ${jsonEncode(joinMessage)}');
      _channel!.sink.add(jsonEncode(joinMessage));
      Logger.debug('WebSocket connected successfully');
    } catch (e) {
      Logger.error('Failed to connect to WebSocket', e);
      throw WebSocketException('Failed to connect to chat: $e');
    }
  }

  @override
  Future<void> sendMessage(String message, String username, String cityName) async {
    if (!_isConnected || _channel == null) {
      throw WebSocketException('Not connected to chat');
    }

    try {
      final messageData = {
        'type': 'message',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'username': username,
        'message': message,
        'cityName': cityName,
        'userId': _currentUserId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      Logger.debug('Sending message: ${jsonEncode(messageData)}');
      _channel!.sink.add(jsonEncode(messageData));
      
      // Immediately add the message to the stream as our own message
      // since the echo server might not return it immediately
      final chatMessage = ChatMessageModel(
        id: messageData['id'] as String,
        username: username,
        message: message,
        cityName: cityName,
        timestamp: DateTime.fromMillisecondsSinceEpoch(messageData['timestamp'] as int),
        isOwnMessage: true,
      );
      
      // Save message to global storage for cross-user persistence
      await _saveMessageToGlobalStorage(chatMessage);
      
      Logger.debug('Adding own message to stream');
      _messageController?.add(chatMessage);
    } catch (e) {
      Logger.error('Failed to send message', e);
      throw WebSocketException('Failed to send message: $e');
    }
  }

  void _handleMessage(dynamic data) {
    try {
      Logger.debug('Received WebSocket data: $data');
      Map<String, dynamic> messageJson;
      
      if (data is String) {
        if (data.trim().isEmpty) return;
        
        try {
          messageJson = jsonDecode(data) as Map<String, dynamic>;
          Logger.debug('Parsed JSON: $messageJson');
        } catch (e) {
          Logger.debug('Failed to parse as JSON, treating as plain text');
          // Create a message from plain text (echo response)
          messageJson = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'username': 'Echo Server',
            'message': data,
            'cityName': _currentCity ?? '',
            'userId': 'system',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
        }
      } else {
        Logger.debug('Received non-string data: ${data.runtimeType}');
        return;
      }

      // Don't add our own messages again (they're already added in sendMessage)
      if (messageJson['userId'] != _currentUserId) {
        Logger.debug('Adding received message to stream');
        final chatMessage = ChatMessageModel.fromWebSocket(messageJson, _currentUserId ?? '');
        if (chatMessage.cityName == _currentCity || chatMessage.cityName.isEmpty) {
          _messageController?.add(chatMessage);
        }
      } else {
        Logger.debug('Ignoring own message echo');
      }
    } catch (e) {
      Logger.error('Error handling WebSocket message', e);
    }
  }

  void _handleError(dynamic error) {
    _isConnected = false;
    _messageController?.addError(WebSocketException('WebSocket error: $error'));
  }

  void _handleDone() {
    _isConnected = false;
    _messageController?.close();
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    await _channel?.sink.close();
    await _messageController?.close();
    _channel = null;
    _messageController = null;
  }

  /// Load previous messages for the city from global storage and emit them
  Future<void> _loadAndEmitPreviousMessages(String cityName) async {
    try {
      final globalMessages = await _getGlobalMessages(cityName);
      Logger.debug('Loading ${globalMessages.length} previous messages for city: $cityName');
      
      for (final message in globalMessages) {
        // Mark all previous messages as not own messages for the current user
        final messageWithUpdatedFlag = ChatMessageModel(
          id: message.id,
          username: message.username,
          message: message.message,
          cityName: message.cityName,
          timestamp: message.timestamp,
          isOwnMessage: false, // All previous messages are from others
        );
        _messageController?.add(messageWithUpdatedFlag);
        
        // Small delay to ensure proper order
        await Future.delayed(Duration(milliseconds: 10));
      }
    } catch (e) {
      Logger.error('Failed to load previous messages', e);
    }
  }

  /// Save message to global storage for cross-user persistence
  Future<void> _saveMessageToGlobalStorage(ChatMessageModel message) async {
    try {
      final globalKey = 'global_chat_${message.cityName.toLowerCase()}';
      Logger.debug('Saving message with key: $globalKey');
      final existingMessages = await _getGlobalMessages(message.cityName);
      Logger.debug('Found ${existingMessages.length} existing messages');
      
      // Add new message
      existingMessages.add(message);
      Logger.debug('Total messages after adding new one: ${existingMessages.length}');
      
      // Keep only last 50 messages per city to prevent infinite growth
      if (existingMessages.length > 50) {
        existingMessages.removeRange(0, existingMessages.length - 50);
      }
      
      final dataToSave = existingMessages.map((m) => m.toJson()).toList();
      Logger.debug('About to save data: $dataToSave');
      await hiveService.saveData(globalKey, dataToSave);
      Logger.debug('Successfully saved message to global storage for city: ${message.cityName}');
    } catch (e) {
      Logger.error('Failed to save message to global storage', e);
    }
  }

  /// Get global messages for a city
  Future<List<ChatMessageModel>> _getGlobalMessages(String cityName) async {
    try {
      final globalKey = 'global_chat_${cityName.toLowerCase()}';
      Logger.debug('Trying to get messages with key: $globalKey');
      final data = hiveService.getData(globalKey);
      Logger.debug('Retrieved data: $data (type: ${data.runtimeType})');
      
      if (data != null && data is List) {
        Logger.debug('Data is List with ${data.length} items');
        return data
            .map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      Logger.debug('No data found or data is not a List');
      return [];
    } catch (e) {
      Logger.error('Failed to get global messages', e);
      return [];
    }
  }
}