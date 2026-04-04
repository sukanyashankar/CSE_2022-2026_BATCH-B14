import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';

import '../models/contact.dart';
import '../models/sos_event.dart'; // ✅ ADD THIS

class SOSService {
  static Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<void> triggerSOS() async {
    final box = Hive.box<Contact>('contacts');
    final contacts = box.values.toList();

    if (contacts.isEmpty) {
      throw Exception("No emergency contacts found");
    }

    final primary = contacts.firstWhere(
      (c) => c.isPrimary,
      orElse: () => contacts.first,
    );

    final position = await _getLocation();
    final lat = position.latitude;
    final lng = position.longitude;

    // ✅ SAVE SOS HISTORY (BEFORE SMS)
    final historyBox = Hive.box<SOSEvent>('sos_history');
    historyBox.add(
      SOSEvent(
        time: DateTime.now(),
        latitude: lat,
        longitude: lng,
        contactsCount: contacts.length,
        primaryContact: primary.phone,
      ),
    );

    final message = Uri.encodeComponent(
      "🚨 SOS ALERT 🚨\n"
      "I am in danger. Please help me.\n\n"
      "📍 Location:\n"
      "https://maps.google.com/?q=$lat,$lng",
    );

    // ✅ Send to all contacts
    final numbers = contacts.map((c) => c.phone).join(',');

    // 1️⃣ Open SMS app
    final smsUri = Uri.parse("sms:$numbers?body=$message");
    await launchUrl(smsUri);

    // 2️⃣ Give user time to press SEND
    await Future.delayed(const Duration(seconds: 6));

    // 3️⃣ Call primary contact
    final callUri = Uri.parse("tel:${primary.phone}");
    await launchUrl(callUri);
  }
}
