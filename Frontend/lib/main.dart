import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const OrigamiTourApp());
}

class OrigamiTourApp extends StatelessWidget {
  const OrigamiTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
        title: 'Origami Tour',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF24389C),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF24389C),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
            ),
        // go_router/bottom-nav shell are not implemented yet. For now the
        // app boots straight to Splash -> Login (or Shell, if a session
        // restores) and screens push each other directly via Navigator.
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
