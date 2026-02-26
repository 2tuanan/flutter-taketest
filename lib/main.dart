import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taketest/reset_new_password_screen.dart';

import 'auth_service.dart';   // assuming this exports supabase or you use Supabase.instance.client
import 'login_screen.dart';
import 'home_screen.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ────────────────────────────────────────────────
  // Global navigator key (helps with context-safe navigation from anywhere)
  // ────────────────────────────────────────────────
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Listener – set up once, very early
  supabase.auth.onAuthStateChange.listen((data) {
    print('=== AUTH CHANGE EVENT ===');
    print('Event: ${data.event.name}');

    if (data.event == AuthChangeEvent.signedIn && data.session != null) {
      if (AuthService.isInRecoveryFlow) {
        print('→ SIGNED IN during password recovery – ignoring (manual nav to reset screen)');
      } else {
        print('→ SIGNED IN – navigating to Home');
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false, // clear all previous routes
        );
      }
    } else if (data.event == AuthChangeEvent.signedOut) {
      print('→ SIGNED OUT – navigating to Login');
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false, // clear all previous routes
      );
    } else if (data.event == AuthChangeEvent.passwordRecovery) {
      print('→ PASSWORD RECOVERY – navigating to ResetNewPasswordScreen');
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const ResetNewPasswordScreen()),
      );
    } else if (data.event == AuthChangeEvent.tokenRefreshed) {
      print('Token refreshed - ignoring navigation');
    } else {
      print('→ Ignoring ${data.event.name} event for navigation');
    }
  });

  // Optional: initial session check / refresh (safe – won't throw normally)
  try {
    final initialSession = supabase.auth.currentSession;
    print('Initial session on app start: ${initialSession != null ? "YES" : "NO"}');
    if (initialSession == null) {
      // Only refresh if no session – helps in some persistence glitch cases
      await supabase.auth.refreshSession();
    }
  } catch (e) {
    print('Initial session/refresh issue: $e');
  }

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    // Debug print on every build
    final isSignedIn = supabase.auth.currentSession != null;
    print('MyApp build → isSignedIn: $isSignedIn');

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Supabase Auth Test',
      debugShowCheckedModeBanner: false,
      home: supabase.auth.currentSession != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}