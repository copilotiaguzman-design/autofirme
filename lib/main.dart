import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/corporate_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutofirmeApp());
}

class AutofirmeApp extends StatelessWidget {
  const AutofirmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autofirme Sistema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CorporateTheme.primaryBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: CorporateTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
