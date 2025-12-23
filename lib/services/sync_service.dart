import 'firestore_service.dart';
import 'inventario_service.dart';
import 'ventas_service.dart';
import 'gastos_service.dart';
import 'usuarios_service.dart';
import 'roles_service.dart';

class SyncService {
  // Este servicio maneja la sincronización unidireccional
  // Firestore = Principal (lectura/escritura)
  // Google Sheets = Solo escritura (respaldo visual, nunca se lee de ahí)

  // INVENTARIO
  static Future<List<Map<String, dynamic>>> obtenerInventario() async {
    try {
      // Leer SOLO de Firestore
      List<Map<String, dynamic>> firestoreData = await FirestoreService.obtenerInventario();
      print('📊 [SYNC] Inventario desde Firestore: ${firestoreData.length} vehículos');
      return firestoreData;
    } catch (e) {
      print('❌ [SYNC] Error obteniendo inventario: $e');
      return [];
    }
  }

  static Future<void> agregarVehiculo(Map<String, dynamic> vehiculo) async {
    try {
      // 1. Agregar a Firestore (principal)
      await FirestoreService.agregarVehiculo(vehiculo);
      
      // 2. Agregar SOLO este vehículo a Sheets (respaldo)
      final id = vehiculo['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        await _agregarVehiculoASheets(vehiculo);
      }
      
    } catch (e) {
      print('Error al agregar vehículo: $e');
      throw e;
    }
  }

  static Future<void> actualizarVehiculo(String id, Map<String, dynamic> datos) async {
    try {
      // 1. Actualizar en Firestore (principal)
      await FirestoreService.actualizarVehiculo(id, datos);
      
      // 2. Sincronizar SOLO este vehículo con Sheets (respaldo)
      // Usar el 'id' interno de Sheets (VEH_XXX), no el docId de Firestore
      final sheetsId = datos['id']?.toString() ?? id;
      await _sincronizarVehiculoConSheets(sheetsId, datos);
      
    } catch (e) {
      print('Error al actualizar vehículo: $e');
      throw e;
    }
  }

  static Future<void> eliminarVehiculo(String id) async {
    try {
      // 1. Eliminar de Firestore (principal)
      await FirestoreService.eliminarVehiculo(id);
      
      // 2. Eliminar SOLO este vehículo de Sheets (respaldo)
      await _eliminarVehiculoDeSheets(id);
      
    } catch (e) {
      print('Error al eliminar vehículo: $e');
      throw e;
    }
  }

  // VENTAS
  static Future<List<Map<String, dynamic>>> obtenerVentas() async {
    // Leer SOLO de Firestore
    return await FirestoreService.obtenerVentas();
  }

  static Future<void> agregarVenta(Map<String, dynamic> venta) async {
    try {
      // 1. Agregar a Firestore (principal)
      await FirestoreService.agregarVenta(venta);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarVentasConSheets();
      
    } catch (e) {
      print('Error al agregar venta: $e');
      throw e;
    }
  }

  static Future<void> actualizarVenta(String id, Map<String, dynamic> datos) async {
    try {
      // 1. Actualizar en Firestore (principal)
      await FirestoreService.actualizarVenta(id, datos);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarVentasConSheets();
      
    } catch (e) {
      print('Error al actualizar venta: $e');
      throw e;
    }
  }

  static Future<void> eliminarVenta(String id) async {
    try {
      // 1. Eliminar de Firestore (principal)
      await FirestoreService.eliminarVenta(id);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarVentasConSheets();
      
    } catch (e) {
      print('Error al eliminar venta: $e');
      throw e;
    }
  }

  // GASTOS
  static Future<List<Map<String, dynamic>>> obtenerGastos() async {
    // Leer SOLO de Firestore
    return await FirestoreService.obtenerGastos();
  }

  static Future<void> agregarGasto(Map<String, dynamic> gasto) async {
    try {
      // 1. Agregar a Firestore (principal)
      await FirestoreService.agregarGasto(gasto);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarGastosConSheets();
      
    } catch (e) {
      print('Error al agregar gasto: $e');
      throw e;
    }
  }

