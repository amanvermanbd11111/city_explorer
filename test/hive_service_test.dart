import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:city_explorer/data/datasources/local/hive_service.dart';
import 'package:city_explorer/data/models/user_model.dart';
import 'package:city_explorer/data/models/chat_message_model.dart';

void main() {
  group('HiveService', () {
    late HiveService hiveService;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test_hive');
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChatMessageModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      
      // Initialize HiveService which will open boxes
      await HiveService.init();
      hiveService = HiveService();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    group('User Operations', () {
      test('should save and retrieve current user', () async {
        // Arrange
        final user = UserModel.guest('TestUser');

        // Act
        await hiveService.saveUser(user);
        final retrievedUser = hiveService.getCurrentUser();

        // Assert
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.username, 'TestUser');
        expect(retrievedUser.isGuest, true);
      });

      test('should return null when no user is saved', () {
        // Act
        final user = hiveService.getCurrentUser();

        // Assert
        expect(user, isNull);
      });
    });

    group('Cache Operations', () {
      test('should save and retrieve last searched city', () async {
        // Arrange
        const cityName = 'New York';

        // Act
        await hiveService.saveLastSearchedCity(cityName);
        final retrievedCity = hiveService.getLastSearchedCity();

        // Assert
        expect(retrievedCity, cityName);
      });

      test('should save and retrieve places cache', () async {
        // Arrange
        const cityName = 'Paris';
        const placesJson = '{"places": ["place1", "place2"]}';

        // Act
        await hiveService.savePlacesCache(cityName, placesJson);
        final retrievedPlaces = hiveService.getPlacesCache(cityName);

        // Assert
        expect(retrievedPlaces, placesJson);
      });

      test('should return null for non-existent cache', () {
        // Act
        final places = hiveService.getPlacesCache('NonExistentCity');
        final city = hiveService.getLastSearchedCity();

        // Assert
        expect(places, isNull);
        expect(city, isNull);
      });
    });

    group('Chat Messages Operations', () {
      test('should save and retrieve chat messages', () async {
        // Arrange
        const cityName = 'London';
        final messages = [
          ChatMessageModel(
            id: '1',
            username: 'User1',
            message: 'Hello London!',
            cityName: cityName,
            timestamp: DateTime.now(),
            isOwnMessage: false,
          ),
          ChatMessageModel(
            id: '2',
            username: 'User2',
            message: 'Great city!',
            cityName: cityName,
            timestamp: DateTime.now(),
            isOwnMessage: true,
          ),
        ];

        // Act
        await hiveService.saveChatMessages(cityName, messages);
        final retrievedMessages = hiveService.getChatMessages(cityName);

        // Assert
        expect(retrievedMessages, isNotEmpty);
        expect(retrievedMessages.length, lessThanOrEqualTo(20)); // Should limit to 20
      });

      test('should limit chat messages to last 20', () async {
        // Arrange
        const cityName = 'Tokyo';
        final messages = List.generate(
          25,
          (index) => ChatMessageModel(
            id: '$index',
            username: 'User$index',
            message: 'Message $index',
            cityName: cityName,
            timestamp: DateTime.now(),
            isOwnMessage: index % 2 == 0,
          ),
        );

        // Act
        await hiveService.saveChatMessages(cityName, messages);
        final retrievedMessages = hiveService.getChatMessages(cityName);

        // Assert
        expect(retrievedMessages.length, lessThanOrEqualTo(20));
      });
    });

    group('Clear Operations', () {
      test('should clear all data', () async {
        // Arrange
        final user = UserModel.guest('TestUser');
        await hiveService.saveUser(user);
        await hiveService.saveLastSearchedCity('TestCity');
        await hiveService.savePlacesCache('TestCity', '{}');

        // Act
        await hiveService.clearAll();

        // Assert
        expect(hiveService.getCurrentUser(), isNull);
        expect(hiveService.getLastSearchedCity(), isNull);
        expect(hiveService.getPlacesCache('TestCity'), isNull);
      });
    });
  });
}