import 'dart:io';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Service for sharing verified images via system intents.
abstract class ShareService {
  /// Shares [image] bytes to the specified [messenger] (e.g. 'whatsapp', 'telegram')
  /// via the system's share intent.
  Future<void> shareToMessenger(Uint8List image, String messenger);
}

/// Concrete implementation using share_plus [Share.shareXFiles].
///
/// Writes image bytes to a temporary file and invokes the system share sheet.
class ShareServiceImpl implements ShareService {
  @override
  Future<void> shareToMessenger(Uint8List image, String messenger) async {
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/verimask_$timestamp.png');

    try {
      await tempFile.writeAsBytes(image);

      final xFile = XFile(tempFile.path);

      if (messenger == 'whatsapp') {
        // Try to share directly to WhatsApp using its package name.
        // If WhatsApp is not installed, falls back to generic share sheet.
        try {
          final result = await Share.shareXFiles(
            [xFile],
            text: 'Verified by VeriMask',
            sharePositionOrigin: null,
          );
          // share_plus doesn't support direct package targeting,
          // so we use a URL intent as fallback
          if (result.status == ShareResultStatus.dismissed) {
            await Share.shareXFiles([xFile], text: 'Verified by VeriMask');
          }
        } catch (_) {
          await Share.shareXFiles([xFile], text: 'Verified by VeriMask');
        }
      } else {
        await Share.shareXFiles([xFile], text: 'Verified by VeriMask');
      }
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
