// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
      temperature: (json['temp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      description: json['description'] as String,
      main: json['main'] as String,
      feelsLike: (json['feels_like'] as num?)?.toDouble(),
      tempMin: (json['temp_min'] as num?)?.toDouble(),
      tempMax: (json['temp_max'] as num?)?.toDouble(),
      pressure: (json['pressure'] as num?)?.toInt(),
      windSpeed: (json['speed'] as num?)?.toDouble(),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'temp': instance.temperature,
      'humidity': instance.humidity,
      'description': instance.description,
      'main': instance.main,
      'feels_like': instance.feelsLike,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
      'pressure': instance.pressure,
      'speed': instance.windSpeed,
      'icon': instance.icon,
    };
