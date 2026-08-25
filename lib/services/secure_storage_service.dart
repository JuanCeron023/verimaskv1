import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for reading/writing
/// encrypted JSON data (embeddings, keys, etc.).
abstract class SecureStorageService {
  /// Writes a JSON-serializable [value] under [key].
  Future<void> writeJson(String key, Map<String, dynamic> value);

  /// Reads a JSON map stored under [key]. Returns null if not found.
  Future<Map<String, dynamic>?> readJson(String key);

  /// Writes a raw string [value] under [key].
  Future<void> writeString(String key, String value);

  /// Reads a raw string stored under [key]. Returns null if not found.
  Future<String?> readString(String key);

  /// Writes a list of JSON maps under [key].
  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value);

  /// Reads a list of JSON maps stored under [key]. Returns null if not found.
  Future<List<Map<String, dynamic>>?> readJsonList(String key);

  /// Deletes the value stored under [key].
  Future<void> delete(String key);

  /// Returns true if a value exists for [key].
  Future<bool> containsKey(String key);
}

/// Concrete implementation backed by [FlutterSecureStorage].
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _storage.write(key: key, value: jsonString);
  }

  @override
  Future<Map<String, dynamic>?> readJson(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<void> writeString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> readString(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final jsonString = jsonEncode(value);
    await _storage.write(key: key, value: jsonString);
  }

  @override
  Future<List<Map<String, dynamic>>?> readJsonList(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>().toList();
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
