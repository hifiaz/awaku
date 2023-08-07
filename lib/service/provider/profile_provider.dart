import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/provider/states/profile_states.dart';
import 'package:awaku/service/repository/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

class ProfileProvider extends StateNotifier<ProfileState> {
  ProfileProvider(this.ref) : super(const ProfileStateInitial());

  final Ref ref;

  void create(User user) async {
    state = const ProfileStateLoading();
    final response = await ref.read(profileRepositoryProvider).create(user);
    state = response.fold(
      (l) => ProfileStateError(l.toString()),
      (r) => const ProfileStateSuccess(),
    );
  }

  void update({
    required String uid,
    String? url,
    String? name,
    DateTime? dob,
    String? gender,
    bool? enableWater,
    bool? enableFasting,
    double? weight,
    int? height,
  }) async {
    state = const ProfileStateLoading();
    final response = await ref.read(profileRepositoryProvider).update(
          uid,
          name: name,
          dob: dob,
          enableWater: enableWater,
          enableFasting: enableFasting,
          gender: gender,
          weight: weight,
          height: height,
        );
    state = response.fold(
      (l) => ProfileStateError(l.toString()),
      (r) => const ProfileStateSuccess(),
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileProvider, ProfileState>((ref) {
  return ProfileProvider(ref);
});

@riverpod
Future<ProfileModel> fetchUser(FetchUserRef ref) async {
  User? user = FirebaseAuth.instance.currentUser;
  final result = await ref.read(profileRepositoryProvider).getUser(user!.uid);
  return result;
}
