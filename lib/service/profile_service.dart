import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService {
  final FirebaseFirestore _firebaseStore;

  ProfileService(this._firebaseStore);

  Future<Either<String, bool>> create({required User user}) async {
    try {
      await _firebaseStore.collection('user').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL
      });
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something Wrong on Create Account');
    }
  }

  Future<Either<String, bool>> update({
    required String uid,
    String? url,
    String? name,
    required double weight,
    required int height,
  }) async {
    try {
      var params = {
        'name': name,
        'photoUrl': url,
        'weight': weight,
        'height': height,
      };
      params.removeWhere((key, value) => value == null);
      await _firebaseStore.collection('user').doc(uid).update(params);
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something Wrong on Create Account');
    }
  }
}

final profileServiceProvider = Provider<ProfileService>(
    (ref) => ProfileService(ref.read(firebaseFirestoreProvider)));
