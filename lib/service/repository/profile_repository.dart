import 'package:awaku/service/profile_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final ProfileService _profileService;
  ProfileRepository(this._profileService);

  Future<Either<String, bool?>> create(User user) {
    return _profileService.create(user: user);
  }

  Future<Either<String, bool>> update(String uid,
      {required double weight, required int height}) async {
    return _profileService.update(uid: uid, weight: weight, height: height);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(profileServiceProvider));
});
