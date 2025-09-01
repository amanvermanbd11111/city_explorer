import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firebase_auth_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HiveService hiveService;
  final FirebaseAuthService firebaseAuthService;

  AuthRepositoryImpl({
    required this.hiveService,
    required this.firebaseAuthService,
  });

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
      // First check if user is signed in with Firebase
      final firebaseUser = firebaseAuthService.currentUser;
      if (firebaseUser != null) {
        // Create a UserModel from Firebase user and save to local storage
        final userModel = UserModel.fromFirebase(firebaseUser);
        await hiveService.saveUser(userModel);
        return userModel;
      }
      
      // Fall back to local storage for guest users
      return hiveService.getCurrentUser();
    } catch (e) {
      throw CacheFailure('Failed to get current user: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuthService.signOut();
      await hiveService.clearAll();
    } catch (e) {
      throw CacheFailure('Failed to logout: $e');
    }
  }

  // Firebase Auth methods
  @override
  Stream<firebase_auth.User?> get authStateChanges => firebaseAuthService.authStateChanges;

  @override
  firebase_auth.User? get currentFirebaseUser => firebaseAuthService.currentUser;

  @override
  bool get isAuthenticated => firebaseAuthService.isAuthenticated;

  @override
  Future<firebase_auth.UserCredential?> signInAnonymously() async {
    return await firebaseAuthService.signInAnonymously();
  }

  @override
  Future<firebase_auth.UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    return await firebaseAuthService.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<firebase_auth.UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    return await firebaseAuthService.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuthService.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuthService.sendPasswordResetEmail(email);
  }
}