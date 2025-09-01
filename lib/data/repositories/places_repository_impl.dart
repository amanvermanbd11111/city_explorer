import 'dart:convert';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/nominatim_api_service.dart';
import '../models/place_model.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final NominatimApiService apiService;
  final HiveService hiveService;

  PlacesRepositoryImpl({
    required this.apiService,
    required this.hiveService,
  });

  @override
  Future<List<Place>> searchPlaces(String query) async {
    try {
      final places = await apiService.searchPlaces(query);
      await cachePlaces(query, places);
      return places;
    } on NetworkException {
      return getCachedPlaces(query);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to search places: $e');
    }
  }

  @override
  Future<List<Place>> getCachedPlaces(String cityName) async {
    try {
      final cachedData = hiveService.getPlacesCache(cityName);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList
            .map((json) => PlaceModel.fromJson(json as Map<String, dynamic>))
            .cast<Place>()
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheFailure('Failed to get cached places: $e');
    }
  }

  @override
  Future<void> cachePlaces(String cityName, List<Place> places) async {
    try {
      final placesJson = jsonEncode(
        places
            .cast<PlaceModel>()
            .map((place) => place.toJson())
            .toList(),
      );
      await hiveService.savePlacesCache(cityName, placesJson);
    } catch (e) {
      throw CacheFailure('Failed to cache places: $e');
    }
  }

  @override
  Future<String?> getLastSearchedCity() async {
    try {
      return hiveService.getLastSearchedCity();
    } catch (e) {
      throw CacheFailure('Failed to get last searched city: $e');
    }
  }

  @override
  Future<void> saveLastSearchedCity(String cityName) async {
    try {
      await hiveService.saveLastSearchedCity(cityName);
    } catch (e) {
      throw CacheFailure('Failed to save last searched city: $e');
    }
  }
}