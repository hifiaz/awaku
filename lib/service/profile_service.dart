import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/provider/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_service.g.dart';

class ProfileService {
  final FirebaseFirestore _firebaseStore;

  ProfileService(this._firebaseStore);

  Future<ProfileModel> user({required String uid}) async {
    try {
      final data = await _firebaseStore.collection('user').doc(uid).get();
      ProfileModel profile = ProfileModel.fromJson(data.data()!);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw '$e';
    }
  }

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
    DateTime? dob,
    required double weight,
    required int height,
  }) async {
    try {
      var params = {
        'name': name,
        'photoUrl': url,
        'weight': weight,
        'height': height,
        'dob': dob,
      };
      params.removeWhere((key, value) => value == null);
      await _firebaseStore.collection('user').doc(uid).update(params);
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Something Wrong on Create Account');
    }
  }
}

@riverpod
ProfileService profileService(ProfileServiceRef ref) =>
    ProfileService(ref.read(firebaseFirestoreProvider));
