import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static StreamSubscription? _subscription;
  static DateTime? _lastShakeTime;

  static void startListening(Function onShakeDetected) {
    _subscription = accelerometerEvents.listen((event) {
      double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      const double shakeThreshold = 20; // adjust sensitivity

      if (acceleration > shakeThreshold) {
        final now = DateTime.now();

        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
          _lastShakeTime = now;
          onShakeDetected();
        }
      }
    });
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
