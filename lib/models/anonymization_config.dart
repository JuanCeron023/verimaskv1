/// Configuración del pipeline de anonimización visual.
/// Permite ajustar parámetros sin cambiar código.
class AnonymizationConfig {
  // Face blur
  /// Factor de expansión del bounding box facial hacia abajo (mentón).
  final double faceExpandDown;

  /// Factor de expansión del bounding box facial a los lados.
  final double faceExpandSide;

  /// Factor de expansión del bounding box facial hacia arriba.
  final double faceExpandUp;

  /// Tamaño del kernel para Gaussian blur en la zona exterior de la cara.
  final int faceBlurKernelSize;

  /// Número de pasadas de Gaussian blur en la zona exterior.
  final int faceBlurPasses;

  /// Tamaño del kernel para Gaussian blur fuerte en la zona central
  /// (ojos, nariz, boca, mentón). Debe ser mayor que faceBlurKernelSize.
  final int faceInnerBlurKernelSize;

  /// Número de pasadas de Gaussian blur fuerte en la zona central.
  final int faceInnerBlurPasses;

  /// Ratio de feathering para transición gradual en bordes del blur facial.
  final double faceFeatherRatio;

  // Hair processing
  /// Factor de extensión vertical hacia arriba para la región de cabello
  /// (proporción de la altura del face bbox).
  final double hairExtendUp;

  /// Factor de extensión lateral para la región de cabello
  /// (proporción del ancho del face bbox).
  final double hairExtendSide;

  /// Diámetro del bilateral filter para suavizado de cabello.
  final int bilateralDiameter;

  /// Sigma de color para bilateral filter.
  final double bilateralSigmaColor;

  /// Sigma espacial para bilateral filter.
  final double bilateralSigmaSpace;

  /// Radio de blur ligero adicional para cabello.
  final int hairBlurRadius;

  // Clothing
  /// Saturación objetivo para conversión HSV grayscale de ropa.
  final double clothingSaturation;

  // Background gradient (BGRA)
  /// Color interior del gradiente radial de fondo [B, G, R, A].
  final List<int> gradientInnerColor;

  /// Color exterior del gradiente radial de fondo [B, G, R, A].
  final List<int> gradientOuterColor;

  // Skin detection (YCrCb ranges)
  /// Valor mínimo de Cr para detección de piel en espacio YCrCb.
  final int crMin;

  /// Valor máximo de Cr para detección de piel en espacio YCrCb.
  final int crMax;

  /// Valor mínimo de Cb para detección de piel en espacio YCrCb.
  final int cbMin;

  /// Valor máximo de Cb para detección de piel en espacio YCrCb.
  final int cbMax;

  // Feathering
  /// Pixels de feathering en la transición persona-fondo.
  final int backgroundFeatherPixels;

  /// Hue objetivo para tinting de ropa (0–180 en espacio HSV de OpenCV).
  /// Default 110 ≈ azul-grisáceo elegante.
  final int clothingTargetHue;

  /// Saturación mínima para el tinting de ropa (0.0–1.0).
  /// Controla cuánta saturación se preserva como mínimo.
  final double clothingMinSaturation;

  /// Saturación máxima para el tinting de ropa (0.0–1.0).
  final double clothingMaxSaturation;

  const AnonymizationConfig({
    this.faceExpandDown = 0.25,
    this.faceExpandSide = 0.15,
    this.faceExpandUp = 0.25,
    this.faceBlurKernelSize = 11,
    this.faceBlurPasses = 1,
    this.faceInnerBlurKernelSize = 71,
    this.faceInnerBlurPasses = 5,
    this.faceFeatherRatio = 0.12,
    this.hairExtendUp = 0.85,
    this.hairExtendSide = 0.20,
    this.bilateralDiameter = 15,
    this.bilateralSigmaColor = 100.0,
    this.bilateralSigmaSpace = 100.0,
    this.hairBlurRadius = 8,
    this.clothingSaturation = 0.55,
    this.clothingTargetHue = 105,
    this.clothingMinSaturation = 0.40,
    this.clothingMaxSaturation = 0.65,
    this.gradientInnerColor = const [195, 185, 175, 255],
    this.gradientOuterColor = const [80, 70, 60, 255],
    this.crMin = 137,
    this.crMax = 168,
    this.cbMin = 80,
    this.cbMax = 122,
    this.backgroundFeatherPixels = 8,
  });
}
