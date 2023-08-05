import 'package:awaku/service/auth_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Future<Either<String, User?>> login(String email, String password) {
    return _authService.login(email: email, password: password);
  }

  Future<Either<String, User>> register(String email, String password) async {
    return _authService.signup(email: email, password: password);
  }

  Future<void> signout() async {
    return await _authService.signout();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});
