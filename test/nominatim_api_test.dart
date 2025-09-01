import 'package:flutter_test/flutter_test.dart';
import 'package:city_explorer/data/datasources/remote/nominatim_api_service.dart';
import 'package:city_explorer/core/network/http_client.dart';

void main() {
  group('Nominatim API Service', () {
    test('should successfully search for places', () async {
      // Arrange
      final httpClient = HttpClient();
      final nominatimService = NominatimApiServiceImpl(httpClient: httpClient);

      // Act - Search for a well-known city
      final places = await nominatimService.searchPlaces('London');

      // Assert
      expect(places, isNotEmpty);
      expect(places.first.displayName.toLowerCase(), contains('london'));
      expect(places.first.lat, isNonZero);
      expect(places.first.lon, isNonZero);
      
      // Cleanup
      httpClient.dispose();
    });

    test('should handle empty search results', () async {
      // Arrange
      final httpClient = HttpClient();
      final nominatimService = NominatimApiServiceImpl(httpClient: httpClient);

      // Act - Search for something that doesn't exist
      final places = await nominatimService.searchPlaces('xyzinvalidcityname12345');

      // Assert
      expect(places, isEmpty);
      
      // Cleanup
      httpClient.dispose();
    });
  });
}