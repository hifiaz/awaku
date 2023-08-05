import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/profile_service.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final ProfileService _profileService;
  ProfileRepository(this._profileService);

  Future<ProfileModel> getUser(String uid) async {
    return await _profileService.user(uid: uid);
  }

  Future<Either<String, bool?>> create(User user) {
    return _profileService.create(user: user);
  }

  Future<Either<String, bool>> update(String uid,
      {required double weight,
      required int height,
      String? name,
      DateTime? dob}) async {
    return _profileService.update(
        uid: uid, name: name, dob: dob, weight: weight, height: height);
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) =>
    ProfileRepository(ref.read(profileServiceProvider));
