import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class UsuariosService {
  // URL del script de usuarios independiente
  static const String _baseUrl = ApiConfig.usuariosUrl;
  static const String _logPrefix = 'USUARIOS';

  /// Obtener todos los usuarios desde Google Sheets
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      print('INFO [$_logPrefix] Iniciando obtención de usuarios...');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'obtener',
        'tipo': 'usuarios',
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          final rawData = data['data'] ?? [];
          final usuarios = (rawData as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
          print('SUCCESS [$_logPrefix] Total de usuarios: ${usuarios.length}');
          return usuarios;
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

  /// Registrar un nuevo usuario
  static Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String correo,
    required String contrasena,
    required String rol,
    String? imagen,
    bool activo = true,
  }) async {
    try {
      print('INFO [$_logPrefix] Registrando usuario: "$nombre" - "$correo"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'registrar',
        'tipo': 'usuarios',
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol,
        'imagen': imagen ?? '',
        'activo': activo.toString(),
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

  /// Editar un usuario existente
  static Future<Map<String, dynamic>> editarUsuario({
    required String id,
    String? nombre,
    String? correo,
    String? contrasena,
    String? rol,
    String? imagen,
    bool? activo,
  }) async {
    try {
      print('INFO [$_logPrefix] Editando usuario ID: "$id"');
      
      final params = <String, String>{
        'action': 'editar',
        'tipo': 'usuarios',
        'id': id,
      };
      
      // Solo agregar parámetros que no sean null
      if (nombre != null) params['nombre'] = nombre;
      if (correo != null) params['correo'] = correo;
      if (contrasena != null) params['contrasena'] = contrasena;
      if (rol != null) params['rol'] = rol;
      if (imagen != null) params['imagen'] = imagen;
      if (activo != null) params['activo'] = activo.toString();
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      
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

  /// Eliminar un usuario
  static Future<Map<String, dynamic>> eliminarUsuario(String id) async {
    try {
      print('INFO [$_logPrefix] Eliminando usuario ID: "$id"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'eliminar',
        'tipo': 'usuarios',
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

  /// Validar login de usuario
  static Future<Map<String, dynamic>> validarLogin({
    required String correo,
    required String contrasena,
  }) async {
    try {
      print('INFO [$_logPrefix] Validando login para: "$correo"');
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'action': 'login',
        'tipo': 'usuarios',
        'correo': correo,
        'contrasena': contrasena,
      });
      
      print('INFO [$_logPrefix] URL: $uri');
      final response = await http.get(uri);
      
      print('INFO [$_logPrefix] Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('SUCCESS [$_logPrefix] Respuesta: $data');
        
        if (data['success'] == true) {
          print('SUCCESS [$_logPrefix] Login exitoso para: "$correo"');
          print('SUCCESS [$_logPrefix] Usuario: ${data['data']}');
        } else {
          print('ERROR [$_logPrefix] Error en login: ${data['error']}');
        }
        
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