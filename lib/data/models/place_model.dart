import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/place.dart';

part 'place_model.g.dart';

@JsonSerializable()
class PlaceModel extends Place {
  @JsonKey(name: 'display_name')
  final String displayName;
  
  @JsonKey(name: 'addresstype')
  final String? addressType;
  
  @JsonKey(name: 'house_number')
  final String? houseNumber;
  
  final String? road;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;
  
  @JsonKey(fromJson: _doubleFromString)
  final double lat;
  
  @JsonKey(name: 'lon', fromJson: _doubleFromString)
  final double lon;

  const PlaceModel({
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
  }) : super(
          displayName: displayName,
          addressType: addressType,
          houseNumber: houseNumber,
          road: road,
          city: city,
          state: state,
          country: country,
          postcode: postcode,
          lat: lat,
          lon: lon,
        );

  factory PlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceModelToJson(this);

  static double _doubleFromString(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }
}