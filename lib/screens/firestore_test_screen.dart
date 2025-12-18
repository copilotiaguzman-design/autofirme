import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;

  Future<void> _loadFromFirestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await FirestoreService.obtenerInventario();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
      
      print('📊 Vehículos en Firestore: ${vehicles.length}');
    } catch (e) {
      print('❌ Error cargando de Firestore: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runDiagnostic() async {
    print('🔍 Ejecutando diagnóstico...');
    await FirestoreService.diagnosticarFirestore();
  }

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firestore'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 Estado de Firestore',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Cargando datos...'),
                        ],
                      )
                    else
                      Text(
                        'Vehículos en Firestore: ${_vehicles.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFromFirestore,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar desde Firestore'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _runDiagnostic,
              icon: const Icon(Icons.bug_report),
              label: const Text('Diagnóstico Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_vehicles.isNotEmpty)
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '🚗 Vehículos en Firestore',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  '${vehicle['marca']} ${vehicle['modelo']}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Año: ${vehicle['ano']}'),
                                    Text('Estado: ${vehicle['estado']}'),
                                    Text('VIN: ${vehicle['vin']}'),
                                  ],
                                ),
                                trailing: Icon(
                                  vehicle['estado']?.toString().toLowerCase() == 'disponible'
                                    ? Icons.check_circle
                                    : Icons.remove_circle,
                                  color: vehicle['estado']?.toString().toLowerCase() == 'disponible'
                                    ? Colors.green
                                    : Colors.orange,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}