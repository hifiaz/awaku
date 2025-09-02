import 'package:awaku/service/auth_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  // Removed email/password authentication methods
  // Only Google and Apple Sign-In are supported now

  Future<Either<String, User?>> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<Either<String, User?>> signInWithApple() {
    return _authService.signInWithApple();
  }

  Future<void> signout() async {
    return await _authService.signout();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});
