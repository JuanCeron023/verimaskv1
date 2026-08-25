import 'package:flutter/widgets.dart';

import 'modules/ttl_manager.dart';

/// Manages app lifecycle and TTL purge.
///
/// - Initial route → '/camera' (direct access to camera & anonymization).
/// - On app resume → purge expired photos via TTLManager.
class AppController with WidgetsBindingObserver {
  final TTLManager _ttlManager;

  /// Callback invoked when initial route is determined.
  final void Function(String route) onRouteResolved;

  /// Callback invoked after TTL purge completes.
  final void Function(int purgedCount)? onPurgeComplete;

  AppController({
    required TTLManager ttlManager,
    required this.onRouteResolved,
    this.onPurgeComplete,
  })  : _ttlManager = ttlManager;

  /// Initializes the controller: checks enrollment and purges expired photos.
  Future<void> initialize() async {
    await _purgeExpired();
    final route = await resolveInitialRoute();
    onRouteResolved(route);
  }

  /// Returns the initial route. Always defaults to '/camera' in the starter app.
  Future<String> resolveInitialRoute() async {
    return '/camera';
  }

  /// Starts observing app lifecycle events.
  void startListening() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stops observing app lifecycle events.
  void stopListening() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _purgeExpired();
    }
  }

  Future<void> _purgeExpired() async {
    try {
      final count = await _ttlManager.purgeExpiredPhotos();
      onPurgeComplete?.call(count);
    } catch (_) {
      // Non-critical
    }
  }
}
