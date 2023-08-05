import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Future<Either<String, User>> signup(
      {required String email, required String password}) async {
    try {
      final response = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return right(response.user!);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to Signup.');
    }
  }

  Future<Either<String, User?>> login(
      {required String email, required String password}) async {
    try {
      final response = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger().d('result $response');
      return right(response.user);
    } on FirebaseAuthException catch (e) {
      Logger().e('result e $e');
      return left(e.message ?? 'Failed to Login');
    }
  }

  Future<void> signout() async {
    return await _firebaseAuth.signOut();
  }

  // Future<String> login(String email, String password) async {
  //   return Future.delayed(const Duration(milliseconds: 5000))
  //       .then((onValue) => 'authToken');
  // }

  // Future<String> register(String email, String password) async {
  //   return Future.delayed(const Duration(milliseconds: 5000))
  //       .then((onValue) => 'authToken');
  // }
}

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.read(firebaseAuthProvider)));
