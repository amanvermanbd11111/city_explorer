import 'package:equatable/equatable.dart';
import '../../../domain/entities/place.dart';

abstract class PlacesState extends Equatable {
  const PlacesState();

  @override
  List<Object?> get props => [];
}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<Place> places;
  final String searchQuery;

  const PlacesLoaded(this.places, this.searchQuery);

  @override
  List<Object> get props => [places, searchQuery];
}

class PlacesEmpty extends PlacesState {
  final String searchQuery;

  const PlacesEmpty(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class PlacesError extends PlacesState {
  final String message;

  const PlacesError(this.message);

  @override
  List<Object> get props => [message];
}

class LastSearchedCityLoaded extends PlacesState {
  final String? cityName;

  const LastSearchedCityLoaded(this.cityName);

  @override
  List<Object?> get props => [cityName];
}