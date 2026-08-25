import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verimask/app_controller.dart';
import 'package:verimask/di/service_locator.dart';
import 'package:verimask/l10n/app_localizations.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/screens/camera_screen.dart';
import 'package:verimask/screens/onboarding_screen.dart';
import 'package:verimask/screens/splash_screen.dart';
import 'package:verimask/services/device_info_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  await setupDependencies();
  
  runApp(const VeriMaskApp());
}

class VeriMaskApp extends StatelessWidget {
  final DeviceInfoService? deviceInfoService;
  final TTLManager? ttlManager;

  const VeriMaskApp({
    super.key,
    this.deviceInfoService,
    this.ttlManager,
  });

  static const _monoFont = 'monospace';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeriMask Starter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.greenAccent.shade400,
          secondary: Colors.cyanAccent.shade400,
          surface: const Color(0xFF121212),
          error: Colors.redAccent.shade200,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: ThemeData.dark().textTheme.copyWith(
              headlineLarge: const TextStyle(
                fontFamily: _monoFont,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: const TextStyle(
                fontFamily: _monoFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: const TextStyle(fontSize: 18, height: 1.5),
              bodyMedium: const TextStyle(fontSize: 16, height: 1.4),
              labelLarge: const TextStyle(
                fontFamily: _monoFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: _monoFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: _monoFont,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/camera': (context) => const CameraScreen(),
      },
      home: VeriMaskHome(
        deviceInfoService: deviceInfoService,
        ttlManager: ttlManager,
      ),
    );
  }
}

class VeriMaskHome extends StatefulWidget {
  final DeviceInfoService? deviceInfoService;
  final TTLManager? ttlManager;

  const VeriMaskHome({
    super.key,
    this.deviceInfoService,
    this.ttlManager,
  });

  @override
  State<VeriMaskHome> createState() => VeriMaskHomeState();
}

@visibleForTesting
class VeriMaskHomeState extends State<VeriMaskHome> {
  AppController? _controller;
  Widget? _resolvedScreen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingDone) {
      if (!mounted) return;
      setState(() {
        _resolvedScreen = const OnboardingScreen();
        _isLoading = false;
      });
      return;
    }

    final ttlManager = widget.ttlManager ?? getIt<TTLManager>();

    _controller = AppController(
      ttlManager: ttlManager,
      onRouteResolved: (route) {
        if (!mounted) return;
        setState(() {
          _resolvedScreen = const CameraScreen();
          _isLoading = false;
        });
      },
    );

    _controller!.startListening();
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _resolvedScreen ?? const CameraScreen(),
    );
  }
}
