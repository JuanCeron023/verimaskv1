import 'package:flutter/material.dart';

/// Splash screen shown during app initialization.
///
/// Displays the VeriMask logo centered with a subtle loading indicator.
/// Used inline in VeriMaskHome while dependencies load.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/img/logoconpalabras.png',
              width: 200,
              key: const Key('splash_logo'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white12,
                color: Colors.greenAccent.shade400,
                minHeight: 2,
                key: const Key('splash_loading'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
