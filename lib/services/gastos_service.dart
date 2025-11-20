import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class GastosService {
  // URL del script modular
  static const String _baseUrl = ApiConfig.gastosUrl;
  static const String _logPrefix = 'GASTOS';

  /// Obtener todos los gastos desde Google Sheets
  static Future<List<Map<String, dynamic>>> obtenerGastos() async {
    try {
      print('INFO [$_logPrefix] Iniciando obtención de gastos...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'obtener',
        'tipo': 'gastos',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          final gastos = (rawData as List).map((item) => _normalizarDatosGasto(item)).toList();
          print('SUCCESS [$_logPrefix] Total de gastos: ${gastos.length}');
          return gastos;
        } else {
          print('ERROR [$_logPrefix] Error en respuesta: ${data['error']}');
          return [];
        }
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return [];
    }
  }

  /// Agregar nuevo gasto
  static Future<Map<String, dynamic>> agregarGasto({
    required String fecha,
    required String vin,
    required String categoria,
    required String concepto,
    required String tipo,
    required double montoMXN,
    required double tipoCambio,
    double? balance,
    double? montoEnvio,
    double? balanceUSD,
    String? imagen,
    required String nombreUsuario,
    required String correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Agregando gasto: "$concepto" - "$categoria"');
      
      // Calcular MontoUSD usando la fórmula implementada en la app
      final montoUSD = _calcularMontoUSD(tipo, montoMXN, tipoCambio);
      
      final queryParams = {
        'tipo': 'gastos',
        'action': 'agregar',
        'fecha': fecha,
        'vin': vin,
        'categoria': categoria,
        'concepto': concepto,
        'tipoGasto': tipo,
        'montoMXN': montoMXN.toString(),
        'balance': (balance ?? 0.0).toString(),
        'tipoCambio': tipoCambio.toString(),
        'montoEnvio': (montoEnvio ?? 0.0).toString(),
        'balanceUSD': (balanceUSD ?? 0.0).toString(),
        'imagen': imagen ?? '',
        'nombreUsuario': nombreUsuario,
        'correoUsuario': correoUsuario,
      };
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('INFO [$_logPrefix] URL completa: $uri');
      print('INFO [$_logPrefix] MontoUSD calculado: $montoUSD');
      
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Gasto agregado: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Actualizar gasto existente
  static Future<Map<String, dynamic>> actualizarGasto({
    required String id,
    String? fecha,
    String? vin,
    String? categoria,
    String? concepto,
    String? tipo,
    double? montoMXN,
    double? balance,
    double? tipoCambio,
    double? montoEnvio,
    double? balanceUSD,
    String? imagen,
    String? nombreUsuario,
    String? correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Actualizando gasto ID: $id');
      
      final queryParams = <String, String>{
        'tipo': 'gastos',
        'action': 'editar',
        'id': id,
      };
      
      // Agregar solo los parámetros que no son null
      if (fecha != null) queryParams['fecha'] = fecha;
      if (vin != null) queryParams['vin'] = vin;
      if (categoria != null) queryParams['categoria'] = categoria;
      if (concepto != null) queryParams['concepto'] = concepto;
      if (tipo != null) queryParams['tipoGasto'] = tipo;
      if (montoMXN != null) queryParams['montoMXN'] = montoMXN.toString();
      if (balance != null) queryParams['balance'] = balance.toString();
      if (tipoCambio != null) queryParams['tipoCambio'] = tipoCambio.toString();
      if (montoEnvio != null) queryParams['montoEnvio'] = montoEnvio.toString();
      if (balanceUSD != null) queryParams['balanceUSD'] = balanceUSD.toString();
      if (imagen != null) queryParams['imagen'] = imagen;
      if (nombreUsuario != null) queryParams['nombreUsuario'] = nombreUsuario;
      if (correoUsuario != null) queryParams['correoUsuario'] = correoUsuario;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('INFO [$_logPrefix] URL completa: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Gasto actualizado: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al actualizar: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Eliminar gasto
  static Future<Map<String, dynamic>> eliminarGasto(String id) async {
    try {
      print('INFO [$_logPrefix] Eliminando gasto ID: $id');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'eliminar',
        'tipo': 'gastos',
        'id': id,
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Obtener estadísticas de gastos
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      print('INFO [$_logPrefix] Obteniendo estadísticas de gastos...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'estadisticas',
        'tipo': 'gastos',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Estadísticas: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  /// Calcular MontoUSD usando la fórmula especificada
  /// =ARRAYFORMULA(SI(FILA(B:B)=1,"MontoUSD",SI((G:G="Gasto")*(ESNUMERO(H:H))*(ESNUMERO(J:J)),H:H/J:J,"")))
  static double _calcularMontoUSD(String tipo, double montoMXN, double tipoCambio) {
    // Si es tipo "Gasto" y tanto montoMXN como tipoCambio son números válidos y tipoCambio != 0
    if (tipo == "Gasto" && montoMXN > 0 && tipoCambio > 0) {
      return montoMXN / tipoCambio;
    }
    return 0.0;
  }

  /// Normalizar datos de gasto para garantizar consistencia
  static Map<String, dynamic> _normalizarDatosGasto(dynamic item) {
    if (item is! Map) return {};
    
    final Map<String, dynamic> gasto = Map<String, dynamic>.from(item);
    
    return {
      'id': gasto['id']?.toString() ?? '',
      'fecha': gasto['fecha']?.toString() ?? '',
      'semana': _convertirAInt(gasto['semana']),
      'vin': gasto['vin']?.toString() ?? '',
      'categoria': gasto['categoria']?.toString() ?? '',
      'concepto': gasto['concepto']?.toString() ?? '',
      'tipo': gasto['tipo']?.toString() ?? '',
      'montoMXN': _convertirADouble(gasto['montoMXN']),
      'balance': _convertirADouble(gasto['balance']),
      'tipoCambio': _convertirADouble(gasto['tipoCambio']),
      'montoUSD': _convertirADouble(gasto['montoUSD']),
      'montoEnvio': _convertirADouble(gasto['montoEnvio']),
      'balanceUSD': _convertirADouble(gasto['balanceUSD']),
      'imagen': gasto['imagen']?.toString() ?? '',
      'nombreUsuario': gasto['nombreUsuario']?.toString() ?? '',
      'correoUsuario': gasto['correoUsuario']?.toString() ?? '',
      'fechaCreacion': gasto['fechaCreacion']?.toString() ?? '',
      'fechaActualizacion': gasto['fechaActualizacion']?.toString() ?? '',
    };
  }

  /// Convertir valor a double de forma segura
  static double _convertirADouble(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor is String) {
      final parsed = double.tryParse(valor);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  /// Convertir valor a int de forma segura
  static int _convertirAInt(dynamic valor) {
    if (valor == null) return 0;
    if (valor is int) return valor;
    if (valor is double) return valor.round();
    if (valor is String) {
      final parsed = int.tryParse(valor);
      return parsed ?? 0;
    }
    return 0;
  }

  /// Obtener categorías disponibles (incluye gastos de vehículos y sucursal)
  static List<String> getCategorias() {
    return [
      // Gastos específicos de vehículos
      'Mantenimiento',
      'Reparación',
      'Combustible',
      'Seguros',
      'Documentación',
      'Lavado',
      'Accesorios',
      
      // Gastos generales de sucursal
      'Servicios Públicos',
      'Recolección de Basura',
      'Materiales de Oficina',
      'Limpieza',
      'Mantenimiento Edificio',
      'Telecomunicaciones',
      'Seguridad',
      'Papelería',
      'Suministros',
      'Honorarios',
      'Capacitación',
      'Marketing',
      'Otros'
    ];
  }

  /// Obtener tipos disponibles
  static List<String> getTipos() {
    return [
      'Gasto',
      'Ingreso',
      'Transferencia'
    ];
  }
}