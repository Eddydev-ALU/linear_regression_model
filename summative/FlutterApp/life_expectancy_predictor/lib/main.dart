import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prediction_page.dart';

void main() {
  runApp(const LifeExpectancyApp());
}

class LifeExpectancyApp extends StatelessWidget {
  const LifeExpectancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Expectancy Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7A2F),
          primary: const Color(0xFFFF7A2F),
          secondary: const Color(0xFF1B2559),
          surface: Colors.white,
          background: const Color(0xFFF5F6FA),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFFF7A2F), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF8F9BB3),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
      home: const PredictionPage(),
    );
  }
}