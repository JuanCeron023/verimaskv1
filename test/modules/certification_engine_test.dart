import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/modules/certification_engine.dart';
import 'package:verimask/services/secure_storage_service.dart';

class FakeSecureStorage implements SecureStorageService {
  final Map<String, dynamic> _store = {};

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async =>
      _store[key] = Map<String, dynamic>.from(value);
  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final val = _store[key];
    if (val == null) return null;
    return Map<String, dynamic>.from(val as Map);
  }
  @override
  Future<void> writeString(String key, String value) async =>
      _store[key] = value;
  @override
  Future<String?> readString(String key) async => _store[key] as String?;
  @override
  Future<void> writeJsonList(
          String key, List<Map<String, dynamic>> value) async =>
      _store[key] = value;
  @override
  Future<List<Map<String, dynamic>>?> readJsonList(String key) async =>
      _store[key] as List<Map<String, dynamic>>?;
  @override
  Future<void> delete(String key) async => _store.remove(key);
  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);
}

CertificationEngineImpl _createEngine({
  FakeSecureStorage? storage,
  DateTime Function()? clock,
}) {
  return CertificationEngineImpl(
    storage: storage ?? FakeSecureStorage(),
    clock: clock,
  );
}

void main() {
  group('CertificationEngine', () {
    group('initializeKeyPair', () {
      test('generates and stores key pair on first call', () async {
        final storage = FakeSecureStorage();
        final engine = _createEngine(storage: storage);

        await engine.initializeKeyPair();

        expect(await storage.readString('verimask_rsa_private_key'), isNotNull);
        expect(await storage.readString('verimask_rsa_public_key'), isNotNull);
      });
    });

    group('generateVerificationCode', () {
      test('returns 8-char uppercase hex string', () {
        final engine = _createEngine();
        final data = Uint8List.fromList([1, 2, 3]);
        final code = engine.generateVerificationCode(data);

        expect(code.length, equals(8));
        expect(code, matches(RegExp(r'^[0-9A-F]{8}$')));
      });
    });

    group('certify', () {
      test('returns CertifiedPhoto with all fields populated', () async {
        final now = DateTime(2025, 6, 15, 10, 0, 0);
        final storage = FakeSecureStorage();
        final engine = _createEngine(storage: storage, clock: () => now);
        await engine.initializeKeyPair();

        final image = Uint8List.fromList([10, 20, 30, 40, 50]);
        final result = await engine.certify(image);

        expect(result.imageData, equals(image));
        expect(result.sha256Hash, equals(sha256.convert(image).toString()));
        expect(result.verificationCode.length, equals(8));
        expect(result.timestamp, equals(now));
      });
    });
  });
}
