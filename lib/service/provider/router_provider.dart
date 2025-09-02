import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/src/auth/login_view.dart';
import 'package:awaku/src/auth/onboarding_view.dart';
import 'package:awaku/src/fasting/fasting_view.dart';
import 'package:awaku/src/home/home_view.dart';
import 'package:awaku/src/settings/device/add_device_view.dart';
import 'package:awaku/src/settings/profile/profile_page.dart';
import 'package:awaku/src/settings/settings_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to track profile completion status
final profileCompletionProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  try {
    final profile = await ref.read(fetchUserProvider.future);
    
    // Check if essential profile data exists
    return profile.name != null && 
           profile.name!.isNotEmpty &&
           profile.gender != null &&
           profile.dob != null &&
           profile.height != null &&
           profile.weight != null;
  } catch (e) {
    // If user document doesn't exist or any error occurs, profile is incomplete
    return false;
  }
});

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: router,
      redirect: (context, state) => router._redirectLogic(state),
      routes: router._routes);
});

class RouterNotifier extends ChangeNotifier {
  bool? _hasCompletedOnboarding;
  bool? _hasCompletedProfile;
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // Only check profile completion after login, not during onboarding
        _checkProfileCompletion();
      } else {
        _hasCompletedProfile = null;
      }
      notifyListeners();
    });

    // Initialize app status
    _initAppStatus();
  }

  void _initAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  }

  void _checkProfileCompletion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _hasCompletedProfile = null;
        return;
      }
      
      final profile = await _ref.read(fetchUserProvider.future);
      
      // Check if essential profile data exists
      _hasCompletedProfile = profile.name != null && 
                            profile.name!.isNotEmpty &&
                            profile.gender != null &&
                            profile.dob != null &&
                            profile.height != null &&
                            profile.weight != null;
      notifyListeners();
    } catch (e) {
      // If user document doesn't exist or any error occurs, profile is incomplete
      _hasCompletedProfile = false;
      notifyListeners();
    }
  }



  String? _redirectLogic(GoRouterState state) {
    User? user = FirebaseAuth.instance.currentUser;
    final areWeLoggingIn = state.uri.path == '/login';
    final areWeOnboarding = state.uri.path == '/onboarding';
    final areWeHome = state.uri.path == '/';

    // Show onboarding first to new users (before login)
    if (_hasCompletedOnboarding == false && !areWeOnboarding && !areWeLoggingIn) {
      return '/onboarding';
    }

    // If user is not logged in
    if (user == null) {
      // If on onboarding and haven't completed it, stay on onboarding
      if (areWeOnboarding && _hasCompletedOnboarding == false) {
        return null; // Stay on onboarding
      }
      
      // If completed onboarding but not logged in, go to login
      if (_hasCompletedOnboarding == true && !areWeLoggingIn) {
        return '/login';
      }
    }

    // If user is logged in
    if (user != null) {
      // If on login page after authentication, redirect to onboarding to complete profile
      if (areWeLoggingIn) {
        return '/onboarding';
      }

      // If already on onboarding page, let user complete it without profile checks
      if (areWeOnboarding) {
        return null; // Stay on onboarding
      }

      // Only check profile completion when trying to access other pages (not onboarding)
      if (_hasCompletedProfile == false) {
        return '/onboarding';
      }

      // If trying to access home and profile is complete, allow access
      if (areWeHome && _hasCompletedOnboarding == true && _hasCompletedProfile == true) {
        return null;
      }
    }

    return null;
  }

  void markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> refreshAppStatus() async {
    _initAppStatus();
  }

  List<GoRoute> get _routes => [
        GoRoute(
          name: 'login',
          builder: (context, state) => const LoginView(),
          path: '/login',
        ),
        GoRoute(
          name: 'onboarding',
          builder: (context, state) => const OnboardingView(),
          path: '/onboarding',
        ),
        GoRoute(
          name: 'home',
          builder: (context, state) => const HomeView(),
          path: '/',
        ),
        GoRoute(
          name: 'fasting',
          builder: (context, state) => const FastingView(),
          path: '/fasting',
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
