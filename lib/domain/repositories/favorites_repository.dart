import '../entities/place.dart';

abstract class FavoritesRepository {
  Future<List<Place>> getFavorites();
  Future<void> addToFavorites(Place place);
  Future<void> removeFromFavorites(String placeId);
  Future<bool> isFavorite(String placeId);
  Future<void> clearFavorites();
  String generatePlaceId(Place place);
}