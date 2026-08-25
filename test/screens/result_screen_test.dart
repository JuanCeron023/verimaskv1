import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:verimask/l10n/app_localizations.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/screens/result_screen.dart';
import 'package:verimask/services/share_service.dart';

final _getIt = GetIt.instance;

/// Minimal valid 1x1 white PNG image bytes.
final _testImageData = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // 8-bit RGB
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
  0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
  0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// Fake ShareService for testing.
class _FakeShareService implements ShareService {
  String? lastMessenger;
  bool shouldThrow = false;

  @override
  Future<void> shareToMessenger(Uint8List image, String messenger) async {
    if (shouldThrow) throw Exception('Share failed');
    lastMessenger = messenger;
  }
}

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
    home: ResultScreen(imageData: _testImageData),
  );
}

void main() {
  late _FakeShareService fakeShareService;

  setUp(() {
    fakeShareService = _FakeShareService();
    _getIt.registerSingleton<ShareService>(fakeShareService);
    _getIt.registerSingleton<TTLManager>(TTLManagerImpl());
  });

  tearDown(() async {
    await _getIt.reset();
  });

  group('ResultScreen', () {
    testWidgets('renders result title and share buttons', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Tu foto verificada'), findsOneWidget);
      expect(
        find.byKey(const Key('share_whatsapp_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('share_telegram_button')),
        findsOneWidget,
      );
    });

    testWidgets('renders in English locale', (tester) async {
      await tester.pumpWidget(_buildTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Your verified photo'), findsOneWidget);
      expect(find.text('Share on WhatsApp'), findsOneWidget);
      expect(find.text('Share on Telegram'), findsOneWidget);
    });

    testWidgets('shows watermark text in English always', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Watermark is always in English regardless of locale.
      expect(find.text('VERIFIED BY VERIMASK'), findsAtLeast(1));
    });

    testWidgets('shows share prompt', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Comparte tu foto verificada'),
        findsOneWidget,
      );
    });

    testWidgets('displays certified photo with Image.memory', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('certified_photo')), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
