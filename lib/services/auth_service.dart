import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/services/firebase_service.dart';

/// Wraps Firebase Authentication.
/// Only functional when [FirebaseService.isAvailable] is true.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Current Firebase user (null when signed out or Firebase unavailable).
  static User? get currentUser =>
      FirebaseService.isAvailable ? _auth.currentUser : null;

  /// Stream of auth-state changes.
  static Stream<User?> get authStateChanges =>
      FirebaseService.isAvailable
          ? _auth.authStateChanges()
          : Stream.value(null);

  /// Register with email & password. Returns the [User] on success.
  static Future<User?> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Sign in with email & password.
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Sign out.
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
