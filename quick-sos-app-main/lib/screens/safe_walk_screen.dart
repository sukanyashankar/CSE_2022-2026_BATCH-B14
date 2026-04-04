import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sos_service.dart';

class SafeWalkScreen extends StatefulWidget {
  const SafeWalkScreen({super.key});

  @override
  State<SafeWalkScreen> createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends State<SafeWalkScreen> {
  int _selectedMinutes = 5;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;

  void _startTimer() {
    setState(() {
      _secondsRemaining = _selectedMinutes * 60;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 1) {
        timer.cancel();
        _triggerSOS();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _triggerSOS() async {
    await SOSService.triggerSOS();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Safe Walk expired. SOS triggered.")),
    );

    Navigator.pop(context);
  }

  void _markSafe() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Safe Walk"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning) ...[
                const Icon(Icons.directions_walk, size: 60, color: Colors.blue),
                const SizedBox(height: 20),

                const Text(
                  "How long will your walk take?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedMinutes,
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text("5 Minutes")),
                      DropdownMenuItem(value: 10, child: Text("10 Minutes")),
                      DropdownMenuItem(value: 15, child: Text("15 Minutes")),
                      DropdownMenuItem(value: 20, child: Text("20 Minutes")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMinutes = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 35),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _startTimer,
                  child: const Text(
                    "Start Safe Walk",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ] else ...[
                const Icon(Icons.shield, size: 60, color: Colors.green),
                const SizedBox(height: 20),

                const Text(
                  "Safe Walk Active",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    "${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:"
                    "${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _markSafe,
                  child: const Text(
                    "I'm Safe",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
