import 'package:flutter_test/flutter_test.dart';
import 'package:city_explorer/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    test('should parse OpenWeatherMap API response correctly', () {
      // Arrange
      final Map<String, dynamic> openWeatherResponse = {
        'main': {
          'temp': 25.5,
          'humidity': 65,
          'feels_like': 27.3,
          'temp_min': 22.1,
          'temp_max': 28.9,
          'pressure': 1013
        },
        'weather': [
          {
            'main': 'Clear',
            'description': 'clear sky',
            'icon': '01d'
          }
        ],
        'wind': {
          'speed': 3.2
        }
      };

      // Act
      final weatherModel = WeatherModel.fromOpenWeatherMap(openWeatherResponse);

      // Assert
      expect(weatherModel.temperature, 25.5);
      expect(weatherModel.humidity, 65);
      expect(weatherModel.main, 'Clear');
      expect(weatherModel.description, 'clear sky');
      expect(weatherModel.feelsLike, 27.3);
      expect(weatherModel.tempMin, 22.1);
      expect(weatherModel.tempMax, 28.9);
      expect(weatherModel.pressure, 1013);
      expect(weatherModel.windSpeed, 3.2);
      expect(weatherModel.icon, '01d');
    });

    test('should handle missing optional fields in OpenWeatherMap response', () {
      // Arrange
      final Map<String, dynamic> minimalResponse = {
        'main': {
          'temp': 20.0,
          'humidity': 50,
        },
        'weather': [
          {
            'main': 'Cloudy',
            'description': 'overcast clouds',
          }
        ]
      };

      // Act
      final weatherModel = WeatherModel.fromOpenWeatherMap(minimalResponse);

      // Assert
      expect(weatherModel.temperature, 20.0);
      expect(weatherModel.humidity, 50);
      expect(weatherModel.main, 'Cloudy');
      expect(weatherModel.description, 'overcast clouds');
      expect(weatherModel.feelsLike, isNull);
      expect(weatherModel.tempMin, isNull);
      expect(weatherModel.tempMax, isNull);
      expect(weatherModel.pressure, isNull);
      expect(weatherModel.windSpeed, isNull);
      expect(weatherModel.icon, isNull);
    });

    test('should format temperature and humidity correctly', () {
      // Arrange
      const weatherModel = WeatherModel(
        temperature: 23.7,
        humidity: 72,
        description: 'light rain',
        main: 'Rain',
      );

      // Act & Assert
      expect(weatherModel.temperatureCelsius, '24°C');
      expect(weatherModel.humidityPercent, '72%');
    });

    test('should serialize to and from JSON correctly', () {
      // Arrange
      const weatherModel = WeatherModel(
        temperature: 25.5,
        humidity: 65,
        description: 'clear sky',
        main: 'Clear',
        feelsLike: 27.3,
        tempMin: 22.1,
        tempMax: 28.9,
        pressure: 1013,
        windSpeed: 3.2,
        icon: '01d',
      );

      // Act
      final json = weatherModel.toJson();
      final fromJson = WeatherModel.fromJson(json);

      // Assert
      expect(fromJson.temperature, weatherModel.temperature);
      expect(fromJson.humidity, weatherModel.humidity);
      expect(fromJson.description, weatherModel.description);
      expect(fromJson.main, weatherModel.main);
      expect(fromJson.feelsLike, weatherModel.feelsLike);
      expect(fromJson.tempMin, weatherModel.tempMin);
      expect(fromJson.tempMax, weatherModel.tempMax);
      expect(fromJson.pressure, weatherModel.pressure);
      expect(fromJson.windSpeed, weatherModel.windSpeed);
      expect(fromJson.icon, weatherModel.icon);
    });
  });
}