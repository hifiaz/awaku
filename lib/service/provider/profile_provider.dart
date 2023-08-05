import 'package:awaku/service/provider/states/profile_states.dart';
import 'package:awaku/service/repository/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

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
    required double weight,
    required int height,
  }) async {
    state = const ProfileStateLoading();
    Logger().d('first $uid');
    final response = await ref
        .read(profileRepositoryProvider)
        .update(uid, weight: weight, height: height);
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
