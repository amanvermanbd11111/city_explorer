import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/http_client.dart';
import '../../models/weather_model.dart';

abstract class WeatherApiService {
  Future<WeatherModel> getWeather(double lat, double lon);
}

class WeatherApiServiceImpl implements WeatherApiService {
  final HttpClient httpClient;

  WeatherApiServiceImpl({required this.httpClient});

  @override
  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final url = '${ApiConstants.openWeatherMapBaseUrl}/weather'
          '?lat=$lat'
          '&lon=$lon'
          '&appid=${ApiConstants.openWeatherMapApiKey}'
          '&units=metric';

      final response = await httpClient.get(url);
      
      if (response is Map<String, dynamic>) {
        return WeatherModel.fromOpenWeatherMap(response);
      } else {
        throw ServerException('Invalid response format for weather data');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to get weather data: $e');
    }
  }
}