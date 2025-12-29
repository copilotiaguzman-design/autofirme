import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Dar tiempo para que todo se inicialice (especialmente AuthService)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Verificar si hay una sesión activa
      final authService = AuthService.instance;
      
      if (authService.isLoggedIn) {
        // Si hay sesión activa, ir a HomeScreen
        print('🔐 Sesión activa encontrada, redirigiendo a HomeScreen');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Si no hay sesión, ir al catálogo público
        print('📱 Sin sesión activa, mostrando catálogo público');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CatalogScreen(),
          ),
        );
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
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Autofirme',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catálogo de Vehículos',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Inicializando...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}