import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/providers/theme_provider.dart';
import 'package:fc_app3_dailypad/screens/main_shell.dart';
import 'package:fc_app3_dailypad/screens/onboarding_screen.dart';
import 'package:fc_app3_dailypad/screens/splash_screen.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyPadApp extends StatefulWidget {
  const DailyPadApp({super.key});

  @override
  State<DailyPadApp> createState() => _DailyPadAppState();
}

class _DailyPadAppState extends State<DailyPadApp> {
  _AppScreen _screen = _AppScreen.splash;

  void _onSplashFinished(bool showOnboarding) {
    setState(() {
      _screen =
          showOnboarding ? _AppScreen.onboarding : _AppScreen.main;
    });
  }

  void _onOnboardingComplete() {
    setState(() => _screen = _AppScreen.main);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (_screen) {
              _AppScreen.splash => SplashScreen(
                  key: const ValueKey('splash'),
                  onFinished: _onSplashFinished,
                ),
              _AppScreen.onboarding => OnboardingScreen(
                  key: const ValueKey('onboarding'),
                  onComplete: _onOnboardingComplete,
                ),
              _AppScreen.main => const MainShell(
                  key: ValueKey('main'),
                ),
            },
          ),
        );
      },
    );
  }
}

enum _AppScreen { splash, onboarding, main }
