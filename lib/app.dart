import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/features/auth/presentation/pages/splash_page.dart';

class LeasyOpsApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const LeasyOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Leasy Ops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002B4A),
          primary: const Color(0xFF002B4A),
          secondary: const Color(0xFFEDBB00), // Optional leasy yellow/accent
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashPage(),
    );
  }
}
