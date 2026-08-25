// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'VeriMask';

  @override
  String get enrollmentTitleSimple => 'Configurar verificación';

  @override
  String get enrollmentSubtitleSimple =>
      'Solo toma un momento. Tu información no sale de este dispositivo.';

  @override
  String get enrollmentStep1Simple => 'Mira a la cámara';

  @override
  String get enrollmentStep2Simple => 'Quédate quieto';

  @override
  String get enrollmentStep3Simple => 'Gira un poco la cabeza';

  @override
  String get enrollmentStep4Simple => 'Casi listo...';

  @override
  String get enrollmentStep5Simple => 'Guardando tu perfil...';

  @override
  String get enrollmentStartButton => 'Iniciar verificación';

  @override
  String get enrollmentPrivacyText =>
      'Tu información nunca sale de tu teléfono';

  @override
  String get enrollmentFailed =>
      'No pudimos crear tu perfil. Intenta de nuevo.';

  @override
  String get reEnrollmentRequired =>
      'Necesitamos verificar tu identidad antes de continuar.';

  @override
  String reEnrollmentBlocked(int days) {
    return 'Podrás intentarlo de nuevo en $days días.';
  }

  @override
  String get reEnrollmentContactSupport =>
      'Si necesitas ayuda, contacta a soporte.';

  @override
  String get cameraTitle => 'Capturar foto';

  @override
  String get cameraPermissionRequired =>
      'Necesitamos acceso a tu cámara para continuar.';

  @override
  String get cameraPermissionSettings => 'Abrir configuración';

  @override
  String get cameraPermissionDenied =>
      'Se denegó el permiso de cámara. Por favor, otorga el permiso para usar la cámara.';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'El permiso de cámara fue denegado permanentemente. Por favor, habilítalo en la configuración para continuar.';

  @override
  String get cameraPermissionRestricted =>
      'El acceso a la cámara está restringido en este dispositivo. Esto puede deberse a controles parentales o políticas del dispositivo.';

  @override
  String get cameraNotAvailable =>
      'La cámara no está disponible en este momento.';

  @override
  String get handNotDetected => 'Muestra tu mano en la cámara.';

  @override
  String get handGuideSimple => 'Pon tu mano en esta área';

  @override
  String get livenessPrompt => 'Gira un poco la cabeza a la derecha';

  @override
  String get validationFailed =>
      'No pudimos verificar tu identidad. Intenta de nuevo.';

  @override
  String get processingPhoto => 'Procesando tu foto...';

  @override
  String get processingError =>
      'Algo salió mal al procesar la foto. Intenta de nuevo.';

  @override
  String get captureError => 'No pudimos tomar la foto. Intenta de nuevo.';

  @override
  String get genericError => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get resultTitle => 'Tu foto verificada';

  @override
  String get resultAuthentic => 'Foto verificada';

  @override
  String get resultAuthenticDesc =>
      'Generada por VeriMask, sin alteraciones, hace menos de 2 horas.';

  @override
  String get resultAuthenticTip =>
      'Tip: Acuerda encontrarte en un lugar público y pide que se presente en un punto visible.';

  @override
  String get resultTampered => 'Foto no válida';

  @override
  String get resultTamperedDesc =>
      'Esta foto no pasó la verificación de integridad. Podría haber sido alterada.';

  @override
  String get resultExpired => 'Foto expirada';

  @override
  String get resultExpiredDesc =>
      'Esta foto tiene más de 2 horas. Solicita una foto reciente.';

  @override
  String get resultSharePrompt => 'Comparte tu foto verificada';

  @override
  String get shareWhatsApp => 'Compartir en WhatsApp';

  @override
  String get shareTelegram => 'Compartir en Telegram';

  @override
  String get shareGeneric => 'Compartir';

  @override
  String get verifyQrTitle => 'Verificar foto';

  @override
  String get verifyQrInstructions =>
      'Haz captura de pantalla de la foto VeriMask que te compartieron y selecciónala aquí.';

  @override
  String get verifyQrNoCode => 'No se encontró un código QR válido.';

  @override
  String get verifyQrReadError =>
      'No pudimos leer el código QR. Intenta con otra imagen.';

  @override
  String get verifyPhotoButton => 'Verificar foto';

  @override
  String get planFreeLabel => 'Plan Gratuito';

  @override
  String get planPremiumLabel => 'Plan Premium';

  @override
  String get planLimitReached =>
      'Has usado tus 10 fotos gratuitas este mes. ¡Obtén Premium para fotos ilimitadas!';

  @override
  String planPhotosRemaining(int count) {
    return '$count fotos restantes este mes';
  }

  @override
  String get planUpgradeButton => 'Obtener Premium';

  @override
  String get planUnlimited => 'Fotos ilimitadas';

  @override
  String ttlExpiresSoon(int minutes) {
    return 'Esta foto se eliminará automáticamente en $minutes minutos.';
  }

  @override
  String get ttlExpired => 'Esta foto ha expirado y fue eliminada.';

  @override
  String get onboardingWelcome => 'Bienvenido a VeriMask';

  @override
  String get onboardingDescription =>
      'Demuestra que eres tú sin mostrar tu rostro completo.';

  @override
  String get onboardingStep1Title => 'Configura tu perfil';

  @override
  String get onboardingStep1Body =>
      'Toma algunas fotos para que la app te reconozca.';

  @override
  String get onboardingStep2Title => 'Captura tu foto verificada';

  @override
  String get onboardingStep2Body =>
      'Muestra tu mano y mira a la cámara. La app protege tu rostro automáticamente.';

  @override
  String get onboardingStep3Title => 'Comparte con confianza';

  @override
  String get onboardingStep3Body =>
      'Envía tu foto verificada directamente por WhatsApp o Telegram.';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get secureStorageError =>
      'No pudimos guardar tu perfil de forma segura. Reinicia la app.';

  @override
  String get keyPairError =>
      'No pudimos preparar la seguridad de tus fotos. Reinicia la app.';

  @override
  String get segmentationFallback =>
      'No pudimos procesar el fondo de la foto. Se usará un fondo simple.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get aboutTitle => 'Acerca de VeriMask';

  @override
  String get privacyNote =>
      'Toda la información se procesa en tu dispositivo. Nada sale de tu teléfono.';

  @override
  String get buttonRetry => 'Intentar de nuevo';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonContinue => 'Continuar';

  @override
  String get buttonDone => 'Listo';

  @override
  String get progressDetectingHand => 'Detectando mano...';

  @override
  String get progressVerifyingIdentity =>
      'Mueve ligeramente la cabeza a la derecha...';

  @override
  String get progressProcessingPhoto => 'Procesando foto...';

  @override
  String get progressCertifying => 'Certificando...';

  @override
  String get captureButtonSimple => 'Tomar foto anónima VeriMask';

  @override
  String get takeAnotherPhoto => 'Tomar otra foto';

  @override
  String get privacyBadge => '100% en tu dispositivo';
}
