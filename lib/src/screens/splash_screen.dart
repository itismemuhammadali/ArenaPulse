import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for 3 seconds before navigating
    await Future.delayed(const Duration(seconds: 3), () {});
    
    if (mounted) {
      // Check if user is already logged in
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User is logged in, go to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not logged in, go to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'lib/assets/crater_code_dark.png'
                  : 'lib/assets/crater_code_light.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            // App name
            const Text(
              'Crater Code',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            Text(
              'Connect. Compete. Celebrate.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
