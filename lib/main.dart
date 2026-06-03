import 'package:flutter/material.dart';
import 'app.dart';
import 'src/core/notifications/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeasyOpsApp());
  // Bootstrap push notifications after the first frame is rendered so
  // Firebase init doesn't block the UI thread and cause ANR/jank.
  // Token registration with the backend happens after the user logs in
  // (see PushService.registerCurrentDevice call from SplashPage / AuthService).
  PushService.instance.bootstrap();
}
