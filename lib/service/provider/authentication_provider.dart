import 'package:awaku/service/auth/auth_data_source.dart';
import 'package:awaku/service/auth/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<AuthenticationState> {
  AuthNotifier(this._dataSource) : super(const AuthenticationState.initial());

  final AuthDataSource _dataSource;

  Future<void> login({required String email, required String password}) async {
    state = const AuthenticationState.loading();
    final response = await _dataSource.login(email: email, password: password);
    state = response.fold(
      (error) => AuthenticationState.unauthenticated(message: error),
      (response) => AuthenticationState.authenticated(user: response!),
    );
  }

  Future<void> signup({required String email, required String password}) async {
    state = const AuthenticationState.loading();
    final response = await _dataSource.signup(email: email, password: password);
    state = response.fold(
      (error) => AuthenticationState.unauthenticated(message: error),
      (response) => AuthenticationState.authenticated(user: response),
    );
  }

  Future<void> logout() async {
    await _dataSource.logout();
  }

  // Future<void> continueWithGoogle() async {
  //   state = const AuthenticationState.loading();
  //   final response = await _dataSource.continueWithGoogle();
  //   state = response.fold(
  //     (error) => AuthenticationState.unauthenticated(message: error),
  //     (response) => AuthenticationState.authenticated(user: response),
  //   );
  // }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthenticationState>(
  (ref) => AuthNotifier(ref.read(authDataSourceProvider)),
);
