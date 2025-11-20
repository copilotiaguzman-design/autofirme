import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Integral de Documentos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// Pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simular delay de autenticación
      await Future.delayed(const Duration(seconds: 1));

      if (_usuarioController.text.toLowerCase() == 'admin' &&
          _passwordController.text == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuPrincipal()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Credenciales incorrectas'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6),
              const Color(0xFF1D4ED8),
              const Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 20,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Icono
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF3B82F6),
                                          const Color(0xFF1D4ED8),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Título
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Sistema Integral de Documentos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Campo Usuario
                          TextFormField(
                            controller: _usuarioController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              hintText: 'Ingrese su usuario',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su usuario';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Campo Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Ingrese su contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),

                          const SizedBox(height: 32),

                          // Botón de Login
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Credenciales de prueba
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Credenciales de prueba:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Usuario: admin\nContraseña: admin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Menú Principal
class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            // Logo pequeño en AppBar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 16,
                        color: Color(0xFF3B82F6),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Text(
              'Sistema Integral de Documentos',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Está seguro que desea cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF1D4ED8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo en el header del menú principal
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.dashboard,
                                  size: 40,
                                  color: Color(0xFF3B82F6),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Panel de Control',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seleccione el módulo que desea utilizar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Grid de opciones
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    if (constraints.maxWidth > 900) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMenuCard(
                          context,
                          'Generador de Placas',
                          'Genera placas digitales y documentos para vehículos',
                          Icons.directions_car,
                          const Color(0xFF10B981),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PinCodeScreen(),
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Generador de Contratos',
                          'Documenta transacciones de compra y venta de manera profesional',
                          Icons.handshake,
                          const Color(0xFFF59E0B),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompraVentaScreen(),
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Factura Genérica',
                          'Crea facturas personalizadas para diferentes tipos de servicios',
                          Icons.receipt_long,
                          const Color(0xFF3B82F6),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FacturaScreen(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 48, color: color),
              ),

              const SizedBox(height: 16),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Acceder',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de PIN para Generador de Placas
class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isValidating = false;
  
  // PIN correcto (puedes cambiar este valor)
  static const String _correctPin = "2019";

  void _validatePin() async {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor ingrese el código PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    // Simular validación
    await Future.delayed(const Duration(milliseconds: 500));

    if (_pinController.text == _correctPin) {
      // PIN correcto - navegar al generador de placas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlacasScreen()),
      );
    } else {
      // PIN incorrecto
      setState(() {
        _isValidating = false;
        _pinController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Código PIN incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Acceso al Generador de Placas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono de seguridad
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.security,
                          size: 64,
                          color: Color(0xFF10B981),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Título
                      const Text(
                        'Acceso Restringido',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Descripción
                      Text(
                        'Ingrese el código PIN para acceder al\nGenerador de Placas Vehiculares',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Campo de PIN
                      TextFormField(
                        controller: _pinController,
                        obscureText: _obscurePin,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Código PIN',
                          hintText: '••••',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF10B981),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePin ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF6B7280),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onFieldSubmitted: (_) => _validatePin(),
                      ),

                      const SizedBox(height: 24),

                      // Botón de acceso
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isValidating ? null : _validatePin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: _isValidating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Validando...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Acceder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón de cancelar
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlacasScreen extends StatefulWidget {
  const PlacasScreen({super.key});

  @override
  State<PlacasScreen> createState() => _PlacasScreenState();
}

class _PlacasScreenState extends State<PlacasScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _vinController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _colorController = TextEditingController();

  String _enlaceWeb = '';
  String _enlaceDescarga = '';
  String _qrData = '';
  String _htmlGenerado = '';
  bool _isGenerating = false;
  bool _isBuscandoVin = false;

  // URLs de las APIs y recursos
  static const String urlImagenAgua =
      "https://vehicle-information.com/agua.png";
  static const String apiUrlPdf =
      "https://vehicle-information.com/subir_pdf.php";
  static const String apiUrlHtml =
      "https://vehicle-information.com/subir_html.php";
  static const String apiUrlVin1 =
      "https://script.google.com/macros/s/AKfycbzVNf6KuslXY_V404TLF0Lkp140fsE_uzYu4GQ-fm5fyDJR9hqCyGzIvpbtyL-bcohRVw/exec";
  static const String apiUrlVin2 =
      "https://script.google.com/macros/s/AKfycbxo7DtxpLqNgo2yUl6ooqiUP-GJ683BkkQHOKFy6IVN_iBcaqtfsUto3E3v0dln0iU/exec";
  static const String assetImagenPlaca =
      "assets/placa.webp"; // Imagen local del marco

  @override
  void dispose() {
    _vinController.dispose();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  // Función para buscar datos por VIN
  Future<void> _buscarPorVin() async {
    final vinParcial = _vinController.text.trim();

    if (vinParcial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor ingrese un VIN para buscar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBuscandoVin = true;
    });

    try {
      print("🔍 Buscando VIN: $vinParcial");

      // Intentar con la primera API
      bool datoEncontrado = await _buscarEnAPI(apiUrlVin1, vinParcial, "API 1");

      // Si no encontró datos, intentar con la segunda API
      if (!datoEncontrado) {
        print("🔄 Intentando con segunda API...");
        await _buscarEnAPI(apiUrlVin2, vinParcial, "API 2");
      }
    } catch (e) {
      print("❌ Error en búsqueda VIN: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al buscar VIN: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuscandoVin = false;
        });
      }
    }
  }

  // Función auxiliar para buscar en una API específica
  Future<bool> _buscarEnAPI(
    String apiUrl,
    String vinParcial,
    String nombreAPI,
  ) async {
    try {
      final url = Uri.parse('$apiUrl?vin=$vinParcial');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print("📡 $nombreAPI - Status Code: ${response.statusCode}");
      print("📋 $nombreAPI - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('error')) {
          print("⚠️ $nombreAPI - Error en respuesta: ${data['error']}");
          return false;
        } else {
          // Verificar si tenemos datos válidos (al menos marca)
          if (data.containsKey('campoB') &&
              data['campoB'] != null &&
              data['campoB'].toString().isNotEmpty) {
            // Mapear los datos recibidos a los campos del formulario
            setState(() {
              _anoController.text = data['campoA']?.toString() ?? '';
              _marcaController.text = data['campoB']?.toString() ?? '';
              _modeloController.text = data['campoC']?.toString() ?? '';
              _colorController.text = data['campoJ']?.toString() ?? '';
              _vinController.text = data['campoK']?.toString() ?? vinParcial;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✅ Datos encontrados en $nombreAPI y completados',
                ),
                backgroundColor: Colors.green,
              ),
            );

            print(
              "✅ $nombreAPI - Datos cargados correctamente: Año=${_anoController.text}, Marca=${_marcaController.text}, Modelo=${_modeloController.text}, Color=${_colorController.text}",
            );
            return true;
          } else {
            print(
              "❌ $nombreAPI - No se encontraron datos válidos en la respuesta",
            );
            return false;
          }
        }
      } else {
        print("❌ $nombreAPI - Error del servidor: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ $nombreAPI - Error: $e");
      return false;
    }
  }

  void _generarEnlaces() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isGenerating = true;
        _enlaceWeb =
            'https://vehicle-information.com/vehiculos/${_placaController.text}.html';
        _enlaceDescarga =
            'https://vehicle-information.com/pdfs/${_placaController.text}.pdf';
        _qrData = _enlaceWeb;
      });

      try {
        // Generar PDF y subirlo
        await _enviarPDFConQR();

        // Intentar subir HTML pero no fallar si no funciona
        bool htmlExitoso = false;
        try {
          await _subirHTML();
          htmlExitoso = true;
        } catch (htmlError) {
          print(
            "⚠️ HTML no se pudo subir, pero PDF se generó correctamente: $htmlError",
          );
        }

        if (mounted) {
          final mensaje =
              htmlExitoso
                  ? '✅ Placa y página web generadas exitosamente'
                  : '✅ Placa generada exitosamente. PDF subido correctamente.\n⚠️ HTML generado localmente (problemas de conectividad)';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: htmlExitoso ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  // Función equivalente a enviarPDFConQR() de Apps Script
  Future<void> _enviarPDFConQR() async {
    final nombreArchivo = _placaController.text;
    final vinCompleto = _vinController.text;
    final datoQR = _enlaceWeb;

    if (nombreArchivo.isEmpty || datoQR.isEmpty) {
      throw Exception("❌ Falta el nombre de archivo o el dato del QR");
    }

    try {
      // Crear el PDF
      final pdfBytes = await _generarPDFPlaca(
        nombreArchivo,
        vinCompleto,
        datoQR,
      );

      // Descargar/compartir el PDF según la plataforma
      await _descargarOCompartirPDF(pdfBytes, '${nombreArchivo}.pdf');

      try {
        // Enviar PDF a la API
        print("🔄 Enviando PDF a: $apiUrlPdf");
        print(
          "📋 Archivo PDF: ${nombreArchivo}.pdf, tamaño: ${pdfBytes.length} bytes",
        );

        final request = http.MultipartRequest('POST', Uri.parse(apiUrlPdf));
        request.files.add(
          http.MultipartFile.fromBytes(
            'pdf',
            pdfBytes,
            filename: '$nombreArchivo.pdf',
          ),
        );
        request.fields['nombre'] = nombreArchivo;

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        print("📡 PDF - Status: ${response.statusCode}");
        print("✅ Respuesta del PDF: $responseBody");
      } catch (e) {
        print("⚠️ No se pudo enviar PDF a la API: $e");
        // Continuamos sin fallar, el PDF se generó correctamente
      }
    } catch (e) {
      print("❌ Error en _enviarPDFConQR: $e");
      throw e;
    }
  }

  // Función para generar el PDF de la placa
  Future<Uint8List> _generarPDFPlaca(
    String nombreArchivo,
    String vinCompleto,
    String datoQR,
  ) async {
    final pdf = pw.Document();

    // Cargar fuente TTF que soporte caracteres Unicode
    pw.Font? fontRegular;
    try {
      // Cargar fuente BebasNeue desde assets
      final ByteData fontData = await rootBundle.load(
        'assets/BebasNeue-Regular.ttf',
      );
      final pw.Font ttfFont = pw.Font.ttf(fontData);
      fontRegular = ttfFont;
      print("✅ Fuente BebasNeue-Regular.ttf cargada desde assets");
    } catch (e) {
      print("⚠️ No se pudo cargar fuente TTF, usando predeterminada: $e");
      fontRegular = null;
    }

    // Dimensiones de la hoja (como en Apps Script)
    const anchoHoja = 720.0; // Ancho en puntos
    const altoHoja = 350.0; // Alto en puntos

    // Intentar cargar las imágenes
    pw.MemoryImage? imagenBase;
    pw.MemoryImage? imagenAgua;
    pw.MemoryImage? qrImagen;

    try {
      // Cargar imagen del marco de la placa desde assets
      final ByteData data = await rootBundle.load(assetImagenPlaca);
      final Uint8List bytes = data.buffer.asUint8List();
      imagenBase = pw.MemoryImage(bytes);
      print("✅ Imagen de placa cargada desde assets");
    } catch (e) {
      print("⚠️ No se pudo cargar imagen de placa desde assets: $e");
    }

    try {
      // Cargar imagen de agua desde assets (si existe) o usar URL como fallback
      try {
        // Intentar cargar desde assets primero
        final ByteData aguaData = await rootBundle.load('assets/agua.webp');
        final Uint8List aguaBytes = aguaData.buffer.asUint8List();
        imagenAgua = pw.MemoryImage(aguaBytes);
        print("✅ Imagen de agua cargada desde assets");
      } catch (e) {
        // Si no está en assets, intentar descargar
        final imagenAguaResponse = await http.get(Uri.parse(urlImagenAgua));
        if (imagenAguaResponse.statusCode == 200) {
          imagenAgua = pw.MemoryImage(imagenAguaResponse.bodyBytes);
          print("✅ Imagen de agua descargada desde URL");
        }
      }
    } catch (e) {
      print("⚠️ No se pudo cargar imagen de agua: $e");
    }

    try {
      // Generar URL del QR y descargarlo
      final urlQR =
          "https://api.qrserver.com/v1/create-qr-code/?size=900x900&data=${Uri.encodeComponent(datoQR)}";
      final qrResponse = await http.get(Uri.parse(urlQR));
      if (qrResponse.statusCode == 200) {
        qrImagen = pw.MemoryImage(qrResponse.bodyBytes);
        print("✅ QR generado correctamente");
      }
    } catch (e) {
      print("⚠️ No se pudo cargar QR: $e");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(anchoHoja, altoHoja),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Fondo de color si no hay imagen base
              if (imagenBase == null)
                pw.Positioned.fill(
                  child: pw.Container(
                    color: PdfColors.grey100,
                    child: pw.Center(
                      child: pw.Container(
                        width: anchoHoja * 0.8,
                        height: altoHoja * 0.6,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 3,
                          ),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Imagen base si está disponible
                pw.Positioned.fill(
                  child: pw.Image(imagenBase, fit: pw.BoxFit.cover),
                ),

              // Texto de la placa (usando fuente TTF cargada)
              pw.Positioned(
                left: 60,
                top: 40,
                child: pw.Text(
                  nombreArchivo,
                  style: pw.TextStyle(
                    fontSize: 180,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                    font: fontRegular,
                  ),
                ),
              ),

              // Texto del VIN (usando fuente TTF cargada)
              pw.Positioned(
                left: 60,
                top: 230,
                child: pw.Text(
                  "VIN: $vinCompleto",
                  style: pw.TextStyle(
                    fontSize: 15,
                    color: PdfColors.black,
                    font: fontRegular,
                  ),
                ),
              ),

              // Imagen de agua (marca de agua) - POR ENCIMA del texto
              if (imagenAgua != null)
                pw.Positioned.fill(
                  child: pw.Image(imagenAgua, fit: pw.BoxFit.cover),
                ),

              // QR Code si está disponible
              if (qrImagen != null)
                pw.Positioned(
                  right: 10 + 17,
                  bottom: 12,
                  child: pw.Container(
                    width: 86,
                    height: 86,
                    child: pw.Image(qrImagen),
                  ),
                )
              else
                // QR alternativo como texto si no se puede cargar la imagen
                pw.Positioned(
                  right: 27,
                  bottom: 12,
                  child: pw.Container(
                    width: 86,
                    height: 86,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border.all(color: PdfColors.black),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR',
                        style: pw.TextStyle(fontSize: 12, font: fontRegular),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    // Convertir PDF a bytes y retornar
    return await pdf.save();
  }

  // Función universal para descargar/compartir PDF según la plataforma
  Future<void> _descargarOCompartirPDF(
    Uint8List pdfBytes,
    String nombreArchivo,
  ) async {
    try {
      if (kIsWeb) {
        // En web: descargar directamente
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = nombreArchivo;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print("✅ PDF descargado en navegador: $nombreArchivo");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📥 PDF descargado: $nombreArchivo'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // En móvil: guardar y compartir
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$nombreArchivo');
        await file.writeAsBytes(pdfBytes);

        // Compartir el archivo
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Placa vehicular generada',
          subject: 'Documento PDF - $nombreArchivo',
        );

        print("✅ PDF compartido en móvil: $nombreArchivo");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📤 PDF compartido: $nombreArchivo'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error al descargar/compartir PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al manejar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función equivalente a subirHTML() de Apps Script
  Future<void> _subirHTML() async {
    final marca = _marcaController.text;
    final modelo = _modeloController.text;
    final ano = _anoController.text;
    final color = _colorController.text;
    final vin = _vinController.text;
    final placa = _placaController.text;

    if (placa.isEmpty) {
      throw Exception("❌ Falta el dato de la placa");
    }

    // Crear el contenido HTML con diseño formal y responsivo
    _htmlGenerado = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$placa - Información del Vehículo</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary-color: #1f2937;
      --secondary-color: #3b82f6;
      --accent-color: #10b981;
      --text-primary: #111827;
      --text-secondary: #6b7280;
      --text-light: #9ca3af;
      --bg-primary: #ffffff;
      --bg-secondary: #f9fafb;
      --bg-tertiary: #f3f4f6;
      --border-color: #e5e7eb;
      --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
      --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
      --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
      --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, var(--bg-secondary) 0%, var(--bg-tertiary) 100%);
      color: var(--text-primary);
      min-height: 100vh;
      padding: 1rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .container {
      width: 100%;
      max-width: 1200px;
      margin: 0 auto;
    }
    
    .document-card {
      background: var(--bg-primary);
      border-radius: 16px;
      box-shadow: var(--shadow-xl);
      overflow: hidden;
      border: 1px solid var(--border-color);
    }
    
    .header {
      background: linear-gradient(135deg, var(--primary-color) 0%, #374151 100%);
      color: white;
      padding: 2rem;
      position: relative;
      overflow: hidden;
    }
    
    .header::before {
      content: '';
      position: absolute;
      top: 0;
      right: 0;
      width: 200px;
      height: 200px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 50%;
      transform: translate(50%, -50%);
    }
    
    .header-content {
      position: relative;
      z-index: 1;
    }
    
    .header h1 {
      font-size: 1.875rem;
      font-weight: 700;
      margin-bottom: 0.5rem;
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }
    
    .header p {
      font-size: 1rem;
      opacity: 0.9;
      font-weight: 400;
    }
    
    .content {
      padding: 2rem;
    }
    
    .plate-highlight {
      background: linear-gradient(135deg, var(--secondary-color), #60a5fa);
      color: white;
      padding: 1.5rem;
      border-radius: 12px;
      margin-bottom: 2rem;
      text-align: center;
      box-shadow: var(--shadow-md);
    }
    
    .plate-number {
      font-size: 2.5rem;
      font-weight: 700;
      letter-spacing: 0.1em;
      margin-bottom: 0.5rem;
    }
    
    .plate-label {
      font-size: 0.875rem;
      opacity: 0.9;
      font-weight: 500;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .info-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2rem;
    }
    
    .info-section {
      background: var(--bg-secondary);
      border-radius: 12px;
      padding: 1.5rem;
      border: 1px solid var(--border-color);
    }
    
    .section-title {
      font-size: 1.125rem;
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 1rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }
    
    .info-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.75rem 0;
      border-bottom: 1px solid var(--border-color);
    }
    
    .info-item:last-child {
      border-bottom: none;
    }
    
    .info-label {
      font-size: 0.875rem;
      font-weight: 500;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .info-value {
      font-size: 1rem;
      font-weight: 600;
      color: var(--text-primary);
      text-align: right;
    }
    
    .footer {
      background: var(--bg-tertiary);
      padding: 1.5rem 2rem;
      border-top: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 1rem;
    }
    
    .footer-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
      color: var(--text-secondary);
    }
    
    .status-badge {
      background: var(--accent-color);
      color: white;
      padding: 0.25rem 0.75rem;
      border-radius: 9999px;
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .icon {
      width: 1.25rem;
      height: 1.25rem;
      color: var(--secondary-color);
    }
    
    /* Responsive Design */
    @media (max-width: 768px) {
      body {
        padding: 0.5rem;
      }
      
      .header {
        padding: 1.5rem;
      }
      
      .header h1 {
        font-size: 1.5rem;
      }
      
      .content {
        padding: 1.5rem;
      }
      
      .plate-number {
        font-size: 2rem;
      }
      
      .info-grid {
        grid-template-columns: 1fr;
        gap: 1rem;
      }
      
      .info-section {
        padding: 1rem;
      }
      
      .footer {
        padding: 1rem 1.5rem;
        flex-direction: column;
        text-align: center;
      }
      
      .info-item {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.25rem;
      }
      
      .info-value {
        text-align: left;
      }
    }
    
    @media (max-width: 480px) {
      .header h1 {
        font-size: 1.25rem;
        flex-direction: column;
        text-align: center;
        gap: 0.5rem;
      }
      
      .plate-number {
        font-size: 1.75rem;
      }
      
      .info-grid {
        gap: 0.75rem;
      }
    }
    
    /* Print Styles */
    @media print {
      body {
        background: white;
        padding: 0;
      }
      
      .document-card {
        box-shadow: none;
        border: 1px solid #000;
      }
      
      .header {
        background: #333 !important;
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
      }
      
      .plate-highlight {
        background: #333 !important;
        -webkit-print-color-adjust: exact;
        color-adjust: exact;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="document-card">
      <div class="header">
        <div class="header-content">
          <h1>
            <i class="fas fa-car"></i>
            Información del Vehículo
          </h1>
          <p>Documento oficial de registro vehicular</p>
        </div>
      </div>
      
      <div class="content">
        <div class="plate-highlight">
          <div class="plate-number">$placa</div>
          <div class="plate-label">Número de Placa</div>
        </div>
        
        <div class="info-grid">
          <div class="info-section">
            <div class="section-title">
              <i class="fas fa-info-circle icon"></i>
              Datos del Vehículo
            </div>
            <div class="info-item">
              <span class="info-label">Marca</span>
              <span class="info-value">$marca</span>
            </div>
            <div class="info-item">
              <span class="info-label">Modelo</span>
              <span class="info-value">$modelo</span>
            </div>
            <div class="info-item">
              <span class="info-label">Año</span>
              <span class="info-value">$ano</span>
            </div>
            <div class="info-item">
              <span class="info-label">Color</span>
              <span class="info-value">$color</span>
            </div>
          </div>
          
          <div class="info-section">
            <div class="section-title">
              <i class="fas fa-fingerprint icon"></i>
              Identificación
            </div>
            <div class="info-item">
              <span class="info-label">VIN</span>
              <span class="info-value">$vin</span>
            </div>
            <div class="info-item">
              <span class="info-label">Placa</span>
              <span class="info-value">$placa</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="footer">
        <div class="footer-item">
          <i class="fas fa-calendar-alt"></i>
          <span>Generado: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</span>
        </div>
        <div class="status-badge">
          <i class="fas fa-shield-check"></i>
          Verificado
        </div>
      </div>
    </div>
  </div>
</body>
</html>
    ''';

    try {
      print("🔄 Intentando enviar HTML a: $apiUrlHtml");
      print(
        "📋 Datos a enviar: placa=$placa, tamaño HTML=${_htmlGenerado.length} caracteres",
      );

      // Intentar con diferentes métodos
      await _intentarSubirHTML(placa);
    } catch (e) {
      print("⚠️ No se pudo enviar HTML a la API: $e");
      // Re-lanzar el error para que el llamador lo maneje
      rethrow;
    }
  }

  // Función para intentar diferentes métodos de subida del HTML
  Future<void> _intentarSubirHTML(String placa) async {
    // Método 1: JSON como antes
    try {
      print("🔄 Método 1: Enviando como JSON...");
      final response = await http
          .post(
            Uri.parse(apiUrlHtml),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'User-Agent': 'Flutter App/1.0',
            },
            body: json.encode({'html': _htmlGenerado, 'nombre': placa}),
          )
          .timeout(const Duration(seconds: 15));

      print("📡 Método 1 - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        _procesarRespuestaHTML(response);
        return; // Éxito
      }
    } catch (e) {
      print("❌ Método 1 falló: $e");
    }

    // Método 2: Form data (como el PDF)
    try {
      print("🔄 Método 2: Enviando como MultipartRequest...");
      final request = http.MultipartRequest('POST', Uri.parse(apiUrlHtml));
      request.fields['html'] = _htmlGenerado;
      request.fields['nombre'] = placa;

      final response = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final responseBody = await response.stream.bytesToString();

      print("📡 Método 2 - Status: ${response.statusCode}");
      print("📡 Método 2 - Respuesta: $responseBody");

      if (response.statusCode == 200) {
        print("✅ HTML subido exitosamente con Método 2");
        return; // Éxito
      }
    } catch (e) {
      print("❌ Método 2 falló: $e");
    }

    // Método 3: Form URL encoded
    try {
      print("🔄 Método 3: Enviando como form-urlencoded...");
      final response = await http
          .post(
            Uri.parse(apiUrlHtml),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': 'Flutter App/1.0',
            },
            body: {'html': _htmlGenerado, 'nombre': placa},
          )
          .timeout(const Duration(seconds: 15));

      print("📡 Método 3 - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        _procesarRespuestaHTML(response);
        return; // Éxito
      }
    } catch (e) {
      print("❌ Método 3 falló: $e");
    }

    // Si todos los métodos fallaron
    throw Exception(
      "Todos los métodos de envío fallaron. Posible problema de servidor o CORS.",
    );
  }

  void _procesarRespuestaHTML(http.Response response) {
    try {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        print("✅ HTML guardado exitosamente: ${responseData['message']}");
      } else {
        print("⚠️ El servidor respondió con error: ${responseData['message']}");
        throw Exception("Error del servidor: ${responseData['message']}");
      }
    } catch (jsonError) {
      print("✅ HTML subido (respuesta no JSON): ${response.body}");
    }
  }

  void _limpiarCampos() {
    setState(() {
      _vinController.clear();
      _placaController.clear();
      _marcaController.clear();
      _modeloController.clear();
      _anoController.clear();
      _colorController.clear();
      _enlaceWeb = '';
      _enlaceDescarga = '';
      _qrData = '';
      _htmlGenerado = '';
    });
  }

  void _mostrarHTML() {
    if (_htmlGenerado.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('HTML Generado'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  _htmlGenerado,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _copiarAlPortapapeles(_htmlGenerado),
                child: const Text('Copiar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    }
  }

  void _copiarAlPortapapeles(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Generador de Placas Vehiculares',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 768 ? 32.0 : 16.0,
              vertical: 24.0,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header con descripción
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF3B82F6),
                              const Color(0xFF1D4ED8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Logo en header de placas
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.directions_car_rounded,
                                        size: 30,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Sistema de Registro Vehicular',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Genera placas digitales y documentos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '💡 Tip: Ingresa solo parte del VIN y presiona "Buscar" para autocompletar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Formulario de datos
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.edit_document,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'INFORMACIÓN DEL VEHÍCULO',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Grid responsivo para los campos
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 600) {
                                    // Layout para pantallas grandes (2 columnas)
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                _marcaController,
                                                'Marca',
                                                'Ej: Toyota',
                                                Icons.branding_watermark,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildTextField(
                                                _modeloController,
                                                'Modelo',
                                                'Ej: Corolla',
                                                Icons.car_rental,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                _anoController,
                                                'Año',
                                                'Ej: 2020',
                                                Icons.calendar_today,
                                                TextInputType.number,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildTextField(
                                                _colorController,
                                                'Color',
                                                'Ej: Blanco',
                                                Icons.palette,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Campo VIN con botón de búsqueda
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                _vinController,
                                                'VIN',
                                                'Ej: 301713',
                                                Icons.fingerprint,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            SizedBox(
                                              height: 56,
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    _isBuscandoVin
                                                        ? null
                                                        : _buscarPorVin,
                                                icon:
                                                    _isBuscandoVin
                                                        ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        )
                                                        : const Icon(
                                                          Icons.search,
                                                          size: 20,
                                                        ),
                                                label: Text(
                                                  _isBuscandoVin
                                                      ? 'Buscando...'
                                                      : 'Buscar',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF10B981,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          _placaController,
                                          'Placa',
                                          'Ej: ABC-123',
                                          Icons.confirmation_number,
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Layout para pantallas pequeñas (1 columna)
                                    return Column(
                                      children: [
                                        _buildTextField(
                                          _marcaController,
                                          'Marca',
                                          'Ej: Toyota',
                                          Icons.branding_watermark,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          _modeloController,
                                          'Modelo',
                                          'Ej: Corolla',
                                          Icons.car_rental,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          _anoController,
                                          'Año',
                                          'Ej: 2020',
                                          Icons.calendar_today,
                                          TextInputType.number,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          _colorController,
                                          'Color',
                                          'Ej: Blanco',
                                          Icons.palette,
                                        ),
                                        const SizedBox(height: 16),
                                        // Campo VIN con botón de búsqueda (layout móvil)
                                        _buildTextField(
                                          _vinController,
                                          'VIN',
                                          'Ej: 301713',
                                          Icons.fingerprint,
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton.icon(
                                            onPressed:
                                                _isBuscandoVin
                                                    ? null
                                                    : _buscarPorVin,
                                            icon:
                                                _isBuscandoVin
                                                    ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                    : const Icon(
                                                      Icons.search,
                                                      size: 20,
                                                    ),
                                            label: Text(
                                              _isBuscandoVin
                                                  ? 'Buscando por VIN...'
                                                  : 'Buscar por VIN',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF10B981,
                                              ),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          _placaController,
                                          'Placa',
                                          'Ej: ABC-123',
                                          Icons.confirmation_number,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botones de acción
                      _buildActionButtons(),

                      const SizedBox(height: 32),

                      // Resultados
                      if (_enlaceWeb.isNotEmpty) _buildResultsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, [
    TextInputType? keyboardType,
    bool readOnly = false,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (!readOnly && (value == null || value.isEmpty)) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Botón principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generarEnlaces,
                icon:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.rocket_launch),
                label: Text(
                  _isGenerating ? 'Generando...' : 'Generar Placa y Documentos',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones secundarios en grid responsivo
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'Revisar Web',
                          Icons.language,
                          Colors.green,
                          _enlaceWeb.isNotEmpty
                              ? () => _abrirEnlace(_enlaceWeb)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSecondaryButton(
                          'Descargar PDF',
                          Icons.download,
                          Colors.orange,
                          _enlaceDescarga.isNotEmpty
                              ? () => _abrirEnlace(_enlaceDescarga)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSecondaryButton(
                          'Ver HTML',
                          Icons.code,
                          Colors.purple,
                          _htmlGenerado.isNotEmpty ? _mostrarHTML : null,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryButton(
                              'Revisar Web',
                              Icons.language,
                              Colors.green,
                              _enlaceWeb.isNotEmpty
                                  ? () => _abrirEnlace(_enlaceWeb)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSecondaryButton(
                              'Descargar PDF',
                              Icons.download,
                              Colors.orange,
                              _enlaceDescarga.isNotEmpty
                                  ? () => _abrirEnlace(_enlaceDescarga)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryButton(
                              'Ver HTML',
                              Icons.code,
                              Colors.purple,
                              _htmlGenerado.isNotEmpty ? _mostrarHTML : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSecondaryButton(
                              'Limpiar',
                              Icons.clear_all,
                              Colors.grey,
                              _limpiarCampos,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            // Botón limpiar para pantallas grandes
            if (MediaQuery.of(context).size.width > 600) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildSecondaryButton(
                  'Limpiar Campos',
                  Icons.clear_all,
                  Colors.grey,
                  _limpiarCampos,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    MaterialColor color,
    VoidCallback? onPressed,
  ) {
    final colorValue =
        color == Colors.green
            ? const Color(0xFF10B981)
            : color == Colors.orange
            ? const Color(0xFFF59E0B)
            : color == Colors.purple
            ? const Color(0xFF8B5CF6)
            : const Color(0xFF6B7280);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorValue.withOpacity(0.1),
        foregroundColor: colorValue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        // QR Code prominente
        Card(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CÓDIGO QR GENERADO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: MediaQuery.of(context).size.width > 600 ? 200 : 150,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Enlaces generados
        Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ENLACES GENERADOS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLinkItem(
                  'Página Web',
                  _enlaceWeb,
                  Icons.language,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildLinkItem(
                  'Archivo PDF',
                  _enlaceDescarga,
                  Icons.picture_as_pdf,
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    String title,
    String url,
    IconData icon,
    MaterialColor color,
  ) {
    final colorLight =
        color == Colors.green
            ? const Color(0xFFF0FDF4)
            : color == Colors.red
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF8FAFC);

    final colorMain =
        color == Colors.green
            ? const Color(0xFF10B981)
            : color == Colors.red
            ? const Color(0xFFEF4444)
            : const Color(0xFF3B82F6);

    final colorDark =
        color == Colors.green
            ? const Color(0xFF047857)
            : color == Colors.red
            ? const Color(0xFFDC2626)
            : const Color(0xFF1E40AF);

    final colorBorder =
        color == Colors.green
            ? const Color(0xFFBBF7D0)
            : color == Colors.red
            ? const Color(0xFFFECDD3)
            : const Color(0xFFDDEAFE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorMain, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, color: colorDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _abrirEnlace(url),
                  child: Text(
                    url,
                    style: TextStyle(
                      color: colorMain,
                      decoration: TextDecoration.underline,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copiarAlPortapapeles(url),
                icon: Icon(Icons.copy, color: colorMain, size: 18),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Pantalla de Factura Genérica
class FacturaScreen extends StatefulWidget {
  const FacturaScreen({super.key});

  @override
  State<FacturaScreen> createState() => _FacturaScreenState();
}

class _FacturaScreenState extends State<FacturaScreen> {
  final _formKey = GlobalKey<FormState>();

  // URLs de las APIs de VIN
  static const String apiUrlVin1 =
      "https://script.google.com/macros/s/AKfycbzVNf6KuslXY_V404TLF0Lkp140fsE_uzYu4GQ-fm5fyDJR9hqCyGzIvpbtyL-bcohRVw/exec";
  static const String apiUrlVin2 =
      "https://script.google.com/macros/s/AKfycbxo7DtxpLqNgo2yUl6ooqiUP-GJ683BkkQHOKFy6IVN_iBcaqtfsUto3E3v0dln0iU/exec";

  // Controladores para los campos básicos de factura
  final _fechaController = TextEditingController();
  final _lugarController = TextEditingController();

  // Controladores para datos del cliente
  final _nombreCompletoController = TextEditingController();
  final _tipoIdentificacionController = TextEditingController();
  final _numeroIdentificacionController = TextEditingController();

  // Controladores para datos del vehículo
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _numeroSerieController = TextEditingController();
  final _vinController = TextEditingController();

  bool _isGenerating = false;
  bool _isBuscando = false;

  @override
  void initState() {
    super.initState();
    // Establecer fecha actual
    final now = DateTime.now();
    _fechaController.text = '${now.day}/${now.month}/${now.year}';

    // Establecer valores por defecto
    _tipoIdentificacionController.text = 'INE';
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _lugarController.dispose();
    _nombreCompletoController.dispose();
    _tipoIdentificacionController.dispose();
    _numeroIdentificacionController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _numeroSerieController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  // Función para buscar datos por VIN en factura genérica
  Future<void> _buscarPorVin() async {
    print("🚀 FacturaScreen - Iniciando búsqueda por VIN");
    final vinParcial = _vinController.text.trim();

    if (vinParcial.isEmpty) {
      print("⚠️ FacturaScreen - VIN vacío");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor ingrese un VIN para buscar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("🔍 FacturaScreen - VIN a buscar: '$vinParcial'");
    setState(() {
      _isBuscando = true;
    });

    try {
      // Intentar con la primera API
      bool datoEncontrado = await _buscarEnAPIFactura(
        apiUrlVin1,
        vinParcial,
        "API 1",
      );

      // Si no encontró datos, intentar con la segunda API
      if (!datoEncontrado) {
        print("🔄 FacturaScreen - Intentando con segunda API...");
        await _buscarEnAPIFactura(apiUrlVin2, vinParcial, "API 2");
      }
    } catch (e) {
      print("❌ FacturaScreen - Error en búsqueda VIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al buscar VIN: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBuscando = false;
      });
    }
  }

  // Función auxiliar para buscar en una API específica para facturas
  Future<bool> _buscarEnAPIFactura(
    String apiUrl,
    String vinParcial,
    String nombreAPI,
  ) async {
    try {
      final url = Uri.parse('$apiUrl?vin=$vinParcial');

      final response = await http
          .get(url, headers: {'User-Agent': 'Flutter App/1.0'})
          .timeout(const Duration(seconds: 10));

      print(
        "📡 FacturaScreen $nombreAPI - Status Code: ${response.statusCode}",
      );
      print("📋 FacturaScreen $nombreAPI - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("🔍 FacturaScreen $nombreAPI - Datos recibidos: $data");

        // Verificar si tenemos datos válidos (al menos marca y modelo)
        if (data.containsKey('campoB') &&
            data['campoB'] != null &&
            data['campoB'].toString().isNotEmpty) {
          setState(() {
            // Mapeo de campos basado en la API real
            _anoController.text = data['campoA']?.toString() ?? '';
            _marcaController.text = data['campoB']?.toString() ?? '';
            _modeloController.text = data['campoC']?.toString() ?? '';
            // El VIN se mantiene como está o se actualiza con el completo
            if (data['campoK'] != null &&
                data['campoK'].toString().isNotEmpty) {
              _vinController.text = data['campoK'].toString();
            }
          });

          print(
            "✅ FacturaScreen $nombreAPI - Datos cargados correctamente: Año=${_anoController.text}, Marca=${_marcaController.text}, Modelo=${_modeloController.text}",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Datos encontrados en $nombreAPI y completados'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          print(
            "❌ FacturaScreen $nombreAPI - No se encontraron datos válidos en la respuesta",
          );
          return false;
        }
      } else {
        print(
          "❌ FacturaScreen $nombreAPI - Error del servidor: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("❌ FacturaScreen $nombreAPI - Error: $e");
      return false;
    }
  }

  void _generarFactura() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isGenerating = true;
      });

      try {
        // Crear contenido de la factura con todos los datos
        String facturaContent = '''
FACTURA GENÉRICA

Fecha: ${_fechaController.text}
Lugar: ${_lugarController.text}

DATOS DEL CLIENTE:
Nombre Completo: ${_nombreCompletoController.text}
Tipo y Número de Identificación: ${_tipoIdentificacionController.text} - ${_numeroIdentificacionController.text}

DATOS DEL VEHÍCULO:
Marca: ${_marcaController.text}
Modelo: ${_modeloController.text}
Año: ${_anoController.text}
Número de Serie (VIN): ${_vinController.text}

____________________________
Firma Autorizada
        ''';

        // Simular generación de factura
        await Future.delayed(const Duration(seconds: 2));

        print("✅ Factura genérica generada:");
        print(facturaContent);

        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Factura generada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar la factura: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Factura Genérica',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6),
                          const Color(0xFF1D4ED8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Logo en header de facturas
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    size: 30,
                                    color: Color(0xFF3B82F6),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Generador de Facturas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información Básica
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'INFORMACIÓN BÁSICA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _fechaController,
                                  'Fecha',
                                  'DD/MM/AAAA',
                                  Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  _lugarController,
                                  'Lugar',
                                  'Ciudad, Estado',
                                  Icons.location_on,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos del Cliente
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DEL CLIENTE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            _nombreCompletoController,
                            'Nombre Completo del Cliente',
                            'Nombre completo',
                            Icons.person,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildTextField(
                                  _tipoIdentificacionController,
                                  'Tipo ID',
                                  'INE, Pasaporte, etc.',
                                  Icons.credit_card,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  _numeroIdentificacionController,
                                  'Número de Identificación',
                                  'Número de identificación',
                                  Icons.numbers,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos del Vehículo
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DEL VEHÍCULO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // VIN con botón de búsqueda
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _vinController,
                                  'VIN / Número de Serie',
                                  'VIN del vehículo',
                                  Icons.confirmation_number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isBuscando ? null : _buscarPorVin,
                                icon:
                                    _isBuscando
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(Icons.search, size: 18),
                                label: Text(
                                  _isBuscando ? 'Buscando...' : 'Buscar',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '💡 Tip: Ingrese el VIN y presione "Buscar VIN" para autocompletar los datos del vehículo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _anoController,
                                  'Año',
                                  'Año del vehículo',
                                  Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  _marcaController,
                                  'Marca',
                                  'Marca del vehículo',
                                  Icons.branding_watermark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _modeloController,
                            'Modelo',
                            'Modelo del vehículo',
                            Icons.directions_car,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón Generar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generarFactura,
                      icon:
                          _isGenerating
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.receipt_long),
                      label: Text(
                        _isGenerating
                            ? 'Generando Factura...'
                            : 'Generar Factura',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }
}

// Pantalla de Compra Venta
class CompraVentaScreen extends StatefulWidget {
  const CompraVentaScreen({super.key});

  @override
  State<CompraVentaScreen> createState() => _CompraVentaScreenState();
}

class _CompraVentaScreenState extends State<CompraVentaScreen> {
  final _formKey = GlobalKey<FormState>();

  // URLs de las APIs de VIN
  static const String apiUrlVin1 =
      "https://script.google.com/macros/s/AKfycbzVNf6KuslXY_V404TLF0Lkp140fsE_uzYu4GQ-fm5fyDJR9hqCyGzIvpbtyL-bcohRVw/exec";
  static const String apiUrlVin2 =
      "https://script.google.com/macros/s/AKfycbxo7DtxpLqNgo2yUl6ooqiUP-GJ683BkkQHOKFy6IVN_iBcaqtfsUto3E3v0dln0iU/exec";

  // Controladores para los campos del contrato
  final _fechaController = TextEditingController();
  final _folioController = TextEditingController();

  // Datos del vehículo
  final _anoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _noSerieController = TextEditingController();
  final _colorController = TextEditingController();

  // Factura
  final _facturaExpedidaPorController = TextEditingController();
  final _fechaFacturaController = TextEditingController();

  // Datos del comprador
  final _nombreCompradorController = TextEditingController();
  final _ineNumeroController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _domicilioController = TextEditingController();

  // Control para mostrar campo INE
  bool _mostrarINE = false;

  // Datos del vendedor
  final _nombreVendedorController = TextEditingController();

  // Precio y forma de pago
  final _precioController = TextEditingController();
  final _precioEscritoController = TextEditingController();

  // Múltiples formas de pago
  bool _pagoEfectivo = false;
  bool _pagoTransferencia = false;
  bool _pagoCreditoFinanciera = false;
  bool _pagoCreditoInterno = false;

  final _montoEfectivoController = TextEditingController();
  final _montoTransferenciaController = TextEditingController();
  final _montoCreditoFinancieraController = TextEditingController();
  final _montoCreditoInternoController = TextEditingController();

  final _financieraController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Nuevos campos adicionales
  final _compromisoCambioController = TextEditingController();
  final _garantiaController = TextEditingController();

  bool _isGenerating = false;
  bool _isBuscandoVin = false;

  // Variables para factura genérica
  bool _generarFacturaGenerica = false;
  bool _facturaManual = false;

  // Controladores para factura genérica manual
  final _facturaLugarController = TextEditingController();
  final _facturaClienteController = TextEditingController();
  final _facturaIdentificacionController = TextEditingController();
  final _facturaMarcaController = TextEditingController();
  final _facturaModeloController = TextEditingController();
  final _facturaAnoController = TextEditingController();
  final _facturaVinController = TextEditingController();

  bool _isBuscandoVinFactura = false;

  @override
  void initState() {
    super.initState();
    // Establecer fecha actual
    final now = DateTime.now();
    _fechaController.text = '${now.day}/${now.month}/${now.year}';
    _fechaFacturaController.text = '${now.day}/${now.month}/${now.year}';

    // Generar folio automático
    _generarFolioAutomatico();

    // Listener para convertir precio a escrito
    _precioController.addListener(_convertirPrecioAEscrito);
    _precioController.addListener(_actualizarCalculos);

    // Listeners para actualizar resumen de pagos
    _montoEfectivoController.addListener(() => setState(() {}));
    _montoTransferenciaController.addListener(() => setState(() {}));
    _montoCreditoFinancieraController.addListener(() => setState(() {}));
    _montoCreditoInternoController.addListener(() => setState(() {}));
  }

  void _actualizarCalculos() {
    // Esta función puede ser utilizada para auto-calcular montos restantes
    // si se implementa esa funcionalidad en el futuro
  }

  void _generarFolioAutomatico() {
    final now = DateTime.now();
    // Formato: LM-DDMMAAHHHMM (LM seguido de día, mes, año, hora, minuto)
    final folio = 'LM-${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    _folioController.text = folio;
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _folioController.dispose();
    _anoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _noSerieController.dispose();
    _colorController.dispose();
    _facturaExpedidaPorController.dispose();
    _fechaFacturaController.dispose();
    _nombreCompradorController.dispose();
    _ineNumeroController.dispose();
    _telefonoController.dispose();
    _domicilioController.dispose();
    _nombreVendedorController.dispose();
    _precioController.dispose();
    _precioEscritoController.dispose();
    _montoEfectivoController.dispose();
    _montoTransferenciaController.dispose();
    _montoCreditoFinancieraController.dispose();
    _montoCreditoInternoController.dispose();
    _financieraController.dispose();
    _observacionesController.dispose();
    _compromisoCambioController.dispose();
    _garantiaController.dispose();
    _facturaLugarController.dispose();
    _facturaClienteController.dispose();
    _facturaIdentificacionController.dispose();
    _facturaMarcaController.dispose();
    _facturaModeloController.dispose();
    _facturaAnoController.dispose();
    _facturaVinController.dispose();
    super.dispose();
  }

  void _convertirPrecioAEscrito() {
    final precio = _precioController.text;
    if (precio.isNotEmpty) {
      try {
        final double valor = double.parse(precio.replaceAll(',', ''));
        _precioEscritoController.text = _numeroALetras(valor);
      } catch (e) {
        _precioEscritoController.text = '';
      }
    } else {
      _precioEscritoController.text = '';
    }
  }

  // Función para formatear números con comas y decimales
  String _formatearCantidad(String cantidad) {
    if (cantidad.isEmpty) return '';
    
    try {
      // Remover comas existentes para parsear
      final double valor = double.parse(cantidad.replaceAll(',', ''));
      
      // Separar la parte entera y decimal
      final partes = valor.toStringAsFixed(2).split('.');
      final parteEntera = partes[0];
      final parteDecimal = partes[1];
      
      // Agregar comas a la parte entera
      String parteEnteraConComas = '';
      for (int i = 0; i < parteEntera.length; i++) {
        if (i > 0 && (parteEntera.length - i) % 3 == 0) {
          parteEnteraConComas += ',';
        }
        parteEnteraConComas += parteEntera[i];
      }
      
      return '$parteEnteraConComas.$parteDecimal';
    } catch (e) {
      return cantidad; // Si hay error, retornar el valor original
    }
  }

  // Función para obtener solo el número sin formato para cálculos
  double _obtenerValorNumerico(String cantidad) {
    if (cantidad.isEmpty) return 0.0;
    
    try {
      return double.parse(cantidad.replaceAll(',', ''));
    } catch (e) {
      return 0.0;
    }
  }

  // Función para obtener la etiqueta del checkbox de INE
  String _obtenerEtiquetaINECheckbox() {
    // Si solo hay efectivo (pago de contado), mostrar opción de licencia
    bool soloEfectivo = _pagoEfectivo && !_pagoTransferencia && !_pagoCreditoFinanciera && !_pagoCreditoInterno;
    
    if (soloEfectivo) {
      return 'Incluir INE/Licencia';
    } else {
      return 'Incluir INE/IFE';
    }
  }

  // Función para obtener la etiqueta del campo de identificación según el tipo de pago
  String _obtenerEtiquetaIdentificacion() {
    // Si solo hay efectivo (pago de contado), mostrar opción de licencia
    bool soloEfectivo = _pagoEfectivo && !_pagoTransferencia && !_pagoCreditoFinanciera && !_pagoCreditoInterno;
    
    if (soloEfectivo) {
      return 'Número de INE/Licencia';
    } else {
      return 'Número de INE/IFE';
    }
  }

  // Función para obtener el placeholder del campo de identificación
  String _obtenerPlaceholderIdentificacion() {
    bool soloEfectivo = _pagoEfectivo && !_pagoTransferencia && !_pagoCreditoFinanciera && !_pagoCreditoInterno;
    
    if (soloEfectivo) {
      return 'Ej: 1234567890123 (13 dígitos del reverso INE/Licencia)';
    } else {
      return 'Ej: 1234567890123 (13 dígitos del reverso INE/IFE)';
    }
  }

  void _llenarDatosDemo() {
    setState(() {
      // Datos del vehículo
      _anoController.text = '2020';
      _marcaController.text = 'TOYOTA';
      _modeloController.text = 'COROLLA';
      _noSerieController.text = '3TMJU4GN1LM123456';
      _colorController.text = 'BLANCO';

      // Factura
      _facturaExpedidaPorController.text = 'TOYOTA DE MÉXICO';

      // Datos del comprador
      _nombreCompradorController.text = 'JUAN CARLOS PÉREZ GARCÍA';
      _mostrarINE = true; // Activar checkbox en datos demo
      _ineNumeroController.text = '1234567890123'; // Ejemplo de 13 dígitos
      _telefonoController.text = '5551234567';
      _domicilioController.text =
          'AV. INSURGENTES SUR 123, COL. CENTRO, CIUDAD DE MÉXICO, CP 06000';

      // Datos del vendedor
      _nombreVendedorController.text = 'DISTRIBUIDORA AUTOMOTRIZ SA DE CV';

      // Precio y forma de pago
      _precioController.text = _formatearCantidad('250000');

      // Configurar formas de pago demo
      _pagoEfectivo = true;
      _pagoTransferencia = true;
      _montoEfectivoController.text = _formatearCantidad('150000');
      _montoTransferenciaController.text = _formatearCantidad('100000');

      // Campos adicionales
      _observacionesController.text =
          'VEHÍCULO EN EXCELENTES CONDICIONES, MANTENIMIENTOS AL CORRIENTE';
      _garantiaController.text = 'GARANTÍA DE 30 DÍAS POR DEFECTOS OCULTOS';

      // Factura genérica
      _generarFacturaGenerica = true;
      _facturaManual = true;
      _facturaLugarController.text = 'CIUDAD DE MÉXICO';
      _facturaClienteController.text = 'JUAN CARLOS PÉREZ GARCÍA';
      _facturaIdentificacionController.text = 'RFC: PEGJ850715ABC';
      _facturaMarcaController.text = 'TOYOTA';
      _facturaModeloController.text = 'COROLLA';
      _facturaAnoController.text = '2020';
      _facturaVinController.text = '3TMJU4GN1LM123456';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Datos demo cargados correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Función para buscar datos por VIN usando la misma API
  Future<void> _buscarPorVin() async {
    print("🚀 CompraVenta - Iniciando búsqueda por VIN");
    final vinParcial = _noSerieController.text.trim();

    if (vinParcial.isEmpty) {
      print("⚠️ CompraVenta - VIN vacío");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor ingrese un VIN para buscar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("🔍 CompraVenta - VIN a buscar: '$vinParcial'");
    setState(() {
      _isBuscandoVin = true;
    });

    try {
      // Intentar con la primera API
      bool datoEncontrado = await _buscarEnAPICompra(
        apiUrlVin1,
        vinParcial,
        "API 1",
      );

      // Si no encontró datos, intentar con la segunda API
      if (!datoEncontrado) {
        print("🔄 CompraVenta - Intentando con segunda API...");
        await _buscarEnAPICompra(apiUrlVin2, vinParcial, "API 2");
      }
    } catch (e) {
      print("❌ CompraVenta - Error en búsqueda VIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al buscar VIN: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBuscandoVin = false;
      });
    }
  }

  // Función auxiliar para buscar en una API específica
  Future<bool> _buscarEnAPICompra(
    String apiUrl,
    String vinParcial,
    String nombreAPI,
  ) async {
    try {
      final url = Uri.parse('$apiUrl?vin=$vinParcial');

      final response = await http
          .get(url, headers: {'User-Agent': 'Flutter App/1.0'})
          .timeout(const Duration(seconds: 10));

      print("📡 CompraVenta $nombreAPI - Status Code: ${response.statusCode}");
      print("📋 CompraVenta $nombreAPI - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("🔍 CompraVenta $nombreAPI - Datos recibidos: $data");

        // Verificar si tenemos datos válidos (al menos marca y modelo)
        if (data.containsKey('campoB') &&
            data['campoB'] != null &&
            data['campoB'].toString().isNotEmpty) {
          setState(() {
            // Mapeo de campos basado en la API real
            _anoController.text = data['campoA']?.toString() ?? '';
            _marcaController.text = data['campoB']?.toString() ?? '';
            _modeloController.text = data['campoC']?.toString() ?? '';
            _colorController.text = data['campoJ']?.toString() ?? '';
            // El VIN se mantiene como está o se actualiza con el completo
            if (data['campoK'] != null &&
                data['campoK'].toString().isNotEmpty) {
              _noSerieController.text = data['campoK'].toString();
            }
          });

          print(
            "✅ CompraVenta $nombreAPI - Datos cargados correctamente: Año=${_anoController.text}, Marca=${_marcaController.text}, Modelo=${_modeloController.text}, Color=${_colorController.text}",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Datos encontrados en $nombreAPI y completados'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          print(
            "❌ CompraVenta $nombreAPI - No se encontraron datos válidos en la respuesta",
          );
          return false;
        }
      } else {
        print(
          "❌ CompraVenta $nombreAPI - Error del servidor: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("❌ CompraVenta $nombreAPI - Error: $e");
      return false;
    }
  }

  String _numeroALetras(double numero) {
    if (numero == 0) return 'CERO PESOS';

    final entero = numero.floor();
    final decimal = ((numero - entero) * 100).round();

    String resultado = _convertirEntero(entero);

    if (entero == 1) {
      resultado += ' PESO';
    } else {
      resultado += ' PESOS';
    }

    if (decimal > 0) {
      resultado += ' CON $decimal/100 M.N.';
    } else {
      resultado += ' 00/100 M.N.';
    }

    return resultado;
  }

  String _convertirEntero(int numero) {
    if (numero == 0) return 'CERO';

    final unidades = [
      '',
      'UNO',
      'DOS',
      'TRES',
      'CUATRO',
      'CINCO',
      'SEIS',
      'SIETE',
      'OCHO',
      'NUEVE',
    ];
    final decenas = [
      '',
      '',
      'VEINTE',
      'TREINTA',
      'CUARENTA',
      'CINCUENTA',
      'SESENTA',
      'SETENTA',
      'OCHENTA',
      'NOVENTA',
    ];
    final especiales = [
      'DIEZ',
      'ONCE',
      'DOCE',
      'TRECE',
      'CATORCE',
      'QUINCE',
      'DIECISÉIS',
      'DIECISIETE',
      'DIECIOCHO',
      'DIECINUEVE',
    ];
    final centenas = [
      '',
      'CIENTO',
      'DOSCIENTOS',
      'TRESCIENTOS',
      'CUATROCIENTOS',
      'QUINIENTOS',
      'SEISCIENTOS',
      'SETECIENTOS',
      'OCHOCIENTOS',
      'NOVECIENTOS',
    ];

    if (numero < 10) return unidades[numero];
    if (numero < 20) return especiales[numero - 10];
    if (numero < 100) {
      final d = numero ~/ 10;
      final u = numero % 10;
      return decenas[d] + (u > 0 ? ' Y ${unidades[u]}' : '');
    }
    if (numero < 1000) {
      final c = numero ~/ 100;
      final resto = numero % 100;
      String resultado = (numero == 100) ? 'CIEN' : centenas[c];
      if (resto > 0) resultado += ' ${_convertirEntero(resto)}';
      return resultado;
    }
    if (numero < 1000000) {
      final miles = numero ~/ 1000;
      final resto = numero % 1000;
      String resultado =
          (miles == 1) ? 'MIL' : '${_convertirEntero(miles)} MIL';
      if (resto > 0) resultado += ' ${_convertirEntero(resto)}';
      return resultado;
    }

    return 'CANTIDAD MUY GRANDE';
  }

  // Función para obtener la primera línea de observaciones (máximo 120 caracteres)
  String _obtenerPrimeraLineaObservaciones() {
    final observaciones = _observacionesController.text.trim();
    if (observaciones.isEmpty) return '';

    const int maxCaracteresPrimeraLinea = 120;

    if (observaciones.length <= maxCaracteresPrimeraLinea) {
      return observaciones;
    }

    // Buscar el último espacio antes del límite para no cortar palabras
    int puntoCorte = maxCaracteresPrimeraLinea;
    for (int i = maxCaracteresPrimeraLinea; i > 0; i--) {
      if (observaciones[i] == ' ') {
        puntoCorte = i;
        break;
      }
    }

    return observaciones.substring(0, puntoCorte);
  }

  // Función para obtener la segunda línea de observaciones
  String _obtenerSegundaLineaObservaciones() {
    final observaciones = _observacionesController.text.trim();
    if (observaciones.isEmpty) return '';

    const int maxCaracteresPrimeraLinea = 120;

    if (observaciones.length <= maxCaracteresPrimeraLinea) {
      return '';
    }

    // Buscar el último espacio antes del límite para no cortar palabras
    int puntoCorte = maxCaracteresPrimeraLinea;
    for (int i = maxCaracteresPrimeraLinea; i > 0; i--) {
      if (observaciones[i] == ' ') {
        puntoCorte = i;
        break;
      }
    }

    // Retornar el resto del texto, eliminando el espacio inicial si existe
    String segundaLinea = observaciones.substring(puntoCorte).trim();

    // Limitar la segunda línea también para que no se salga del espacio disponible
    const int maxCaracteresSegundaLinea = 120;
    if (segundaLinea.length > maxCaracteresSegundaLinea) {
      segundaLinea = segundaLinea.substring(0, maxCaracteresSegundaLinea);
      // Buscar el último espacio para no cortar palabras
      for (int i = maxCaracteresSegundaLinea; i > 0; i--) {
        if (segundaLinea[i] == ' ') {
          segundaLinea = segundaLinea.substring(0, i);
          break;
        }
      }
    }

    return segundaLinea;
  }

  // Funciones auxiliares para compromiso de cambio
  String _obtenerPrimeraLineaCompromiso() {
    // Para compromiso de cambio, mostramos todo el texto en una sola línea sin dividir
    return _compromisoCambioController.text.trim();
  }

  // Funciones auxiliares para garantía
  String _obtenerPrimeraLineaGarantia() {
    return _obtenerPrimeraLineaTexto(_garantiaController.text.trim());
  }

  String _obtenerSegundaLineaGarantia() {
    return _obtenerSegundaLineaTexto(_garantiaController.text.trim());
  }

  // Función genérica para obtener primera línea de cualquier texto
  String _obtenerPrimeraLineaTexto(String texto) {
    if (texto.isEmpty) return '';

    const int maxCaracteresPrimeraLinea = 120;

    if (texto.length <= maxCaracteresPrimeraLinea) {
      return texto;
    }

    // Buscar el último espacio antes del límite para no cortar palabras
    int puntoCorte = maxCaracteresPrimeraLinea;
    for (int i = maxCaracteresPrimeraLinea; i > 0; i--) {
      if (texto[i] == ' ') {
        puntoCorte = i;
        break;
      }
    }

    return texto.substring(0, puntoCorte);
  }

  // Función genérica para obtener segunda línea de cualquier texto
  String _obtenerSegundaLineaTexto(String texto) {
    if (texto.isEmpty) return '';

    const int maxCaracteresPrimeraLinea = 120;

    if (texto.length <= maxCaracteresPrimeraLinea) {
      return '';
    }

    // Buscar el último espacio antes del límite para no cortar palabras
    int puntoCorte = maxCaracteresPrimeraLinea;
    for (int i = maxCaracteresPrimeraLinea; i > 0; i--) {
      if (texto[i] == ' ') {
        puntoCorte = i;
        break;
      }
    }

    // Retornar el resto del texto, eliminando el espacio inicial si existe
    String segundaLinea = texto.substring(puntoCorte).trim();

    // Limitar la segunda línea también para que no se salga del espacio disponible
    const int maxCaracteresSegundaLinea = 120;
    if (segundaLinea.length > maxCaracteresSegundaLinea) {
      segundaLinea = segundaLinea.substring(0, maxCaracteresSegundaLinea);
      // Buscar el último espacio para no cortar palabras
      for (int i = maxCaracteresSegundaLinea; i > 0; i--) {
        if (segundaLinea[i] == ' ') {
          segundaLinea = segundaLinea.substring(0, i);
          break;
        }
      }
    }

    return segundaLinea;
  }

  Widget _buildResumenPagos() {
    double precioTotal = _obtenerValorNumerico(_precioController.text);
    double montoTotal = 0.0;

    List<Widget> resumenItems = [];

    if (_pagoEfectivo) {
      double monto = _obtenerValorNumerico(_montoEfectivoController.text);
      montoTotal += monto;
      resumenItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('• Efectivo:', style: TextStyle(fontSize: 12)),
            Text(
              '\$${_formatearCantidad(monto.toString())}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_pagoTransferencia) {
      double monto = _obtenerValorNumerico(_montoTransferenciaController.text);
      montoTotal += monto;
      resumenItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('• Transferencia:', style: TextStyle(fontSize: 12)),
            Text(
              '\$${_formatearCantidad(monto.toString())}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_pagoCreditoFinanciera) {
      double monto = _obtenerValorNumerico(_montoCreditoFinancieraController.text);
      montoTotal += monto;
      resumenItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('• Monto de Enganche:', style: TextStyle(fontSize: 12)),
            Text(
              '\$${_formatearCantidad(monto.toString())}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_pagoCreditoInterno) {
      double monto = _obtenerValorNumerico(_montoCreditoInternoController.text);
      montoTotal += monto;
      resumenItems.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('• Crédito Interno:', style: TextStyle(fontSize: 12)),
            Text(
              '\$${_formatearCantidad(monto.toString())}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (resumenItems.isEmpty) {
      return const Text(
        'Seleccione formas de pago para ver el resumen',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    double diferencia = precioTotal - montoTotal;
    Color colorDiferencia =
        diferencia.abs() < 0.01
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

    return Column(
      children: [
        ...resumenItems,
        if (resumenItems.isNotEmpty) ...[
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total de pagos:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${_formatearCantidad(montoTotal.toString())}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precio total:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '\$${_formatearCantidad(precioTotal.toString())}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (diferencia.abs() > 0.01) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  diferencia > 0 ? 'Faltante:' : 'Excedente:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorDiferencia,
                  ),
                ),
                Text(
                  '\$${_formatearCantidad(diferencia.abs().toString())}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorDiferencia,
                  ),
                ),
              ],
            ),
          ] else if (montoTotal > 0) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 4),
                Text(
                  'Pagos cuadrados ✓',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  void _generarContrato() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isGenerating = true;
      });

      try {
        // Validar que al menos una forma de pago esté seleccionada
        if (!_pagoEfectivo &&
            !_pagoTransferencia &&
            !_pagoCreditoFinanciera &&
            !_pagoCreditoInterno) {
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Debe seleccionar al menos una forma de pago'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Validar que los montos sumen el precio total
        double montoTotal = 0.0;
        if (_pagoEfectivo && _montoEfectivoController.text.isNotEmpty) {
          montoTotal += _obtenerValorNumerico(_montoEfectivoController.text);
        }
        if (_pagoTransferencia &&
            _montoTransferenciaController.text.isNotEmpty) {
          montoTotal += _obtenerValorNumerico(_montoTransferenciaController.text);
        }
        if (_pagoCreditoFinanciera &&
            _montoCreditoFinancieraController.text.isNotEmpty) {
          montoTotal += _obtenerValorNumerico(_montoCreditoFinancieraController.text);
        }
        if (_pagoCreditoInterno &&
            _montoCreditoInternoController.text.isNotEmpty) {
          montoTotal += _obtenerValorNumerico(_montoCreditoInternoController.text);
        }

        double precioVenta = _obtenerValorNumerico(_precioController.text);
        if ((montoTotal - precioVenta).abs() > 0.01 && montoTotal > 0) {
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Los montos de pago (\$${_formatearCantidad(montoTotal.toString())}) no coinciden con el precio total (\$${_formatearCantidad(precioVenta.toString())})',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Construir formas de pago para el contrato
        List<String> formasPago = [];
        if (_pagoEfectivo) {
          String monto =
              _montoEfectivoController.text.isNotEmpty
                  ? ' (\$${_montoEfectivoController.text})'
                  : '';
          formasPago.add('Efectivo$monto');
        }
        if (_pagoTransferencia) {
          String monto =
              _montoTransferenciaController.text.isNotEmpty
                  ? ' (\$${_montoTransferenciaController.text})'
                  : '';
          formasPago.add('Transferencia$monto');
        }
        if (_pagoCreditoFinanciera) {
          String monto =
              _montoCreditoFinancieraController.text.isNotEmpty
                  ? ' (\$${_montoCreditoFinancieraController.text})'
                  : '';
          String financiera =
              _financieraController.text.isNotEmpty
                  ? ' - ${_financieraController.text}'
                  : '';
          formasPago.add('Enganche$monto$financiera');
        }
        if (_pagoCreditoInterno) {
          String monto =
              _montoCreditoInternoController.text.isNotEmpty
                  ? ' (\$${_montoCreditoInternoController.text})'
                  : '';
          formasPago.add('Crédito Interno$monto');
        }

        // Mostrar preview del contrato antes de generar el PDF
        await _mostrarPreviewContrato(formasPago);
      } catch (e) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al preparar el contrato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Función para mostrar preview del contrato con la imagen de fondo
  Future<void> _mostrarPreviewContrato(List<String> formasPago) async {
    final contratoWidget = await _construirContratoWidget(formasPago);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                // Header del preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.preview, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Vista Previa del Contrato',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isGenerating = false;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Preview del contrato
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SingleChildScrollView(child: contratoWidget),
                    ),
                  ),
                ),

                // Botones de acción
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isGenerating = false;
                          });
                        },
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _generarPDFContrato(formasPago);
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generar PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para construir el widget visual del contrato
  Future<Widget> _construirContratoWidget(List<String> formasPago) async {
    return Container(
      width: 800,
      height: 1000,
      child: Stack(
        children: [
          // Imagen de fondo del contrato
          Positioned.fill(
            child: Image.asset(
              'assets/compra-venta.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                        Text(
                          'Imagen de fondo no encontrada',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'compra-venta.png (desde assets)',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Textos posicionados según el layout descrito

          // FECHA (arriba a la derecha)
          Positioned(
            right: 165,
            top: 80,
            child: Text(
              _fechaController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // FOLIO (arriba a la derecha, al lado de fecha)
          Positioned(
            right: 63,
            top: 80,
            child: Text(
              _folioController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // PRIMERA LÍNEA: AÑO, MARCA, MODELO
          Positioned(
            left: 110,
            top: 103,
            child: Text(
              _anoController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 360,
            top: 103,
            child: Text(
              _marcaController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 620,
            top: 103,
            child: Text(
              _modeloController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // SEGUNDA LÍNEA: N SERIE, COLOR
          Positioned(
            left: 155,
            top: 121,
            child: Text(
              _noSerieController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 540,
            top: 121,
            child: Text(
              _colorController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // TERCERA LÍNEA: FACTURA EXPEDIDA POR, DE FECHA
          Positioned(
            left: 220,
            top: 135,
            child: Text(
              _facturaExpedidaPorController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 600,
            top: 137,
            child: Text(
              _fechaFacturaController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // CUARTA LÍNEA: NOMBRE COMPRADOR
          Positioned(
            left: 230,
            top: 175,
            child: Text(
              _nombreCompradorController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // QUINTA LÍNEA: INE/LICENCIA, TELEFONO
          if (_mostrarINE)
            Positioned(
              left: 150,
              top: 191,
              child: Text(
                _ineNumeroController.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

          Positioned(
            left: 550,
            top: 192,
            child: Text(
              _telefonoController.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // SEXTA LÍNEA: DOMICILIO
          Positioned(
            left: 140,
            top: 208,
            child: Container(
              width: 500,
              child: Text(
                _domicilioController.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // SÉPTIMA LÍNEA: PRECIO VENTA CANTIDAD, ESCRITO
          Positioned(
            left: 190,
            top: 253,
            child: Text(
              '\$${_formatearCantidad(_precioController.text)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 320,
            top: 253,
            child: Container(
              width: 300,
              child: Text(
                _precioEscritoController.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // OCTAVA LÍNEA: EFECTIVO, TRANSFERENCIA
          Positioned(
            left: 140,
            top: 267,
            child: Text(
              _pagoEfectivo
                  ? (_montoEfectivoController.text.isNotEmpty
                      ? '\$${_formatearCantidad(_montoEfectivoController.text)}'
                      : 'Sí')
                  : '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 490,
            top: 267,
            child: Text(
              _pagoTransferencia
                  ? (_montoTransferenciaController.text.isNotEmpty
                      ? '\$${_formatearCantidad(_montoTransferenciaController.text)}'
                      : 'Sí')
                  : '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // NOVENA LÍNEA: ENGANCHE, CRÉDITO INTERNO
          Positioned(
            left: 240,
            top: 285,
            child: Text(
              _pagoCreditoFinanciera
                  ? (_montoCreditoFinancieraController.text.isNotEmpty
                      ? '\$${_formatearCantidad(_montoCreditoFinancieraController.text)}'
                      : 'Sí')
                  : '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Positioned(
            left: 550,
            top: 285,
            child: Text(
              _pagoCreditoInterno
                  ? (_montoCreditoInternoController.text.isNotEmpty
                      ? '\$${_formatearCantidad(_montoCreditoInternoController.text)}'
                      : 'Sí')
                  : '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // LÍNEA ADICIONAL: NOMBRE DE LA FINANCIERA (separada del monto)
          Positioned(
            left: 300,
            top: 286,
            child: Text(
              _pagoCreditoFinanciera && _financieraController.text.isNotEmpty
                  ? '${_financieraController.text}'
                  : '',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // DÉCIMA LÍNEA: OBSERVACIONES (Primera línea)
          Positioned(
            left: 180,
            top: 304,
            child: Container(
              width: 500,
              child: Text(
                _obtenerPrimeraLineaObservaciones(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // DÉCIMA LÍNEA: OBSERVACIONES (Segunda línea)
          Positioned(
            left: 80,
            top: 320,
            child: Container(
              width: 500,
              child: Text(
                _obtenerSegundaLineaObservaciones(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // CAMPOS ADICIONALES: COMPROMISO DE CAMBIO (Una línea)
          Positioned(
            left: 60,
            top: 510,
            child: Container(
              width: 500,
              child: Text(
                _obtenerPrimeraLineaCompromiso(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // CAMPOS ADICIONALES: GARANTÍA (Primera línea)
          Positioned(
            left: 60,
            top: 640,
            child: Container(
              width: 500,
              child: Text(
                _obtenerPrimeraLineaGarantia(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // CAMPOS ADICIONALES: GARANTÍA (Segunda línea)
          Positioned(
            left: 80,
            top: 740,
            child: Container(
              width: 500,
              child: Text(
                _obtenerSegundaLineaGarantia(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // NOMBRE DEL VENDEDOR (Solo texto en preview)
          if (_nombreVendedorController.text.isNotEmpty)
            Positioned(
              left: 180,
              top: 893,
              child: Text(
                _nombreVendedorController.text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Función para generar el PDF del contrato
  Future<void> _generarPDFContrato(List<String> formasPago) async {
    try {
      // Generar el PDF
      final pdfBytes = await _generarPDFContratoBytes();

      // Descargar/compartir el PDF según la plataforma
      final nombreArchivo =
          'contrato_${_folioController.text.isNotEmpty ? _folioController.text : DateTime.now().millisecondsSinceEpoch}.pdf';
      await _descargarOCompartirPDF(pdfBytes, nombreArchivo);

      setState(() {
        _isGenerating = false;
      });

      String mensaje =
          '✅ Contrato de compra-venta generado exitosamente como PDF';

      // Generar factura genérica si está habilitada
      if (_generarFacturaGenerica) {
        await _generarFacturaGenericaAutomatica();
        mensaje += '\n📄 Factura genérica también generada';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al generar el PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Función para generar el PDF del contrato y retornar los bytes
  Future<Uint8List> _generarPDFContratoBytes() async {
    // Crear el PDF con la imagen de fondo y textos posicionados
    final pdf = pw.Document();

    // Cargar fuente TTF
    pw.Font? fontRegular;
    try {
      final ByteData fontData = await rootBundle.load(
        'assets/BebasNeue-Regular.ttf',
      );
      fontRegular = pw.Font.ttf(fontData);
    } catch (e) {
      print("⚠️ No se pudo cargar fuente TTF: $e");
    }

    // Cargar imagen de fondo del contrato
    pw.MemoryImage? imagenContrato;
    try {
      // Cargar desde assets para todas las plataformas
      print("📁 Cargando imagen de contrato desde assets...");
      final ByteData contratoData = await rootBundle.load('assets/compra-venta.png');
      final Uint8List contratoBytes = contratoData.buffer.asUint8List();
      imagenContrato = pw.MemoryImage(contratoBytes);
      print("✅ Imagen de contrato cargada desde assets");
    } catch (e) {
      print("⚠️ No se pudo cargar imagen de contrato desde assets: $e");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                if (imagenContrato != null)
                  // Imagen que llena toda la página
                  pw.Positioned.fill(
                    child: pw.Image(
                      imagenContrato,
                      fit: pw.BoxFit.fill, // Forzar que llene toda la página
                    ),
                  )
                else
                  pw.Positioned.fill(
                    child: pw.Container(
                      color: PdfColors.white,
                      child: pw.Center(
                        child: pw.Text(
                          'CONTRATO DE COMPRA-VENTA',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            font: fontRegular,
                          ),
                        ),
                      ),
                    ),
                  ),

                // FECHA (arriba a la derecha)
                pw.Positioned(
                  right: 130,
                  top: 71,
                  child: pw.Text(
                    _fechaController.text,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      font: fontRegular,
                    ),
                  ),
                ),

                // FOLIO (arriba a la derecha, junto a fecha)
                pw.Positioned(
                  right: 50,
                  top: 71,
                  child: pw.Text(
                    _folioController.text,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      font: fontRegular,
                    ),
                  ),
                ),

                // PRIMERA LÍNEA: AÑO - MARCA - MODELO
                pw.Positioned(
                  left: 75,
                  top: 91,
                  child: pw.Text(
                    _anoController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  left: 270,
                  top: 91,
                  child: pw.Text(
                    _marcaController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  left: 460,
                  top: 91,
                  child: pw.Text(
                    _modeloController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // SEGUNDA LÍNEA: N° SERIE - COLOR
                pw.Positioned(
                  left: 120,
                  top: 104,
                  child: pw.Text(
                    _noSerieController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  right: 160,
                  top: 104,
                  child: pw.Text(
                    _colorController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // TERCERA LÍNEA: FACTURA EXPEDIDA POR - DE FECHA
                pw.Positioned(
                  left: 160,
                  top: 118,
                  child: pw.Text(
                    _facturaExpedidaPorController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  left: 430,
                  top: 120,
                  child: pw.Text(
                    _fechaFacturaController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // CUARTA LÍNEA: NOMBRE COMPRADOR
                pw.Positioned(
                  left: 170,
                  top: 151,
                  child: pw.Text(
                    _nombreCompradorController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // QUINTA LÍNEA: INE/LICENCIA - TELEFONO
                if (_mostrarINE)
                  pw.Positioned(
                    left: 110,
                    top: 165,
                    child: pw.Text(
                      _ineNumeroController.text,
                      style: pw.TextStyle(fontSize: 9, font: fontRegular),
                    ),
                  ),
                pw.Positioned(
                  left: 420,
                  top: 165,
                  child: pw.Text(
                    _telefonoController.text,
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // SEXTA LÍNEA: DOMICILIO
                pw.Positioned(
                  left: 100,
                  top: 178,
                  child: pw.Container(
                    width: 450,
                    child: pw.Text(
                      _domicilioController.text,
                      style: pw.TextStyle(fontSize: 9, font: fontRegular),
                    ),
                  ),
                ),

                // SÉPTIMA LÍNEA: PRECIO VENTA CANTIDAD - ESCRITO
                pw.Positioned(
                  left: 135,
                  top: 216,
                  child: pw.Text(
                    '\$${_formatearCantidad(_precioController.text)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      font: fontRegular,
                    ),
                  ),
                ),
                pw.Positioned(
                  left: 230,
                  top: 216,
                  child: pw.Container(
                    width: 250,
                    child: pw.Text(
                      _precioEscritoController.text,
                      style: pw.TextStyle(fontSize: 9, font: fontRegular),
                    ),
                  ),
                ),

                // OCTAVA LÍNEA: EFECTIVO - TRANSFERENCIA
                pw.Positioned(
                  left: 100,
                  top: 229,
                  child: pw.Text(
                    _pagoEfectivo
                        ? (_montoEfectivoController.text.isNotEmpty
                            ? '\$${_formatearCantidad(_montoEfectivoController.text)}'
                            : 'Sí')
                        : '',
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  left: 370,
                  top: 229,
                  child: pw.Text(
                    _pagoTransferencia
                        ? (_montoTransferenciaController.text.isNotEmpty
                            ? '\$${_formatearCantidad(_montoTransferenciaController.text)}'
                            : 'Sí')
                        : '',
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // NOVENA LÍNEA: ENGANCHE - CRÉDITO INTERNO
                pw.Positioned(
                  left: 180,
                  top: 245,
                  child: pw.Text(
                    _pagoCreditoFinanciera
                        ? (_montoCreditoFinancieraController.text.isNotEmpty
                            ? '\$${_formatearCantidad(_montoCreditoFinancieraController.text)}'
                            : 'Sí')
                        : '',
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),
                pw.Positioned(
                  left: 410,
                  top: 245,
                  child: pw.Text(
                    _pagoCreditoInterno
                        ? (_montoCreditoInternoController.text.isNotEmpty
                            ? '\$${_formatearCantidad(_montoCreditoInternoController.text)}'
                            : 'Sí')
                        : '',
                    style: pw.TextStyle(fontSize: 9, font: fontRegular),
                  ),
                ),

                // LÍNEA ADICIONAL: NOMBRE DE LA FINANCIERA (separada del monto)
                if (_pagoCreditoFinanciera &&
                    _financieraController.text.isNotEmpty)
                  pw.Positioned(
                    left: 220,
                    top: 245,
                    child: pw.Text(
                      '${_financieraController.text}',
                      style: pw.TextStyle(fontSize: 8, font: fontRegular),
                    ),
                  ),

                // DÉCIMA LÍNEA: OBSERVACIONES (Primera línea)
                if (_obtenerPrimeraLineaObservaciones().isNotEmpty)
                  pw.Positioned(
                    left: 130,
                    top: 260,
                    child: pw.Container(
                      width: 400,
                      child: pw.Text(
                        _obtenerPrimeraLineaObservaciones(),
                        style: pw.TextStyle(fontSize: 8, font: fontRegular),
                      ),
                    ),
                  ),

                // DÉCIMA LÍNEA: OBSERVACIONES (Segunda línea)
                if (_obtenerSegundaLineaObservaciones().isNotEmpty)
                  pw.Positioned(
                    left: 60,
                    top: 275,
                    child: pw.Container(
                      width: 400,
                      child: pw.Text(
                        _obtenerSegundaLineaObservaciones(),
                        style: pw.TextStyle(fontSize: 8, font: fontRegular),
                      ),
                    ),
                  ),

                // CAMPOS ADICIONALES: COMPROMISO DE CAMBIO (Una línea)
                if (_obtenerPrimeraLineaCompromiso().isNotEmpty)
                  pw.Positioned(
                    left: 40,
                    top: 430,
                    child: pw.Container(
                      width: 450,
                      child: pw.Text(
                        _obtenerPrimeraLineaCompromiso(),
                        style: pw.TextStyle(fontSize: 8, font: fontRegular),
                      ),
                    ),
                  ),

                // CAMPOS ADICIONALES: GARANTÍA (Primera línea)
                if (_obtenerPrimeraLineaGarantia().isNotEmpty)
                  pw.Positioned(
                    left: 50,
                    top: 545,
                    child: pw.Container(
                      width: 450,
                      child: pw.Text(
                        _obtenerPrimeraLineaGarantia(),
                        style: pw.TextStyle(fontSize: 8, font: fontRegular),
                      ),
                    ),
                  ),

                // CAMPOS ADICIONALES: GARANTÍA (Segunda línea)
                if (_obtenerSegundaLineaGarantia().isNotEmpty)
                  pw.Positioned(
                    left: 40,
                    top: 740,
                    child: pw.Container(
                      width: 450,
                      child: pw.Text(
                        _obtenerSegundaLineaGarantia(),
                        style: pw.TextStyle(fontSize: 8, font: fontRegular),
                      ),
                    ),
                  ),

                // NOMBRE DEL VENDEDOR (Solo texto)
                if (_nombreVendedorController.text.isNotEmpty)
                  pw.Positioned(
                    left: 60,
                    top: 762,
                    child: pw.Text(
                      _nombreVendedorController.text,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        font: fontRegular,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );

    // Convertir PDF a bytes y retornar
    return await pdf.save();
  }

  // Función universal para descargar/compartir PDF según la plataforma
  Future<void> _descargarOCompartirPDF(
    Uint8List pdfBytes,
    String nombreArchivo,
  ) async {
    try {
      if (kIsWeb) {
        // En web: descargar directamente
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = nombreArchivo;
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print("✅ PDF descargado en navegador: $nombreArchivo");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📥 PDF descargado: $nombreArchivo'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // En móvil: guardar y compartir
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$nombreArchivo');
        await file.writeAsBytes(pdfBytes);

        // Compartir el archivo
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Contrato de compra-venta generado',
          subject: 'Documento PDF - $nombreArchivo',
        );

        print("✅ PDF compartido en móvil: $nombreArchivo");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📤 PDF compartido: $nombreArchivo'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error al descargar/compartir PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al manejar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para generar factura genérica automáticamente
  Future<void> _generarFacturaGenericaAutomatica() async {
    try {
      String fecha = _fechaController.text;
      String lugar =
          _facturaLugarController.text.isNotEmpty
              ? _facturaLugarController.text
              : 'México'; // Valor por defecto

      // Usar datos manuales si está en modo manual, sino usar los del contrato
      String cliente =
          _facturaManual && _facturaClienteController.text.isNotEmpty
              ? _facturaClienteController.text
              : _nombreCompradorController.text;

      String identificacion =
          _facturaManual && _facturaIdentificacionController.text.isNotEmpty
              ? _facturaIdentificacionController.text
              : _ineNumeroController.text;

      String marca =
          _facturaManual && _facturaMarcaController.text.isNotEmpty
              ? _facturaMarcaController.text
              : _marcaController.text;

      String modelo =
          _facturaManual && _facturaModeloController.text.isNotEmpty
              ? _facturaModeloController.text
              : _modeloController.text;

      String ano =
          _facturaManual && _facturaAnoController.text.isNotEmpty
              ? _facturaAnoController.text
              : _anoController.text;

      String vin =
          _facturaManual && _facturaVinController.text.isNotEmpty
              ? _facturaVinController.text
              : _noSerieController.text;

      String vehiculo = '$marca $modelo $ano';
      String precio = _precioController.text;

      String facturaContent = '''
FACTURA GENÉRICA

Fecha: $fecha
Lugar: $lugar

DATOS DEL CLIENTE:
Nombre Completo: $cliente
Tipo y Número de Identificación: INE/IFE - $identificacion

DATOS DEL VEHÍCULO:
Marca, Modelo, Año: $vehiculo
Número de Serie (VIN): $vin

MONTO:
Precio: \$$precio

OBSERVACIONES:
${_observacionesController.text.isEmpty ? 'Ninguna' : _observacionesController.text}

COMPROMISO DE CAMBIO DE PROPIETARIO:
${_compromisoCambioController.text.isEmpty ? 'No especificado' : _compromisoCambioController.text}

GARANTÍA:
${_garantiaController.text.isEmpty ? 'No especificada' : _garantiaController.text}

____________________________
Firma Autorizada
      ''';

      // Simular generación de factura
      await Future.delayed(const Duration(seconds: 1));

      print("✅ Factura genérica generada automáticamente:");
      print(facturaContent);
    } catch (e) {
      print("❌ Error al generar factura genérica: $e");
      throw e;
    }
  }

  // Función para buscar datos por VIN en factura genérica
  Future<void> _buscarPorVinFactura() async {
    print("🚀 Factura - Iniciando búsqueda por VIN");
    final vinParcial = _facturaVinController.text.trim();

    if (vinParcial.isEmpty) {
      print("⚠️ Factura - VIN vacío");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Por favor ingrese un VIN para buscar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("🔍 Factura - VIN a buscar: '$vinParcial'");
    setState(() {
      _isBuscandoVinFactura = true;
    });

    try {
      // Intentar con la primera API
      bool datoEncontrado = await _buscarEnAPIFactura(
        apiUrlVin1,
        vinParcial,
        "API 1",
      );

      // Si no encontró datos, intentar con la segunda API
      if (!datoEncontrado) {
        print("🔄 Factura - Intentando con segunda API...");
        await _buscarEnAPIFactura(apiUrlVin2, vinParcial, "API 2");
      }
    } catch (e) {
      print("❌ Factura - Error en búsqueda VIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al buscar VIN: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBuscandoVinFactura = false;
      });
    }
  }

  // Función auxiliar para buscar en una API específica para facturas
  Future<bool> _buscarEnAPIFactura(
    String apiUrl,
    String vinParcial,
    String nombreAPI,
  ) async {
    try {
      final url = Uri.parse('$apiUrl?vin=$vinParcial');

      final response = await http
          .get(url, headers: {'User-Agent': 'Flutter App/1.0'})
          .timeout(const Duration(seconds: 10));

      print("📡 Factura $nombreAPI - Status Code: ${response.statusCode}");
      print("📋 Factura $nombreAPI - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("🔍 Factura $nombreAPI - Datos recibidos: $data");

        // Verificar si tenemos datos válidos (al menos marca y modelo)
        if (data.containsKey('campoB') &&
            data['campoB'] != null &&
            data['campoB'].toString().isNotEmpty) {
          setState(() {
            // Mapeo de campos basado en la API real
            _facturaAnoController.text = data['campoA']?.toString() ?? '';
            _facturaMarcaController.text = data['campoB']?.toString() ?? '';
            _facturaModeloController.text = data['campoC']?.toString() ?? '';
            // El VIN se mantiene como está o se actualiza con el completo
            if (data['campoK'] != null &&
                data['campoK'].toString().isNotEmpty) {
              _facturaVinController.text = data['campoK'].toString();
            }
          });

          print(
            "✅ Factura $nombreAPI - Datos cargados correctamente: Año=${_facturaAnoController.text}, Marca=${_facturaMarcaController.text}, Modelo=${_facturaModeloController.text}",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Datos encontrados en $nombreAPI y completados'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        } else {
          print(
            "❌ Factura $nombreAPI - No se encontraron datos válidos en la respuesta",
          );
          return false;
        }
      } else {
        print(
          "❌ Factura $nombreAPI - Error del servidor: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("❌ Factura $nombreAPI - Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Contrato de Compra-Venta',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B),
                          const Color(0xFFD97706),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Logo en header de compra-venta
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.handshake,
                                    size: 30,
                                    color: Color(0xFFF59E0B),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Generador de Contratos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón Demo
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _llenarDatosDemo,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text(
                        'LLENAR DATOS DEMO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información General
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Color(0xFF3B82F6)),
                              const SizedBox(width: 8),
                              const Text(
                                'INFORMACIÓN GENERAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _fechaController,
                                  'Fecha',
                                  'DD/MM/AAAA',
                                  Icons.calendar_today,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        _folioController,
                                        'Folio',
                                        'Generado automáticamente',
                                        Icons.confirmation_number,
                                        null,
                                        true, // readOnly
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _generarFolioAutomatico();
                                        });
                                      },
                                      icon: const Icon(Icons.refresh),
                                      tooltip: 'Regenerar folio',
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos del Vehículo
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DEL VEHÍCULO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _anoController,
                                  'Año',
                                  'Ej: 2020',
                                  Icons.calendar_today,
                                  TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  _marcaController,
                                  'Marca',
                                  'Ej: Toyota',
                                  Icons.branding_watermark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _modeloController,
                                  'Modelo',
                                  'Ej: Corolla',
                                  Icons.car_rental,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  _colorController,
                                  'Color',
                                  'Ej: Blanco',
                                  Icons.palette,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _noSerieController,
                                  'No. de Serie (VIN)',
                                  'Número de serie del vehículo',
                                  Icons.fingerprint,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed:
                                    _isBuscandoVin ? null : _buscarPorVin,
                                icon:
                                    _isBuscandoVin
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(Icons.search, size: 18),
                                label: Text(
                                  _isBuscandoVin ? 'Buscando...' : 'Buscar VIN',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '💡 Tip: Ingrese el VIN y presione "Buscar VIN" para autocompletar los datos del vehículo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Factura
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt,
                                color: Color(0xFF8B5CF6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DE LA FACTURA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            _facturaExpedidaPorController,
                            'Factura Expedida Por',
                            'Nombre de la empresa/persona',
                            Icons.business,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _fechaFacturaController,
                            'Fecha de Factura',
                            'DD/MM/AAAA',
                            Icons.calendar_today,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos del Comprador
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DEL COMPRADOR',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            _nombreCompradorController,
                            'Nombre del Comprador',
                            'Nombre completo',
                            Icons.person,
                          ),
                          const SizedBox(height: 16),
                          
                          // Checkbox para INE/Licencia
                          CheckboxListTile(
                            title: Text(_obtenerEtiquetaINECheckbox()),
                            subtitle: Text('Marcar si desea incluir número de identificación'),
                            value: _mostrarINE,
                            onChanged: (value) {
                              setState(() {
                                _mostrarINE = value!;
                                if (!value) {
                                  _ineNumeroController.clear();
                                }
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          
                          // Campo INE condicional
                          if (_mostrarINE) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _buildTextField(
                                _ineNumeroController,
                                _obtenerEtiquetaIdentificacion(),
                                _obtenerPlaceholderIdentificacion(),
                                Icons.credit_card,
                                TextInputType.text,
                                false, // readOnly
                                true,  // optional
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Campo de teléfono
                          _buildTextField(
                            _telefonoController,
                            'Teléfono',
                            'Número de teléfono',
                            Icons.phone,
                            TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _domicilioController,
                            'Domicilio',
                            'Dirección completa',
                            Icons.location_on,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos del Vendedor
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                color: Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DATOS DEL VENDEDOR',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            _nombreVendedorController,
                            'Nombre del Vendedor',
                            'Nombre completo o razón social',
                            Icons.business,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Precio y Forma de Pago
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'PRECIO Y FORMA DE PAGO',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            _precioController,
                            'Precio de Venta',
                            '0.00',
                            Icons.attach_money,
                            TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _precioEscritoController,
                            'Precio en Letra',
                            'Se genera automáticamente',
                            Icons.text_fields,
                            null,
                            true,
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Formas de Pago:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Puede seleccionar múltiples formas de pago y especificar el monto de cada una:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Efectivo
                          CheckboxListTile(
                            title: const Text('Efectivo'),
                            value: _pagoEfectivo,
                            onChanged: (value) {
                              setState(() {
                                _pagoEfectivo = value!;
                                if (!value) _montoEfectivoController.clear();
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_pagoEfectivo) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _buildTextField(
                                _montoEfectivoController,
                                'Monto en Efectivo',
                                '0.00',
                                Icons.attach_money,
                                TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Transferencia
                          CheckboxListTile(
                            title: const Text('Transferencia'),
                            value: _pagoTransferencia,
                            onChanged: (value) {
                              setState(() {
                                _pagoTransferencia = value!;
                                if (!value)
                                  _montoTransferenciaController.clear();
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_pagoTransferencia) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _buildTextField(
                                _montoTransferenciaController,
                                'Monto por Transferencia',
                                '0.00',
                                Icons.attach_money,
                                TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Enganche (Crédito Financiera/Banco)
                          CheckboxListTile(
                            title: const Text('Enganche (Crédito Financiera/Banco)'),
                            value: _pagoCreditoFinanciera,
                            onChanged: (value) {
                              setState(() {
                                _pagoCreditoFinanciera = value!;
                                if (!value) {
                                  _montoCreditoFinancieraController.clear();
                                  _financieraController.clear();
                                }
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_pagoCreditoFinanciera) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    _montoCreditoFinancieraController,
                                    'Monto del Enganche',
                                    '0.00',
                                    Icons.attach_money,
                                    TextInputType.number,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    _financieraController,
                                    'Financiera/Banco',
                                    'Nombre de la institución',
                                    Icons.account_balance,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Crédito Interno
                          CheckboxListTile(
                            title: const Text('Crédito Interno'),
                            value: _pagoCreditoInterno,
                            onChanged: (value) {
                              setState(() {
                                _pagoCreditoInterno = value!;
                                if (!value)
                                  _montoCreditoInternoController.clear();
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          if (_pagoCreditoInterno) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _buildTextField(
                                _montoCreditoInternoController,
                                'Monto del Crédito Interno',
                                '0.00',
                                Icons.attach_money,
                                TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Resumen de pagos
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📋 Resumen de Pagos:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF0369A1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildResumenPagos(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Observaciones dentro de Precio y Forma de Pago
                          const Text(
                            'Observaciones:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _observacionesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'OBSERVACIONES DE PAGO',
                              hintText:
                                  'Información adicional, condiciones especiales, etc.',
                              prefixIcon: const Icon(
                                Icons.comment,
                                color: Color(0xFF10B981),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF10B981),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Compromiso de Cambio de Propietario
                          const Text(
                            'Compromiso de Cambio de Propietario:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _compromisoCambioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Compromiso de Cambio de Propietario',
                              hintText:
                                  'Detalles del compromiso para el cambio de propietario...',
                              prefixIcon: const Icon(
                                Icons.swap_horiz,
                                color: Color(0xFF3B82F6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Garantía
                          const Text(
                            'Garantía:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _garantiaController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Garantía',
                              hintText:
                                  'Términos y condiciones de la garantía...',
                              prefixIcon: const Icon(
                                Icons.verified_user,
                                color: Color(0xFF8B5CF6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B5CF6),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Factura Genérica
                          const Divider(),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Factura Genérica',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          CheckboxListTile(
                            title: const Text('Generar Factura Genérica'),
                            subtitle: const Text(
                              'Se generará automáticamente con los datos del contrato',
                            ),
                            value: _generarFacturaGenerica,
                            onChanged: (value) {
                              setState(() {
                                _generarFacturaGenerica = value!;
                                if (!value) {
                                  _facturaManual = false;
                                  _facturaLugarController.clear();
                                }
                              });
                            },
                            activeColor: const Color(0xFF10B981),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),

                          if (_generarFacturaGenerica) ...[
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              title: const Text('Configuración Manual'),
                              subtitle: const Text(
                                'Permite modificar todos los datos para la factura',
                              ),
                              value: _facturaManual,
                              onChanged: (value) {
                                setState(() {
                                  _facturaManual = value!;
                                  if (!value) {
                                    _facturaLugarController.clear();
                                    _facturaClienteController.clear();
                                    _facturaIdentificacionController.clear();
                                    _facturaMarcaController.clear();
                                    _facturaModeloController.clear();
                                    _facturaAnoController.clear();
                                    _facturaVinController.clear();
                                  }
                                });
                              },
                              activeColor: const Color(0xFF10B981),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),

                            if (_facturaManual) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '⚙️ Configuración Manual de Factura:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Datos básicos
                                    _buildTextField(
                                      _facturaLugarController,
                                      'Lugar',
                                      'Ciudad, Estado',
                                      Icons.location_on,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      _facturaClienteController,
                                      'Nombre del Cliente',
                                      'Nombre completo',
                                      Icons.person,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      _facturaIdentificacionController,
                                      'Número de Identificación',
                                      'INE, Pasaporte, etc.',
                                      Icons.credit_card,
                                    ),
                                    const SizedBox(height: 16),

                                    // Sección de vehículo con VIN search
                                    const Text(
                                      'Datos del Vehículo:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // VIN con botón de búsqueda
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            _facturaVinController,
                                            'VIN / Número de Serie',
                                            'VIN del vehículo',
                                            Icons.confirmation_number,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed:
                                              _isBuscandoVinFactura
                                                  ? null
                                                  : _buscarPorVinFactura,
                                          icon:
                                              _isBuscandoVinFactura
                                                  ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                  : const Icon(
                                                    Icons.search,
                                                    size: 18,
                                                  ),
                                          label: Text(
                                            _isBuscandoVinFactura
                                                ? 'Buscando...'
                                                : 'Buscar',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF10B981,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            _facturaAnoController,
                                            'Año',
                                            'Año del vehículo',
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildTextField(
                                            _facturaMarcaController,
                                            'Marca',
                                            'Marca del vehículo',
                                            Icons.branding_watermark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTextField(
                                      _facturaModeloController,
                                      'Modelo',
                                      'Modelo del vehículo',
                                      Icons.directions_car,
                                    ),

                                    const SizedBox(height: 12),
                                    const Text(
                                      '💡 Tip: Use "Buscar" para autocompletar los datos del vehículo con el VIN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF065F46),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '✅ Factura Automática Configurada:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Solo lugar en modo automático
                                    _buildTextField(
                                      _facturaLugarController,
                                      'Lugar',
                                      'Ciudad, Estado',
                                      Icons.location_on,
                                    ),

                                    const SizedBox(height: 12),
                                    const Text(
                                      '• Fecha: Se usará la fecha del contrato\n• Cliente: Nombre del comprador\n• Identificación: Número INE/IFE\n• Vehículo: Marca, modelo, año, VIN del contrato',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de generar contrato
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generarContrato,
                          icon:
                              _isGenerating
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.description),
                          label: Text(
                            _isGenerating
                                ? 'Generando Contrato...'
                                : 'Generar Contrato',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, [
    TextInputType? keyboardType,
    bool readOnly = false,
    bool optional = false,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFF59E0B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
      ),
      validator:
          readOnly || optional
              ? null
              : (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese $label';
                }
                return null;
              },
    );
  }
}
