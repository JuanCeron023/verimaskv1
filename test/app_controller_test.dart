import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/app_controller.dart';
import 'package:verimask/modules/ttl_manager.dart';

class _FakeTTLManager implements TTLManager {
  int purgeCallCount = 0;
  int expiredToReturn;

  _FakeTTLManager({this.expiredToReturn = 0});

  @override
  Future<void> registerPhoto(String photoId, DateTime createdAt) async {}

  @override
  Future<int> purgeExpiredPhotos() async {
    purgeCallCount++;
    return expiredToReturn;
  }

  @override
  Duration getRemainingTTL(String photoId) => Duration.zero;

  @override
  bool isExpired(String photoId) => true;
}

void main() {
  group('AppController', () {
    test('resolves to /camera as default route', () async {
      final ttl = _FakeTTLManager();

      String? resolvedRoute;
      final controller = AppController(
        ttlManager: ttl,
        onRouteResolved: (route) => resolvedRoute = route,
      );

      await controller.initialize();

      expect(resolvedRoute, '/camera');
    });

    test('purges expired photos on initialize', () async {
      final ttl = _FakeTTLManager(expiredToReturn: 3);

      int? purgedCount;
      final controller = AppController(
        ttlManager: ttl,
        onRouteResolved: (_) {},
        onPurgeComplete: (count) => purgedCount = count,
      );

      await controller.initialize();

      expect(ttl.purgeCallCount, 1);
      expect(purgedCount, 3);
    });
  });
}
