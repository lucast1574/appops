import 'package:flutter/material.dart';
import 'app.dart';
import 'src/core/notifications/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bootstrap push notifications. Token registration with the backend
  // happens after the user logs in (see PushService.registerCurrentDevice
  // call from the auth bloc/repo).
  await PushService.instance.bootstrap();
  runApp(const LeasyOpsApp());
}
