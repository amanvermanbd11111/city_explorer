import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final int humidity;
  final String description;
  final String main;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final double? windSpeed;
  final String? icon;

  const Weather({
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
  });

  @override
  List<Object?> get props => [
        temperature,
        humidity,
        description,
        main,
        feelsLike,
        tempMin,
        tempMax,
        pressure,
        windSpeed,
        icon,
      ];

  String get temperatureCelsius => '${temperature.round()}°C';
  String get humidityPercent => '$humidity%';
}