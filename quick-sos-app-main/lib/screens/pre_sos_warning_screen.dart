import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/sos_service.dart';

class PreSOSWarningScreen extends StatefulWidget {
  const PreSOSWarningScreen({super.key});

  @override
  State<PreSOSWarningScreen> createState() => _PreSOSWarningScreenState();
}

class _PreSOSWarningScreenState extends State<PreSOSWarningScreen> {
  int _secondsLeft = 5;
  Timer? _timer;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startWarning();
  }

  void _startWarning() {
    _startVibration();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsLeft == 1) {
        timer.cancel();
        await _triggerSOS();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _startVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 300, 500], repeat: 0);
    }
  }

  Future<void> _stopVibration() async {
    Vibration.cancel();
  }

  Future<void> _triggerSOS() async {
    if (_cancelled) return;

    await _stopVibration();
    await SOSService.triggerSOS();

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _cancelSOS() async {
    _cancelled = true;
    _timer?.cancel();
    await _stopVibration();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopVibration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "SOS WILL TRIGGER",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "$_secondsLeft",
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _cancelSOS,
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
