import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/sos_service.dart';

class SOSCountdownScreen extends StatefulWidget {
  const SOSCountdownScreen({super.key});

  @override
  State<SOSCountdownScreen> createState() => _SOSCountdownScreenState();
}

class _SOSCountdownScreenState extends State<SOSCountdownScreen> {
  int _secondsLeft = 5;
  Timer? _timer;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCancelled) {
        timer.cancel();
        return;
      }

      if (_secondsLeft == 1) {
        timer.cancel();
        _triggerSOS();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _triggerSOS() async {
    // ✅ STOP if cancelled
    if (_isCancelled) return;
    try {
      await SOSService.triggerSOS();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SOS Sent Successfully")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _cancelSOS() async {
    final correctPin = await StorageService.getPin();
    final pinController = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Enter PIN to Cancel"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "4-digit PIN"),
                  ),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (pinController.text == correctPin) {
                      _isCancelled = true; // ✅ MARK CANCELLED
                      _timer?.cancel(); // stop timer
                      Navigator.pop(context); // close PIN dialog
                      Navigator.pop(context); // go back to Home
                    } else {
                      setStateDialog(() {
                        error = "Incorrect PIN";
                      });
                    }
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SOS ACTIVATING",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 20),
            Text(
              _secondsLeft.toString(),
              style: const TextStyle(
                fontSize: 72,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _cancelSOS,
              child: const Text(
                "CANCEL SOS",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
