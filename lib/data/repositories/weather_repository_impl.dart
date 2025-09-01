import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/remote/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;

  WeatherRepositoryImpl({required this.apiService});

  @override
  Future<Weather> getWeather(double lat, double lon) async {
    try {
      return await apiService.getWeather(lat, lon);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get weather: $e');
    }
  }
}