  static Future<void> actualizarGasto(String id, Map<String, dynamic> datos) async {
    try {
      // 1. Actualizar en Firestore (principal)
      await FirestoreService.actualizarGasto(id, datos);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarGastosConSheets();
      
    } catch (e) {
      print('Error al actualizar gasto: $e');
      throw e;
    }
  }

  static Future<void> eliminarGasto(String id) async {
    try {
      // 1. Eliminar de Firestore (principal)
      await FirestoreService.eliminarGasto(id);
      
      // 2. Sincronizar con Sheets (respaldo)
      await _sincronizarGastosConSheets();
      
    } catch (e) {
      print('Error al eliminar gasto: $e');
      throw e;
    }
  }

  // USUARIOS
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    // Leer SOLO de Firestore
    return await FirestoreService.obtenerUsuarios();
  }

  /// Validar login de usuario contra Firestore
  static Future<Map<String, dynamic>> validarLogin({
    required String correo,
    required String contrasena,
  }) async {
    try {
      print('🔐 [SYNC] Validando login para: "$correo" en Firestore');
      
      // Obtener todos los usuarios de Firestore
      List<Map<String, dynamic>> usuarios = await FirestoreService.obtenerUsuarios();
      
      if (usuarios.isEmpty) {
        print('⚠️ [SYNC] No hay usuarios en Firestore');
        return {
          'success': false,
          'error': 'No hay usuarios registrados. Ejecuta la migración primero.'
        };
      }
      
      // Buscar usuario por correo
      Map<String, dynamic>? usuarioEncontrado;
      for (var usuario in usuarios) {
        final emailUsuario = (usuario['correo'] ?? usuario['email'] ?? '').toString().toLowerCase().trim();
        if (emailUsuario == correo.toLowerCase().trim()) {
          usuarioEncontrado = usuario;
          break;
        }
      }
      
      if (usuarioEncontrado == null) {
        print('❌ [SYNC] Usuario no encontrado: $correo');
        return {
          'success': false,
          'error': 'Usuario no encontrado'
        };
      }
      
      // Verificar contraseña
      final passwordGuardada = (usuarioEncontrado['contrasena'] ?? usuarioEncontrado['password'] ?? '').toString();
      
      if (passwordGuardada != contrasena) {
        print('❌ [SYNC] Contraseña incorrecta para: $correo');
        return {
          'success': false,
          'error': 'Contraseña incorrecta'
        };
      }
      
      // Verificar si el usuario está activo
      final activo = usuarioEncontrado['activo'];
      if (activo == false || activo == 'false' || activo == '0') {
        print('❌ [SYNC] Usuario inactivo: $correo');
        return {
          'success': false,
          'error': 'Usuario inactivo. Contacta al administrador.'
        };
      }
      
      print('✅ [SYNC] Login exitoso para: $correo');
      print('✅ [SYNC] Datos usuario: ${usuarioEncontrado.keys.join(', ')}');
      
      return {
        'success': true,
        'data': usuarioEncontrado
      };
      
    } catch (e) {
      print('❌ [SYNC] Error en validarLogin: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e'
      };
    }
  }

  static Future<void> agregarUsuario(Map<String, dynamic> usuario) async {
    try {
      // 1. Agregar a Firestore (principal)
      await FirestoreService.agregarUsuario(usuario);
      
      // 2. No sincronizamos usuarios con Sheets por seguridad
      
    } catch (e) {
      print('Error al agregar usuario: $e');
      throw e;
    }
  }

  static Future<void> actualizarUsuario(String id, Map<String, dynamic> datos) async {
    try {
      // 1. Actualizar en Firestore (principal)
      await FirestoreService.actualizarUsuario(id, datos);
      
      // 2. No sincronizamos usuarios con Sheets por seguridad
      
    } catch (e) {
      print('Error al actualizar usuario: $e');
      throw e;
    }
  }

  static Future<void> eliminarUsuario(String id) async {
    try {
      // 1. Eliminar de Firestore (principal)
      await FirestoreService.eliminarUsuario(id);
      
      // 2. No sincronizamos usuarios con Sheets por seguridad
      
    } catch (e) {
      print('Error al eliminar usuario: $e');
      throw e;
    }
  }

  /// Método temporal para actualizar contraseñas de usuarios migrados
  static Future<void> actualizarContrasenasUsuarios() async {
    try {
      print('🔐 [SYNC] Actualizando contraseñas de usuarios...');
      
      // Mapa de correos y contraseñas
      final Map<String, String> contrasenasUsuarios = {
        'brandon@gmail.com': 'admin123',
        'cargoag@gmail.com': 'cargoag@',
        'v_patricia66@hotmail.com': 'susana@',
        'armando@gmail.com': 'armando@',
      };
      
      // Obtener usuarios de Firestore (esto ya incluye el docId real)
      List<Map<String, dynamic>> usuarios = await FirestoreService.obtenerUsuarios();
      print('🔐 [SYNC] Usuarios encontrados: ${usuarios.length}');
      
      for (var usuario in usuarios) {
        final correo = (usuario['correo'] ?? usuario['email'] ?? '').toString().toLowerCase().trim();
        // El 'docId' es el ID real del documento en Firestore
        final firestoreDocId = usuario['docId']?.toString() ?? '';
        
        print('🔐 [SYNC] Procesando usuario: $correo con docId: $firestoreDocId');
        
        if (firestoreDocId.isEmpty) {
          print('⚠️ [SYNC] Usuario sin docId: $correo');
          continue;
        }
        
        // Buscar contraseña correspondiente
        String? contrasena;
        for (var entry in contrasenasUsuarios.entries) {
          if (entry.key.toLowerCase() == correo) {
            contrasena = entry.value;
            break;
          }
        }
        
        if (contrasena != null) {
          print('🔐 [SYNC] Actualizando contraseña para: $correo (docId: $firestoreDocId)');
          await FirestoreService.actualizarUsuario(firestoreDocId, {'contrasena': contrasena});
          print('✅ [SYNC] Contraseña actualizada para: $correo');
        } else {
          print('⚠️ [SYNC] No se encontró contraseña para: $correo');
        }
      }
      
      print('✅ [SYNC] Actualización de contraseñas completada');
      
    } catch (e) {
      print('❌ [SYNC] Error actualizando contraseñas: $e');
      throw e;
    }
  }

  // ROLES
  static Future<List<Map<String, dynamic>>> obtenerRoles() async {
    // Leer SOLO de Firestore
    return await FirestoreService.obtenerRoles();
  }

  static Future<void> agregarRol(Map<String, dynamic> rol) async {
    try {
      // 1. Agregar a Firestore (principal)
      await FirestoreService.agregarRol(rol);
      
      // 2. No sincronizamos roles con Sheets por seguridad
      
    } catch (e) {
      print('Error al agregar rol: $e');
      throw e;
    }
  }

  static Future<void> actualizarRol(String id, Map<String, dynamic> datos) async {
    try {
      // 1. Actualizar en Firestore (principal)
      await FirestoreService.actualizarRol(id, datos);
      
      // 2. No sincronizamos roles con Sheets por seguridad
      
    } catch (e) {
      print('Error al actualizar rol: $e');
      throw e;
    }
  }

  static Future<void> eliminarRol(String id) async {
    try {
      // 1. Eliminar de Firestore (principal)
      await FirestoreService.eliminarRol(id);
      
      // 2. No sincronizamos roles con Sheets por seguridad
      
    } catch (e) {
      print('Error al eliminar rol: $e');
      throw e;
    }
  }

  // MÉTODOS PRIVADOS DE SINCRONIZACIÓN

  // Sincroniza UN SOLO vehículo con Sheets (para actualizaciones individuales)
  static Future<void> _sincronizarVehiculoConSheets(String id, Map<String, dynamic> datos) async {
    try {
      print('📊 [SYNC] Sincronizando vehículo $id con Google Sheets...');
      
      await InventarioService.actualizarVehiculo(
        id: id,
        ano: datos['ano']?.toString(),
        marca: datos['marca']?.toString(),
        modelo: datos['modelo']?.toString(),
        vin: datos['vin']?.toString(),
        color: datos['color']?.toString(),
        motor: datos['motor']?.toString(),
        traccion: datos['traccion']?.toString(),
        version: datos['version']?.toString(),
        comercializadora: datos['comercializadora']?.toString(),
        costo: double.tryParse(datos['costo']?.toString() ?? '0'),
        gastos: double.tryParse(datos['gastos']?.toString() ?? '0'),
        precioSugerido: double.tryParse(datos['precioSugerido']?.toString() ?? '0'),
        estado: datos['estado']?.toString(),
        imagenesUrl: datos['imagenesUrl']?.toString(),
      );
      
      print('✅ [SYNC] Vehículo $id sincronizado con Sheets');
    } catch (e) {
      print('⚠️ [SYNC] Error sincronizando vehículo $id con Sheets: $e');
      // No lanzamos error porque Sheets es solo respaldo
    }
  }

  // Agrega UN SOLO vehículo a Sheets
  static Future<void> _agregarVehiculoASheets(Map<String, dynamic> datos) async {
    try {
      print('📊 [SYNC] Agregando vehículo a Google Sheets...');
      
      await InventarioService.agregarVehiculo(
        ano: datos['ano']?.toString() ?? '',
        marca: datos['marca']?.toString() ?? '',
        modelo: datos['modelo']?.toString() ?? '',
        vin: datos['vin']?.toString() ?? '',
        color: datos['color']?.toString() ?? '',
        motor: datos['motor']?.toString() ?? '',
        traccion: datos['traccion']?.toString() ?? '',
        version: datos['version']?.toString() ?? '',
        comercializadora: datos['comercializadora']?.toString() ?? '',
        costo: double.tryParse(datos['costo']?.toString() ?? '0') ?? 0,
        gastos: double.tryParse(datos['gastos']?.toString() ?? '0') ?? 0,
        precioSugerido: double.tryParse(datos['precioSugerido']?.toString() ?? '0') ?? 0,
        estado: datos['estado']?.toString() ?? 'Disponible',
        imagenesUrl: datos['imagenesUrl']?.toString() ?? '',
        nombreUsuario: datos['nombreUsuario']?.toString() ?? '',
        correoUsuario: datos['correoUsuario']?.toString() ?? '',
      );
      
      print('✅ [SYNC] Vehículo agregado a Sheets');
    } catch (e) {
      print('⚠️ [SYNC] Error agregando vehículo a Sheets: $e');
      // No lanzamos error porque Sheets es solo respaldo
    }
  }

  // Elimina UN SOLO vehículo de Sheets
  static Future<void> _eliminarVehiculoDeSheets(String id) async {
    try {
      print('📊 [SYNC] Eliminando vehículo $id de Google Sheets...');
      
      await InventarioService.eliminarVehiculo(id);
      
      print('✅ [SYNC] Vehículo $id eliminado de Sheets');
    } catch (e) {
      print('⚠️ [SYNC] Error eliminando vehículo $id de Sheets: $e');
      // No lanzamos error porque Sheets es solo respaldo
    }
  }

  static Future<void> _sincronizarInventarioConSheets() async {
    try {
      print('📊 [SYNC] Sincronizando inventario con Google Sheets...');
      
      // Obtener datos actuales de Firestore
      List<Map<String, dynamic>> inventario = await FirestoreService.obtenerInventario();
      print('📊 [SYNC] ${inventario.length} vehículos en Firestore');
      
      // Sincronizar cada vehículo con Sheets
      for (var vehiculo in inventario) {
        try {
          final id = vehiculo['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          
          // Enviar actualización a Sheets
          await InventarioService.actualizarVehiculo(
            id: id,
            ano: vehiculo['ano']?.toString(),
            marca: vehiculo['marca']?.toString(),
            modelo: vehiculo['modelo']?.toString(),
            vin: vehiculo['vin']?.toString(),
            color: vehiculo['color']?.toString(),
            motor: vehiculo['motor']?.toString(),
            traccion: vehiculo['traccion']?.toString(),
            version: vehiculo['version']?.toString(),
            comercializadora: vehiculo['comercializadora']?.toString(),
            costo: double.tryParse(vehiculo['costo']?.toString() ?? '0'),
            gastos: double.tryParse(vehiculo['gastos']?.toString() ?? '0'),
            precioSugerido: double.tryParse(vehiculo['precioSugerido']?.toString() ?? '0'),
            estado: vehiculo['estado']?.toString(),
            imagenesUrl: vehiculo['imagenesUrl']?.toString(),
          );
        } catch (e) {
          print('⚠️ [SYNC] Error sincronizando vehículo ${vehiculo['id']}: $e');
          // Continuar con el siguiente vehículo
        }
      }
      
      print('✅ [SYNC] Sincronización de inventario completada');
      
    } catch (e) {
      print('❌ [SYNC] Error sincronizando inventario con Sheets: $e');
      // No lanzamos error porque Sheets es solo respaldo
    }
  }

  static Future<void> _sincronizarVentasConSheets() async {
    try {
      print('💰 [SYNC] Sincronizando ventas con Google Sheets...');
      
      List<Map<String, dynamic>> ventas = await FirestoreService.obtenerVentas();
      print('💰 [SYNC] ${ventas.length} ventas en Firestore');
      
      // Sincronizar cada venta con Sheets
      for (var venta in ventas) {
        try {
          final id = venta['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          
          await VentasService.actualizarVenta(
            id: id,
            fechaVenta: venta['fechaVenta']?.toString(),
            vin: venta['vin']?.toString(),
            ano: venta['ano']?.toString(),
            modelo: venta['modelo']?.toString(),
            precioVenta: double.tryParse(venta['precioVenta']?.toString() ?? '0'),
            estatus: venta['estatus']?.toString(),
            vendedor: venta['vendedor']?.toString(),
          );
        } catch (e) {
          print('⚠️ [SYNC] Error sincronizando venta ${venta['id']}: $e');
        }
      }
      
      print('✅ [SYNC] Sincronización de ventas completada');
      
    } catch (e) {
      print('❌ [SYNC] Error sincronizando ventas con Sheets: $e');
    }
  }

  static Future<void> _sincronizarGastosConSheets() async {
    try {
      print('💸 [SYNC] Sincronizando gastos con Google Sheets...');
      
      List<Map<String, dynamic>> gastos = await FirestoreService.obtenerGastos();
      print('💸 [SYNC] ${gastos.length} gastos en Firestore');
      
      // Sincronizar cada gasto con Sheets
      for (var gasto in gastos) {
        try {
          final id = gasto['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          
          await GastosService.actualizarGasto(
            id: id,
            fecha: gasto['fecha']?.toString(),
            vin: gasto['vin']?.toString(),
            categoria: gasto['categoria']?.toString(),
            concepto: gasto['concepto']?.toString(),
            tipo: gasto['tipo']?.toString(),
            montoMXN: double.tryParse(gasto['montoMXN']?.toString() ?? '0'),
          );
        } catch (e) {
          print('⚠️ [SYNC] Error sincronizando gasto ${gasto['id']}: $e');
        }
      }
      
      print('✅ [SYNC] Sincronización de gastos completada');
      
    } catch (e) {
      print('❌ [SYNC] Error sincronizando gastos con Sheets: $e');
    }
  }

  // MIGRACIÓN INICIAL (ejecutar una sola vez)
  static Future<void> migrarDesdeSheetsAFirestore() async {
    try {
      print('🚀 Iniciando migración desde Google Sheets a Firestore...');
      
      // Migrar inventario
      print('📦 Obteniendo inventario de Sheets...');
      List<Map<String, dynamic>> inventarioSheets = await InventarioService.obtenerInventario();
      print('📦 Obtenidos ${inventarioSheets.length} vehículos de Sheets');
      
      if (inventarioSheets.isNotEmpty) {
        print('📦 Comenzando migración de inventario a Firestore...');
        int migratedCount = 0;
        for (int i = 0; i < inventarioSheets.length; i++) {
          try {
            Map<String, dynamic> vehiculo = inventarioSheets[i];
            print('📦 Migrando vehículo ${i+1}/${inventarioSheets.length}: ${vehiculo['marca']} ${vehiculo['modelo']}');
            await FirestoreService.agregarVehiculo(vehiculo);
            migratedCount++;
            print('✅ Vehículo migrado exitosamente');
          } catch (e) {
            print('❌ Error migrando vehículo ${i+1}: $e');
            // Continuamos con el siguiente vehículo
          }
        }
        print('✅ Inventario migrado: $migratedCount/${inventarioSheets.length} vehículos');
      }
      
      // Migrar ventas
      print('💰 Obteniendo ventas de Sheets...');
      List<Map<String, dynamic>> ventasSheets = await VentasService.obtenerVentas();
      print('💰 Obtenidas ${ventasSheets.length} ventas de Sheets');
      
      if (ventasSheets.isNotEmpty) {
        print('💰 Comenzando migración de ventas a Firestore...');
        int migratedVentas = 0;
        for (int i = 0; i < ventasSheets.length; i++) {
          try {
            Map<String, dynamic> venta = ventasSheets[i];
            print('💰 Migrando venta ${i+1}/${ventasSheets.length}');
            await FirestoreService.agregarVenta(venta);
            migratedVentas++;
          } catch (e) {
            print('❌ Error migrando venta ${i+1}: $e');
          }
        }
        print('✅ Ventas migradas: $migratedVentas/${ventasSheets.length} ventas');
      }
      
      // Migrar gastos
      print('💸 Obteniendo gastos de Sheets...');
      List<Map<String, dynamic>> gastosSheets = await GastosService.obtenerGastos();
      print('💸 Obtenidos ${gastosSheets.length} gastos de Sheets');
      
      if (gastosSheets.isNotEmpty) {
        print('💸 Comenzando migración de gastos a Firestore...');
        int migratedGastos = 0;
        for (int i = 0; i < gastosSheets.length; i++) {
          try {
            Map<String, dynamic> gasto = gastosSheets[i];
            print('💸 Migrando gasto ${i+1}/${gastosSheets.length}');
            await FirestoreService.agregarGasto(gasto);
            migratedGastos++;
          } catch (e) {
            print('❌ Error migrando gasto ${i+1}: $e');
          }
        }
        print('✅ Gastos migrados: $migratedGastos/${gastosSheets.length} gastos');
      }
      
      // Migrar usuarios
      print('👤 Obteniendo usuarios de Sheets...');
      List<Map<String, dynamic>> usuariosSheets = await UsuariosService.obtenerUsuarios();
      print('👤 Obtenidos ${usuariosSheets.length} usuarios de Sheets');
      
      if (usuariosSheets.isNotEmpty) {
        print('👤 Comenzando migración de usuarios a Firestore...');
        int migratedUsuarios = 0;
        for (int i = 0; i < usuariosSheets.length; i++) {
          try {
            Map<String, dynamic> usuario = usuariosSheets[i];
            print('👤 Migrando usuario ${i+1}/${usuariosSheets.length}: ${usuario['nombre']} - ${usuario['correo']}');
            await FirestoreService.agregarUsuario(usuario);
            migratedUsuarios++;
          } catch (e) {
            print('❌ Error migrando usuario ${i+1}: $e');
          }
        }
        print('✅ Usuarios migrados: $migratedUsuarios/${usuariosSheets.length} usuarios');
      }
      
      // Migrar roles
      print('🔐 Obteniendo roles de Sheets...');
      List<Map<String, dynamic>> rolesSheets = await RolesService.obtenerRoles();
      print('🔐 Obtenidos ${rolesSheets.length} roles de Sheets');
      
      if (rolesSheets.isNotEmpty) {
        print('🔐 Comenzando migración de roles a Firestore...');
        int migratedRoles = 0;
        for (int i = 0; i < rolesSheets.length; i++) {
          try {
            Map<String, dynamic> rol = rolesSheets[i];
            print('🔐 Migrando rol ${i+1}/${rolesSheets.length}: ${rol['rol'] ?? rol['nombre']}');
            await FirestoreService.agregarRol(rol);
            migratedRoles++;
          } catch (e) {
            print('❌ Error migrando rol ${i+1}: $e');
          }
        }
        print('✅ Roles migrados: $migratedRoles/${rolesSheets.length} roles');
      }
      
      print('🎉 Migración completada exitosamente');
      
    } catch (e) {
      print('❌ Error general en migración: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw e;
    }
  }
}