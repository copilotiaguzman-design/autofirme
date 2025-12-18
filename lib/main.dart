import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/public/catalog_screen.dart';
import 'screens/public/initialization_screen.dart';
import 'theme/corporate_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando aplicación...');
  
  // Pequeño delay para que los servicios se estabilicen
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Inicializar Firebase con manejo de errores
  try {
    print('🔥 Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
    
    // Verificar si está en modo emulador (NO queremos esto)
    try {
      // Asegurar que NO esté usando el emulador
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      print('⚠️ DETECTADO: Estaba usando emulador local');
    } catch (e) {
      print('✅ No hay emulador activo');
    }
    
    // Configurar Firestore para forzar conexión online
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false, // Deshabilitar caché offline
      host: 'firestore.googleapis.com', // Forzar host de producción
      sslEnabled: true,
    );
    
    print('🌐 Configurado Firestore para servidor de producción');
    print('🔗 Host: firestore.googleapis.com');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
    print('⚠️ La app funcionará con Google Sheets solamente');
    // Continuar sin Firebase por ahora
  }
  
  print('📱 Ejecutando aplicación...');
  runApp(const AutofirmeApp());
}

class AutofirmeApp extends StatelessWidget {
  const AutofirmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autofirme',
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
      initialRoute: '/init',
      routes: {
        '/init': (context) => const InitializationScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/login': (context) => const LoginScreen(),
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
