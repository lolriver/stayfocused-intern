import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text(
              'This app is blocked.\nStay focused.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () {
                // Use platform channel to go home
                const channel = MethodChannel('com.stayfocus/app_blocker');
                channel.invokeMethod('goHome');
              },
              child: const Text('Go Back', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
