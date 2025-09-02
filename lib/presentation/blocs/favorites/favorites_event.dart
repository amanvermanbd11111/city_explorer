import 'package:equatable/equatable.dart';
import '../../../domain/entities/place.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final Place place;

  const ToggleFavoriteEvent(this.place);

  @override
  List<Object?> get props => [place];
}

class CheckFavoriteStatusEvent extends FavoritesEvent {
  final String placeId;

  const CheckFavoriteStatusEvent(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class ClearFavoritesEvent extends FavoritesEvent {}