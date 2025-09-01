import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/places_repository.dart';
import '../../../domain/usecases/search_places.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlacesRepository placesRepository;
  final SearchPlaces searchPlaces;

  PlacesBloc({
    required this.placesRepository,
    required this.searchPlaces,
  }) : super(PlacesInitial()) {
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<LoadCachedPlacesEvent>(_onLoadCachedPlaces);
    on<LoadLastSearchedCityEvent>(_onLoadLastSearchedCity);
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<PlacesState> emit,
  ) async {
    try {
      emit(PlacesLoading());
      final places = await searchPlaces(event.query);
      
      await placesRepository.saveLastSearchedCity(event.query);
      
      if (places.isEmpty) {
        emit(PlacesEmpty(event.query));
      } else {
        emit(PlacesLoaded(places, event.query));
      }
    } on NetworkFailure {
      try {
        final cachedPlaces = await placesRepository.getCachedPlaces(event.query);
        if (cachedPlaces.isNotEmpty) {
          emit(PlacesLoaded(cachedPlaces, event.query));
        } else {
          emit(PlacesError('No internet connection and no cached data available'));
        }
      } catch (e) {
        emit(PlacesError('No internet connection and failed to load cached data'));
      }
    } on ServerFailure catch (e) {
      emit(PlacesError(e.message));
    } catch (e) {
      emit(PlacesError('Failed to search places: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCachedPlaces(
    LoadCachedPlacesEvent event,
    Emitter<PlacesState> emit,
  ) async {
    try {
      emit(PlacesLoading());
      final places = await placesRepository.getCachedPlaces(event.cityName);
      
      if (places.isEmpty) {
        emit(PlacesEmpty(event.cityName));
      } else {
        emit(PlacesLoaded(places, event.cityName));
      }
    } catch (e) {
      emit(PlacesError('Failed to load cached places: ${e.toString()}'));
    }
  }

  Future<void> _onLoadLastSearchedCity(
    LoadLastSearchedCityEvent event,
    Emitter<PlacesState> emit,
  ) async {
    try {
      final cityName = await placesRepository.getLastSearchedCity();
      emit(LastSearchedCityLoaded(cityName));
    } catch (e) {
      emit(LastSearchedCityLoaded(null));
    }
  }
}