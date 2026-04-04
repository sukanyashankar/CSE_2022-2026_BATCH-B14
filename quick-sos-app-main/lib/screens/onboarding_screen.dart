import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? error;

  void _savePin() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    if (pin.length != 4 || confirmPin.length != 4) {
      setState(() => error = "PIN must be 4 digits");
      return;
    }

    if (pin != confirmPin) {
      setState(() => error = "PINs do not match");
      return;
    }

    await StorageService.savePin(pin);
    await StorageService.setOnboarded(true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Safety PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Create a 4-digit PIN.\nThis PIN is required to cancel SOS.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm PIN"),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _savePin, child: const Text("Save PIN")),
          ],
        ),
      ),
    );
  }
}
