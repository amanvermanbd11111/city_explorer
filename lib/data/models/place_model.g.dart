// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceModel _$PlaceModelFromJson(Map<String, dynamic> json) => PlaceModel(
      displayName: json['display_name'] as String,
      addressType: json['addresstype'] as String?,
      houseNumber: json['house_number'] as String?,
      road: json['road'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postcode: json['postcode'] as String?,
      lat: PlaceModel._doubleFromString(json['lat']),
      lon: PlaceModel._doubleFromString(json['lon']),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PlaceModelToJson(PlaceModel instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'addresstype': instance.addressType,
      'house_number': instance.houseNumber,
      'road': instance.road,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postcode': instance.postcode,
      'lat': instance.lat,
      'lon': instance.lon,
      'imageUrl': instance.imageUrl,
    };
