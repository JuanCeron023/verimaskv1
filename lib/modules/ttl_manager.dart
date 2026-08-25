import 'dart:async';

/// Abstract interface for managing photo TTL (Time To Live).
///
/// Photos expire 2 hours after creation and are purged automatically.
abstract class TTLManager {
  /// Registers a photo with its creation timestamp.
  Future<void> registerPhoto(String photoId, DateTime createdAt);

  /// Verifies and removes all expired photos (>= 2h).
  /// Returns the number of purged photos.
  Future<int> purgeExpiredPhotos();

  /// Returns the remaining time-to-live for a photo.
  /// Returns [Duration.zero] if expired or not found.
  Duration getRemainingTTL(String photoId);

  /// Returns true if the photo has expired (>= 2h since creation).
  bool isExpired(String photoId);
}

/// Concrete in-memory implementation of [TTLManager].
///
/// Uses an injectable [clock] function for testability.
/// TTL is fixed at 2 hours from creation.
class TTLManagerImpl implements TTLManager {
  static const ttlDuration = Duration(hours: 2);

  final Map<String, DateTime> _photos = {};
  final DateTime Function() _clock;

  TTLManagerImpl({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  @override
  Future<void> registerPhoto(String photoId, DateTime createdAt) async {
    _photos[photoId] = createdAt;
  }

  @override
  bool isExpired(String photoId) {
    final createdAt = _photos[photoId];
    if (createdAt == null) return true;
    return _clock().difference(createdAt) >= ttlDuration;
  }

  @override
  Duration getRemainingTTL(String photoId) {
    final createdAt = _photos[photoId];
    if (createdAt == null) return Duration.zero;
    final elapsed = _clock().difference(createdAt);
    if (elapsed >= ttlDuration) return Duration.zero;
    return ttlDuration - elapsed;
  }

  @override
  Future<int> purgeExpiredPhotos() async {
    final expiredIds = _photos.keys.where((id) => isExpired(id)).toList();
    for (final id in expiredIds) {
      _photos.remove(id);
    }
    return expiredIds.length;
  }

  /// Returns the number of currently registered (non-purged) photos.
  int get photoCount => _photos.length;
}
