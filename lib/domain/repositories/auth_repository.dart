import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> loginAsGuest(String username);
  Future<User?> getCurrentUser();
  Future<void> logout();
}