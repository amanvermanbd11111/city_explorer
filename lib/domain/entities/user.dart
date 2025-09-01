import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final bool isGuest;

  const User({
    required this.id,
    required this.username,
    this.isGuest = true,
  });

  @override
  List<Object?> get props => [id, username, isGuest];

  factory User.guest(String username) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      isGuest: true,
    );
  }
}