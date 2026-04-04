import 'package:hive/hive.dart';

part 'sos_event.g.dart';

@HiveType(typeId: 1)
class SOSEvent extends HiveObject {
  @HiveField(0)
  DateTime time;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double longitude;

  @HiveField(3)
  int contactsCount;

  @HiveField(4)
  String primaryContact;

  SOSEvent({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.contactsCount,
    required this.primaryContact,
  });
}
