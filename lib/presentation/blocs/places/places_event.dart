import 'package:equatable/equatable.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object> get props => [];
}

class SearchPlacesEvent extends PlacesEvent {
  final String query;

  const SearchPlacesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadCachedPlacesEvent extends PlacesEvent {
  final String cityName;

  const LoadCachedPlacesEvent(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class LoadLastSearchedCityEvent extends PlacesEvent {}