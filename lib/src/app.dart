import 'package:awaku/service/local_notification_service.dart';
import 'package:awaku/service/provider/router_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialise  localnotification
    LocalNotificationService.initialize();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      Logger().d("Initial Message ${message.toString()}");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Logger().d("Message on App opened ${event.toString()}");
    });
    FirebaseMessaging.onMessage.listen((event) {
      Logger().d("Message when it is termination mode ${event.toString()}");
      if (event.notification != null) {
        LocalNotificationService.display(event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        routerConfig: router);
  }
}
