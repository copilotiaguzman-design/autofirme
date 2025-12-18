import 'gastos_service.dart';
import 'sync_service.dart';

/// Servicio para calcular gastos asociados a cada VIN
/// No modifica Google Apps Script, solo calcula totales localmente
class GastosCalculadosService {
  static const String _logPrefix = 'GASTOS_CALCULADOS';
  
  /// Cache de gastos por VIN para mejorar rendimiento
  static Map<String, double> _gastosCache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Obtener total de gastos para un VIN específico
  static Future<double> obtenerGastosPorVin(String vin) async {
    try {
      print('INFO [$_logPrefix] Calculando gastos para VIN: $vin');
      
      // Verificar cache válido
      if (_isCacheValid() && _gastosCache.containsKey(vin)) {
        final gastosCacheado = _gastosCache[vin]!;
        print('INFO [$_logPrefix] Usando cache para VIN $vin: \$${gastosCacheado.toStringAsFixed(2)}');
        return gastosCacheado;
      }

      // Si no hay cache válido, recalcular todos los gastos
      await _recalcularTodosLosGastos();
      
      final gastos = _gastosCache[vin] ?? 0.0;
      print('INFO [$_logPrefix] Gastos calculados para VIN $vin: \$${gastos.toStringAsFixed(2)}');
      return gastos;
      
    } catch (e) {
      print('ERROR [$_logPrefix] Error al calcular gastos para VIN $vin: $e');
      return 0.0;
    }
  }

  /// Obtener gastos para múltiples VINs de una sola vez (más eficiente)
  static Future<Map<String, double>> obtenerGastosParaVins(List<String> vins) async {
    try {
      print('INFO [$_logPrefix] Calculando gastos para ${vins.length} VINs');
      
      // Si el cache no es válido, recalcular
      if (!_isCacheValid()) {
        await _recalcularTodosLosGastos();
      }
      
      // Devolver gastos para los VINs solicitados
      final Map<String, double> resultado = {};
      for (String vin in vins) {
        resultado[vin] = _gastosCache[vin] ?? 0.0;
      }
      
      print('INFO [$_logPrefix] Gastos calculados para ${resultado.length} VINs');
      return resultado;
      
    } catch (e) {
      print('ERROR [$_logPrefix] Error al calcular gastos para múltiples VINs: $e');
      return {};
    }
  }

  /// Recalcular todos los gastos y actualizar cache
  static Future<void> _recalcularTodosLosGastos() async {
    try {
      print('INFO [$_logPrefix] Recalculando todos los gastos...');
      
      // Obtener todos los gastos desde Firestore (no Sheets)
      final todosLosGastos = await SyncService.obtenerGastos();
      
      // Limpiar cache anterior
      _gastosCache.clear();
      
      // Agrupar gastos por VIN
      for (final gasto in todosLosGastos) {
        final vin = gasto['vin']?.toString().trim() ?? '';
        final monto = _parseDouble(gasto['monto']);
        
        if (vin.isNotEmpty && monto > 0) {
          _gastosCache[vin] = (_gastosCache[vin] ?? 0.0) + monto;
        }
      }
      
      // Actualizar timestamp del cache
      _lastCacheUpdate = DateTime.now();
      
      print('INFO [$_logPrefix] Cache actualizado con gastos para ${_gastosCache.length} VINs');
      
    } catch (e) {
      print('ERROR [$_logPrefix] Error al recalcular gastos: $e');
      _gastosCache.clear();
    }
  }

