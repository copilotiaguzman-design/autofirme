import 'package:flutter/material.dart';
import '../services/roles_service.dart';
import '../services/usuarios_service.dart';

class TestServicesScreen extends StatefulWidget {
  const TestServicesScreen({Key? key}) : super(key: key);

  @override
  State<TestServicesScreen> createState() => _TestServicesScreenState();
}

class _TestServicesScreenState extends State<TestServicesScreen> {
  bool _testing = false;
  String _results = '';

  Future<void> _testServices() async {
    setState(() {
      _testing = true;
      _results = 'Iniciando pruebas...\n\n';
    });

    // Test RolesService
    try {
      _addResult('=== TESTING ROLES SERVICE ===');
      _addResult('Obteniendo roles...');
      
      final roles = await RolesService.obtenerRoles();
      _addResult('✅ Roles obtenidos: ${roles.length} roles');
      
      for (var rol in roles.take(3)) {
        _addResult('  - ID: ${rol['id']}, Nombre: ${rol['rol']}');
      }
      
    } catch (e) {
      _addResult('❌ Error en RolesService: $e');
    }

    _addResult('\n=== TESTING USUARIOS SERVICE ===');
    
    // Test UsuariosService
    try {
      _addResult('Obteniendo usuarios...');
      
      final usuarios = await UsuariosService.obtenerUsuarios();
      _addResult('✅ Usuarios obtenidos: ${usuarios.length} usuarios');
      
      for (var usuario in usuarios.take(3)) {
        _addResult('  - ID: ${usuario['id']}, Nombre: ${usuario['nombre']}, Correo: ${usuario['correo']}');
      }
      
    } catch (e) {
      _addResult('❌ Error en UsuariosService: $e');
    }

    setState(() {
      _testing = false;
      _addResult('\n=== PRUEBAS COMPLETADAS ===');
    });
  }

  void _addResult(String message) {
    setState(() {
      _results += '$message\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Servicios'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _testing ? null : _testServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _testing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Probar Servicios'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _results.isEmpty ? 'Presiona "Probar Servicios" para iniciar' : _results,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}