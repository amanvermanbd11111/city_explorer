import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/weather.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherModel extends Weather {
  @JsonKey(name: 'temp')
  final double temperature;
  
  final int humidity;
  final String description;
  final String main;
  
  @JsonKey(name: 'feels_like')
  final double? feelsLike;
  
  @JsonKey(name: 'temp_min')
  final double? tempMin;
  
  @JsonKey(name: 'temp_max')
  final double? tempMax;
  
  final int? pressure;
  
  @JsonKey(name: 'speed')
  final double? windSpeed;
  
  final String? icon;

  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.main,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.windSpeed,
    this.icon,
  }) : super(
          temperature: temperature,
          humidity: humidity,
          description: description,
          main: main,
          feelsLike: feelsLike,
          tempMin: tempMin,
          tempMax: tempMax,
          pressure: pressure,
          windSpeed: windSpeed,
          icon: icon,
        );

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);

  factory WeatherModel.fromOpenWeatherMap(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>?;

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
      main: weather['main'] as String,
      feelsLike: main['feels_like'] != null ? (main['feels_like'] as num).toDouble() : null,
      tempMin: main['temp_min'] != null ? (main['temp_min'] as num).toDouble() : null,
      tempMax: main['temp_max'] != null ? (main['temp_max'] as num).toDouble() : null,
      pressure: main['pressure'] as int?,
      windSpeed: wind?['speed'] != null ? (wind!['speed'] as num).toDouble() : null,
      icon: weather['icon'] as String?,
    );
  }
}