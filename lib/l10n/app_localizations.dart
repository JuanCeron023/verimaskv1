import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'VeriMask'**
  String get appTitle;

  /// No description provided for @enrollmentTitleSimple.
  ///
  /// In es, this message translates to:
  /// **'Configurar verificación'**
  String get enrollmentTitleSimple;

  /// No description provided for @enrollmentSubtitleSimple.
  ///
  /// In es, this message translates to:
  /// **'Solo toma un momento. Tu información no sale de este dispositivo.'**
  String get enrollmentSubtitleSimple;

  /// No description provided for @enrollmentStep1Simple.
  ///
  /// In es, this message translates to:
  /// **'Mira a la cámara'**
  String get enrollmentStep1Simple;

  /// No description provided for @enrollmentStep2Simple.
  ///
  /// In es, this message translates to:
  /// **'Quédate quieto'**
  String get enrollmentStep2Simple;

  /// No description provided for @enrollmentStep3Simple.
  ///
  /// In es, this message translates to:
  /// **'Gira un poco la cabeza'**
  String get enrollmentStep3Simple;

  /// No description provided for @enrollmentStep4Simple.
  ///
  /// In es, this message translates to:
  /// **'Casi listo...'**
  String get enrollmentStep4Simple;

  /// No description provided for @enrollmentStep5Simple.
  ///
  /// In es, this message translates to:
  /// **'Guardando tu perfil...'**
  String get enrollmentStep5Simple;

  /// No description provided for @enrollmentStartButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar verificación'**
  String get enrollmentStartButton;

  /// No description provided for @enrollmentPrivacyText.
  ///
  /// In es, this message translates to:
  /// **'Tu información nunca sale de tu teléfono'**
  String get enrollmentPrivacyText;

  /// No description provided for @enrollmentFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos crear tu perfil. Intenta de nuevo.'**
  String get enrollmentFailed;

  /// No description provided for @reEnrollmentRequired.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos verificar tu identidad antes de continuar.'**
  String get reEnrollmentRequired;

  /// No description provided for @reEnrollmentBlocked.
  ///
  /// In es, this message translates to:
  /// **'Podrás intentarlo de nuevo en {days} días.'**
  String reEnrollmentBlocked(int days);

  /// No description provided for @reEnrollmentContactSupport.
  ///
  /// In es, this message translates to:
  /// **'Si necesitas ayuda, contacta a soporte.'**
  String get reEnrollmentContactSupport;

  /// No description provided for @cameraTitle.
  ///
  /// In es, this message translates to:
  /// **'Capturar foto'**
  String get cameraTitle;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos acceso a tu cámara para continuar.'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir configuración'**
  String get cameraPermissionSettings;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Se denegó el permiso de cámara. Por favor, otorga el permiso para usar la cámara.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In es, this message translates to:
  /// **'El permiso de cámara fue denegado permanentemente. Por favor, habilítalo en la configuración para continuar.'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @cameraPermissionRestricted.
  ///
  /// In es, this message translates to:
  /// **'El acceso a la cámara está restringido en este dispositivo. Esto puede deberse a controles parentales o políticas del dispositivo.'**
  String get cameraPermissionRestricted;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'La cámara no está disponible en este momento.'**
  String get cameraNotAvailable;

  /// No description provided for @handNotDetected.
  ///
  /// In es, this message translates to:
  /// **'Muestra tu mano en la cámara.'**
  String get handNotDetected;

  /// No description provided for @handGuideSimple.
  ///
  /// In es, this message translates to:
  /// **'Pon tu mano en esta área'**
  String get handGuideSimple;

  /// No description provided for @livenessPrompt.
  ///
  /// In es, this message translates to:
  /// **'Gira un poco la cabeza a la derecha'**
  String get livenessPrompt;

  /// No description provided for @validationFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos verificar tu identidad. Intenta de nuevo.'**
  String get validationFailed;

  /// No description provided for @processingPhoto.
  ///
  /// In es, this message translates to:
  /// **'Procesando tu foto...'**
  String get processingPhoto;

  /// No description provided for @processingError.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal al procesar la foto. Intenta de nuevo.'**
  String get processingError;

  /// No description provided for @captureError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos tomar la foto. Intenta de nuevo.'**
  String get captureError;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intenta de nuevo.'**
  String get genericError;

  /// No description provided for @resultTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu foto verificada'**
  String get resultTitle;

  /// No description provided for @resultAuthentic.
  ///
  /// In es, this message translates to:
  /// **'Foto verificada'**
  String get resultAuthentic;

  /// No description provided for @resultAuthenticDesc.
  ///
  /// In es, this message translates to:
  /// **'Generada por VeriMask, sin alteraciones, hace menos de 2 horas.'**
  String get resultAuthenticDesc;

  /// No description provided for @resultAuthenticTip.
  ///
  /// In es, this message translates to:
  /// **'Tip: Acuerda encontrarte en un lugar público y pide que se presente en un punto visible.'**
  String get resultAuthenticTip;

  /// No description provided for @resultTampered.
  ///
  /// In es, this message translates to:
  /// **'Foto no válida'**
  String get resultTampered;

  /// No description provided for @resultTamperedDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta foto no pasó la verificación de integridad. Podría haber sido alterada.'**
  String get resultTamperedDesc;

  /// No description provided for @resultExpired.
  ///
  /// In es, this message translates to:
  /// **'Foto expirada'**
  String get resultExpired;

  /// No description provided for @resultExpiredDesc.
  ///
  /// In es, this message translates to:
  /// **'Esta foto tiene más de 2 horas. Solicita una foto reciente.'**
  String get resultExpiredDesc;

  /// No description provided for @resultSharePrompt.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu foto verificada'**
  String get resultSharePrompt;

  /// No description provided for @shareWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Compartir en WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareTelegram.
  ///
  /// In es, this message translates to:
  /// **'Compartir en Telegram'**
  String get shareTelegram;

  /// No description provided for @shareGeneric.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get shareGeneric;

  /// No description provided for @verifyQrTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificar foto'**
  String get verifyQrTitle;

  /// No description provided for @verifyQrInstructions.
  ///
  /// In es, this message translates to:
  /// **'Haz captura de pantalla de la foto VeriMask que te compartieron y selecciónala aquí.'**
  String get verifyQrInstructions;

  /// No description provided for @verifyQrNoCode.
  ///
  /// In es, this message translates to:
  /// **'No se encontró un código QR válido.'**
  String get verifyQrNoCode;

  /// No description provided for @verifyQrReadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer el código QR. Intenta con otra imagen.'**
  String get verifyQrReadError;

  /// No description provided for @verifyPhotoButton.
  ///
  /// In es, this message translates to:
  /// **'Verificar foto'**
  String get verifyPhotoButton;

  /// No description provided for @planFreeLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan Gratuito'**
  String get planFreeLabel;

  /// No description provided for @planPremiumLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan Premium'**
  String get planPremiumLabel;

  /// No description provided for @planLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Has usado tus 10 fotos gratuitas este mes. ¡Obtén Premium para fotos ilimitadas!'**
  String get planLimitReached;

  /// No description provided for @planPhotosRemaining.
  ///
  /// In es, this message translates to:
  /// **'{count} fotos restantes este mes'**
  String planPhotosRemaining(int count);

  /// No description provided for @planUpgradeButton.
  ///
  /// In es, this message translates to:
  /// **'Obtener Premium'**
  String get planUpgradeButton;

  /// No description provided for @planUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Fotos ilimitadas'**
  String get planUnlimited;

  /// No description provided for @ttlExpiresSoon.
  ///
  /// In es, this message translates to:
  /// **'Esta foto se eliminará automáticamente en {minutes} minutos.'**
  String ttlExpiresSoon(int minutes);

  /// No description provided for @ttlExpired.
  ///
  /// In es, this message translates to:
  /// **'Esta foto ha expirado y fue eliminada.'**
  String get ttlExpired;

  /// No description provided for @onboardingWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a VeriMask'**
  String get onboardingWelcome;

  /// No description provided for @onboardingDescription.
  ///
  /// In es, this message translates to:
  /// **'Demuestra que eres tú sin mostrar tu rostro completo.'**
  String get onboardingDescription;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In es, this message translates to:
  /// **'Configura tu perfil'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In es, this message translates to:
  /// **'Toma algunas fotos para que la app te reconozca.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In es, this message translates to:
  /// **'Captura tu foto verificada'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In es, this message translates to:
  /// **'Muestra tu mano y mira a la cámara. La app protege tu rostro automáticamente.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In es, this message translates to:
  /// **'Comparte con confianza'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In es, this message translates to:
  /// **'Envía tu foto verificada directamente por WhatsApp o Telegram.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @secureStorageError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu perfil de forma segura. Reinicia la app.'**
  String get secureStorageError;

  /// No description provided for @keyPairError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar la seguridad de tus fotos. Reinicia la app.'**
  String get keyPairError;

  /// No description provided for @segmentationFallback.
  ///
  /// In es, this message translates to:
  /// **'No pudimos procesar el fondo de la foto. Se usará un fondo simple.'**
  String get segmentationFallback;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In es, this message translates to:
  /// **'Acerca de VeriMask'**
  String get aboutTitle;

  /// No description provided for @privacyNote.
  ///
  /// In es, this message translates to:
  /// **'Toda la información se procesa en tu dispositivo. Nada sale de tu teléfono.'**
  String get privacyNote;

  /// No description provided for @buttonRetry.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get buttonRetry;

  /// No description provided for @buttonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get buttonCancel;

  /// No description provided for @buttonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get buttonContinue;

  /// No description provided for @buttonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get buttonDone;

  /// No description provided for @progressDetectingHand.
  ///
  /// In es, this message translates to:
  /// **'Detectando mano...'**
  String get progressDetectingHand;

  /// No description provided for @progressVerifyingIdentity.
  ///
  /// In es, this message translates to:
  /// **'Mueve ligeramente la cabeza a la derecha...'**
  String get progressVerifyingIdentity;

  /// No description provided for @progressProcessingPhoto.
  ///
  /// In es, this message translates to:
  /// **'Procesando foto...'**
  String get progressProcessingPhoto;

  /// No description provided for @progressCertifying.
  ///
  /// In es, this message translates to:
  /// **'Certificando...'**
  String get progressCertifying;

  /// No description provided for @captureButtonSimple.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto anónima VeriMask'**
  String get captureButtonSimple;

  /// No description provided for @takeAnotherPhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar otra foto'**
  String get takeAnotherPhoto;

  /// No description provided for @privacyBadge.
  ///
  /// In es, this message translates to:
  /// **'100% en tu dispositivo'**
  String get privacyBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
