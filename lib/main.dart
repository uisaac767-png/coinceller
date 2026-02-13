import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/app_config_service.dart';
import 'services/wallet_service.dart';
import 'screens/splash_screen.dart';
import 'theme/bybit_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    // In release mode, forward to zone handler so we can log it.
    if (kReleaseMode) {
      Zone.current.handleUncaughtError(
          details.exception, details.stack ?? StackTrace.current);
    } else {
      FlutterError.presentError(details);
    }
  };

  runZonedGuarded<Future<void>>(() async {
    await AppConfigService.initialize();
    await WalletService.initialize();
    runApp(const MyApp());
  }, (error, stack) {
    // Print the error so it appears in adb logcat for release builds.
    // The developer can collect this output to diagnose the crash.
    debugPrint('Uncaught zone error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Celler Wallet',
      theme: BybitTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
