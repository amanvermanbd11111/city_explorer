import 'package:hive_flutter/hive_flutter.dart';
import '../../models/chat_message_model.dart';
import '../../models/user_model.dart';

class HiveService {
  static const String _userBoxName = 'user_box';
  static const String _chatMessagesBoxName = 'chat_messages_box';
  static const String _placesBoxName = 'places_box';
  static const String _lastSearchedCityBoxName = 'last_searched_city_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(ChatMessageModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    
    await _openBoxes();
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<UserModel>(_userBoxName),
      Hive.openBox<ChatMessageModel>(_chatMessagesBoxName),
      Hive.openBox<String>(_placesBoxName),
      Hive.openBox<String>(_lastSearchedCityBoxName),
    ]);
  }

  Box<UserModel> get _userBox => Hive.box<UserModel>(_userBoxName);
  Box<ChatMessageModel> get _chatMessagesBox => Hive.box<ChatMessageModel>(_chatMessagesBoxName);
  Box<String> get _placesBox => Hive.box<String>(_placesBoxName);
  Box<String> get _lastSearchedCityBox => Hive.box<String>(_lastSearchedCityBoxName);

  Future<void> saveUser(UserModel user) async {
    await _userBox.put('current_user', user);
  }

  UserModel? getCurrentUser() {
    return _userBox.get('current_user');
  }

  Future<void> saveChatMessages(String cityName, List<ChatMessageModel> messages) async {
    final recentMessages = messages.length > 20 ? messages.sublist(messages.length - 20) : messages;
    await _chatMessagesBox.put(cityName, recentMessages.last);
    for (int i = 0; i < recentMessages.length; i++) {
      await _chatMessagesBox.put('${cityName}_$i', recentMessages[i]);
    }
  }

  List<ChatMessageModel> getChatMessages(String cityName) {
    final messages = <ChatMessageModel>[];
    for (int i = 0; i < 20; i++) {
      final message = _chatMessagesBox.get('${cityName}_$i');
      if (message != null) {
        messages.add(message);
      }
    }
    return messages;
  }

  Future<void> saveLastSearchedCity(String cityName) async {
    await _lastSearchedCityBox.put('last_city', cityName);
  }

  String? getLastSearchedCity() {
    return _lastSearchedCityBox.get('last_city');
  }

  Future<void> savePlacesCache(String cityName, String placesJson) async {
    await _placesBox.put(cityName, placesJson);
  }

  String? getPlacesCache(String cityName) {
    return _placesBox.get(cityName);
  }

  Future<void> clearAll() async {
    await Future.wait([
      _userBox.clear(),
      _chatMessagesBox.clear(),
      _placesBox.clear(),
      _lastSearchedCityBox.clear(),
    ]);
  }
}