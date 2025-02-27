import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://nhwyylhpzbvkscdamwoy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5od3l5bGhwemJ2a3NjZGFtd295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc3NjQ5NjQsImV4cCI6MjA1MzM0MDk2NH0.mamyyNjFaq2liwjWT8znghSMLqjrrpk-hhTO09JYGCY',
  );
  runApp(const MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UKK 2025',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
