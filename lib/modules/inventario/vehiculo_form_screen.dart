import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/exports.dart';
import '../../services/inventario_service.dart';
import '../../services/sync_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/vehiculo_imagenes.dart';

class VehiculoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? vehiculo;
  final bool isEditing;

  const VehiculoFormScreen({
    Key? key,
    this.vehiculo,
  }) : isEditing = vehiculo != null, super(key: key);

  @override
  State<VehiculoFormScreen> createState() => _VehiculoFormScreenState();
}

class _VehiculoFormScreenState extends State<VehiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para todos los campos
  final _anoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _vinController = TextEditingController();
  final _colorController = TextEditingController();
  final _motorController = TextEditingController();
  final _traccionController = TextEditingController();
  final _versionController = TextEditingController();
  final _comercializadoraController = TextEditingController();
  final _costoController = TextEditingController();
  final _gastosController = TextEditingController();
  final _precioSugeridoController = TextEditingController();
  final _imagenesUrlController = TextEditingController();
  
  String _estado = 'Disponible';
  bool _isLoading = false;
  double _total = 0.0;
  bool _canViewFinancialInfo = false;
  bool _isBuscandoVin = false;
  
  // URL para búsqueda de VIN en base de datos externa
  static const String apiUrlVin = 'https://script.google.com/macros/s/AKfycbyh4_2lpN7xsQTaOyOfe7oZogJzEIBXaoQRe3n8iRyJo3jErmiEPQ1jK3GI2q2QTwoc/exec';

  /// Convierte el texto de URLs a una lista de URLs
  List<String> _parseImagenesUrl(String text) {
    if (text.isEmpty) return [];
    return text.split(RegExp(r'[,\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _checkUserPermissions();
    _costoController.addListener(_calcularTotal);
    _gastosController.addListener(_calcularTotal);
  }

  void _initializeForm() {
    if (widget.isEditing && widget.vehiculo != null) {
      final vehiculo = widget.vehiculo!;
      _anoController.text = vehiculo['ano']?.toString() ?? '';
      _marcaController.text = vehiculo['marca']?.toString() ?? '';
      _modeloController.text = vehiculo['modelo']?.toString() ?? '';
      _vinController.text = vehiculo['vin']?.toString() ?? '';
      _colorController.text = vehiculo['color']?.toString() ?? '';
      _motorController.text = vehiculo['motor']?.toString() ?? '';
      _traccionController.text = vehiculo['traccion']?.toString() ?? '';
      _versionController.text = vehiculo['version']?.toString() ?? '';
      _comercializadoraController.text = vehiculo['comercializadora']?.toString() ?? '';
      _costoController.text = vehiculo['costo']?.toString() ?? '';
      _gastosController.text = vehiculo['gastos']?.toString() ?? '';
      _precioSugeridoController.text = vehiculo['precioSugerido']?.toString() ?? '';
      // Combinar imagen e imagenesUrl si existen ambos
      String imagenes = vehiculo['imagenesUrl']?.toString() ?? '';
      String imagenPrincipal = vehiculo['imagen']?.toString() ?? '';
      if (imagenPrincipal.isNotEmpty && imagenes.isEmpty) {
        imagenes = imagenPrincipal;
      } else if (imagenPrincipal.isNotEmpty && imagenes.isNotEmpty) {
        imagenes = '$imagenPrincipal,$imagenes';
      }
      _imagenesUrlController.text = imagenes;
      _estado = vehiculo['estado']?.toString() ?? 'Disponible';
      _calcularTotal();
    }
  }

  void _calcularTotal() {
    final costo = double.tryParse(_costoController.text) ?? 0.0;
    final gastos = double.tryParse(_gastosController.text) ?? 0.0;
    setState(() {
      _total = costo + gastos;
    });
  }

  void _checkUserPermissions() {
    try {
      // Obtener el rol del usuario actual desde AuthService
      final userRole = AuthService.instance.getUserRole();
      setState(() {
        // Solo administrador y recepción (encargado) pueden ver información financiera
        _canViewFinancialInfo = userRole == UserRole.admin || userRole == UserRole.recepcion;
      });
    } catch (e) {
      print('Error al verificar permisos de usuario: $e');
      setState(() {
        _canViewFinancialInfo = false;
      });
    }
  }

  // Función para verificar conectividad con la API
  Future<void> _verificarAPI() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔧 Verificando conectividad con la API...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final url = Uri.parse('$apiUrlVin?vin=TEST123');
      print("🔧 Verificando API: $url");
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout de verificación');
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ API accesible'),
                  Text('Status: ${response.statusCode}', style: const TextStyle(fontSize: 12)),
                  Text('Respuesta: ${response.body.length > 50 ? response.body.substring(0, 50) + "..." : response.body}', 
                       style: const TextStyle(fontSize: 11)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ API respondió con código: ${response.statusCode}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error en verificación de API: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❌ No se puede conectar a la API'),
                Text('Error: ${e.toString()}', style: const TextStyle(fontSize: 11)),
                const Text('Verifica que el Google Apps Script esté desplegado correctamente', 
                          style: TextStyle(fontSize: 10)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  // Función para buscar datos por VIN en base de datos externa
  Future<void> _buscarPorVin() async {
    final vinParcial = _vinController.text.trim();

    if (vinParcial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor ingrese un VIN para buscar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBuscandoVin = true;
    });

    try {
      print("🔍 Buscando VIN: $vinParcial");

      // Buscar en la API - primero buscar exacto
      bool encontrado = await _buscarEnAPI(apiUrlVin, vinParcial, "API VIN (exacto)");
      
      // Si no encontró nada, intentar con variaciones
      if (!encontrado && mounted) {
        // Intentar con VIN en mayúsculas
        if (vinParcial != vinParcial.toUpperCase()) {
          print("🔄 Intentando con VIN en mayúsculas...");
          encontrado = await _buscarEnAPI(apiUrlVin, vinParcial.toUpperCase(), "API VIN (mayúsculas)");
        }
        
        // Intentar con VIN en minúsculas solo si aún no encontró
        if (!encontrado && vinParcial != vinParcial.toLowerCase()) {
          print("🔄 Intentando con VIN en minúsculas...");
          encontrado = await _buscarEnAPI(apiUrlVin, vinParcial.toLowerCase(), "API VIN (minúsculas)");
        }
        
        // Si después de todas las variaciones no encontró nada
        if (!encontrado && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❌ VIN $vinParcial no encontrado'),
                  const SizedBox(height: 4),
                  const Text(
                    'Opciones:\n• Verifica que el VIN sea correcto\n• Continúa llenando los datos manualmente\n• Contacta al administrador si persiste el problema',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      
    } catch (e) {
      print("❌ Error en búsqueda VIN: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al buscar VIN: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBuscandoVin = false;
        });
      }
    }
  }

  // Función auxiliar para buscar en la API
  Future<bool> _buscarEnAPI(
    String apiUrl,
    String vinParcial,
    String nombreAPI,
  ) async {
    try {
      final url = Uri.parse('$apiUrl?vin=$vinParcial');
      print("🌐 $nombreAPI - Intentando conectar a: $url");

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La API no respondió en 30 segundos');
        },
      );

      print("📡 $nombreAPI - Status Code: ${response.statusCode}");
      print("📋 $nombreAPI - Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('error')) {
          print("⚠️ $nombreAPI - Error en respuesta: ${data['error']}");
          
          // Solo mostrar mensaje de error para la primera búsqueda
          if (nombreAPI.contains("exacto")) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ℹ️ VIN $vinParcial no encontrado en la base de datos'),
                      const SizedBox(height: 4),
                      const Text(
                        'Esto puede significar:\n• El VIN no existe en la base de datos externa\n• Intenta con un VIN diferente\n• Puedes continuar llenando los datos manualmente',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 6),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
          return false;
        } else {
          // Verificar si tenemos datos válidos (al menos marca)
          if (data.containsKey('campoB') &&
              data['campoB'] != null &&
              data['campoB'].toString().isNotEmpty) {
            // Mapear los datos recibidos a los campos del formulario
            setState(() {
              _anoController.text = data['campoA']?.toString() ?? '';
              _marcaController.text = data['campoB']?.toString() ?? '';
              _modeloController.text = data['campoC']?.toString() ?? '';
              
              // Nuevos campos agregados
              _motorController.text = data['campoH']?.toString() ?? '';
              _traccionController.text = data['campoI']?.toString() ?? '';
              
              _colorController.text = data['campoJ']?.toString() ?? '';
              _vinController.text = data['campoK']?.toString() ?? vinParcial;
              
              // Campo adicional AO puede ser versión o comercializadora
              String campoAO = data['campoAO']?.toString() ?? '';
              if (campoAO.isNotEmpty) {
                // Si parece ser información de versión, mapear a versión
                if (campoAO.toLowerCase().contains('version') || 
                    campoAO.toLowerCase().contains('v') ||
                    campoAO.contains('L') || campoAO.contains('T')) {
                  _versionController.text = campoAO;
                } else {
                  // Si no, mapear a comercializadora
                  _comercializadoraController.text = campoAO;
                }
              }
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Datos encontrados en $nombreAPI - ${_marcaController.text} ${_modeloController.text} ${_anoController.text}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }

            print(
              "✅ $nombreAPI - Datos cargados correctamente: Año=${_anoController.text}, Marca=${_marcaController.text}, Modelo=${_modeloController.text}, Color=${_colorController.text}, Motor=${_motorController.text}, Tracción=${_traccionController.text}",
            );
            return true;
          } else {
            print(
              "❌ $nombreAPI - No se encontraron datos válidos en la respuesta",
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ $nombreAPI: VIN no encontrado'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return false;
          }
        }
      } else {
        print("❌ $nombreAPI - Error del servidor: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $nombreAPI: Error del servidor (${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print("❌ $nombreAPI - Error detallado: $e");
      
      String mensajeError;
      if (e.toString().contains('Failed to fetch')) {
        mensajeError = '🌐 No se puede conectar a la API. Verifica tu conexión a internet.';
      } else if (e.toString().contains('Timeout')) {
        mensajeError = '⏱️ La API tardó demasiado en responder. Intenta de nuevo.';
      } else if (e.toString().contains('SocketException')) {
        mensajeError = '📡 Sin conexión a internet. Verifica tu red.';
      } else if (e.toString().contains('FormatException')) {
        mensajeError = '📄 La API devolvió datos con formato incorrecto.';
      } else {
        mensajeError = '❌ Error inesperado: ${e.toString()}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mensajeError),
                const SizedBox(height: 4),
                Text(
                  'Tip: Verifica que el Google Apps Script esté activo y con permisos públicos',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: widget.isEditing ? 'Editar Vehículo' : 'Nuevo Vehículo',
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _guardarVehiculo,
              child: Text(
                'GUARDAR',
                style: CorporateTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(CorporateTheme.spacingLG),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: CorporateTheme.spacingXL),
                  _buildVehiculoInfoSection(),
                  const SizedBox(height: CorporateTheme.spacingXL),
                  // Solo mostrar información financiera si el usuario tiene permisos
                  if (_canViewFinancialInfo) ...[
                    _buildPreciosSection(),
                    const SizedBox(height: CorporateTheme.spacingXL),
                  ] else ...[
                    // Mostrar mensaje informativo cuando no hay permisos
                    Container(
                      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'La información financiera solo es visible para Administradores y Encargados.',
                              style: CorporateTheme.bodyMedium.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: CorporateTheme.spacingXL),
                  ],
                  _buildEstadoSection(),
                  const SizedBox(height: CorporateTheme.spacingXL),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeaderSection() {
    final tieneImagenes = widget.isEditing && 
        _imagenesUrlController.text.isNotEmpty;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mostrar galería de imágenes si existe
          if (tieneImagenes) ...[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: VehiculoImagenes(
                imagenesUrl: _parseImagenesUrl(_imagenesUrlController.text),
                height: 180,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(CorporateTheme.spacingLG),
            child: Column(
              children: [
                if (!tieneImagenes) ...[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.1),
                          const Color(0xFF3B82F6).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      widget.isEditing ? Icons.edit : Icons.directions_car,
                      size: 40,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: CorporateTheme.spacingMD),
                ],
                Text(
                  widget.isEditing ? 'Actualizar Vehículo' : 'Registrar Nuevo Vehículo',
                  style: CorporateTheme.bodyLarge.copyWith(
                    fontSize: tieneImagenes ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: CorporateTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: CorporateTheme.spacingSM),
                Text(
                  widget.isEditing 
                    ? 'Modifica la información del vehículo'
                    : 'Completa todos los datos del vehículo',
                  style: CorporateTheme.bodyMedium.copyWith(
                    color: CorporateTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoInfoSection() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Vehículo',
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'Año',
                  hint: '2024',
                  controller: _anoController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El año es requerido';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                      return 'Año inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: CorporateInput(
                  label: 'Marca',
                  hint: 'Toyota',
                  controller: _marcaController,
                  prefixIcon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La marca es requerida';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'Modelo',
                  hint: 'Corolla',
                  controller: _modeloController,
                  prefixIcon: Icons.directions_car,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El modelo es requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: CorporateInput(
                  label: 'Color',
                  hint: 'Blanco',
                  controller: _colorController,
                  prefixIcon: Icons.palette,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El color es requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Campo VIN con botón de búsqueda
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'VIN',
                  hint: 'Ej: 123456 o 1HGBH41JXMN109186',
                  controller: _vinController,
                  prefixIcon: Icons.fingerprint,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El VIN es requerido';
                    }
                    if (value.length < 6) {
                      return 'El VIN debe tener al menos 6 caracteres';
                    }
                    if (value.length > 17) {
                      return 'El VIN no puede tener más de 17 caracteres';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Container(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isBuscandoVin ? null : _buscarPorVin,
                  icon: _isBuscandoVin 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search, size: 18),
                  label: Text(
                    _isBuscandoVin ? 'Buscando...' : 'Buscar',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CorporateTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),/* 
              const SizedBox(width: 8),
              Container(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isBuscandoVin ? null : _verificarAPI,
                  icon: const Icon(Icons.network_check, size: 16),
                  label: const Text(
                    'Test API',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    side: BorderSide(color: CorporateTheme.primaryBlue),
                  ),
                ),
              ), */
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'Motor',
                  hint: '2.0L',
                  controller: _motorController,
                  prefixIcon: Icons.engineering,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El motor es requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingMD),
          
          // Tracción y Versión
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'Tracción',
                  hint: 'FWD, RWD, AWD, 4WD',
                  controller: _traccionController,
                  prefixIcon: Icons.alt_route,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La tracción es requerida';
                    }
                    if (value.length < 2) {
                      return 'La tracción debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: CorporateInput(
                  label: 'Versión',
                  hint: 'XLE',
                  controller: _versionController,
                  prefixIcon: Icons.star,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La versión es requerida';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Comercializadora',
            hint: 'AutoFirme Motors',
            controller: _comercializadoraController,
            prefixIcon: Icons.store,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La comercializadora es requerida';
              }
              return null;
            },
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'URL de Imágenes (opcional)',
            hint: 'https://drive.google.com/drive/folders/...',
            controller: _imagenesUrlController,
            prefixIcon: Icons.photo_library,
          ),
        ],
      ),
    );
  }

  Widget _buildPreciosSection() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Financiera',
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          
          Row(
            children: [
              Expanded(
                child: CorporateInput(
                  label: 'Costo',
                  hint: '15000.00',
                  controller: _costoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.attach_money,
                  validator: (value) {
                    // Solo validar si el usuario tiene permisos y hay un valor
                    if (!_canViewFinancialInfo) return null;
                    
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: CorporateInput(
                  label: 'Gastos',
                  hint: '1500.00',
                  controller: _gastosController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.receipt,
                  validator: (value) {
                    // Solo validar si el usuario tiene permisos y hay un valor
                    if (!_canViewFinancialInfo) return null;
                    
                    if (value != null && value.trim().isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Precio Sugerido',
            hint: '18000.00',
            controller: _precioSugeridoController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.sell,
            validator: (value) {
              // Solo validar si el usuario tiene permisos y hay un valor
              if (!_canViewFinancialInfo) return null;
              
              if (value != null && value.trim().isNotEmpty) {
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Mostrar total calculado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calculate,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total (Costo + Gastos)',
                        style: CorporateTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: CorporateTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoSection() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado del Vehículo',
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CorporateTheme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: InventarioService.obtenerEstadosDisponibles().map((estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(estado),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(estado),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _estado = value ?? 'Disponible';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'reservado':
        return Colors.orange;
      case 'vendido':
        return Colors.blue;
      case 'en reparación':
        return Colors.red;
      case 'en tránsito':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: CorporateTheme.dividerColor),
            ),
          ),
        ),
        const SizedBox(width: CorporateTheme.spacingMD),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _guardarVehiculo,
            icon: _isLoading 
              ? const SizedBox(
                  width: 16, 
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(widget.isEditing ? Icons.save : Icons.add),
            label: Text(widget.isEditing ? 'Actualizar' : 'Agregar Vehículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final userName = 'Usuario'; // TODO: Implementar obtener nombre de usuario
      final userEmail = authService.userEmail;
      
      // Solo procesar información financiera si el usuario tiene permisos
      final costo = _canViewFinancialInfo && _costoController.text.trim().isNotEmpty 
          ? double.parse(_costoController.text.trim()) 
          : 0.0;
      final gastos = _canViewFinancialInfo && _gastosController.text.trim().isNotEmpty 
          ? double.parse(_gastosController.text.trim()) 
          : 0.0;
      final precioSugerido = _canViewFinancialInfo && _precioSugeridoController.text.trim().isNotEmpty 
          ? double.parse(_precioSugeridoController.text.trim()) 
          : 0.0;

      // Construir datos del vehículo
      final vehiculoData = {
        'ano': _anoController.text.trim(),
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'vin': _vinController.text.trim(),
        'color': _colorController.text.trim(),
        'motor': _motorController.text.trim(),
        'traccion': _traccionController.text.trim(),
        'version': _versionController.text.trim(),
        'comercializadora': _comercializadoraController.text.trim(),
        'costo': costo,
        'gastos': gastos,
        'precioSugerido': precioSugerido,
        'estado': _estado,
        'imagenesUrl': _imagenesUrlController.text.trim().isNotEmpty ? _imagenesUrlController.text.trim() : '',
        'nombreUsuario': userName,
        'correoUsuario': userEmail,
        // Incluir el ID de Sheets para sincronización
        if (widget.isEditing) 'id': widget.vehiculo!['id']?.toString() ?? '',
      };

      if (widget.isEditing) {
        // Actualizar vehículo existente usando SyncService (Firestore + Sheets)
        final docId = widget.vehiculo!['docId']?.toString() ?? widget.vehiculo!['id'].toString();
        await SyncService.actualizarVehiculo(docId, vehiculoData);
      } else {
        // Agregar nuevo vehículo usando SyncService (Firestore + Sheets)
        await SyncService.agregarVehiculo(vehiculoData);
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing 
            ? '✅ Vehículo actualizado exitosamente' 
            : '✅ Vehículo agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Retornar true para indicar cambios
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _anoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _motorController.dispose();
    _traccionController.dispose();
    _versionController.dispose();
    _comercializadoraController.dispose();
    _costoController.dispose();
    _gastosController.dispose();
    _precioSugeridoController.dispose();
    _imagenesUrlController.dispose();
    super.dispose();
  }
}