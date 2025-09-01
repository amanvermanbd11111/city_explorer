import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../models/chat_message_model.dart';

abstract class WebSocketService {
  Stream<ChatMessageModel> get messageStream;
  Future<void> connect(String cityName);
  Future<void> sendMessage(String message, String username, String cityName);
  Future<void> disconnect();
  bool get isConnected;
}

class WebSocketServiceImpl implements WebSocketService {
  WebSocketChannel? _channel;
  StreamController<ChatMessageModel>? _messageController;
  String? _currentCity;
  String? _currentUserId;
  bool _isConnected = false;

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
}