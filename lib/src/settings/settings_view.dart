import 'package:awaku/service/provider/authentication_provider.dart';
import 'package:awaku/service/provider/health_provider.dart';
import 'package:awaku/service/provider/profile_provider.dart';
import 'package:awaku/service/provider/states/profile_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool enableWater = true;
  @override
  void initState() {
    initialData();
    super.initState();
  }

  void initialData() {
    final profile = ref.read(fetchUserProvider);
    if (profile.hasValue) {
      enableWater = profile.value?.waterEnable ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(fetchUserProvider);
    final healthAuth = ref.watch(healthAuthNotifierProvider);
    ref.listen(profileProvider, (previous, next) {
      if (next is ProfileStateError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error),
          behavior: SnackBarBehavior.floating,
        ));
      } else if (next is ProfileStateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Changes updated'),
          behavior: SnackBarBehavior.floating,
        ));
        ref.invalidate(fetchUserProvider);
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.account_box_outlined),
              title: Text(AppLocalizations.of(context)!.personalData),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: () => context.push('/setting/profile'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.feature,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_dining),
              title: Text(AppLocalizations.of(context)!.intermittentFasting),
              trailing: Switch(value: false, onChanged: (val) {}),
            ),
            ListTile(
              leading: const Icon(Icons.local_drink),
              title: Text(AppLocalizations.of(context)!.water),
              trailing: Switch(
                  value: enableWater,
                  onChanged: (val) {
                    setState(() => enableWater = !enableWater);
                    ref.read(profileProvider.notifier).update(
                          uid: user.value!.uid!,
                          enableWater: val,
                        );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.tools,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.device_hub),
              title: Text(AppLocalizations.of(context)!.devices),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: () => context.push('/setting/add-device'),
            ),
            ListTile(
              leading: const Icon(Icons.healing_outlined),
              title: Text(AppLocalizations.of(context)!.health),
              trailing: healthAuth.value == true
                  ? Text(
                      AppLocalizations.of(context)!.connected,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.green),
                    )
                  : ElevatedButton(
                      onPressed: requestAuthHealt,
                      child: Text(
                        AppLocalizations.of(context)!.requestAuth,
                      )),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.logout),
              trailing: const Icon(Icons.logout),
              onTap: () {
                ref.read(authenticationProvider.notifier).logout();
              },
            ),
          ],
        ));
  }

  void requestAuthHealt() async {
    try {
      await ref.read(healthProvider).auth();
      if (context.mounted) context.go('/');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
