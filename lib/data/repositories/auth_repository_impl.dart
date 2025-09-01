import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/hive_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HiveService hiveService;

  AuthRepositoryImpl({required this.hiveService});

  @override
  Future<User> loginAsGuest(String username) async {
    try {
      if (username.isEmpty) {
        throw ValidationException('Username cannot be empty');
      }

      final user = UserModel.guest(username);
      await hiveService.saveUser(user);
      return user;
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } catch (e) {
      throw CacheFailure('Failed to login as guest: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return hiveService.getCurrentUser();
    } catch (e) {
      throw CacheFailure('Failed to get current user: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await hiveService.clearAll();
    } catch (e) {
      throw CacheFailure('Failed to logout: $e');
    }
  }
}