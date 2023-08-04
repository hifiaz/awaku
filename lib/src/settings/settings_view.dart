import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/src/auth/login_view.dart';
import 'package:awaku/src/settings/device/add_device_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: user.when(
        initial: () => const SizedBox(),
        unauthenticated: (message) => const Center(child: Text('Please Login')),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        authenticated: (user) {
          return Column(
            children: [
              Text('${user.email}'),
              ListTile(
                title: const Text('Add Device'),
                trailing: const Icon(Icons.arrow_forward_ios_outlined),
                onTap: () => Navigator.restorablePushNamed(
                    context, AddDeviceView.routeName),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                // Glue the SettingsController to the theme selection DropdownButton.
                //
                // When a user selects a theme from the dropdown list, the
                // SettingsController is updated, which rebuilds the MaterialApp.
                child: DropdownButton<ThemeMode>(
                  isExpanded: true,
                  // Read the selected themeMode from the controller
                  value: controller.themeMode,
                  // Call the updateThemeMode method any time the user selects a theme.
                  onChanged: controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
              ),
              ListTile(
                title: const Text('Log Out'),
                trailing: const Icon(Icons.logout),
                onTap: () {
                  ref.read(authNotifierProvider.notifier).logout();
                  Navigator.pushReplacementNamed(context, LoginView.routeName);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
