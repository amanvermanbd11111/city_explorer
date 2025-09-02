import '../../domain/entities/place.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesService favoritesService;

  FavoritesRepositoryImpl({required this.favoritesService});

  @override
  Future<List<Place>> getFavorites() async {
    return await favoritesService.getFavorites();
  }

  @override
  Future<void> addToFavorites(Place place) async {
    await favoritesService.addToFavorites(place);
  }

  @override
  Future<void> removeFromFavorites(String placeId) async {
    await favoritesService.removeFromFavorites(placeId);
  }

  @override
  Future<bool> isFavorite(String placeId) async {
    return await favoritesService.isFavorite(placeId);
  }

  @override
  Future<void> clearFavorites() async {
    await favoritesService.clearFavorites();
  }

  @override
  String generatePlaceId(Place place) {
    return '${place.lat.toStringAsFixed(6)}_${place.lon.toStringAsFixed(6)}_${place.displayName.hashCode}';
  }
}