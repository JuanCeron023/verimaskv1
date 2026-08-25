import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:verimask/l10n/app_localizations.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/services/share_service.dart';

final _getIt = GetIt.instance;

/// Result screen showing the verified anonymized photo with share options.
///
/// Displays the certified photo and provides direct sharing to
/// WhatsApp and Telegram via ShareService. Registers the photo
/// with TTLManager on creation.
///
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6
class ResultScreen extends StatefulWidget {
  /// The certified image bytes to display and share.
  final Uint8List imageData;

  const ResultScreen({super.key, required this.imageData});

  @override
  State<ResultScreen> createState() => ResultScreenState();
}

@visibleForTesting
class ResultScreenState extends State<ResultScreen> {
  bool _isSharing = false;

  late final ShareService _shareService;
  late final TTLManager _ttlManager;

  @override
  void initState() {
    super.initState();
    _shareService = _getIt<ShareService>();
    _ttlManager = _getIt<TTLManager>();

    // Req 4.3: Register photo for auto-expiration (2 hours).
    final photoId = DateTime.now().millisecondsSinceEpoch.toString();
    _ttlManager.registerPhoto(photoId, DateTime.now());
  }

  Future<void> _shareToMessenger(String messenger) async {
    setState(() => _isSharing = true);

    try {
      // Req 4.4, 4.5: Share via real ShareService.
      await _shareService.shareToMessenger(widget.imageData, messenger);
    } catch (e) {
      // Req 4.6: Show error SnackBar without crashing.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.genericError ??
                  'Algo salió mal. Intenta de nuevo.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Success animation + certified photo.
              Expanded(
                child: Column(
                  children: [
                    // Success animation (scale-in check).
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Icon(
                        Icons.check_circle,
                        size: 48,
                        color: theme.colorScheme.primary,
                        key: const Key('result_success_icon'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Req 4.1: Show certified photo using Image.memory.
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          widget.imageData,
                          fit: BoxFit.contain,
                          key: const Key('certified_photo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Watermark text (always in English).
              Text(
                'VERIFIED BY VERIMASK',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 2,
                ),
                key: const Key('watermark_text'),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.resultSharePrompt,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Share buttons.
              _buildShareButtons(l10n, theme),
              const SizedBox(height: 12),
              // "Take another photo" button.
              OutlinedButton.icon(
                key: const Key('take_another_photo_button'),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/camera'),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.takeAnotherPhoto),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButtons(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        ElevatedButton.icon(
          key: const Key('share_whatsapp_button'),
          onPressed: _isSharing ? null : () => _shareToMessenger('whatsapp'),
          icon: const Icon(Icons.chat),
          label: Text(l10n.shareWhatsApp),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          key: const Key('share_telegram_button'),
          onPressed: _isSharing ? null : () => _shareToMessenger('generic'),
          icon: const Icon(Icons.share),
          label: Text(l10n.shareGeneric),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0088CC),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (_isSharing)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
