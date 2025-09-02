import 'package:awaku/service/model/profile_model.dart';
import 'package:awaku/service/repository/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// part 'profile_provider.g.dart'; // Commented out due to build issues

// Manual providers to replace @riverpod generated ones
final createProfileProvider = FutureProvider.family<void, User>((ref, user) async {
  await ref.read(profileRepositoryProvider).create(user);
});

final updateProfileProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  await ref.read(profileRepositoryProvider).update(
    params['uid'] as String,
    name: params['name'] as String?,
    dob: params['dob'] as DateTime?,
    enableWater: params['enableWater'] as bool?,
    enableFasting: params['enableFasting'] as bool?,
    gender: params['gender'] as String?,
    weight: params['weight'] as double?,
    height: params['height'] as int?,
  );
});

final fetchUserProvider = FutureProvider<ProfileModel>((ref) async {
  User? user = FirebaseAuth.instance.currentUser;
  final result = await ref.read(profileRepositoryProvider).getUser(user!.uid);
  return result;
});

// Helper function for updateProfileProvider
Future<void> updateProfile(WidgetRef ref, {
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
  final params = {
    'uid': uid,
    if (url != null) 'url': url,
    if (name != null) 'name': name,
    if (dob != null) 'dob': dob,
    if (gender != null) 'gender': gender,
    if (enableWater != null) 'enableWater': enableWater,
    if (enableFasting != null) 'enableFasting': enableFasting,
    if (weight != null) 'weight': weight,
    if (height != null) 'height': height,
  };
  await ref.read(updateProfileProvider(params).future);
}
