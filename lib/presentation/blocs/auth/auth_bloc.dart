import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_guest.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final LoginGuest loginGuest;

  AuthBloc({
    required this.authRepository,
    required this.loginGuest,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginAsGuestEvent>(_onLoginAsGuest);
    on<LogoutEvent>(_onLogout);
    on<LoginWithFirebaseEvent>(_onLoginWithFirebase);
    on<SignUpWithFirebaseEvent>(_onSignUpWithFirebase);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginAsGuest(
    LoginAsGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await loginGuest(event.username);
      emit(AuthAuthenticated(user));
    } on ValidationFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to login: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout: ${e.toString()}'));
    }
  }

  Future<void> _onLoginWithFirebase(
    LoginWithFirebaseEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      
      if (result != null && result.user != null) {
        // Create a local user model from Firebase user
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Failed to get user data'));
        }
      } else {
        emit(AuthError('Failed to sign in with Firebase'));
      }
    } catch (e) {
      emit(AuthError('Sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpWithFirebase(
    SignUpWithFirebaseEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await authRepository.createUserWithEmailAndPassword(
        event.email,
        event.password,
      );
      
      if (result != null && result.user != null) {
        // Create a local user model from Firebase user
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Failed to get user data'));
        }
      } else {
        emit(AuthError('Failed to create Firebase account'));
      }
    } catch (e) {
      emit(AuthError('Sign up failed: ${e.toString()}'));
    }
  }
}