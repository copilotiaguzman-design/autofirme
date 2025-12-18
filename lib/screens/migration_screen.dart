import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../services/firestore_service.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isLoading = false;
  String _status = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _iniciarMigracion() async {
    setState(() {
      _isLoading = true;
      _status = 'Iniciando migración...';
      _logs.clear();
    });

    try {
      _addLog('🚀 Iniciando migración desde Google Sheets a Firestore');
      
      await SyncService.migrarDesdeSheetsAFirestore();
      
      _addLog('✅ Migración completada exitosamente');
      setState(() {
        _status = '¡Migración completada!';
        _isLoading = false;
      });

      // Mostrar dialog de éxito
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Migración Exitosa'),
            content: const Text(
              'Todos los datos se han migrado correctamente de Google Sheets a Firestore.\n\n'
              'Ahora Firestore será la base de datos principal y Google Sheets solo será un respaldo visual.'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Regresar a la pantalla anterior
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      _addLog('❌ Error en migración: $e');
      setState(() {
        _status = 'Error en migración';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en migración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _limpiarYReMigrar() async {
    // Confirmar antes de ejecutar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar Re-Migración'),
        content: const Text(
          '¿Estás seguro de querer limpiar TODO Firestore y hacer una nueva migración?\n\n'
          'Esto eliminará todos los datos actuales de Firestore y los volverá a importar desde Google Sheets.\n\n'
          'Los IDs de Firestore serán iguales a los de Sheets.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Re-Migrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Limpiando Firestore...';
      _logs.clear();
    });

    try {
      _addLog('🗑️ Limpiando todas las colecciones de Firestore...');
      await FirestoreService.limpiarTodasLasColecciones();
      _addLog('✅ Firestore limpiado');

      _addLog('🚀 Iniciando re-migración desde Google Sheets...');
      await SyncService.migrarDesdeSheetsAFirestore();
      
      _addLog('🔐 Actualizando contraseñas de usuarios...');
      await SyncService.actualizarContrasenasUsuarios();

      _addLog('✅ Re-migración completada exitosamente');
      setState(() {
        _status = '¡Re-migración completada!';
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Re-Migración Exitosa'),
            content: const Text(
              'Todos los datos se han re-migrado correctamente.\n\n'
              'Ahora los IDs de Firestore son iguales a los de Google Sheets.'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      _addLog('❌ Error en re-migración: $e');
      setState(() {
        _status = 'Error en re-migración';
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarContrasenas() async {
    setState(() {
      _isLoading = true;
      _status = 'Actualizando contraseñas...';
    });

    try {
      _addLog('🔐 Iniciando actualización de contraseñas');
      
      await SyncService.actualizarContrasenasUsuarios();
      
      _addLog('✅ Contraseñas actualizadas exitosamente');
      setState(() {
        _status = '¡Contraseñas actualizadas!';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contraseñas actualizadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() {
        _status = 'Error al actualizar contraseñas';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migración a Firebase'),
        backgroundColor: Colors.blue.shade600,
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
                      '🔄 Migración de Datos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Esta herramienta migra todos los datos desde Google Sheets hacia Firestore.\n\n'
                      '• Firestore será la base de datos principal\n'
                      '• Google Sheets quedará como respaldo visual\n'
                      '• Solo ejecutar UNA VEZ',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isLoading 
                            ? Colors.blue.shade50 
                            : _status.contains('Error')
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isLoading 
                              ? Colors.blue 
                              : _status.contains('Error')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            if (_isLoading) const SizedBox(width: 8),
                            Text(
                              _status,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _isLoading 
                                  ? Colors.blue.shade700 
                                  : _status.contains('Error')
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _iniciarMigracion,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync),
              label: Text(_isLoading ? 'Migrando...' : 'Iniciar Migración'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _actualizarContrasenas,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Actualizar Contraseñas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _limpiarYReMigrar,
              icon: const Icon(Icons.refresh),
              label: const Text('🔄 Limpiar Firestore y Re-Migrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            if (_logs.isNotEmpty)
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: const Text(
                          '📋 Log de Migración',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _logs[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              );
                            },
                          ),
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