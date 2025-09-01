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