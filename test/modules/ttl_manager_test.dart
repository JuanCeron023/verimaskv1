import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/modules/ttl_manager.dart';

void main() {
  group('TTLManagerImpl', () {
    late DateTime currentTime;
    late TTLManagerImpl manager;

    setUp(() {
      currentTime = DateTime(2025, 6, 15, 12, 0, 0);
      manager = TTLManagerImpl(clock: () => currentTime);
    });

    test('registerPhoto stores photo and isExpired returns false when fresh',
        () async {
      await manager.registerPhoto('p1', currentTime);
      expect(manager.isExpired('p1'), isFalse);
    });

    test('isExpired returns true for unknown photoId', () {
      expect(manager.isExpired('unknown'), isTrue);
    });

    test('isExpired returns false when less than 2 hours have passed', () async {
      final createdAt = currentTime.subtract(const Duration(hours: 1, minutes: 59));
      await manager.registerPhoto('p1', createdAt);
      expect(manager.isExpired('p1'), isFalse);
    });

    test('isExpired returns true when exactly 2 hours have passed', () async {
      final createdAt = currentTime.subtract(const Duration(hours: 2));
      await manager.registerPhoto('p1', createdAt);
      expect(manager.isExpired('p1'), isTrue);
    });

    test('isExpired returns true when more than 2 hours have passed', () async {
      final createdAt = currentTime.subtract(const Duration(hours: 3));
      await manager.registerPhoto('p1', createdAt);
      expect(manager.isExpired('p1'), isTrue);
    });

    test('getRemainingTTL returns correct remaining duration', () async {
      final createdAt = currentTime.subtract(const Duration(minutes: 30));
      await manager.registerPhoto('p1', createdAt);
      final remaining = manager.getRemainingTTL('p1');
      expect(remaining, const Duration(hours: 1, minutes: 30));
    });

    test('getRemainingTTL returns Duration.zero for expired photo', () async {
      final createdAt = currentTime.subtract(const Duration(hours: 3));
      await manager.registerPhoto('p1', createdAt);
      expect(manager.getRemainingTTL('p1'), Duration.zero);
    });

    test('getRemainingTTL returns Duration.zero for unknown photo', () {
      expect(manager.getRemainingTTL('unknown'), Duration.zero);
    });

    test('purgeExpiredPhotos removes only expired photos', () async {
      final fresh = currentTime.subtract(const Duration(minutes: 30));
      final expired = currentTime.subtract(const Duration(hours: 3));

      await manager.registerPhoto('fresh1', fresh);
      await manager.registerPhoto('expired1', expired);
      await manager.registerPhoto('expired2', expired);

      final purged = await manager.purgeExpiredPhotos();
      expect(purged, 2);
      expect(manager.photoCount, 1);
      expect(manager.isExpired('fresh1'), isFalse);
    });

    test('purgeExpiredPhotos returns 0 when no photos are expired', () async {
      await manager.registerPhoto('p1', currentTime);
      await manager.registerPhoto('p2', currentTime);

      final purged = await manager.purgeExpiredPhotos();
      expect(purged, 0);
      expect(manager.photoCount, 2);
    });

    test('purgeExpiredPhotos handles empty state', () async {
      final purged = await manager.purgeExpiredPhotos();
      expect(purged, 0);
    });
  });
}
