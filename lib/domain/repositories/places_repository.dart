import '../entities/place.dart';

abstract class PlacesRepository {
  Future<List<Place>> searchPlaces(String query);
  Future<List<Place>> getCachedPlaces(String cityName);
  Future<void> cachePlaces(String cityName, List<Place> places);
  Future<String?> getLastSearchedCity();
  Future<void> saveLastSearchedCity(String cityName);
}