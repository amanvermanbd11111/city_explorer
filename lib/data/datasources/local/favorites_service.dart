import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/entities/place.dart';
import '../../models/place_model.dart';

abstract class FavoritesService {
  Future<List<Place>> getFavorites();
  Future<void> addToFavorites(Place place);
  Future<void> removeFromFavorites(String placeId);
  Future<bool> isFavorite(String placeId);
  Future<void> clearFavorites();
}

class FavoritesServiceImpl implements FavoritesService {
  static const String _favoritesKey = 'favorites';
  
  @override
  Future<List<Place>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return PlaceModel.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<void> addToFavorites(Place place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      // Check if already exists
      final placeId = _generatePlaceId(place);
      if (favorites.any((fav) => _generatePlaceId(fav) == placeId)) {
        return;
      }
      
      // Convert to PlaceModel and add
      final placeModel = PlaceModel(
        displayName: place.displayName,
        addressType: place.addressType,
        houseNumber: place.houseNumber,
        road: place.road,
        city: place.city,
        state: place.state,
        country: place.country,
        postcode: place.postcode,
        lat: place.lat,
        lon: place.lon,
      );
      
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      favoritesJson.add(jsonEncode(placeModel.toJson()));
      
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      // Handle error silently
    }
  }
  
  @override
  Future<void> removeFromFavorites(String placeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      final favoritesJson = favorites
          .where((place) => _generatePlaceId(place) != placeId)
          .map((place) => jsonEncode((place as PlaceModel).toJson()))
          .toList();
      
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      // Handle error silently
    }
  }
  
  @override
  Future<bool> isFavorite(String placeId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((place) => _generatePlaceId(place) == placeId);
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      // Handle error silently
    }
  }
  
  String _generatePlaceId(Place place) {
    // Generate a unique ID based on coordinates and display name
    return '${place.lat.toStringAsFixed(6)}_${place.lon.toStringAsFixed(6)}_${place.displayName.hashCode}';
  }
}