  /// Verificar si el cache es válido (no ha expirado)
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry;
  }

  /// Convertir valor a double de forma segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Limpiar string: remover $ y comas
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Limpiar cache manualmente (útil para forzar recalculo)
  static void limpiarCache() {
    print('INFO [$_logPrefix] Limpiando cache de gastos');
    _gastosCache.clear();
    _lastCacheUpdate = null;
  }

  /// Obtener estadísticas de gastos por VIN
  static Future<Map<String, dynamic>> obtenerEstadisticasGastos() async {
    try {
      print('INFO [$_logPrefix] Calculando estadísticas de gastos por VIN');
      
      if (!_isCacheValid()) {
        await _recalcularTodosLosGastos();
      }
      
      final List<double> valores = _gastosCache.values.toList();
      
      if (valores.isEmpty) {
        return {
          'totalVinsConGastos': 0,
          'gastoTotal': 0.0,
          'gastoPromedio': 0.0,
          'gastoMaximo': 0.0,
          'gastoMinimo': 0.0,
          'vinsConMasGastos': <Map<String, dynamic>>[],
        };
      }
      
      valores.sort((a, b) => b.compareTo(a)); // Ordenar descendente
      
      final gastoTotal = valores.fold(0.0, (sum, valor) => sum + valor);
      final gastoPromedio = gastoTotal / valores.length;
      final gastoMaximo = valores.first;
      final gastoMinimo = valores.last;
      
      // Top 5 VINs con más gastos
      final vinsOrdenados = _gastosCache.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final vinsConMasGastos = vinsOrdenados
          .take(5)
          .map((entry) => {
                'vin': entry.key,
                'gastos': entry.value,
              })
          .toList();
      
      final estadisticas = {
        'totalVinsConGastos': _gastosCache.length,
        'gastoTotal': gastoTotal,
        'gastoPromedio': gastoPromedio,
        'gastoMaximo': gastoMaximo,
        'gastoMinimo': gastoMinimo,
        'vinsConMasGastos': vinsConMasGastos,
      };
      
      print('INFO [$_logPrefix] Estadísticas calculadas: $estadisticas');
      return estadisticas;
      
    } catch (e) {
      print('ERROR [$_logPrefix] Error al calcular estadísticas: $e');
      return {};
    }
  }

  /// Verificar si un VIN tiene gastos asociados
  static Future<bool> vinTieneGastos(String vin) async {
    try {
      final gastos = await obtenerGastosPorVin(vin);
      return gastos > 0;
    } catch (e) {
      print('ERROR [$_logPrefix] Error al verificar gastos para VIN $vin: $e');
      return false;
    }
  }

  /// Obtener detalles de gastos para un VIN específico
  static Future<List<Map<String, dynamic>>> obtenerDetalleGastosPorVin(String vin) async {
    try {
      print('INFO [$_logPrefix] Obteniendo detalle de gastos para VIN: $vin');
      
      // Obtener todos los gastos
      final todosLosGastos = await GastosService.obtenerGastos();
      
      // Filtrar gastos para el VIN específico
      final gastosDelVin = todosLosGastos.where((gasto) {
        final gastoVin = gasto['vin']?.toString().trim() ?? '';
        return gastoVin == vin;
      }).toList();
      
      print('INFO [$_logPrefix] Encontrados ${gastosDelVin.length} gastos para VIN $vin');
      return gastosDelVin;
      
    } catch (e) {
      print('ERROR [$_logPrefix] Error al obtener detalle de gastos para VIN $vin: $e');
      return [];
    }
  }

  /// Invalidar cache para forzar recálculo en la próxima consulta
  /// Llamar este método después de agregar, editar o eliminar gastos
  static void invalidarCache() {
    print('INFO [$_logPrefix] Cache invalidado - se recalculará en la próxima consulta');
    _gastosCache.clear();
    _lastCacheUpdate = null;
  }

  /// Obtener estadísticas del cache actual
  static Map<String, dynamic> obtenerEstadisticasCache() {
    return {
      'vinConGastos': _gastosCache.length,
      'ultimaActualizacion': _lastCacheUpdate?.toIso8601String(),
      'cacheValido': _isCacheValid(),
      'gastosTotal': _gastosCache.values.fold(0.0, (a, b) => a + b),
    };
  }
}