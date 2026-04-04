import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sos_event.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<SOSEvent>('sos_history');

    return Scaffold(
      appBar: AppBar(title: const Text("SOS History")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<SOSEvent> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No SOS events yet"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final event = box.getAt(index)!;
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(
                  "SOS at ${event.time.toLocal()}",
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  "Contacts: ${event.contactsCount}\nPrimary: ${event.primaryContact}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
