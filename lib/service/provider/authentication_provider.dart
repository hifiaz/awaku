import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/provider/states/login_states.dart';
import 'package:awaku/service/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationProvider extends StateNotifier<LoginState> {
  AuthenticationProvider(this.ref) : super(const LoginStateInitial());

  final Ref ref;

  void login(String email, String password) async {
    state = const LoginStateLoading();
    final response =
        await ref.read(authRepositoryProvider).login(email, password);
    state = response.fold(
      (l) => LoginStateError(l.toString()),
      (r) => const LoginStateSuccess(),
    );
  }

  void register(String email, String password) async {
    state = const LoginStateLoading();
    final response =
        await ref.read(authRepositoryProvider).register(email, password);
    state = response.fold(
      (l) => LoginStateError(l.toString()),
      (r) {
        ref.read(profileProvider.notifier).create(r);
        return RegisterStateSuccess(r);
      },
    );
  }

  void logout() async {
    state = const LoginStateLoading();

    try {
      await ref.read(authRepositoryProvider).signout();
      state = const LogoutStateSuccess();
    } catch (e) {
      state = LoginStateError(e.toString());
    }
  }
}

final authenticationProvider =
    StateNotifierProvider<AuthenticationProvider, LoginState>((ref) {
  return AuthenticationProvider(ref);
});
