import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for obtaining device identification and fingerprint.
///
/// Uses a persisted generated ID stored in secure storage,
/// since accessing the actual Android ID requires platform channels.
abstract class DeviceInfoService {
  /// Obtains the Android ID (or persisted device ID) for this device.
  Future<String> getAndroidId();

  /// Generates a generic device fingerprint for QR encoding.
  Future<String> getDeviceFingerprint();
}

/// Concrete implementation that persists a generated device ID
/// in [FlutterSecureStorage].
class DeviceInfoServiceImpl implements DeviceInfoService {
  static const _androidIdKey = 'verimask_device_id';
  static const _fingerprintKey = 'verimask_device_fingerprint';

  final FlutterSecureStorage _storage;

  DeviceInfoServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String> getAndroidId() async {
    var id = await _storage.read(key: _androidIdKey);
    if (id == null) {
      id = _generateId();
      await _storage.write(key: _androidIdKey, value: id);
    }
    return id;
  }

  @override
  Future<String> getDeviceFingerprint() async {
    var fingerprint = await _storage.read(key: _fingerprintKey);
    if (fingerprint == null) {
      final androidId = await getAndroidId();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final raw = '$androidId-$timestamp';
      fingerprint = sha256.convert(utf8.encode(raw)).toString().substring(0, 16);
      await _storage.write(key: _fingerprintKey, value: fingerprint);
    }
    return fingerprint;
  }

  /// Generates a unique device ID using SHA-256 hash of current timestamp
  /// and a random-like seed.
  String _generateId() {
    final seed = '${DateTime.now().microsecondsSinceEpoch}-verimask';
    return sha256.convert(utf8.encode(seed)).toString();
  }
}
