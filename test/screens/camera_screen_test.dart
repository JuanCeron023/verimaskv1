import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:verimask/l10n/app_localizations.dart';
import 'package:verimask/screens/camera_screen.dart';

Widget _buildTestApp({Locale locale = const Locale('es')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.dark(useMaterial3: true),
    home: const CameraScreen(),
  );
}

void main() {
  group('CameraScreen', () {
    testWidgets('renders camera title and capture button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Capturar foto'), findsOneWidget);
      expect(find.byKey(const Key('capture_button')), findsOneWidget);
    }, skip: true);

    testWidgets('capture button is rendered', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('capture_button')),
      );
      expect(button, isNotNull);
    }, skip: true);
  });
}
