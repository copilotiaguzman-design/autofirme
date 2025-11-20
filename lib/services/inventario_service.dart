import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class InventarioService {
  // URL del script modular (mismo que usuarios y roles)
  static const String _baseUrl = ApiConfig.inventarioUrl;
  static const String _logPrefix = 'INVENTARIO';



  // Obtener todos los vehículos del inventario
  static Future<List<Map<String, dynamic>>> obtenerInventario() async {
    try {
      print('INFO [$_logPrefix] Iniciando obtención de inventario...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'tipo': 'inventario',
        'action': 'obtener',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta parseada: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          List<Map<String, dynamic>> inventario = (rawData as List)
              .map((item) => _normalizarDatosVehiculo(Map<String, dynamic>.from(item as Map)))
              .toList();
          
          print('SUCCESS [$_logPrefix] Total de vehículos: ${inventario.length}');
          return inventario;
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

  // Agregar nuevo vehículo al inventario
  static Future<Map<String, dynamic>> agregarVehiculo({
    required String ano,
    required String marca,
    required String modelo,
    required String vin,
    required String color,
    required String motor,
    required String traccion,
    required String version,
    required String comercializadora,
    required double costo,
    required double gastos,
    required double precioSugerido,
    required String estado,
    String? imagen,
    required String nombreUsuario,
    required String correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Agregando nuevo vehículo: $marca $modelo');
      
      final fechaRecibido = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final total = costo + gastos;
      
      final vehiculoData = {
        'fechaRecibido': fechaRecibido,
        'ano': ano,
        'marca': marca,
        'modelo': modelo,
        'vin': vin,
        'color': color,
        'motor': motor,
        'traccion': traccion,
        'version': version,
        'comercializadora': comercializadora,
        'costo': costo,
        'gastos': gastos,
        'precioSugerido': precioSugerido,
        'total': total,
        'estado': estado,
        'imagen': imagen ?? '',
        'nombreUsuario': nombreUsuario,
        'correoUsuario': correoUsuario,
      };
      
      print('INFO [$_logPrefix] Datos del vehículo: $vehiculoData');
      
      // PRUEBA TEMPORAL: Enviar como GET con parámetros en URL
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'tipo': 'inventario',
        'action': 'agregar',
        'fechaRecibido': vehiculoData['fechaRecibido']?.toString() ?? '',
        'ano': vehiculoData['ano']?.toString() ?? '',
        'marca': vehiculoData['marca']?.toString() ?? '',
        'modelo': vehiculoData['modelo']?.toString() ?? '',
        'vin': vehiculoData['vin']?.toString() ?? '',
        'color': vehiculoData['color']?.toString() ?? '',
        'motor': vehiculoData['motor']?.toString() ?? '',
        'traccion': vehiculoData['traccion']?.toString() ?? '',
        'version': vehiculoData['version']?.toString() ?? '',
        'comercializadora': vehiculoData['comercializadora']?.toString() ?? '',
        'costo': vehiculoData['costo']?.toString() ?? '0',
        'gastos': vehiculoData['gastos']?.toString() ?? '0',
        'precioSugerido': vehiculoData['precioSugerido']?.toString() ?? '0',
        'estado': vehiculoData['estado']?.toString() ?? 'Disponible',
        'nombreUsuario': vehiculoData['nombreUsuario']?.toString() ?? '',
        'correoUsuario': vehiculoData['correoUsuario']?.toString() ?? '',
      });
      
      print('INFO [$_logPrefix] URL completa: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Vehículo agregado: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al agregar: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Actualizar vehículo existente
  static Future<Map<String, dynamic>> actualizarVehiculo({
    required String id,
    String? ano,
    String? marca,
    String? modelo,
    String? vin,
    String? color,
    String? motor,
    String? traccion,
    String? version,
    String? comercializadora,
    double? costo,
    double? gastos,
    double? precioSugerido,
    String? estado,
    String? imagen,
    String? nombreUsuario,
    String? correoUsuario,
  }) async {
    try {
      print('INFO [$_logPrefix] Actualizando vehículo ID: $id');
      
      Map<String, dynamic> updateData = {'id': id};
      
      if (ano != null) updateData['ano'] = ano;
      if (marca != null) updateData['marca'] = marca;
      if (modelo != null) updateData['modelo'] = modelo;
      if (vin != null) updateData['vin'] = vin;
      if (color != null) updateData['color'] = color;
      if (motor != null) updateData['motor'] = motor;
      if (traccion != null) updateData['traccion'] = traccion;
      if (version != null) updateData['version'] = version;
      if (comercializadora != null) updateData['comercializadora'] = comercializadora;
      if (costo != null) updateData['costo'] = costo;
      if (gastos != null) updateData['gastos'] = gastos;
      if (precioSugerido != null) updateData['precioSugerido'] = precioSugerido;
      if (estado != null) updateData['estado'] = estado;
      if (imagen != null) updateData['imagen'] = imagen;
      if (nombreUsuario != null) updateData['nombreUsuario'] = nombreUsuario;
      if (correoUsuario != null) updateData['correoUsuario'] = correoUsuario;
      
      print('INFO [$_logPrefix] Datos a actualizar: $updateData');

      // Construir parámetros de URL igual que agregarVehiculo
      final queryParams = <String, String>{
        'tipo': 'inventario',
        'action': 'editar',
        'id': id,
      };
      
      // Agregar solo los parámetros que no son null
      if (ano != null) queryParams['ano'] = ano;
      if (marca != null) queryParams['marca'] = marca;
      if (modelo != null) queryParams['modelo'] = modelo;
      if (vin != null) queryParams['vin'] = vin;
      if (color != null) queryParams['color'] = color;
      if (motor != null) queryParams['motor'] = motor;
      if (traccion != null) queryParams['traccion'] = traccion;
      if (version != null) queryParams['version'] = version;
      if (comercializadora != null) queryParams['comercializadora'] = comercializadora;
      if (costo != null) queryParams['costo'] = costo.toString();
      if (gastos != null) queryParams['gastos'] = gastos.toString();
      if (precioSugerido != null) queryParams['precioSugerido'] = precioSugerido.toString();
      if (estado != null) queryParams['estado'] = estado;
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
        print('SUCCESS [$_logPrefix] Vehículo actualizado: $data');
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

  // Eliminar vehículo del inventario
  static Future<Map<String, dynamic>> eliminarVehiculo(String id) async {
    try {
      print('INFO [$_logPrefix] Eliminando vehículo ID: $id');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'tipo': 'inventario',
        'action': 'eliminar',
        'id': id,
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);

      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Vehículo eliminado: $data');
        return data;
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return {'success': false, 'error': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al eliminar: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener estadísticas del inventario
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      print('INFO [$_logPrefix] Calculando estadísticas localmente...');
      
      // Obtenemos todos los vehículos primero
      final vehiculos = await obtenerInventario();
      print('INFO [$_logPrefix] Calculando estadísticas para ${vehiculos.length} vehículos');
      
      final estadisticas = _calcularEstadisticasLocales(vehiculos);
      print('SUCCESS [$_logPrefix] Estadísticas calculadas: $estadisticas');
      
      return estadisticas;
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al obtener estadísticas: $e');
      return {};
    }
  }

  // Obtener lista de marcas únicas
  static Future<List<String>> obtenerMarcas() async {
    try {
      print('INFO [$_logPrefix] Obteniendo marcas...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'tipo': 'inventario',
        'action': 'marcas',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      print('INFO [$_logPrefix] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Marcas obtenidas: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          return List<String>.from(rawData);
        } else {
          print('ERROR [$_logPrefix] Error en respuesta: ${data['error']}');
          return [];
        }
      } else {
        print('ERROR [$_logPrefix] Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción al obtener marcas: $e');
      return [];
    }
  }

  // Función privada para calcular días en inventario
  static int _calcularDiasInventario(String fechaRecibido) {
    try {
      final fechaInicio = DateTime.parse(fechaRecibido);
      final fechaActual = DateTime.now();
      final diferencia = fechaActual.difference(fechaInicio);
      return diferencia.inDays;
    } catch (e) {
      print('Error al calcular días en inventario: $e');
      return 0;
    }
  }

  // Helper para parsear doubles de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Función helper para mostrar VIN de manera segura (sin truncar si es corto)
  static String _truncarVin(String? vin) {
    if (vin == null || vin.isEmpty) return 'N/A';
    // Si el VIN es corto (6-8 caracteres), mostrarlo completo
    // Si es largo (más de 8), mostrar solo los primeros 8
    return vin.length > 8 ? vin.substring(0, 8) + '...' : vin;
  }

  // Función helper para normalizar datos recibidos de Google Sheets
  static Map<String, dynamic> _normalizarDatosVehiculo(Map<String, dynamic> raw) {
    return {
      'id': raw['id'] ?? '',
      'fechaRecibido': raw['fechaRecibido'] ?? '',
      'ano': raw['ano'] ?? '',
      'marca': raw['marca'] ?? '',
      'modelo': raw['modelo'] ?? '',
      'vin': _truncarVin(raw['vin']?.toString()),
      'vinCompleto': raw['vin']?.toString() ?? '',
      'color': raw['color'] ?? '',
      'motor': raw['motor'] ?? '',
      'traccion': raw['traccion'] ?? '',
      'version': raw['version'] ?? '',
      'comercializadora': raw['comercializadora'] ?? '',
      'costo': _parseDouble(raw['costo']),
      'gastos': _parseDouble(raw['gastos']),
      'precioSugerido': _parseDouble(raw['precioSugerido']),
      'total': _parseDouble(raw['total']),
      'diasInventario': _calcularDiasInventario(raw['fechaRecibido']?.toString() ?? ''),
      // Corregir el mapeo del estado - parece estar en nombreUsuario por error en los datos
      'estado': _determinarEstado(raw),
      'imagen': raw['correoUsuario'] ?? '', // Las imágenes parecen estar en correoUsuario
      'nombreUsuario': raw['fechaCreacion'] ?? '',
      'correoUsuario': raw['fechaActualizacion'] ?? '',
      'fechaCreacion': raw['fechaCreacion'] ?? '',
      'fechaActualizacion': raw['fechaActualizacion'] ?? '',
    };
  }

  static String _determinarEstado(Map<String, dynamic> raw) {
    // Revisar si el estado está en nombreUsuario (parece ser el caso)
    String posibleEstado = raw['nombreUsuario']?.toString() ?? '';
    if (posibleEstado.toLowerCase() == 'vendido') return 'Vendido';
    if (posibleEstado.toLowerCase() == 'disponible') return 'Disponible';
    if (posibleEstado.toLowerCase() == 'reservado') return 'Reservado';
    
    // Si no encontramos estado válido, usar 'estado' directamente
    return raw['estado']?.toString() ?? 'Disponible';
  }

  // Calcular estadísticas localmente para corregir el problema del Google Script
  static Map<String, dynamic> _calcularEstadisticasLocales(List<Map<String, dynamic>> vehiculos) {
    int totalVehiculos = vehiculos.length;
    int disponibles = 0;
    int vendidos = 0;
    int reservados = 0;
    int enReparacion = 0;
    int enTransito = 0;
    double valorTotal = 0;
    int totalDias = 0;

    for (var vehiculo in vehiculos) {
      String estado = vehiculo['estado']?.toString().toLowerCase() ?? '';
      double total = vehiculo['total']?.toDouble() ?? 0;
      int dias = vehiculo['diasInventario'] ?? 0;

      switch (estado) {
        case 'disponible':
          disponibles++;
          break;
        case 'vendido':
          vendidos++;
          break;
        case 'reservado':
          reservados++;
          break;
        case 'en reparación':
        case 'en reparacion':
          enReparacion++;
          break;
        case 'en tránsito':
        case 'en transito':
          enTransito++;
          break;
      }

      valorTotal += total;
      totalDias += dias;
    }

    int promedioInventario = totalVehiculos > 0 ? (totalDias / totalVehiculos).round() : 0;

    return {
      'totalVehiculos': totalVehiculos,
      'disponibles': disponibles,
      'vendidos': vendidos,
      'reservados': reservados,
      'enReparacion': enReparacion,
      'enTransito': enTransito,
      'valorTotal': valorTotal,
      'promedioInventario': promedioInventario,
    };
  }

  // Obtener estados disponibles
  static List<String> obtenerEstadosDisponibles() {
    return ['Disponible', 'Reservado', 'Vendido', 'En Reparación', 'En Tránsito'];
  }
}