import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const OrigamiTourApp());
}

class OrigamiTourApp extends StatelessWidget {
  const OrigamiTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Origami Tour',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF24389C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      // table, auth gating and bottom-nav shell are implemented. For now the
      // app boots straight to Splash -> Login.
      home: const SplashScreen(),
    );
  }
}
