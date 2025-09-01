import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/get_weather.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeather getWeather;

  WeatherBloc({required this.getWeather}) : super(WeatherInitial()) {
    on<GetWeatherEvent>(_onGetWeather);
  }

  Future<void> _onGetWeather(
    GetWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    try {
      emit(WeatherLoading());
      final weather = await getWeather(event.lat, event.lon);
      emit(WeatherLoaded(weather));
    } on NetworkFailure catch (e) {
      emit(WeatherError(e.message));
    } on ServerFailure catch (e) {
      emit(WeatherError(e.message));
    } catch (e) {
      emit(WeatherError('Failed to get weather: ${e.toString()}'));
    }
  }
}