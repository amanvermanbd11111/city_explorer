import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../models/chat_message_model.dart';
import 'firebase_auth_service.dart';

abstract class FirebaseChatService {
  Stream<ChatMessageModel> get messageStream;
  Future<void> connectToCity(String cityName);
  Future<void> sendMessage(String message, String username, String cityName);
  Future<void> disconnect();
  Future<List<ChatMessageModel>> getPreviousMessages(String cityName);
  bool get isConnected;
}

class FirebaseChatServiceImpl implements FirebaseChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuthService _authService;
  StreamController<ChatMessageModel>? _messageController;
  StreamSubscription? _messagesSubscription;
  String? _currentCity;
  String? _currentUserId;
  bool _isConnected = false;

  FirebaseChatServiceImpl({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService();

  @override
  Stream<ChatMessageModel> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connectToCity(String cityName) async {
    try {
      Logger.debug('Connecting to Firebase chat for city: $cityName');
      
      // Skip authentication since Firebase rules allow public access
      Logger.debug('Using public access mode (no authentication required)');

      await disconnect();

      _currentCity = cityName;
      _currentUserId = _authService.currentUser?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();
      _messageController = StreamController<ChatMessageModel>.broadcast();

      // Reference to the city's messages in Firebase
      final messagesRef = _database.ref().child('cities').child(cityName.toLowerCase()).child('messages');

      // Listen to new messages
      _messagesSubscription = messagesRef.onChildAdded.listen(
        (DatabaseEvent event) {
          try {
            final data = event.snapshot.value;
            if (data != null && data is Map) {
              final messageData = Map<String, dynamic>.from(data as Map);
              messageData['id'] = event.snapshot.key; // Use Firebase key as ID
              
              Logger.debug('Received message from Firebase: $messageData');
              
              final message = ChatMessageModel.fromFirebase(messageData, _currentUserId ?? '');
              _messageController?.add(message);
            }
          } catch (e) {
            Logger.error('Error processing Firebase message', e);
          }
        },
        onError: (error) {
          Logger.error('Firebase messages stream error', error);
          _messageController?.addError(WebSocketException('Firebase connection error: $error'));
        },
      );

      _isConnected = true;
      Logger.debug('Successfully connected to Firebase chat for city: $cityName');
    } catch (e) {
      Logger.error('Failed to connect to Firebase chat', e);
      throw WebSocketException('Failed to connect to Firebase chat: $e');
    }
  }

  @override
  Future<void> sendMessage(String message, String username, String cityName) async {
    if (!_isConnected || _currentCity == null) {
      throw WebSocketException('Not connected to Firebase chat');
    }

    try {
      // Skip authentication since Firebase rules allow public access
      Logger.debug('Using public access mode for sending message (no authentication required)');

      final messageData = {
        'username': username,
        'message': message,
        'cityName': cityName,
        'userId': _currentUserId,
        'timestamp': ServerValue.timestamp,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      Logger.debug('Sending message to Firebase: $messageData');
      
      // Add message to Firebase Realtime Database
      final messagesRef = _database.ref().child('cities').child(cityName.toLowerCase()).child('messages');
      await messagesRef.push().set(messageData);
      
      Logger.debug('Successfully sent message to Firebase');
    } catch (e) {
      Logger.error('Failed to send message to Firebase', e);
      throw WebSocketException('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getPreviousMessages(String cityName) async {
    try {
      Logger.debug('Getting previous messages for city: $cityName');
      
      // Skip authentication since Firebase rules allow public access
      Logger.debug('Using public access mode for getting messages (no authentication required)');
      
      final messagesRef = _database.ref()
          .child('cities')
          .child(cityName.toLowerCase())
          .child('messages')
          .orderByChild('createdAt')
          .limitToLast(50); // Get last 50 messages

      final snapshot = await messagesRef.get();
      
      if (!snapshot.exists || snapshot.value == null) {
        Logger.debug('No previous messages found for city: $cityName');
        return [];
      }

      final messagesData = snapshot.value as Map<dynamic, dynamic>;
      final messages = <ChatMessageModel>[];
      
      messagesData.forEach((key, value) {
        try {
          final messageData = Map<String, dynamic>.from(value as Map);
          messageData['id'] = key; // Use Firebase key as ID
          final message = ChatMessageModel.fromFirebase(messageData, _currentUserId ?? '');
          messages.add(message);
        } catch (e) {
          Logger.error('Error parsing message data', e);
        }
      });

      // Sort by timestamp (createdAt)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      Logger.debug('Retrieved ${messages.length} previous messages for city: $cityName');
      return messages;
    } catch (e) {
      Logger.error('Failed to get previous messages from Firebase', e);
      return [];
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    await _messagesSubscription?.cancel();
    await _messageController?.close();
    _messagesSubscription = null;
    _messageController = null;
    _currentCity = null;
    _currentUserId = null;
    Logger.debug('Disconnected from Firebase chat');
  }
}