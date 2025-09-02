import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/favorites_repository.dart';
import '../../../domain/usecases/get_favorites.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository favoritesRepository;
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc({
    required this.favoritesRepository,
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);
    on<ClearFavoritesEvent>(_onClearFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await getFavorites();
      
      // Create favorite status map
      final favoriteStatus = <String, bool>{};
      for (final place in favorites) {
        final placeId = favoritesRepository.generatePlaceId(place);
        favoriteStatus[placeId] = true;
      }
      
      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteStatus: favoriteStatus,
      ));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await toggleFavorite(event.place);
      emit(FavoriteToggled(isFavorite: isFavorite, place: event.place));
      
      // Reload favorites to keep the list updated
      add(LoadFavoritesEvent());
    } catch (e) {
      emit(FavoritesError('Failed to toggle favorite: ${e.toString()}'));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatusEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await favoritesRepository.isFavorite(event.placeId);
      
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final updatedStatus = Map<String, bool>.from(currentState.favoriteStatus);
        updatedStatus[event.placeId] = isFavorite;
        
        emit(currentState.copyWith(favoriteStatus: updatedStatus));
      }
    } catch (e) {
      // Handle error silently for status checks
    }
  }

  Future<void> _onClearFavorites(
    ClearFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await favoritesRepository.clearFavorites();
      emit(const FavoritesLoaded(favorites: []));
    } catch (e) {
      emit(FavoritesError('Failed to clear favorites: ${e.toString()}'));
    }
  }
}