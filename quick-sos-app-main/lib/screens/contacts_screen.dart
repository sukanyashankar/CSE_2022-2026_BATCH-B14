import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Contact>('contacts');

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Contact> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No contacts added"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final contact = box.getAt(index)!;

              return ListTile(
                leading: Icon(
                  contact.isPrimary ? Icons.star : Icons.person,
                  color: contact.isPrimary ? Colors.red : null,
                ),
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => contact.delete(),
                ),
                onTap: () => _setPrimary(contact),
              );
            },
          );
        },
      ),
    );
  }

  void _setPrimary(Contact selected) {
    final box = Hive.box<Contact>('contacts');

    for (var c in box.values) {
      c.isPrimary = false;
      c.save();
    }
    selected.isPrimary = true;
    selected.save();
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final box = Hive.box<Contact>('contacts');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (box.length >= 3) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Maximum 3 contacts allowed")),
                );
                return;
              }

              box.add(Contact(name: nameCtrl.text, phone: phoneCtrl.text));
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
