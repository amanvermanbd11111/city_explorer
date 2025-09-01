import '../entities/place.dart';
import '../repositories/places_repository.dart';

class SearchPlaces {
  final PlacesRepository repository;

  SearchPlaces(this.repository);

  Future<List<Place>> call(String query) async {
    if (query.trim().isEmpty) {
      throw Exception('Search query cannot be empty');
    }
    
    return await repository.searchPlaces(query.trim());
  }
}