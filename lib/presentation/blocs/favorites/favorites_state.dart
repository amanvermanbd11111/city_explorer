import 'package:equatable/equatable.dart';
import '../../../domain/entities/place.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Place> favorites;
  final Map<String, bool> favoriteStatus;

  const FavoritesLoaded({
    required this.favorites,
    this.favoriteStatus = const {},
  });

  @override
  List<Object?> get props => [favorites, favoriteStatus];

  FavoritesLoaded copyWith({
    List<Place>? favorites,
    Map<String, bool>? favoriteStatus,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoriteToggled extends FavoritesState {
  final bool isFavorite;
  final Place place;

  const FavoriteToggled({
    required this.isFavorite,
    required this.place,
  });

  @override
  List<Object?> get props => [isFavorite, place];
}