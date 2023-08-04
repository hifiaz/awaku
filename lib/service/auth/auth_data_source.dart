import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final Ref ref; // use for reading other providers

  AuthDataSource(this._firebaseAuth, this.ref);

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
      return right(response.user);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to Login');
    }
  }

  Future<void> logout() async {
    return await _firebaseAuth.signOut();
  }

  // Future<Either<String, User>> continueWithGoogle() async {
  //   try {
  //     final googleSignIn =
  //         GoogleSignIn(clientId: DefaultFirebaseOptions.ios.iosClientId);
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );
  //       final response = await _firebaseAuth.signInWithCredential(credential);
  //       return right(response.user!);
  //     } else {
  //       return left('Unknown Error');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     return left(e.message ?? 'Unknow Error');
  //   }
  // }
}

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(ref.read(firebaseAuthProvider), ref),
);
