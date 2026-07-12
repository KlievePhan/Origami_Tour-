import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontFamily: 'Work Sans', fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Switch between light and dark themes',
              style: TextStyle(fontFamily: 'Work Sans', fontSize: 13),
            ),
            value: isDark,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) =>
                context.read<ThemeProvider>().toggleTheme(value),
          ),

        ],
      ),
    );
  }
}
