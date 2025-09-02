import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String displayName;
  final String? addressType;
  final String? houseNumber;
  final String? road;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;
  final double lat;
  final double lon;
  const Place({
    required this.displayName,
    this.addressType,
    this.houseNumber,
    this.road,
    this.city,
    this.state,
    this.country,
    this.postcode,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [
        displayName,
        addressType,
        houseNumber,
        road,
        city,
        state,
        country,
        postcode,
        lat,
        lon,
      ];

  String get formattedAddress {
    final parts = <String>[];
    if (road != null) parts.add(road!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }
}