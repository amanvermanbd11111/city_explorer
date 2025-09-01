import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginAsGuestEvent extends AuthEvent {
  final String username;

  const LoginAsGuestEvent(this.username);

  @override
  List<Object> get props => [username];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class LoginWithFirebaseEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithFirebaseEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignUpWithFirebaseEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithFirebaseEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}