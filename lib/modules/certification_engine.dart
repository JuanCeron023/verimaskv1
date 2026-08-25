import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

import '../services/secure_storage_service.dart';

/// Result of certifying an anonymised image.
class CertifiedPhoto {
  final Uint8List imageData;
  final String sha256Hash;
  final String verificationCode;
  final DateTime timestamp;
  final String digitalSignature;

  CertifiedPhoto({
    required this.imageData,
    required this.sha256Hash,
    required this.verificationCode,
    required this.timestamp,
    required this.digitalSignature,
  });
}

/// Storage keys used by [CertificationEngineImpl].
class _Keys {
  static const privateKey = 'verimask_rsa_private_key';
  static const publicKey = 'verimask_rsa_public_key';
}

/// Engine responsible for certifying anonymised images.
abstract class CertificationEngine {
  /// Full certification pipeline.
  Future<CertifiedPhoto> certify(
      Uint8List anonymizedImage,
      {Map<String, int>? faceRect});

  /// Deterministic verification code from image data.
  String generateVerificationCode(Uint8List imageData);

  /// Generates and stores an RSA key pair on first launch.
  Future<void> initializeKeyPair();
}

class CertificationEngineImpl implements CertificationEngine {
  final SecureStorageService _storage;

  final DateTime Function() _now;

  CertificationEngineImpl({
    required SecureStorageService storage,
    DateTime Function()? clock,
  })  : _storage = storage,
        _now = clock ?? DateTime.now;

  @override
  Future<void> initializeKeyPair() async {
    final existing = await _storage.readString(_Keys.privateKey);
    if (existing != null) return;

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        _secureRandom(),
      ));

    final pair = keyGen.generateKeyPair();
    final pub = pair.publicKey as RSAPublicKey;
    final priv = pair.privateKey as RSAPrivateKey;

    await _storage.writeString(
        _Keys.privateKey, _encodePrivateKey(priv));
    await _storage.writeString(
        _Keys.publicKey, _encodePublicKey(pub));
  }

  @override
  String generateVerificationCode(Uint8List imageData) {
    final hash = sha256.convert(imageData).toString();
    return hash.substring(0, 8).toUpperCase();
  }

  @override
  Future<CertifiedPhoto> certify(
      Uint8List anonymizedImage,
      {Map<String, int>? faceRect}) async {
    final timestamp = _now();
    final verificationCode = generateVerificationCode(anonymizedImage);
    final imageHash = sha256.convert(anonymizedImage).toString();

    return CertifiedPhoto(
      imageData: anonymizedImage,
      sha256Hash: imageHash,
      verificationCode: verificationCode,
      timestamp: timestamp,
      digitalSignature: "template_signature",
    );
  }

  static SecureRandom _secureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  String _encodePrivateKey(RSAPrivateKey key) {
    final map = {
      'n': key.modulus.toString(),
      'd': key.privateExponent.toString(),
      'p': key.p.toString(),
      'q': key.q.toString(),
    };
    return jsonEncode(map);
  }

  String _encodePublicKey(RSAPublicKey key) {
    final map = {
      'n': key.modulus.toString(),
      'e': key.publicExponent.toString(),
    };
    return jsonEncode(map);
  }
}
