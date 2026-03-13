import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/auth/login.dart';
import 'package:flutter_app/auth/signup.dart';
import 'package:flutter_app/homePageState.dart';
import 'package:flutter_app/welcomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform => null;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? seenWelcome;
  Future<void> checkWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    seenWelcome = prefs.getBool('seenWelcome') ?? false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    checkWelcome();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
            bodySmall: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        home: FirebaseAuth.instance.currentUser == null ||
                !FirebaseAuth.instance.currentUser!.emailVerified
            ? const Login()
            : const HomePage(),
        routes: {
          "signup": (context) => const Signup(),
          "login": (context) => const Login(),
          "homepage": (context) => const HomePage(),
          'welcome': (context) => const WelcomePage(),
        });
  }
}
