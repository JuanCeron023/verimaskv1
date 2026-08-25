import '../modules/image_processor.dart';

/// Resultado del pipeline de anonimización visual.
/// Contiene la imagen procesada, warnings de etapas con degradación graceful,
/// y el tiempo total de procesamiento.
class AnonymizationResult {
  final ImageData anonymizedImage;
  final List<String> warnings;
  final Duration processingTime;
  /// Whether the anonymization completed successfully.
  /// False if a critical stage (face blur) failed irrecoverably.
  final bool success;

  AnonymizationResult({
    required this.anonymizedImage,
    this.warnings = const [],
    this.processingTime = Duration.zero,
    this.success = true,
  });
}
