import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/http_client.dart';
import '../../../core/utils/logger.dart';
import '../../models/place_model.dart';

abstract class NominatimApiService {
  Future<List<PlaceModel>> searchPlaces(String query);
}

class NominatimApiServiceImpl implements NominatimApiService {
  final HttpClient httpClient;

  NominatimApiServiceImpl({required this.httpClient});

  @override
  Future<List<PlaceModel>> searchPlaces(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '${ApiConstants.nominatimBaseUrl}/search'
          '?q=$encodedQuery'
          '&format=json'
          '&limit=${ApiConstants.placesLimit}'
          '&addressdetails=1'
          '&extratags=1';

      Logger.debug('Searching places with URL: $url');
      
      final response = await httpClient.get(url, headers: {
        'User-Agent': 'CityExplorer/1.0 (Flutter App)',
      });
      Logger.debug('API Response type: ${response.runtimeType}');
      Logger.debug('API Response: $response');
      
      if (response is List) {
        Logger.debug('Response is List with ${response.length} items');
        final places = (response as List<dynamic>)
            .map((json) => _parsePlace(json as Map<String, dynamic>))
            .where((place) => place != null)
            .cast<PlaceModel>()
            .toList();
        Logger.debug('Parsed ${places.length} places successfully');
        return places;
      } else {
        Logger.error('Invalid response format - expected List but got ${response.runtimeType}');
        throw ServerException('Invalid response format');
      }
    } catch (e) {
      Logger.error('Error searching places', e);
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Failed to search places: $e');
    }
  }

  PlaceModel? _parsePlace(Map<String, dynamic> json) {
    try {
      Logger.debug('Parsing place: ${json['display_name']}');
      final address = json['address'] as Map<String, dynamic>? ?? {};
      
      final place = PlaceModel(
        displayName: json['display_name'] ?? '',
        addressType: json['addresstype'],
        houseNumber: address['house_number'],
        road: address['road'],
        city: address['city'] ?? address['town'] ?? address['village'],
        state: address['state'],
        country: address['country'],
        postcode: address['postcode'],
        lat: double.tryParse(json['lat']?.toString() ?? '0.0') ?? 0.0,
        lon: double.tryParse(json['lon']?.toString() ?? '0.0') ?? 0.0,
      );
      Logger.debug('Successfully parsed place: ${place.displayName}');
      return place;
    } catch (e) {
      Logger.error('Failed to parse place', e);
      return null;
    }
  }

}