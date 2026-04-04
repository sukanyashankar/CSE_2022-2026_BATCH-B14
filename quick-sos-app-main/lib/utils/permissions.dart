import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestAll() async {
    final statuses = await [Permission.location, Permission.phone].request();

    return statuses.values.every((status) => status.isGranted);
  }
}
