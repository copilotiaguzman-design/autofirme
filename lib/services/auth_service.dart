import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';

class AuthService extends ChangeNotifier {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyRememberMe = 'rememberMe';
  
  // Singleton instance
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();
  
  // Factory constructor to return singleton
  factory AuthService() => instance;
  
  // Private constructor
  AuthService._internal() {
    _loadAuthState();
  }
  
  bool _isLoggedIn = false;
  String _userEmail = '';
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  // Credenciales ahora se validan a través de UsuariosService

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  /// Cargar estado de autenticación desde caché
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      
      // Solo cargar el estado si el usuario eligió recordar sesión
      if (rememberMe) {
        _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
        _userEmail = prefs.getString(_keyUserEmail) ?? '';
      } else {
        // Si no eligió recordar, limpiar la sesión
        _isLoggedIn = false;
        _userEmail = '';
      }
      
      print('🔐 AuthService: Estado cargado - isLoggedIn: $_isLoggedIn, email: $_userEmail, rememberMe: $rememberMe');
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando estado de auth: $e');
    }
  }

  /// Iniciar sesión usando Firestore (SyncService)
  Future<AuthResult> login(String email, String password, bool rememberMe) async {
    _setLoading(true);
    
    try {
      // Validar credenciales usando SyncService (Firestore)
      final loginResult = await SyncService.validarLogin(
        correo: email,
        contrasena: password,
      );
      
      if (loginResult['success'] == true) {
        // Login exitoso
        _isLoggedIn = true;
        _userEmail = email;
        _userData = loginResult['data']; // Almacenar datos del usuario
        
        // Guardar en caché si el usuario eligió recordar
        await _saveAuthState(rememberMe);
        
        notifyListeners();
        print('✅ Login exitoso para: $email');
        print('✅ Datos usuario: $_userData');
        return AuthResult.success();
      } else {
        // Login fallido
        final errorMessage = loginResult['error'] ?? 'Credenciales inválidas';
        print('❌ Error en login: $errorMessage');
        return AuthResult.error(errorMessage);
      }
      
    } catch (e) {
      print('❌ Error en login: $e');
      return AuthResult.error('Error de conexión. Intenta nuevamente.');
    } finally {
      _setLoading(false);
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _userEmail = '';
      _userData = null;
      
      // Limpiar TODA la caché de autenticación
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserEmail);
      await prefs.remove(_keyRememberMe);
      
      notifyListeners();
      print('🔓 Logout completado - todo el caché limpiado');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }

  /// Guardar estado en caché
  Future<void> _saveAuthState(bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_keyRememberMe, rememberMe);
      
      if (rememberMe) {
        // Guardar la sesión persistente
        await prefs.setBool(_keyIsLoggedIn, _isLoggedIn);
        await prefs.setString(_keyUserEmail, _userEmail);
        print('💾 Sesión guardada con persistencia');
      } else {
        // Limpiar cualquier sesión persistente anterior
        await prefs.remove(_keyIsLoggedIn);
        await prefs.remove(_keyUserEmail);
        print('🗑️ Sesión temporal (sin persistencia)');
      }
    } catch (e) {
      print('❌ Error guardando estado: $e');
    }
  }

  /// Obtener rol del usuario basado en los datos reales
  UserRole getUserRole() {
    if (!_isLoggedIn || _userData == null) {
      return UserRole.recepcion; // Por defecto recepción si no está logueado
    }
    
    final userRole = _userData!['rol']?.toString().toLowerCase() ?? '';
    
    // Mapear roles de la base de datos a enum
    switch (userRole) {
      case 'administrador':
      case 'admin':
        return UserRole.admin;
      case 'encargado':
      case 'recepcion':
        return UserRole.recepcion;
      case 'vendedor':
      case 'inventario':
        return UserRole.inventario;
      default:
        return UserRole.recepcion; // Por defecto recepción
    }
  }

  /// Validar si el usuario tiene acceso a un módulo específico
  bool hasAccessTo(String module) {
    if (!_isLoggedIn) return false;
    
    final userRole = getUserRole();
    
    switch (module.toLowerCase()) {
      case 'usuarios':
        // Admin y Encargado pueden acceder a usuarios
        return userRole == UserRole.admin || userRole == UserRole.recepcion;
      
      case 'roles':
        // Solo Admin puede acceder a roles
        return userRole == UserRole.admin;
      
      case 'placas':
        // Solo Admin puede acceder a placas
        return userRole == UserRole.admin;
      
      case 'recepcion':
        // Todos los roles pueden acceder a recepción
        return true;
      
      case 'inventario':
        // Admin, Encargado e Inventario pueden acceder a inventario
        return userRole == UserRole.admin || 
               userRole == UserRole.recepcion || 
               userRole == UserRole.inventario;
      
      case 'ventas':
        // Admin y Encargado pueden acceder a ventas
        return userRole == UserRole.admin || 
               userRole == UserRole.recepcion;
      
      case 'gastos':
        // Solo Admin y Encargado pueden acceder a gastos
        return userRole == UserRole.admin || userRole == UserRole.recepcion;
      
      default:
        // Por defecto, solo admin tiene acceso a módulos no definidos
        return userRole == UserRole.admin;
    }
  }

  /// Verificar si el usuario puede crear usuarios
  bool canCreateUsers() {
    final userRole = getUserRole();
    return userRole == UserRole.admin || userRole == UserRole.recepcion;
  }

  /// Verificar si el usuario puede eliminar usuarios
  bool canDeleteUsers() {
    final userRole = getUserRole();
    return userRole == UserRole.admin; // Solo admin puede eliminar
  }

  /// Verificar si el usuario puede asignar un rol específico
  bool canAssignRole(String targetRole) {
    final userRole = getUserRole();
    final targetRoleLower = targetRole.toLowerCase();
    
    if (userRole == UserRole.admin) {
      return true; // Admin puede asignar cualquier rol
    }
    
    if (userRole == UserRole.recepcion) {
      // Encargado solo puede asignar roles de encargado y vendedor
      return targetRoleLower == 'encargado' || 
             targetRoleLower == 'vendedor' ||
             targetRoleLower == 'recepcion' ||
             targetRoleLower == 'inventario';
    }
    
    return false; // Otros roles no pueden asignar roles
  }

  /// Obtener roles que el usuario actual puede asignar
  List<String> getAssignableRoles() {
    final userRole = getUserRole();
    
    if (userRole == UserRole.admin) {
      return ['Administrador', 'Encargado', 'Vendedor'];
    }
    
    if (userRole == UserRole.recepcion) {
      return ['Encargado', 'Vendedor'];
    }
    
    return []; // Otros roles no pueden asignar roles
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

/// Resultado de operaciones de autenticación
class AuthResult {
  final bool success;
  final String? error;

  AuthResult.success() : success = true, error = null;
  AuthResult.error(this.error) : success = false;
}

/// Roles de usuario
enum UserRole {
  admin,
  recepcion,
  inventario,
}

/// Extensión para obtener nombre legible del rol
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.recepcion:
        return 'Recepción';
      case UserRole.inventario:
        return 'Inventario';
    }
  }
}