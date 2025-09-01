import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class GetWeather {
  final WeatherRepository repository;

  GetWeather(this.repository);

  Future<Weather> call(double lat, double lon) async {
    if (lat < -90 || lat > 90) {
      throw Exception('Invalid latitude: $lat');
    }
    if (lon < -180 || lon > 180) {
      throw Exception('Invalid longitude: $lon');
    }
    
    return await repository.getWeather(lat, lon);
  }
}