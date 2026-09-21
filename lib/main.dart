import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sports_chat_app/src/screens/splash_screen.dart';
import 'package:sports_chat_app/src/screens/login_screen.dart';
import 'package:sports_chat_app/src/screens/home_screen.dart';
import 'package:sports_chat_app/src/screens/owner_dashboard_screen.dart';
import 'package:sports_chat_app/src/screens/facility_onboarding_screen.dart';
import 'package:sports_chat_app/src/screens/super_admin_dashboard_screen.dart';
import 'package:sports_chat_app/src/screens/customer_bookings_screen.dart';
import 'package:sports_chat_app/src/services/notification_service.dart';
import 'package:sports_chat_app/src/services/remote_config_service.dart';
import 'package:sports_chat_app/src/services/admob_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize AdMob
  await AdMobService().initializeMobileAds();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Initialize Remote Config
  await RemoteConfigService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SprintIndex',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/owner': (context) => const OwnerDashboardScreen(),
        '/owner/onboarding': (context) => const FacilityOnboardingScreen(),
        '/admin': (context) => const SuperAdminDashboardScreen(),
        '/super-admin': (context) => const SuperAdminDashboardScreen(),
        '/my-bookings': (context) => const CustomerBookingsScreen(),
      },
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name == '/owner') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const OwnerDashboardScreen(),
          );
        } else if (name == '/owner/onboarding') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const FacilityOnboardingScreen(),
          );
        } else if (name == '/admin' || name == '/super-admin') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const SuperAdminDashboardScreen(),
          );
        } else if (name == '/my-bookings') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const CustomerBookingsScreen(),
          );
        } else if (name == '/home') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const HomeScreen(),
          );
        } else if (name == '/login') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const LoginScreen(),
          );
        }
        return null;
      },
    );
  }
}
