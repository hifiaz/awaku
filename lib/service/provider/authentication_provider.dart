import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Removed email/password authentication providers
// Only Google and Apple Sign-In are supported now

final googleSignInProvider = FutureProvider<void>((ref) async {
  final result = await ref.read(authRepositoryProvider).signInWithGoogle();
  result.fold(
    (l) => throw Exception(l),
    (r) async {
      if (r != null) {
        await ref.read(createProfileProvider(r).future);
      }
    },
  );
});

final appleSignInProvider = FutureProvider<void>((ref) async {
  final result = await ref.read(authRepositoryProvider).signInWithApple();
  result.fold(
    (l) => throw Exception(l),
    (r) async {
      if (r != null) {
        await ref.read(createProfileProvider(r).future);
      }
    },
  );
});

final logoutUserProvider = FutureProvider<void>((ref) async {
  await ref.read(authRepositoryProvider).signout();
});
