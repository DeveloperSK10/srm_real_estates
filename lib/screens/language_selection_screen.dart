import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3498db),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('en'));
                context.go('/login');
              },
              child: const Text('English'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('ta'));
                context.go('/login');
              },
              child: const Text('தமிழ்'),
            ),
          ],
        ),
      ),
    );
  }
}
