import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart';

abstract class AuthRepository {
  // Existing methods
  Future<User> loginAsGuest(String username);
  Future<User?> getCurrentUser();
  Future<void> logout();
  
  // Firebase Auth methods
  Stream<firebase_auth.User?> get authStateChanges;
  firebase_auth.User? get currentFirebaseUser;
  bool get isAuthenticated;
  Future<firebase_auth.UserCredential?> signInAnonymously();
  Future<firebase_auth.UserCredential?> signInWithEmailAndPassword(String email, String password);
  Future<firebase_auth.UserCredential?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}