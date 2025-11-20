import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class VentasService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const String _logPrefix = 'VENTAS';

  /// Obtener todas las ventas desde Google Sheets
  static Future<List<Map<String, dynamic>>> obtenerVentas() async {
    try {
      print('INFO [$_logPrefix] Iniciando obtención de ventas...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'obtener',
        'tipo': 'ventas',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          final ventas = (rawData as List).map((item) => _normalizarDatosVenta(item)).toList();
          print('SUCCESS [$_logPrefix] Total de ventas: ${ventas.length}');
          return ventas;
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

  /// Obtener información de vehículo por VIN
  static Future<Map<String, dynamic>?> obtenerVehiculoPorVin(String vin) async {
    try {
      print('INFO [$_logPrefix] Obteniendo vehículo por VIN: $vin');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'obtener_vehiculo',
        'tipo': 'ventas',
        'vin': vin,
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          print('ERROR [$_logPrefix] Error: ${data['error']}');
          return null;
        }
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return null;
    }
  }

  /// Agregar nueva venta
  static Future<Map<String, dynamic>> agregarVenta({
    required String fechaCaptura,
    String? fechaVenta,
    required String vin,
    required String ano,
    required String modelo,
    String? lote,
    String? notas,
    required double precioVenta,
    String? fechaPago1,
    String? metodo1,
    double? pago1,
    String? fechaPago2,
    String? metodo2,
    double? pago2,
    String? fechaPago3,
    String? metodo3,
    double? pago3,
    String? vendedor,
    String? imagenResponsiva,
    required String nombreUsuario,
    required String correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Agregando venta: VIN: $vin, Precio: \$${precioVenta.toStringAsFixed(2)}');
      
      final queryParams = {
        'tipo': 'ventas',
        'action': 'agregar',
        'fechaCaptura': fechaCaptura,
        'vin': vin,
        'ano': ano,
        'modelo': modelo,
        'precioVenta': precioVenta.toString(),
        'nombreUsuario': nombreUsuario,
        'correoUsuario': correoUsuario,
      };

      // Agregar parámetros opcionales solo si no son null
      if (fechaVenta != null) queryParams['fechaVenta'] = fechaVenta;
      if (lote != null) queryParams['lote'] = lote;
      if (notas != null) queryParams['notas'] = notas;
      if (fechaPago1 != null) queryParams['fechaPago1'] = fechaPago1;
      if (metodo1 != null) queryParams['metodo1'] = metodo1;
      if (pago1 != null) queryParams['pago1'] = pago1.toString();
      if (fechaPago2 != null) queryParams['fechaPago2'] = fechaPago2;
      if (metodo2 != null) queryParams['metodo2'] = metodo2;
      if (pago2 != null) queryParams['pago2'] = pago2.toString();
      if (fechaPago3 != null) queryParams['fechaPago3'] = fechaPago3;
      if (metodo3 != null) queryParams['metodo3'] = metodo3;
      if (pago3 != null) queryParams['pago3'] = pago3.toString();
      if (vendedor != null) queryParams['vendedor'] = vendedor;
      if (imagenResponsiva != null) queryParams['imagenResponsiva'] = imagenResponsiva;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('INFO [$_logPrefix] URL completa: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Venta agregada: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al agregar: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Actualizar venta existente
  static Future<Map<String, dynamic>> actualizarVenta({
    required String id,
    String? fechaCaptura,
    String? fechaVenta,
    String? vin,
    String? ano,
    String? modelo,
    String? lote,
    String? notas,
    double? precioVenta,
    String? fechaPago1,
    String? metodo1,
    double? pago1,
    String? fechaPago2,
    String? metodo2,
    double? pago2,
    String? fechaPago3,
    String? metodo3,
    double? pago3,
    String? estatus,
    String? vendedor,
    String? imagenResponsiva,
    String? nombreUsuario,
    String? correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Actualizando venta ID: $id');
      
      final queryParams = <String, String>{
        'tipo': 'ventas',
        'action': 'editar',
        'id': id,
      };
      
      // Agregar solo los parámetros que no son null
      if (fechaCaptura != null) queryParams['fechaCaptura'] = fechaCaptura;
      if (fechaVenta != null) queryParams['fechaVenta'] = fechaVenta;
      if (vin != null) queryParams['vin'] = vin;
      if (ano != null) queryParams['ano'] = ano;
      if (modelo != null) queryParams['modelo'] = modelo;
      if (lote != null) queryParams['lote'] = lote;
      if (notas != null) queryParams['notas'] = notas;
      if (precioVenta != null) queryParams['precioVenta'] = precioVenta.toString();
      if (fechaPago1 != null) queryParams['fechaPago1'] = fechaPago1;
      if (metodo1 != null) queryParams['metodo1'] = metodo1;
      if (pago1 != null) queryParams['pago1'] = pago1.toString();
      if (fechaPago2 != null) queryParams['fechaPago2'] = fechaPago2;
      if (metodo2 != null) queryParams['metodo2'] = metodo2;
      if (pago2 != null) queryParams['pago2'] = pago2.toString();
      if (fechaPago3 != null) queryParams['fechaPago3'] = fechaPago3;
      if (metodo3 != null) queryParams['metodo3'] = metodo3;
      if (pago3 != null) queryParams['pago3'] = pago3.toString();
      if (estatus != null) queryParams['estatus'] = estatus;
      if (vendedor != null) queryParams['vendedor'] = vendedor;
      if (imagenResponsiva != null) queryParams['imagenResponsiva'] = imagenResponsiva;
      if (nombreUsuario != null) queryParams['nombreUsuario'] = nombreUsuario;
      if (correoUsuario != null) queryParams['correoUsuario'] = correoUsuario;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      
      print('INFO [$_logPrefix] URL completa: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Venta actualizada: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al actualizar: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Eliminar venta
  static Future<Map<String, dynamic>> eliminarVenta(String id) async {
    try {
      print('INFO [$_logPrefix] Eliminando venta ID: $id');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'eliminar',
        'tipo': 'ventas',
        'id': id,
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Venta eliminada: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al eliminar: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Obtener estadísticas de ventas
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      print('INFO [$_logPrefix] Obteniendo estadísticas de ventas...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'estadisticas',
        'tipo': 'ventas',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Estadísticas: $data');
        
        if (data['success'] == true) {
          return data['data'] ?? {};
        } else {
          print('ERROR [$_logPrefix] Error en estadísticas: ${data['error']}');
          return {};
        }
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción en estadísticas: $e');
      return {};
    }
  }

  /// Normalizar datos de venta recibidos del servidor
  static Map<String, dynamic> _normalizarDatosVenta(dynamic item) {
    if (item is Map<String, dynamic>) {
      return {
        'id': item['id']?.toString() ?? '',
        'fechacaptura': item['fechaCaptura']?.toString() ?? '',
        'fechaventa': item['fechaVenta']?.toString() ?? '',
        'vin': item['vin']?.toString() ?? '',
        'ano': item['ano']?.toString() ?? '',
        'modelo': item['modelo']?.toString() ?? '',
        'lote': item['lote']?.toString() ?? '',
        'notas': item['notas']?.toString() ?? '',
        'precioventa': (item['precioVenta'] ?? 0).toDouble(),
        'fechapago1': item['fechaPago1']?.toString() ?? '',
        'metodo1': item['metodo1']?.toString() ?? '',
        'pago1': (item['pago1'] ?? 0).toDouble(),
        'fechapago2': item['fechaPago2']?.toString() ?? '',
        'metodo2': item['metodo2']?.toString() ?? '',
        'pago2': (item['pago2'] ?? 0).toDouble(),
        'fechapago3': item['fechaPago3']?.toString() ?? '',
        'metodo3': item['metodo3']?.toString() ?? '',
        'pago3': (item['pago3'] ?? 0).toDouble(),
        'totalpagado': (item['totalPagado'] ?? 0).toDouble(),
        'restante': (item['restante'] ?? 0).toDouble(),
        'estatus': item['estatus']?.toString() ?? '',
        'vendedor': item['vendedor']?.toString() ?? '',
        'imagenresponsiva': item['imagenResponsiva']?.toString() ?? '',
        'nombreusuario': item['nombreUsuario']?.toString() ?? '',
        'correousuario': item['correoUsuario']?.toString() ?? '',
        'fechacreacion': item['fechaCreacion']?.toString() ?? '',
        'fechaactualizacion': item['fechaActualizacion']?.toString() ?? '',
      };
    } else {
      print('WARNING [$_logPrefix] Item no es Map<String, dynamic>: $item');
      return {};
    }
  }

  /// Obtener lista de métodos de pago disponibles
  static List<String> getMetodosPago() {
    return [
      'Efectivo',
      'Transferencia',
      'Cheque',
      'Tarjeta de Crédito',
      'Tarjeta de Débito',
      'PayPal',
      'Financiamiento',
      'Intercambio',
      'Otro'
    ];
  }

  /// Obtener lista de estatus de venta
  static List<String> getEstatusVenta() {
    return [
      'Pendiente',
      'Parcial',
      'Pagado',
      'Cancelado'
    ];
  }

  /// Calcular totales de una venta
  static Map<String, double> calcularTotales(double pago1, double pago2, double pago3, double precioVenta) {
    final totalPagado = pago1 + pago2 + pago3;
    final restante = precioVenta - totalPagado;
    
    return {
      'totalPagado': totalPagado,
      'restante': restante,
    };
  }

  /// Determinar estatus automático
  static String determinarEstatus(double totalPagado, double precioVenta) {
    if (totalPagado <= 0) return 'Pendiente';
    if (totalPagado >= precioVenta) return 'Pagado';
    if (totalPagado > 0 && totalPagado < precioVenta) return 'Parcial';
    return 'Pendiente';
  }
}