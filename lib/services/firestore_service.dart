import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      print('❌ Firestore no disponible: $e');
      return null;
    }
  }

  // Colecciones
  static const String _inventarioCollection = 'inventario';
  static const String _ventasCollection = 'ventas';
  static const String _gastosCollection = 'gastos';
  static const String _usuariosCollection = 'usuarios';
  static const String _rolesCollection = 'roles';

  // LIMPIAR COLECCIONES (para re-migración)
  static Future<void> limpiarTodasLasColecciones() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      print('🗑️ Limpiando todas las colecciones de Firestore...');
      
      // Limpiar inventario
      await _limpiarColeccion(_inventarioCollection);
      
      // Limpiar ventas
      await _limpiarColeccion(_ventasCollection);
      
      // Limpiar gastos
      await _limpiarColeccion(_gastosCollection);
      
      // Limpiar usuarios
      await _limpiarColeccion(_usuariosCollection);
      
      // Limpiar roles
      await _limpiarColeccion(_rolesCollection);
      
      print('✅ Todas las colecciones limpiadas');
    } catch (e) {
      print('❌ Error al limpiar colecciones: $e');
      throw e;
    }
  }

  static Future<void> _limpiarColeccion(String coleccion) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      print('🗑️ Limpiando colección: $coleccion');
      QuerySnapshot snapshot = await firestore.collection(coleccion).get();
      
      int count = 0;
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
        count++;
      }
      
      print('✅ Eliminados $count documentos de $coleccion');
    } catch (e) {
      print('❌ Error al limpiar $coleccion: $e');
    }
  }

  // INVENTARIO
  static Future<List<Map<String, dynamic>>> obtenerInventario() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('⚠️ Firestore no disponible, retornando lista vacía');
        return [];
      }

      print('🔥 Consultando Firestore proyecto: autofirme-196f0');
      print('🔥 Colección: $_inventarioCollection');

      QuerySnapshot querySnapshot = await firestore
          .collection(_inventarioCollection)
          .orderBy('fechaCreacion', descending: true)
          .get();

      print('🔥 Documentos encontrados: ${querySnapshot.docs.length}');
      print('🔥 Metadatos: fromCache=${querySnapshot.metadata.isFromCache}, hasPendingWrites=${querySnapshot.metadata.hasPendingWrites}');

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No hay documentos en Firestore, intentando sin orderBy...');
        
        // Intentar sin orderBy en caso de que el índice no exista
        QuerySnapshot simpleQuery = await firestore
            .collection(_inventarioCollection)
            .get();
        
        print('🔥 Documentos sin orderBy: ${simpleQuery.docs.length}');
        
        return simpleQuery.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'docId': doc.id, // ID real del documento en Firestore
                ...data,
              };
            })
            .toList();
      }

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'docId': doc.id, // ID real del documento en Firestore
              ...data,
            };
          })
          .toList();
    } catch (e) {
      print('❌ Error al obtener inventario: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      return [];
    }
  }

  static Future<void> agregarVehiculo(Map<String, dynamic> vehiculo) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      print('🔥 Agregando vehículo a Firestore...');
      print('🔥 Datos del vehículo: ${vehiculo.keys.join(', ')}');
      
      // Usar el ID de Sheets como document ID en Firestore
      final String sheetsId = vehiculo['id']?.toString() ?? '';
      
      // Crear una copia para no modificar el original
      Map<String, dynamic> vehiculoFirestore = Map.from(vehiculo);
      vehiculoFirestore['fechaCreacion'] = FieldValue.serverTimestamp();
      vehiculoFirestore['fechaModificacion'] = FieldValue.serverTimestamp();
      
      if (sheetsId.isNotEmpty) {
        // Usar el ID de Sheets como document ID
        await firestore.collection(_inventarioCollection).doc(sheetsId).set(vehiculoFirestore);
        print('✅ Vehículo agregado con ID: $sheetsId');
      } else {
        // Si no hay ID, generar uno automático (no debería pasar)
        DocumentReference docRef = await firestore.collection(_inventarioCollection).add(vehiculoFirestore);
        print('✅ Vehículo agregado con ID generado: ${docRef.id}');
      }
    } catch (e) {
      print('❌ Error al agregar vehículo a Firestore: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      throw e;
    }
  }

  static Future<void> actualizarVehiculo(String id, Map<String, dynamic> datos) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      datos['fechaModificacion'] = FieldValue.serverTimestamp();
      
      await firestore
          .collection(_inventarioCollection)
          .doc(id)
          .update(datos);
    } catch (e) {
      print('Error al actualizar vehículo: $e');
      throw e;
    }
  }

  static Future<void> eliminarVehiculo(String id) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      await firestore
          .collection(_inventarioCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar vehículo: $e');
      throw e;
    }
  }

  // VENTAS
  static Future<List<Map<String, dynamic>>> obtenerVentas() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('⚠️ Firestore no disponible, retornando lista vacía');
        return [];
      }

      QuerySnapshot querySnapshot = await firestore
          .collection(_ventasCollection)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error al obtener ventas: $e');
      return [];
    }
  }

  static Future<void> agregarVenta(Map<String, dynamic> venta) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      final String sheetsId = venta['id']?.toString() ?? '';
      Map<String, dynamic> ventaFirestore = Map.from(venta);
      ventaFirestore['fechaCreacion'] = FieldValue.serverTimestamp();
      
      if (sheetsId.isNotEmpty) {
        await firestore.collection(_ventasCollection).doc(sheetsId).set(ventaFirestore);
      } else {
        await firestore.collection(_ventasCollection).add(ventaFirestore);
      }
    } catch (e) {
      print('Error al agregar venta: $e');
      throw e;
    }
  }

  static Future<void> actualizarVenta(String id, Map<String, dynamic> datos) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      datos['fechaModificacion'] = FieldValue.serverTimestamp();
      
      await firestore
          .collection(_ventasCollection)
          .doc(id)
          .update(datos);
    } catch (e) {
      print('Error al actualizar venta: $e');
      throw e;
    }
  }

  static Future<void> eliminarVenta(String id) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      await firestore
          .collection(_ventasCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar venta: $e');
      throw e;
    }
  }

  // GASTOS
  static Future<List<Map<String, dynamic>>> obtenerGastos() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('⚠️ Firestore no disponible, retornando lista vacía');
        return [];
      }

      QuerySnapshot querySnapshot = await firestore
          .collection(_gastosCollection)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error al obtener gastos: $e');
      return [];
    }
  }

  static Future<void> agregarGasto(Map<String, dynamic> gasto) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      final String sheetsId = gasto['id']?.toString() ?? '';
      Map<String, dynamic> gastoFirestore = Map.from(gasto);
      gastoFirestore['fechaCreacion'] = FieldValue.serverTimestamp();
      
      if (sheetsId.isNotEmpty) {
        await firestore.collection(_gastosCollection).doc(sheetsId).set(gastoFirestore);
      } else {
        await firestore.collection(_gastosCollection).add(gastoFirestore);
      }
    } catch (e) {
      print('Error al agregar gasto: $e');
      throw e;
    }
  }

  static Future<void> actualizarGasto(String id, Map<String, dynamic> datos) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      datos['fechaModificacion'] = FieldValue.serverTimestamp();
      
      await firestore
          .collection(_gastosCollection)
          .doc(id)
          .update(datos);
    } catch (e) {
      print('Error al actualizar gasto: $e');
      throw e;
    }
  }

  static Future<void> eliminarGasto(String id) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      await firestore
          .collection(_gastosCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar gasto: $e');
      throw e;
    }
  }

  // USUARIOS
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('⚠️ Firestore no disponible, retornando lista vacía');
        return [];
      }

      QuerySnapshot querySnapshot = await firestore
          .collection(_usuariosCollection)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Usar docId para el ID real de Firestore, mantener id original si existe
            return {
              'docId': doc.id, // ID real del documento en Firestore
              ...data,
            };
          })
          .toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  static Future<void> agregarUsuario(Map<String, dynamic> usuario) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      // Usar ID de Sheets, o correo como fallback
      final String sheetsId = usuario['id']?.toString() ?? usuario['correo']?.toString() ?? '';
      Map<String, dynamic> usuarioFirestore = Map.from(usuario);
      usuarioFirestore['fechaCreacion'] = FieldValue.serverTimestamp();
      
      if (sheetsId.isNotEmpty) {
        await firestore.collection(_usuariosCollection).doc(sheetsId).set(usuarioFirestore);
        print('✅ Usuario agregado con ID: $sheetsId');
      } else {
        await firestore.collection(_usuariosCollection).add(usuarioFirestore);
      }
    } catch (e) {
      print('Error al agregar usuario: $e');
      throw e;
    }
  }

  // ROLES
  static Future<List<Map<String, dynamic>>> obtenerRoles() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('⚠️ Firestore no disponible, retornando lista vacía');
        return [];
      }

      QuerySnapshot querySnapshot = await firestore
          .collection(_rolesCollection)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error al obtener roles: $e');
      return [];
    }
  }

  static Future<void> agregarRol(Map<String, dynamic> rol) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      final String sheetsId = rol['id']?.toString() ?? rol['rol']?.toString() ?? '';
      Map<String, dynamic> rolFirestore = Map.from(rol);
      rolFirestore['fechaCreacion'] = FieldValue.serverTimestamp();
      
      if (sheetsId.isNotEmpty) {
        await firestore.collection(_rolesCollection).doc(sheetsId).set(rolFirestore);
      } else {
        await firestore.collection(_rolesCollection).add(rolFirestore);
      }
    } catch (e) {
      print('Error al agregar rol: $e');
      throw e;
    }
  }

  static Future<void> actualizarUsuario(String id, Map<String, dynamic> datos) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      datos['fechaModificacion'] = FieldValue.serverTimestamp();
      
      await firestore
          .collection(_usuariosCollection)
          .doc(id)
          .update(datos);
    } catch (e) {
      print('Error al actualizar usuario: $e');
      throw e;
    }
  }

  static Future<void> eliminarUsuario(String id) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      await firestore
          .collection(_usuariosCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar usuario: $e');
      throw e;
    }
  }

  static Future<void> actualizarRol(String id, Map<String, dynamic> datos) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      datos['fechaModificacion'] = FieldValue.serverTimestamp();
      
      await firestore
          .collection(_rolesCollection)
          .doc(id)
          .update(datos);
    } catch (e) {
      print('Error al actualizar rol: $e');
      throw e;
    }
  }

  static Future<void> eliminarRol(String id) async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        throw Exception('Firestore no está disponible');
      }

      await firestore
          .collection(_rolesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar rol: $e');
      throw e;
    }
  }

  // UTILIDADES
  static Future<void> sincronizarConSheets() async {
    // Este método se llamará después de cada cambio para mantener
    // Google Sheets actualizado como respaldo visual
    try {
      // Implementaremos la lógica de sincronización
      print('Sincronizando con Google Sheets...');
      
      // Aquí llamaremos a los métodos existentes de GoogleSheetsService
      // para mantener Sheets actualizado
      
    } catch (e) {
      print('Error en sincronización con Sheets: $e');
      // No lanzamos error porque Sheets es solo respaldo
    }
  }

  // REINICIALIZAR CONEXIÓN
  static Future<void> reinicializarConexion() async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      print('🔄 Reinicializando conexión Firestore...');
      
      // Deshabilitar y habilitar red para forzar reconexión
      await firestore.disableNetwork();
      await Future.delayed(const Duration(seconds: 1));
      await firestore.enableNetwork();
      
      // Reconfigurar settings
      firestore.settings = const Settings(
        persistenceEnabled: false,
        host: 'firestore.googleapis.com',
        sslEnabled: true,
      );
      
      print('✅ Conexión reinicializada');
    } catch (e) {
      print('❌ Error reinicializando: $e');
    }
  }

  // DIAGNÓSTICO
  static Future<void> diagnosticarFirestore() async {
    try {
      final firestore = _firestore;
      if (firestore == null) {
        print('❌ Firestore no está disponible');
        return;
      }

      print('🔍 === DIAGNÓSTICO FIRESTORE ===');
      print('🔍 Proyecto: autofirme-196f0');
      
      // Verificar estado de conexión
      try {
        await firestore.enableNetwork();
        print('🌐 Red habilitada');
      } catch (e) {
        print('❌ Error habilitando red: $e');
      }
      
      // Verificar configuración
      Settings settings = firestore.settings;
      print('🔍 Configuración Firestore:');
      print('   - Persistencia: ${settings.persistenceEnabled}');
      print('   - Host: ${settings.host}');
      print('   - SSL: ${settings.sslEnabled}');
      
      // Verificar colecciones
      List<String> colecciones = [_inventarioCollection, _ventasCollection, _gastosCollection, _usuariosCollection, _rolesCollection];
      
      for (String coleccion in colecciones) {
        try {
          // Forzar consulta desde servidor
          QuerySnapshot snapshot = await firestore
              .collection(coleccion)
              .limit(1)
              .get(const GetOptions(source: Source.server));
          print('🔍 Colección "$coleccion": ${snapshot.docs.length} docs (SERVIDOR REAL)');
        } catch (e) {
          print('❌ Error servidor "$coleccion": $e');
          
          // Intentar desde cache como fallback
          try {
            QuerySnapshot cacheSnapshot = await firestore
                .collection(coleccion)
                .limit(1)
                .get(const GetOptions(source: Source.cache));
            print('🔍 Colección "$coleccion": ${cacheSnapshot.docs.length} docs (CACHE LOCAL)');
          } catch (cacheError) {
            print('❌ Error cache "$coleccion": $cacheError');
          }
        }
      }

      // Intentar escribir un documento de prueba
      try {
        print('📝 Intentando escribir documento de prueba...');
        DocumentReference testDoc = await firestore.collection('_test').add({
          'timestamp': FieldValue.serverTimestamp(),
          'mensaje': 'Test de conexión',
          'testTime': DateTime.now().toIso8601String(),
        });
        print('✅ Escritura de prueba exitosa: ${testDoc.id}');
        
        // Esperar un poco y verificar que se escribió
        await Future.delayed(const Duration(seconds: 2));
        
        // Leer desde el servidor para confirmar
        DocumentSnapshot doc = await testDoc.get(const GetOptions(source: Source.server));
        if (doc.exists) {
          print('✅ Documento confirmado en servidor: ${doc.data()}');
        } else {
          print('⚠️ Documento no encontrado en servidor');
        }
        
        // Eliminar el documento de prueba
        await testDoc.delete();
        print('🗑️ Documento de prueba eliminado');
      } catch (e) {
        print('❌ Error en escritura de prueba: $e');
        print('❌ Tipo de error: ${e.runtimeType}');
        print('❌ Detalles: ${e.toString()}');
      }

      print('🔍 === FIN DIAGNÓSTICO ===');
    } catch (e) {
      print('❌ Error en diagnóstico: $e');
    }
  }
}