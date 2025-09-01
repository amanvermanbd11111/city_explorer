import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginGuest {
  final AuthRepository repository;

  LoginGuest(this.repository);

  Future<User> call(String username) async {
    if (username.trim().isEmpty) {
      throw Exception('Username cannot be empty');
    }
    
    return await repository.loginAsGuest(username.trim());
  }
}