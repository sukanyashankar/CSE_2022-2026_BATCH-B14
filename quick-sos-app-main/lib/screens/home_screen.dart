import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'contacts_screen.dart';
import 'sos_countdown_screen.dart';
import 'history_screen.dart';
import '../utils/permissions.dart';
import '../models/contact.dart';
import 'safe_walk_screen.dart';
import '../services/shake_service.dart';
import '../services/sos_service.dart';
import '../main.dart';
import '../services/storage_service.dart';
import 'pre_sos_warning_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _shakeEnabled = false;
  bool _isProcessingShake = false;

  @override
  void initState() {
    super.initState();
    _loadShakePreference();
  }

  Future<void> _loadShakePreference() async {
    final enabled = await StorageService.isShakeEnabled();
    setState(() {
      _shakeEnabled = enabled;
    });

    if (enabled) {
      _startShakeListener();
    }
  }

  void _startShakeListener() {
    ShakeService.startListening(() async {
      if (_isProcessingShake) return;
      _isProcessingShake = true;

      final allowed = await PermissionUtils.requestAll();
      if (!allowed) {
        _isProcessingShake = false;
        return;
      }

      final contactsBox = Hive.box<Contact>('contacts');
      final contacts = contactsBox.values.toList();

      if (contacts.isEmpty) {
        _isProcessingShake = false;
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shake detected! Triggering SOS...")),
      );

      // Trigger SOS
      //await SOSService.triggerSOS();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PreSOSWarningScreen()),
      );

      await Future.delayed(const Duration(seconds: 3));
      _isProcessingShake = false;
    });
  }

  void _stopShakeListener() {
    ShakeService.stopListening();
  }

  @override
  void dispose() {
    _stopShakeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Girls SOS"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () async {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;

              themeNotifier.value = newMode;
              await StorageService.setDarkMode(!isDark);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // 🔴 SOS BUTTON
            GestureDetector(
              onTap: () async {
                final allowed = await PermissionUtils.requestAll();
                if (!allowed) return;

                final contactsBox = Hive.box<Contact>('contacts');
                if (contactsBox.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SOSCountdownScreen()),
                );
              },
              child: Container(
                height: 190,
                width: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 38,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Tap immediately in emergency",
              style: theme.textTheme.bodySmall,
            ),

            const SizedBox(height: 35),

            // SAFE WALK CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.directions_walk, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          "Safe Walk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Set a timer while walking. If you don’t confirm safety, SOS will trigger automatically.",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SafeWalkScreen(),
                            ),
                          );
                        },
                        child: const Text("Start Safe Walk"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SHAKE CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.vibration, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shake to Trigger SOS",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Shake phone strongly to activate SOS.",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _shakeEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _shakeEnabled = value;
                        });

                        await StorageService.setShakeEnabled(value);

                        if (value) {
                          _startShakeListener();
                        } else {
                          _stopShakeListener();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
