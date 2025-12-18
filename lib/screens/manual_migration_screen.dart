import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/connectivity_test.dart';

class ManualMigrationScreen extends StatefulWidget {
  const ManualMigrationScreen({super.key});

  @override
  State<ManualMigrationScreen> createState() => _ManualMigrationScreenState();
}

class _ManualMigrationScreenState extends State<ManualMigrationScreen> {
  String _status = '';
  bool _isLoading = false;

  Future<void> _testFirestoreWrite() async {
    setState(() {
      _isLoading = true;
      _status = 'Probando escritura en Firestore...';
    });

    try {
      // Test de conectividad general primero
      setState(() => _status = 'Probando conectividad general...');
      await ConnectivityTest.testConnectivity();
      
      // Reinicializar conexión
      setState(() => _status = 'Reinicializando conexión...');
      await FirestoreService.reinicializarConexion();
      
      // Ejecutar diagnóstico primero
      setState(() => _status = 'Ejecutando diagnóstico...');
      await FirestoreService.diagnosticarFirestore();
      
      // Intentar escribir un vehículo de prueba
      Map<String, dynamic> vehiculoPrueba = {
        'marca': 'Toyota',
        'modelo': 'Camry',
        'ano': 2023,
        'estado': 'Disponible',
        'vin': 'TEST123',
        'color': 'Rojo',
        'motor': '4 cilindros',
        'traccion': '2WD',
        'version': 'LE',
        'comercializadora': 'Test',
        'costo': 25000,
        'gastos': 0,
        'precioSugerido': 30000,
        'total': 25000,
        'diasInventario': 0,
        'imagen': '',
        'nombreUsuario': 'Admin',
        'correoUsuario': 'test@test.com',
      };

      print('🚗 Intentando agregar vehículo de prueba...');
      await FirestoreService.agregarVehiculo(vehiculoPrueba);
      
      setState(() {
        _status = '✅ Vehículo de prueba agregado exitosamente';
        _isLoading = false;
      });

      // Verificar que se escribió
      await Future.delayed(const Duration(seconds: 2));
      List<Map<String, dynamic>> vehiculos = await FirestoreService.obtenerInventario();
      print('📊 Vehículos después de agregar: ${vehiculos.length}');

    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
      print('❌ Error completo: $e');
    }
  }

  Future<void> _forceReconnect() async {
    try {
      print('🔄 Forzando reconexión...');
      await FirestoreService.reinicializarConexion();
      
      setState(() {
        _status = '✅ Reconexión completada. Prueba ahora.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error en reconexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Manual Firestore'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Prueba Manual de Firestore',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Esta prueba intentará:\n'
                      '• Ejecutar diagnóstico de Firestore\n'
                      '• Escribir un vehículo de prueba\n'
                      '• Verificar que se guardó correctamente',
                    ),
                    const SizedBox(height: 16),
                    if (_status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _status.contains('Error') || _status.contains('❌')
                            ? Colors.red.shade50
                            : _status.contains('✅')
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _status.contains('Error') || _status.contains('❌')
                              ? Colors.red
                              : _status.contains('✅')
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          _status,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _status.contains('Error') || _status.contains('❌')
                              ? Colors.red.shade700
                              : _status.contains('✅')
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFirestoreWrite,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.science),
              label: Text(_isLoading ? 'Probando...' : 'Probar Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _forceReconnect,
              icon: const Icon(Icons.refresh),
              label: const Text('Forzar Reconexión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '💡 Tip: Revisa los logs en la terminal para ver el diagnóstico completo.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}