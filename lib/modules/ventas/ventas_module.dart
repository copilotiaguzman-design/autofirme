import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/ventas_service.dart';

class VentasModule extends StatefulWidget {
  const VentasModule({Key? key}) : super(key: key);

  @override
  State<VentasModule> createState() => _VentasModuleState();
}

class _VentasModuleState extends State<VentasModule> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasAccess = false;
  bool _loadingData = false;
  
  List<Map<String, dynamic>> _ventas = [];
  Map<String, dynamic> _estadisticas = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Listener para cargar estadísticas cuando se cambie a esa pestaña
    _tabController.addListener(() {
      if (_tabController.index == 2 && _estadisticas.isEmpty) {
        _cargarEstadisticas();
      }
    });
    
    _checkAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    try {
      final userRole = await AuthService.instance.getUserRole();
      final hasAccess = userRole == UserRole.admin || userRole == UserRole.recepcion || userRole == UserRole.inventario;
      
      setState(() {
        _hasAccess = hasAccess;
        _isLoading = false;
      });
      
      if (hasAccess) {
        _cargarDatos();
      }
    } catch (e) {
      setState(() {
        _hasAccess = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loadingData = true;
    });

    try {
      final ventas = await VentasService.obtenerVentas();
      
      setState(() {
        _ventas = ventas;
        _loadingData = false;
      });

      // Cargar estadísticas solo si estamos en la pestaña de estadísticas
      if (_tabController.index == 2) {
        await _cargarEstadisticas();
      }
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final estadisticas = await VentasService.obtenerEstadisticas();
      setState(() {
        _estadisticas = estadisticas;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  Future<void> _eliminarVenta(String id) async {
    try {
      final response = await VentasService.eliminarVenta(id);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venta eliminada correctamente')),
          );
          _cargarDatos();
        }
      } else {
        throw Exception(response['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ventas'),
          backgroundColor: CorporateTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Acceso Denegado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'No tienes permisos para acceder al módulo de ventas',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Ventas'),
        backgroundColor: CorporateTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'Nueva Venta'),
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNuevaVenta(),
          _buildListaVentas(),
          _buildEstadisticas(),
        ],
      ),
    );
  }

  Widget _buildNuevaVenta() {
    return NuevaVentaForm(onVentaCreada: _cargarDatos);
  }

  Widget _buildListaVentas() {
    if (_loadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ventas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sell_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ventas registradas',
              style: CorporateTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las ventas aparecerán aquí una vez que agregues la primera',
              style: CorporateTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CorporateTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Column(
        children: [
          // Header con información y refresh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CorporateTheme.primaryBlue.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ${_ventas.length} ventas',
                      style: CorporateTheme.headingSmall,
                    ),
                    Text(
                      'Última actualización: ${DateTime.now().toString().substring(0, 16)}',
                      style: CorporateTheme.caption.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _cargarDatos,
                  icon: Icon(Icons.refresh, color: CorporateTheme.primaryBlue),
                  tooltip: 'Actualizar lista',
                ),
              ],
            ),
          ),
          
          // Lista de ventas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ventas.length,
              itemBuilder: (context, index) {
                final venta = _ventas[index];
                return _buildVentaCard(venta);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentaCard(Map<String, dynamic> venta) {
    final precioVenta = double.tryParse(venta['precioventa']?.toString() ?? '0') ?? 0.0;
    final totalPagado = double.tryParse(venta['totalpagado']?.toString() ?? '0') ?? 0.0;
    final restante = double.tryParse(venta['restante']?.toString() ?? '0') ?? 0.0;
    final estatus = venta['estatus']?.toString() ?? 'Pendiente';
    
    Color statusColor = Colors.grey;
    switch (estatus.toLowerCase()) {
      case 'pagado':
        statusColor = Colors.green;
        break;
      case 'parcial':
        statusColor = Colors.orange;
        break;
      case 'pendiente':
        statusColor = Colors.red;
        break;
      case 'cancelado':
        statusColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _mostrarDetalleVenta(venta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con VIN y botones
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIN: ${venta['vin'] ?? 'N/A'}',
                          style: CorporateTheme.headingSmall.copyWith(
                            color: CorporateTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          '${venta['ano']} ${venta['modelo'] ?? 'Modelo desconocido'}',
                          style: CorporateTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      estatus.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'editar':
                          _mostrarEditarVenta(venta);
                          break;
                        case 'eliminar':
                          _confirmarEliminarVenta(venta['id']?.toString() ?? '');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          leading: Icon(Icons.edit, size: 20),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          leading: Icon(Icons.delete, size: 20, color: Colors.red),
                          title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información de precio y pagos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Precio de Venta:', style: CorporateTheme.bodyMedium),
                        Text(
                          '\$${precioVenta.toStringAsFixed(2)}',
                          style: CorporateTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CorporateTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pagado:', style: CorporateTheme.bodyMedium),
                        Text(
                          '\$${totalPagado.toStringAsFixed(2)}',
                          style: CorporateTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (restante > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Restante:', style: CorporateTheme.bodyMedium),
                          Text(
                            '\$${restante.toStringAsFixed(2)}',
                            style: CorporateTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Información adicional
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (venta['vendedor']?.toString().isNotEmpty == true)
                          Text(
                            '👤 ${venta['vendedor']}',
                            style: CorporateTheme.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        if (venta['fechaventa']?.toString().isNotEmpty == true)
                          Text(
                            '📅 ${_formatearFecha(venta['fechaventa']?.toString() ?? '')}',
                            style: CorporateTheme.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (venta['lote']?.toString().isNotEmpty == true)
                    Chip(
                      label: Text(
                        'Lote: ${venta['lote']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.blue[50],
                      side: BorderSide(color: Colors.blue[200]!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final DateTime dateTime = DateTime.parse(fecha);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return fecha;
    }
  }

  Widget _buildEstadisticas() {
    if (_loadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si no hay estadísticas cargadas, cargarlas
    if (_estadisticas.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarEstadisticas();
      });
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando estadísticas...'),
          ],
        ),
      );
    }

    final totalVentas = _estadisticas['totalVentas']?.toString() ?? '0';
    final totalFacturado = double.tryParse(_estadisticas['totalFacturado']?.toString() ?? '0') ?? 0.0;
    final totalCobrado = double.tryParse(_estadisticas['totalCobrado']?.toString() ?? '0') ?? 0.0;
    final totalPendiente = double.tryParse(_estadisticas['totalPendienteCobro']?.toString() ?? '0') ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header con refresh
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📊 Dashboard de Ventas',
                  style: CorporateTheme.headingMedium.copyWith(
                    color: CorporateTheme.primaryBlue,
                  ),
                ),
                IconButton(
                  onPressed: _cargarEstadisticas,
                  icon: Icon(Icons.refresh, color: CorporateTheme.primaryBlue),
                  tooltip: 'Actualizar estadísticas',
                ),
              ],
            ),
          ),

          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Ventas',
                  totalVentas,
                  Icons.sell,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Facturado',
                  '\$${totalFacturado.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Cobrado',
                  '\$${totalCobrado.toStringAsFixed(2)}',
                  Icons.payment,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendiente',
                  '\$${totalPendiente.toStringAsFixed(2)}',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progreso de cobranza
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💰 Progreso de Cobranza',
                    style: CorporateTheme.headingSmall.copyWith(
                      color: CorporateTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: totalFacturado > 0 ? totalCobrado / totalFacturado : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      totalCobrado >= totalFacturado ? Colors.green : Colors.orange,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalFacturado > 0 
                        ? '${((totalCobrado / totalFacturado) * 100).toStringAsFixed(1)}% cobrado'
                        : '0% cobrado',
                    style: CorporateTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Resumen final
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CorporateTheme.primaryBlue.withOpacity(0.1),
                    CorporateTheme.primaryBlue.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.insights,
                    size: 48,
                    color: CorporateTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Resumen Ejecutivo',
                    style: CorporateTheme.headingSmall.copyWith(
                      color: CorporateTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    int.parse(totalVentas) > 0
                        ? 'Venta promedio: \$${(totalFacturado / int.parse(totalVentas)).toStringAsFixed(2)}'
                        : 'No hay ventas registradas',
                    style: CorporateTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (int.parse(totalVentas) > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Efectividad de cobranza: ${totalFacturado > 0 ? ((totalCobrado / totalFacturado) * 100).toStringAsFixed(1) : '0'}%',
                      style: CorporateTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: CorporateTheme.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: CorporateTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleVenta(Map<String, dynamic> venta) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: DetalleVentaDialog(venta: venta),
      ),
    );
  }

  void _mostrarEditarVenta(Map<String, dynamic> venta) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: EditarVentaForm(
          venta: venta,
          onVentaActualizada: _cargarDatos,
        ),
      ),
    );
  }

  void _confirmarEliminarVenta(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta venta? Esta acción no se puede deshacer y el vehículo volverá a estar disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarVenta(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Placeholder para el formulario de nueva venta
class NuevaVentaForm extends StatefulWidget {
  final VoidCallback onVentaCreada;

  const NuevaVentaForm({Key? key, required this.onVentaCreada}) : super(key: key);

  @override
  State<NuevaVentaForm> createState() => _NuevaVentaFormState();
}

class _NuevaVentaFormState extends State<NuevaVentaForm> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _loteController = TextEditingController();
  final _notasController = TextEditingController();
  final _vendedorController = TextEditingController();
  final _pago1Controller = TextEditingController();
  final _pago2Controller = TextEditingController();
  final _pago3Controller = TextEditingController();

  DateTime _fechaCaptura = DateTime.now();
  DateTime? _fechaVenta;
  DateTime? _fechaPago1;
  DateTime? _fechaPago2;
  DateTime? _fechaPago3;

  String _metodo1 = 'Efectivo';
  String _metodo2 = 'Efectivo';
  String _metodo3 = 'Efectivo';

  bool _enviando = false;
  bool _cargandoVehiculo = false;

  String _anoVehiculo = '';
  String _modeloVehiculo = '';
  Map<String, dynamic>? _vehiculoInfo;
  
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _vinController.dispose();
    _precioVentaController.dispose();
    _loteController.dispose();
    _notasController.dispose();
    _vendedorController.dispose();
    _pago1Controller.dispose();
    _pago2Controller.dispose();
    _pago3Controller.dispose();
    super.dispose();
  }

  void _buscarVehiculoConDebounce(String vin) {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();
    
    // Crear un nuevo timer con debounce de 800ms
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (vin.length >= 5) {
        _buscarVehiculo();
      }
    });
  }

  Future<void> _buscarVehiculo() async {
    if (_vinController.text.trim().isEmpty) return;

    setState(() {
      _cargandoVehiculo = true;
    });

    try {
      final vehiculo = await VentasService.obtenerVehiculoPorVin(_vinController.text.trim());
      
      if (vehiculo != null) {
        setState(() {
          _vehiculoInfo = vehiculo;
          _anoVehiculo = vehiculo['ano']?.toString() ?? '';
          _modeloVehiculo = '${vehiculo['marca']} ${vehiculo['modelo']}'.trim();
          
          // Sugerir precio basado en el precio sugerido del inventario
          final precioSugerido = vehiculo['precioSugerido']?.toString() ?? '';
          if (precioSugerido.isNotEmpty && _precioVentaController.text.isEmpty) {
            _precioVentaController.text = precioSugerido;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo encontrado y datos cargados')),
          );
        }
      } else {
        setState(() {
          _vehiculoInfo = null;
          _anoVehiculo = '';
          _modeloVehiculo = '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo no encontrado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar vehículo: $e')),
        );
      }
    } finally {
      setState(() {
        _cargandoVehiculo = false;
      });
    }
  }

  Future<void> _crearVenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
    });

    try {
      final userEmail = AuthService.instance.userEmail;
      final nombreUsuario = userEmail.split('@')[0];

      final response = await VentasService.agregarVenta(
        fechaCaptura: _fechaCaptura.toIso8601String(),
        fechaVenta: _fechaVenta?.toIso8601String(),
        vin: _vinController.text.trim(),
        ano: _anoVehiculo,
        modelo: _modeloVehiculo,
        lote: _loteController.text.trim(),
        notas: _notasController.text.trim(),
        precioVenta: double.parse(_precioVentaController.text),
        fechaPago1: _fechaPago1?.toIso8601String(),
        metodo1: _pago1Controller.text.isNotEmpty ? _metodo1 : null,
        pago1: _pago1Controller.text.isNotEmpty ? double.parse(_pago1Controller.text) : null,
        fechaPago2: _fechaPago2?.toIso8601String(),
        metodo2: _pago2Controller.text.isNotEmpty ? _metodo2 : null,
        pago2: _pago2Controller.text.isNotEmpty ? double.parse(_pago2Controller.text) : null,
        fechaPago3: _fechaPago3?.toIso8601String(),
        metodo3: _pago3Controller.text.isNotEmpty ? _metodo3 : null,
        pago3: _pago3Controller.text.isNotEmpty ? double.parse(_pago3Controller.text) : null,
        vendedor: _vendedorController.text.trim(),
        nombreUsuario: nombreUsuario,
        correoUsuario: userEmail,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venta creada correctamente')),
          );
          
          // Limpiar formulario
          _formKey.currentState!.reset();
          _vinController.clear();
          _precioVentaController.clear();
          _loteController.clear();
          _notasController.clear();
          _vendedorController.clear();
          _pago1Controller.clear();
          _pago2Controller.clear();
          _pago3Controller.clear();
          
          setState(() {
            _fechaCaptura = DateTime.now();
            _fechaVenta = null;
            _fechaPago1 = null;
            _fechaPago2 = null;
            _fechaPago3 = null;
            _vehiculoInfo = null;
            _anoVehiculo = '';
            _modeloVehiculo = '';
          });
          
          widget.onVentaCreada();
        }
      } else {
        throw Exception(response['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CorporateTheme.primaryBlue,
                    CorporateTheme.primaryBlue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nueva Venta',
                    style: CorporateTheme.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra una nueva venta de vehículo',
                    style: CorporateTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Información del vehículo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚗 Información del Vehículo',
                      style: CorporateTheme.headingSmall.copyWith(
                        color: CorporateTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // VIN con botón de búsqueda
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vinController,
                            decoration: const InputDecoration(
                              labelText: 'VIN del Vehículo *',
                              hintText: 'Ingresa el VIN',
                              prefixIcon: Icon(Icons.search),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'VIN es requerido';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Buscar con debounce - evita múltiples peticiones
                              _buscarVehiculoConDebounce(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _cargandoVehiculo ? null : _buscarVehiculo,
                          child: _cargandoVehiculo 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Información del vehículo encontrado
                    if (_vehiculoInfo != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✅ Vehículo Encontrado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Año: ${_vehiculoInfo!['ano']}'),
                            Text('Marca: ${_vehiculoInfo!['marca']}'),
                            Text('Modelo: ${_vehiculoInfo!['modelo']}'),
                            Text('Color: ${_vehiculoInfo!['color']}'),
                            Text('Estado: ${_vehiculoInfo!['estado']}'),
                            if (_vehiculoInfo!['precioSugerido'] != null)
                              Text('Precio Sugerido: \$${_vehiculoInfo!['precioSugerido']}'),
                          ],
                        ),
                      ),
                    ] else if (_vinController.text.isNotEmpty && !_cargandoVehiculo) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ Vehículo No Encontrado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('El VIN no existe en el inventario. Ingresa los datos manualmente.'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Campos manuales si no se encuentra el vehículo
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Año *',
                                hintText: '2020',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Año es requerido';
                                }
                                return null;
                              },
                              onSaved: (value) => _anoVehiculo = value ?? '',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Marca y Modelo *',
                                hintText: 'Toyota Camry',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Marca y modelo son requeridos';
                                }
                                return null;
                              },
                              onSaved: (value) => _modeloVehiculo = value ?? '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Información de la venta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💰 Información de la Venta',
                      style: CorporateTheme.headingSmall.copyWith(
                        color: CorporateTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Precio de venta
                    TextFormField(
                      controller: _precioVentaController,
                      decoration: const InputDecoration(
                        labelText: 'Precio de Venta *',
                        hintText: '250000.00',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Precio de venta es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Precio debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: _fechaCaptura,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (fecha != null) {
                                setState(() {
                                  _fechaCaptura = fecha;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Captura',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_fechaCaptura.day}/${_fechaCaptura.month}/${_fechaCaptura.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: _fechaVenta ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (fecha != null) {
                                setState(() {
                                  _fechaVenta = fecha;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Venta',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _fechaVenta != null 
                                    ? '${_fechaVenta!.day}/${_fechaVenta!.month}/${_fechaVenta!.year}'
                                    : 'Seleccionar',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campos adicionales
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _loteController,
                            decoration: const InputDecoration(
                              labelText: 'Lote',
                              hintText: 'A-123',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _vendedorController,
                            decoration: const InputDecoration(
                              labelText: 'Vendedor',
                              hintText: 'Nombre del vendedor',
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notas
                    TextFormField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas',
                        hintText: 'Observaciones adicionales...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Pagos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💳 Pagos (Opcional)',
                      style: CorporateTheme.headingSmall.copyWith(
                        color: CorporateTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Pago 1
                    ExpansionTile(
                      title: const Text('Pago 1'),
                      leading: const Icon(Icons.payment),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _pago1Controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Monto',
                                        prefixText: '\$ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _metodo1,
                                      decoration: const InputDecoration(
                                        labelText: 'Método',
                                      ),
                                      items: VentasService.getMetodosPago()
                                          .map((metodo) => DropdownMenuItem(
                                                value: metodo,
                                                child: Text(metodo),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _metodo1 = value ?? 'Efectivo';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () async {
                                  final fecha = await showDatePicker(
                                    context: context,
                                    initialDate: _fechaPago1 ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (fecha != null) {
                                    setState(() {
                                      _fechaPago1 = fecha;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de Pago',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _fechaPago1 != null 
                                        ? '${_fechaPago1!.day}/${_fechaPago1!.month}/${_fechaPago1!.year}'
                                        : 'Seleccionar',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Pago 2
                    ExpansionTile(
                      title: const Text('Pago 2'),
                      leading: const Icon(Icons.payment),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _pago2Controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Monto',
                                        prefixText: '\$ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _metodo2,
                                      decoration: const InputDecoration(
                                        labelText: 'Método',
                                      ),
                                      items: VentasService.getMetodosPago()
                                          .map((metodo) => DropdownMenuItem(
                                                value: metodo,
                                                child: Text(metodo),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _metodo2 = value ?? 'Efectivo';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () async {
                                  final fecha = await showDatePicker(
                                    context: context,
                                    initialDate: _fechaPago2 ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (fecha != null) {
                                    setState(() {
                                      _fechaPago2 = fecha;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de Pago',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _fechaPago2 != null 
                                        ? '${_fechaPago2!.day}/${_fechaPago2!.month}/${_fechaPago2!.year}'
                                        : 'Seleccionar',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Pago 3
                    ExpansionTile(
                      title: const Text('Pago 3'),
                      leading: const Icon(Icons.payment),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _pago3Controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Monto',
                                        prefixText: '\$ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _metodo3,
                                      decoration: const InputDecoration(
                                        labelText: 'Método',
                                      ),
                                      items: VentasService.getMetodosPago()
                                          .map((metodo) => DropdownMenuItem(
                                                value: metodo,
                                                child: Text(metodo),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _metodo3 = value ?? 'Efectivo';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () async {
                                  final fecha = await showDatePicker(
                                    context: context,
                                    initialDate: _fechaPago3 ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (fecha != null) {
                                    setState(() {
                                      _fechaPago3 = fecha;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de Pago',
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _fechaPago3 != null 
                                        ? '${_fechaPago3!.day}/${_fechaPago3!.month}/${_fechaPago3!.year}'
                                        : 'Seleccionar',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Botón de envío
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _enviando ? null : _crearVenta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CorporateTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Crear Venta',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder para el diálogo de detalles
class DetalleVentaDialog extends StatelessWidget {
  final Map<String, dynamic> venta;

  const DetalleVentaDialog({Key? key, required this.venta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detalles de la Venta',
            style: CorporateTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          Text('ID: ${venta['id']}'),
          Text('VIN: ${venta['vin']}'),
          Text('Precio: \$${venta['precioventa']}'),
          Text('Estado: ${venta['estatus']}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// Formulario completo para editar ventas
class EditarVentaForm extends StatefulWidget {
  final Map<String, dynamic> venta;
  final VoidCallback onVentaActualizada;

  const EditarVentaForm({
    Key? key,
    required this.venta,
    required this.onVentaActualizada,
  }) : super(key: key);

  @override
  State<EditarVentaForm> createState() => _EditarVentaFormState();
}

class _EditarVentaFormState extends State<EditarVentaForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para todos los campos
  final _precioVentaController = TextEditingController();
  final _loteController = TextEditingController();
  final _notasController = TextEditingController();
  final _vendedorController = TextEditingController();
  final _pago1Controller = TextEditingController();
  final _pago2Controller = TextEditingController();
  final _pago3Controller = TextEditingController();

  DateTime? _fechaVenta;
  DateTime? _fechaPago1;
  DateTime? _fechaPago2;
  DateTime? _fechaPago3;

  String _metodo1 = 'Efectivo';
  String _metodo2 = 'Efectivo';
  String _metodo3 = 'Efectivo';

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosVenta();
  }

  void _cargarDatosVenta() {
    // Cargar datos existentes
    _precioVentaController.text = widget.venta['precioventa']?.toString() ?? '';
    _loteController.text = widget.venta['lote']?.toString() ?? '';
    _notasController.text = widget.venta['notas']?.toString() ?? '';
    _vendedorController.text = widget.venta['vendedor']?.toString() ?? '';
    
    // Cargar fechas
    if (widget.venta['fechaventa']?.toString().isNotEmpty == true) {
      try {
        _fechaVenta = DateTime.parse(widget.venta['fechaventa'].toString());
      } catch (e) {
        print('Error parsing fechaVenta: $e');
      }
    }
    
    // Cargar pagos
    _pago1Controller.text = widget.venta['pago1']?.toString() ?? '';
    _metodo1 = widget.venta['metodo1']?.toString() ?? 'Efectivo';
    if (widget.venta['fechapago1']?.toString().isNotEmpty == true) {
      try {
        _fechaPago1 = DateTime.parse(widget.venta['fechapago1'].toString());
      } catch (e) {
        print('Error parsing fechaPago1: $e');
      }
    }
    
    _pago2Controller.text = widget.venta['pago2']?.toString() ?? '';
    _metodo2 = widget.venta['metodo2']?.toString() ?? 'Efectivo';
    if (widget.venta['fechapago2']?.toString().isNotEmpty == true) {
      try {
        _fechaPago2 = DateTime.parse(widget.venta['fechapago2'].toString());
      } catch (e) {
        print('Error parsing fechaPago2: $e');
      }
    }
    
    _pago3Controller.text = widget.venta['pago3']?.toString() ?? '';
    _metodo3 = widget.venta['metodo3']?.toString() ?? 'Efectivo';
    if (widget.venta['fechapago3']?.toString().isNotEmpty == true) {
      try {
        _fechaPago3 = DateTime.parse(widget.venta['fechapago3'].toString());
      } catch (e) {
        print('Error parsing fechaPago3: $e');
      }
    }
  }

  @override
  void dispose() {
    _precioVentaController.dispose();
    _loteController.dispose();
    _notasController.dispose();
    _vendedorController.dispose();
    _pago1Controller.dispose();
    _pago2Controller.dispose();
    _pago3Controller.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final userEmail = AuthService.instance.userEmail;
      final nombreUsuario = userEmail.split('@')[0];

      final response = await VentasService.actualizarVenta(
        id: widget.venta['id']?.toString() ?? '',
        fechaVenta: _fechaVenta?.toIso8601String(),
        precioVenta: double.parse(_precioVentaController.text),
        lote: _loteController.text.trim(),
        notas: _notasController.text.trim(),
        vendedor: _vendedorController.text.trim(),
        fechaPago1: _fechaPago1?.toIso8601String(),
        metodo1: _pago1Controller.text.isNotEmpty ? _metodo1 : null,
        pago1: _pago1Controller.text.isNotEmpty ? double.parse(_pago1Controller.text) : null,
        fechaPago2: _fechaPago2?.toIso8601String(),
        metodo2: _pago2Controller.text.isNotEmpty ? _metodo2 : null,
        pago2: _pago2Controller.text.isNotEmpty ? double.parse(_pago2Controller.text) : null,
        fechaPago3: _fechaPago3?.toIso8601String(),
        metodo3: _pago3Controller.text.isNotEmpty ? _metodo3 : null,
        pago3: _pago3Controller.text.isNotEmpty ? double.parse(_pago3Controller.text) : null,
        nombreUsuario: nombreUsuario,
        correoUsuario: userEmail,
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Venta actualizada correctamente')),
          );
          widget.onVentaActualizada();
        }
      } else {
        throw Exception(response['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CorporateTheme.primaryBlue, CorporateTheme.primaryBlue.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.edit, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Editar Venta',
                  style: CorporateTheme.headingMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'VIN: ${widget.venta['vin']} - ${widget.venta['ano']} ${widget.venta['modelo']}',
                  style: CorporateTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Formulario con scroll
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información de la venta
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💰 Información de la Venta',
                              style: CorporateTheme.headingSmall.copyWith(
                                color: CorporateTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Precio de venta
                            TextFormField(
                              controller: _precioVentaController,
                              decoration: const InputDecoration(
                                labelText: 'Precio de Venta *',
                                hintText: '250000.00',
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Precio de venta es requerido';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Precio debe ser un número válido';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Fecha de venta
                            InkWell(
                              onTap: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaVenta ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (fecha != null) {
                                  setState(() {
                                    _fechaVenta = fecha;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Venta',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _fechaVenta != null 
                                      ? '${_fechaVenta!.day}/${_fechaVenta!.month}/${_fechaVenta!.year}'
                                      : 'Seleccionar fecha',
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Campos adicionales
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _loteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Lote',
                                      hintText: 'A-123',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _vendedorController,
                                    decoration: const InputDecoration(
                                      labelText: 'Vendedor',
                                      hintText: 'Nombre del vendedor',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Notas
                            TextFormField(
                              controller: _notasController,
                              decoration: const InputDecoration(
                                labelText: 'Notas',
                                hintText: 'Observaciones adicionales...',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Pagos - Editable
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💳 Gestión de Pagos',
                              style: CorporateTheme.headingSmall.copyWith(
                                color: CorporateTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Actualiza los pagos conforme se vayan recibiendo de la financiera',
                              style: CorporateTheme.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Pago 1
                            _buildPagoSection(
                              titulo: 'Pago 1 (Enganche/Inicial)',
                              controller: _pago1Controller,
                              metodo: _metodo1,
                              fecha: _fechaPago1,
                              onMetodoChanged: (value) => setState(() => _metodo1 = value ?? 'Efectivo'),
                              onFechaChanged: (fecha) => setState(() => _fechaPago1 = fecha),
                              color: Colors.blue,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Pago 2
                            _buildPagoSection(
                              titulo: 'Pago 2 (Intermedio)',
                              controller: _pago2Controller,
                              metodo: _metodo2,
                              fecha: _fechaPago2,
                              onMetodoChanged: (value) => setState(() => _metodo2 = value ?? 'Efectivo'),
                              onFechaChanged: (fecha) => setState(() => _fechaPago2 = fecha),
                              color: Colors.orange,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Pago 3
                            _buildPagoSection(
                              titulo: 'Pago 3 (Final)',
                              controller: _pago3Controller,
                              metodo: _metodo3,
                              fecha: _fechaPago3,
                              onMetodoChanged: (value) => setState(() => _metodo3 = value ?? 'Efectivo'),
                              onFechaChanged: (fecha) => setState(() => _fechaPago3 = fecha),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CorporateTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _guardando
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagoSection({
    required String titulo,
    required TextEditingController controller,
    required String metodo,
    required DateTime? fecha,
    required Function(String?) onMetodoChanged,
    required Function(DateTime?) onFechaChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: '\$ ',
                    hintText: '0.00',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: metodo,
                  decoration: const InputDecoration(
                    labelText: 'Método',
                  ),
                  items: VentasService.getMetodosPago()
                      .map((metodo) => DropdownMenuItem(
                            value: metodo,
                            child: Text(metodo),
                          ))
                      .toList(),
                  onChanged: onMetodoChanged,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          InkWell(
            onTap: () async {
              final nuevaFecha = await showDatePicker(
                context: context,
                initialDate: fecha ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (nuevaFecha != null) {
                onFechaChanged(nuevaFecha);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de Pago',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                fecha != null 
                    ? '${fecha.day}/${fecha.month}/${fecha.year}'
                    : 'Seleccionar fecha',
              ),
            ),
          ),
        ],
      ),
    );
  }
}