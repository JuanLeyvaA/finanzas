import 'package:flutter/material.dart';

import 'controller.dart';
import 'automation_payload.dart';
import 'currency_theme.dart';
import 'screens/launch_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/shell_screen.dart';
import 'storage.dart';

class PresuCoApp extends StatefulWidget {
  const PresuCoApp({super.key});

  @override
  State<PresuCoApp> createState() => _PresuCoAppState();
}

class _PresuCoAppState extends State<PresuCoApp> {
  late final PresuCoController _controller;
  late final Future<_StartupState> _bootstrap;

  @override
  void initState() {
    super.initState();
    _controller = PresuCoController(const PresuCoStore());
    final incomingText = extractAutomationText(Uri.base);
    _bootstrap = _controller.load().then((_) async {
      var initialIndex = 0;
      if (incomingText != null) {
        final imported = await _controller.ingestText(incomingText, autoImport: true);
        initialIndex = imported ? 0 : 1;
      }
      return _StartupState(initialIndex: initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final palette = paletteForCurrency(_controller.profile.currency);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PresuCo',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: palette.seed,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: palette.scaffold,
            appBarTheme: const AppBarTheme(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xDD170B22),
              indicatorColor: palette.accent,
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                (states) => TextStyle(
                  color: states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.white.withOpacity(0.72),
                  fontWeight: states.contains(MaterialState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>(
                (states) => IconThemeData(
                  color: states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.white.withOpacity(0.72),
                ),
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              bodyLarge: TextStyle(fontSize: 16, height: 1.35),
              bodyMedium: TextStyle(fontSize: 14, height: 1.35),
            ),
          ),
          home: FutureBuilder<_StartupState>(
            future: _bootstrap,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _SplashScreen();
              }

              if (_controller.showOnboardingWizard) {
                return OnboardingScreen(controller: _controller);
              }

              if (!_controller.profile.onboardingComplete) {
                return LaunchScreen(controller: _controller);
              }

              return ShellScreen(
                controller: _controller,
                initialIndex: snapshot.data?.initialIndex ?? 0,
              );
            },
          ),
        );
      },
    );
  }
}

class _StartupState {
  const _StartupState({required this.initialIndex});

  final int initialIndex;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando PresuCo...'),
          ],
        ),
      ),
    );
  }
}
