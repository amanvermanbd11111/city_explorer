import '../entities/place.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  final FavoritesRepository repository;

  ToggleFavorite(this.repository);

  Future<bool> call(Place place) async {
    final placeId = repository.generatePlaceId(place);
    final isFavorite = await repository.isFavorite(placeId);
    
    if (isFavorite) {
      await repository.removeFromFavorites(placeId);
      return false;
    } else {
      await repository.addToFavorites(place);
      return true;
    }
  }
}