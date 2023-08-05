import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/service/provider/states/login_states.dart';
import 'package:awaku/src/auth/login_view.dart';
import 'package:awaku/src/home/home_item_details_view.dart';
import 'package:awaku/src/home/home_item_list_view.dart';
import 'package:awaku/src/settings/device/add_device_view.dart';
import 'package:awaku/src/settings/profile/profile_page.dart';
import 'package:awaku/src/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: router,
      redirect: (context, state) => router._redirectLogic(state),
      routes: router._routes);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<LoginState>(
      authenticationProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? _redirectLogic(GoRouterState state) {
    User? user = FirebaseAuth.instance.currentUser;
    final loginState = _ref.read(authenticationProvider);

    // final areWeLoggingIn = state.uri.path == '/login';

    if (loginState is LoginStateInitial && user == null) {
      return '/login';
    }

    if (loginState is RegisterStateSuccess) {
      return '/login';
    }

    if (loginState is LogoutStateSuccess) {
      return '/login';
    }

    // if (areWeLoggingIn) return '/';

    return null;
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: 'login',
          builder: (context, state) => const LoginView(),
          path: '/login',
        ),
        GoRoute(
          name: 'home',
          builder: (context, state) => const HomeItemListView(),
          path: '/',
        ),
        GoRoute(
          name: 'detail',
          builder: (context, state) => const HomeItemDetailsView(),
          path: '/detail',
        ),
        GoRoute(
          name: 'setting',
          builder: (context, state) => const SettingsView(),
          path: '/setting',
          routes: [
            GoRoute(
              name: 'addDevice',
              builder: (context, state) => const AddDeviceView(),
              path: 'add-device',
            ),
            GoRoute(
              name: 'profile',
              builder: (context, state) => const ProfileView(),
              path: 'profile',
            ),
          ],
        ),
      ];
}
