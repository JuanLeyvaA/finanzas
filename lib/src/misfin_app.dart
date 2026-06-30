import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'automation_bridge.dart';
import 'controller.dart';
import 'automation_payload.dart';
import 'currency_theme.dart';
import 'screens/launch_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/shell_screen.dart';
import 'storage.dart';

class MisFinApp extends StatefulWidget {
  const MisFinApp({super.key});

  @override
  State<MisFinApp> createState() => _MisFinAppState();
}

class _MisFinAppState extends State<MisFinApp> with WidgetsBindingObserver {
  late final MisFinController _controller;
  late final Future<_StartupState> _bootstrap;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _bootstrapFinished = false;
  String? _queuedNativeText;
  String? _lastAutomationText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MisFinController(const MisFinStore());
    final incomingText = extractAutomationText(Uri.base);
    final nativeText = AutomationBridge.initialize(_handleNativeText);
    _bootstrap = _controller.load().then((_) async {
      var initialIndex = 0;
      final startupText = incomingText ??
          await nativeText ??
          _queuedNativeText ??
          await _readClipboardText();
      if (startupText != null && startupText.trim().isNotEmpty) {
        final imported = await _captureAutomationText(
          startupText,
          showFeedback: false,
        );
        if (imported) {
          initialIndex = 0;
        } else if (_controller.draft != null) {
          initialIndex = 1;
        }
      }
      _bootstrapFinished = true;
      return _StartupState(initialIndex: initialIndex);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _bootstrapFinished) {
      _captureIncomingOnResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final palette = paletteForCurrency(_controller.profile.currency);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MisFin',
          scaffoldMessengerKey: _scaffoldMessengerKey,
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

  Future<void> _handleNativeText(String text) async {
    if (!_bootstrapFinished) {
      _queuedNativeText = text;
      return;
    }

    await _captureAutomationText(text, showFeedback: true);
  }

  Future<void> _captureIncomingOnResume() async {
    final nativeText = await AutomationBridge.consumePendingText();
    if (nativeText != null && nativeText.isNotEmpty) {
      await _captureAutomationText(nativeText, showFeedback: true);
      return;
    }

    final clipboardText = await _readClipboardText();
    if (clipboardText == null ||
        clipboardText.isEmpty ||
        clipboardText == _lastAutomationText) {
      return;
    }

    await _captureAutomationText(clipboardText, showFeedback: true);
  }

  Future<bool> _captureAutomationText(String text,
      {required bool showFeedback}) async {
    try {
      final normalized = text.trim();
      if (normalized.isEmpty) {
        return false;
      }
      _lastAutomationText = normalized;

      final alreadySaved = _controller.hasExpenseWithRawText(normalized);
      final imported =
          await _controller.ingestText(normalized, autoImport: true);

      if (showFeedback && mounted) {
        final messenger = _scaffoldMessengerKey.currentState;
        if (imported && !alreadySaved) {
          messenger?.showSnackBar(
            const SnackBar(
                content:
                    Text('Se guardo el ultimo gasto copiado automaticamente.')),
          );
        } else if (!imported && _controller.draft != null) {
          messenger?.showSnackBar(
            const SnackBar(
              content: Text(
                'Detectamos un movimiento que necesita una revision rapida.',
              ),
            ),
          );
        }
      }

      return imported;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _readClipboardText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text?.trim();
    } catch (_) {
      return null;
    }
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
            Text('Cargando MisFin...'),
          ],
        ),
      ),
    );
  }
}
