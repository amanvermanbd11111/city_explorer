import '../entities/place.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;

  GetFavorites(this.repository);

  Future<List<Place>> call() async {
    return await repository.getFavorites();
  }
}