import 'package:flutter/material.dart';
import 'package:girls_sos/models/sos_event.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/contact.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

/// ✅ GLOBAL THEME NOTIFIER
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(SOSEventAdapter());

  // Open boxes
  await Hive.openBox<Contact>('contacts');
  await Hive.openBox<SOSEvent>('sos_history');

  final isOnboarded = await StorageService.isOnboarded();

  // ✅ Load Dark Mode Preference
  final isDark = await StorageService.isDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(GirlsSOSApp(isOnboarded: isOnboarded));
}

class GirlsSOSApp extends StatelessWidget {
  final bool isOnboarded;

  const GirlsSOSApp({super.key, required this.isOnboarded});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: isOnboarded ? const HomeScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}
