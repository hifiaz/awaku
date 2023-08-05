import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/src/settings/settings_controller.dart';
import 'package:awaku/src/settings/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool isLoading = true;
  late SettingsController controller = SettingsController(SettingsService());
  @override
  void initState() {
    inital();
    super.initState();
  }

  Future<void> inital() async {
    await controller.loadSettings();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(loginControllerProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_box_outlined),
                    title: const Text('Personal Data'),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () => context.push('/setting/add-device'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.device_hub),
                    title: const Text('Devices'),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () => context.push('/setting/add-device'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Themes'),
                    trailing: DropdownButton<ThemeMode>(
                      underline: const SizedBox(),
                      // Read the selected themeMode from the controller
                      value: controller.themeMode,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: (val) {
                        controller.updateThemeMode(val);
                        inital();
                      },
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
                      ref.read(loginControllerProvider.notifier).logout();
                    },
                  ),
                ],
              ));
  }
}
