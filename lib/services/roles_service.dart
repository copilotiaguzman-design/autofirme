import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class RolesService {
  // URL del script de roles independiente
  static const String _baseUrl = ApiConfig.rolesUrl;
  static const String _logPrefix = 'ROLES';

  /// Obtener todos los roles desde Google Sheets
  static Future<List<Map<String, dynamic>>> obtenerRoles() async {
    try {
      print('INFO [$_logPrefix] Iniciando obtención de roles...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'obtener',
        'tipo': 'roles',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          final roles = (rawData as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
          print('SUCCESS [$_logPrefix] Total de roles: ${roles.length}');
          return roles;
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

  /// Registrar un nuevo rol
  static Future<Map<String, dynamic>> registrarRol(String nombreRol) async {
    try {
      print('INFO [$_logPrefix] Registrando rol: "$nombreRol"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'registrar',
        'tipo': 'roles',
        'rol': nombreRol,
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
        return {
          'success': false,
          'error': 'Error de conexión: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e'
      };
    }
  }

  /// Editar un rol existente
  static Future<Map<String, dynamic>> editarRol(String id, String nuevoNombre) async {
    try {
      print('INFO [$_logPrefix] Editando rol ID: "$id" -> "$nuevoNombre"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'editar',
        'tipo': 'roles',
        'id': id,
        'rol': nuevoNombre,
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
        return {
          'success': false,
          'error': 'Error de conexión: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e'
      };
    }
  }

  /// Eliminar un rol
  static Future<Map<String, dynamic>> eliminarRol(String id) async {
    try {
      print('INFO [$_logPrefix] Eliminando rol ID: "$id"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'eliminar',
        'tipo': 'roles',
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
        return {
          'success': false,
          'error': 'Error de conexión: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Excepción: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e'
      };
    }
  }
}