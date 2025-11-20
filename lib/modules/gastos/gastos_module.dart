import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/exports.dart';
import '../../services/auth_service.dart';
import '../../services/gastos_service.dart';
import '../../services/gastos_calculados_service.dart';

class GastosModule extends StatefulWidget {
  const GastosModule({Key? key}) : super(key: key);

  @override
  State<GastosModule> createState() => _GastosModuleState();
}

class _GastosModuleState extends State<GastosModule> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasAccess = false;
  late TabController _tabController;
  
  List<Map<String, dynamic>> _gastos = [];
  Map<String, dynamic> _estadisticas = {};
  bool _loadingData = false;

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

  void _checkAccess() async {
    try {
      final userRole = AuthService.instance.getUserRole();
      final hasAccess = userRole == UserRole.admin || userRole == UserRole.recepcion;
      
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
      final gastos = await GastosService.obtenerGastos();
      
      setState(() {
        _gastos = gastos;
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
      final estadisticas = await GastosService.obtenerEstadisticas();
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

  Future<void> _eliminarGasto(String id) async {
    try {
      await GastosService.eliminarGasto(id);
      await _cargarDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar gasto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasAccess) {
      return _buildAccessDeniedScreen();
    }

    return _buildMainScreen();
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(title: 'Acceso Denegado'),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.red[600]),
              const SizedBox(height: 16),
              Text(
                'Acceso Restringido',
                style: CorporateTheme.bodyLarge.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Solo Administradores y Encargados pueden acceder a gastos.',
                textAlign: TextAlign.center,
                style: CorporateTheme.bodyLarge.copyWith(color: Colors.red[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Gestión de Gastos'),
        backgroundColor: CorporateTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.add), text: 'Nuevo'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaGastos(),
          _buildNuevoGasto(),
          _buildEstadisticas(),
        ],
      ),
    );
  }

  Widget _buildListaGastos() {
    if (_loadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gastos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay gastos registrados',
              style: CorporateTheme.bodyLarge.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega tu primer gasto usando la pestaña "Nuevo"',
              style: CorporateTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: Column(
        children: [
          // Header de resumen
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CorporateTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CorporateTheme.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_gastos.length} gastos',
                  style: CorporateTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CorporateTheme.primaryBlue,
                  ),
                ),
                IconButton(
                  onPressed: _cargarDatos,
                  icon: Icon(Icons.refresh, color: CorporateTheme.primaryBlue),
                  tooltip: 'Actualizar lista',
                ),
              ],
            ),
          ),
          
          // Lista de gastos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                return _buildGastoTile(_gastos[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGastoTile(Map<String, dynamic> gasto, int index) {
    // Mapear campos correctamente según la respuesta del API
    final id = gasto['id']?.toString() ?? '';
    final fecha = _formatFecha(gasto['fecha']?.toString() ?? '');
    final semana = gasto['semana']?.toString() ?? '';
    final vin = gasto['vin']?.toString() ?? '';
    final categoria = gasto['categoria']?.toString() ?? '';
    final concepto = gasto['concepto']?.toString() ?? '';
    final tipo = gasto['tipo']?.toString() ?? '';
    final montoMXN = gasto['montoMXN']?.toString() ?? '0';
    final tipoCambio = gasto['tipoCambio']?.toString() ?? '0';
    final montoUSD = gasto['montoUSD']?.toString() ?? '0';
    final nombreUsuario = gasto['nombreUsuario']?.toString() ?? '';

    // Formatear números
    final montoMXNFormatted = double.tryParse(montoMXN)?.toStringAsFixed(2) ?? montoMXN;
    final tipoCambioFormatted = double.tryParse(tipoCambio)?.toStringAsFixed(2) ?? tipoCambio;
    final montoUSDFormatted = double.tryParse(montoUSD)?.toStringAsFixed(2) ?? montoUSD;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: tipo == 'Gasto' 
            ? Colors.red.withOpacity(0.2) 
            : Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header del gasto
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tipo == 'Gasto' 
                ? Colors.red.withOpacity(0.05) 
                : Colors.green.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Número de orden
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CorporateTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concepto,
                        style: CorporateTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoriaColor(categoria),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              categoria,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tipo == 'Gasto' ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tipo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Acciones
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _mostrarEditarGasto(gasto);
                    } else if (value == 'delete') {
                      _confirmarEliminarGasto(id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Detalles del gasto
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Fila 1: Montos
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Monto MXN',
                        '\$${montoMXNFormatted}',
                        Icons.monetization_on,
                        tipo == 'Gasto' ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        'Monto USD',
                        '\$${montoUSDFormatted}',
                        Icons.attach_money,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Fila 2: Fecha y Semana
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Fecha',
                        fecha,
                        Icons.calendar_today,
                        Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        'Semana',
                        semana == '#NUM!' ? 'Error' : 'Sem. $semana',
                        Icons.date_range,
                        semana == '#NUM!' ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Fila 3: VIN y Tipo de Cambio
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'VIN/Origen',
                        vin.isEmpty ? 'Gasto Sucursal' : vin,
                        vin.isEmpty ? Icons.store : Icons.directions_car,
                        vin.isEmpty ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        'Tipo Cambio',
                        '\$${tipoCambioFormatted}',
                        Icons.currency_exchange,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                // Usuario (si hay espacio)
                if (nombreUsuario.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Registrado por: $nombreUsuario',
                          style: CorporateTheme.bodyMedium.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: CorporateTheme.bodyMedium.copyWith(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatFecha(String fecha) {
    try {
      if (fecha.contains('T')) {
        final dateTime = DateTime.parse(fecha);
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'mantenimiento':
        return Colors.blue;
      case 'reparación':
        return Colors.orange;
      case 'combustible':
        return Colors.green;
      case 'seguros':
        return Colors.purple;
      case 'documentación':
        return Colors.teal;
      case 'servicios públicos':
        return Colors.indigo;
      case 'recolección de basura':
        return Colors.brown;
      case 'materiales de oficina':
        return Colors.cyan;
      case 'limpieza':
        return Colors.lightBlue;
      case 'telecomunicaciones':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }



  Widget _buildNuevoGasto() {
    return NuevoGastoForm(onGastoCreado: _cargarDatos);
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

    final totalMXN = double.tryParse(_estadisticas['totalMXN']?.toString() ?? '0') ?? 0.0;
    final totalUSD = double.tryParse(_estadisticas['totalUSD']?.toString() ?? '0') ?? 0.0;
    final totalGastos = int.tryParse(_estadisticas['totalGastos']?.toString() ?? '0') ?? 0;
    
    // Procesar datos para gráficos
    final categorias = _estadisticas['categorias'] as Map<String, dynamic>? ?? {};
    final tipos = _estadisticas['tipos'] as Map<String, dynamic>? ?? {};

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
                  '📊 Dashboard de Gastos',
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

          // Tarjetas de resumen mejoradas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Gastos',
                  totalGastos.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total MXN',
                  '\$${totalMXN.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Total USD',
            '\$${totalUSD.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.orange,
            fullWidth: true,
          ),
          const SizedBox(height: 24),

          // Gráfico de pastel por categorías
          if (categorias.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pie_chart, color: CorporateTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Gastos por Categoría',
                          style: CorporateTheme.headingSmall.copyWith(
                            color: CorporateTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildCategoriasPieChart(categorias),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriaLegend(categorias),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Gráfico de barras por tipo
          if (tipos.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: CorporateTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Distribución por Tipo',
                          style: CorporateTheme.headingSmall.copyWith(
                            color: CorporateTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildTiposBarChart(tipos),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Análisis de gastos por datos reales
          if (_gastos.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: CorporateTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Análisis Temporal',
                          style: CorporateTheme.headingSmall.copyWith(
                            color: CorporateTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildGastosTemporales(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

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
                    totalGastos > 0
                        ? 'Promedio por gasto: \$${(totalMXN / totalGastos).toStringAsFixed(2)} MXN'
                        : 'No hay gastos registrados',
                    style: CorporateTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (totalGastos > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tipo de cambio promedio: \$${_calcularTipoCambioPromedio().toStringAsFixed(2)}',
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Card(
      child: Container(
        width: fullWidth ? double.infinity : null,
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

  // Gráfico de pastel para categorías
  Widget _buildCategoriasPieChart(Map<String, dynamic> categorias) {
    final sections = <PieChartSectionData>[];
    final colors = [
      CorporateTheme.primaryBlue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    int colorIndex = 0;
    final total = categorias.values.fold<double>(0.0, (sum, value) {
      return sum + (double.tryParse(value.toString()) ?? 0.0);
    });

    categorias.forEach((categoria, monto) {
      final amount = double.tryParse(monto.toString()) ?? 0.0;
      if (amount > 0) {
        final percentage = (amount / total) * 100;
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: amount,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIndex++;
      }
    });

    if (sections.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Manejo de toques opcionales
          },
        ),
      ),
    );
  }

  // Leyenda para el gráfico de categorías
  Widget _buildCategoriaLegend(Map<String, dynamic> categorias) {
    final colors = [
      CorporateTheme.primaryBlue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    int colorIndex = 0;
    final items = <Widget>[];

    categorias.forEach((categoria, monto) {
      final amount = double.tryParse(monto.toString()) ?? 0.0;
      if (amount > 0) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[colorIndex % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$categoria (\$${amount.toStringAsFixed(2)})',
                    style: CorporateTheme.bodyMedium.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
        colorIndex++;
      }
    });

    return Wrap(
      alignment: WrapAlignment.center,
      children: items,
    );
  }

  // Gráfico de barras para tipos
  Widget _buildTiposBarChart(Map<String, dynamic> tipos) {
    final barGroups = <BarChartGroupData>[];
    int index = 0;

    tipos.forEach((tipo, monto) {
      final amount = double.tryParse(monto.toString()) ?? 0.0;
      if (amount > 0) {
        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: index % 2 == 0 ? CorporateTheme.primaryBlue : Colors.green,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        );
        index++;
      }
    });

    if (barGroups.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final tiposList = tipos.keys.toList();
                if (value.toInt() < tiposList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      tiposList[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: null,
          verticalInterval: 1,
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final tiposList = tipos.keys.toList();
              if (groupIndex < tiposList.length) {
                return BarTooltipItem(
                  '${tiposList[groupIndex]}\n\$${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  // Gráfico temporal basado en gastos reales
  Widget _buildGastosTemporales() {
    if (_gastos.isEmpty) {
      return const Center(
        child: Text('No hay gastos para analizar'),
      );
    }

    // Agrupar gastos por mes
    final gastosPorMes = <String, double>{};
    
    for (final gasto in _gastos) {
      try {
        final fechaStr = gasto['fecha']?.toString() ?? '';
        if (fechaStr.isNotEmpty) {
          final fecha = DateTime.parse(fechaStr);
          final mesKey = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
          final monto = double.tryParse(gasto['montomxn']?.toString() ?? '0') ?? 0.0;
          gastosPorMes[mesKey] = (gastosPorMes[mesKey] ?? 0.0) + monto;
        }
      } catch (e) {
        // Ignorar fechas inválidas
      }
    }

    if (gastosPorMes.isEmpty) {
      return const Center(
        child: Text('No se pudieron procesar las fechas'),
      );
    }

    // Crear puntos para el gráfico de líneas
    final spots = <FlSpot>[];
    final mesesOrdenados = gastosPorMes.keys.toList()..sort();
    
    for (int i = 0; i < mesesOrdenados.length && i < 12; i++) {
      final monto = gastosPorMes[mesesOrdenados[i]] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), monto));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: CorporateTheme.primaryBlue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: CorporateTheme.primaryBlue.withOpacity(0.2),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < mesesOrdenados.length) {
                  final mesKey = mesesOrdenados[value.toInt()];
                  final parts = mesKey.split('-');
                  if (parts.length == 2) {
                    final mes = int.tryParse(parts[1]) ?? 1;
                    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                                  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                    return Text(
                      meses[mes - 1],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: null,
        ),
        borderData: FlBorderData(show: true),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                if (spot.barIndex == 0 && spot.spotIndex < mesesOrdenados.length) {
                  final mesKey = mesesOrdenados[spot.spotIndex];
                  return LineTooltipItem(
                    '$mesKey\n\$${spot.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // Calcular tipo de cambio promedio
  double _calcularTipoCambioPromedio() {
    if (_gastos.isEmpty) return 0.0;
    
    double totalTipoCambio = 0.0;
    int contador = 0;
    
    for (final gasto in _gastos) {
      final tipoCambio = double.tryParse(gasto['tipocambio']?.toString() ?? '0') ?? 0.0;
      if (tipoCambio > 0) {
        totalTipoCambio += tipoCambio;
        contador++;
      }
    }
    
    return contador > 0 ? totalTipoCambio / contador : 0.0;
  }

  void _mostrarEditarGasto(Map<String, dynamic> gasto) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: EditarGastoForm(
          gasto: gasto,
          onGastoActualizado: _cargarDatos,
        ),
      ),
    );
  }

  void _confirmarEliminarGasto(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarGasto(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class NuevoGastoForm extends StatefulWidget {
  final VoidCallback onGastoCreado;

  const NuevoGastoForm({Key? key, required this.onGastoCreado}) : super(key: key);

  @override
  State<NuevoGastoForm> createState() => _NuevoGastoFormState();
}

class _NuevoGastoFormState extends State<NuevoGastoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();
  final TextEditingController _montoMXNController = TextEditingController();
  final TextEditingController _tipoCambioController = TextEditingController(text: '20.0');
  final TextEditingController _montoEnvioController = TextEditingController(text: '0');
  final TextEditingController _balanceController = TextEditingController(text: '0');
  final TextEditingController _imagenController = TextEditingController();
  
  String _categoriaSeleccionada = 'Otros';
  String _tipoSeleccionado = 'Gasto';
  DateTime _fechaSeleccionada = DateTime.now();
  bool _enviando = false;
  double _montoUSDCalculado = 0.0;

  @override
  void initState() {
    super.initState();
    _montoMXNController.addListener(_calcularMontoUSD);
    _tipoCambioController.addListener(_calcularMontoUSD);
  }

  @override
  void dispose() {
    _vinController.dispose();
    _conceptoController.dispose();
    _montoMXNController.dispose();
    _tipoCambioController.dispose();
    _montoEnvioController.dispose();
    _balanceController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  void _calcularMontoUSD() {
    final montoMXN = double.tryParse(_montoMXNController.text) ?? 0.0;
    final tipoCambio = double.tryParse(_tipoCambioController.text) ?? 1.0;
    
    setState(() {
      if (_tipoSeleccionado == 'Gasto' && tipoCambio > 0) {
        _montoUSDCalculado = montoMXN / tipoCambio;
      } else {
        _montoUSDCalculado = 0.0;
      }
    });
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: CorporateTheme.headingMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // VIN (Opcional)
                    TextFormField(
                      controller: _vinController,
                      decoration: const InputDecoration(
                        labelText: 'VIN del Vehículo (Opcional)',
                        hintText: 'Solo si el gasto es específico de un vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                        helperText: 'Dejar vacío para gastos generales de sucursal',
                      ),
                      // Removemos el validator para hacerlo opcional
                    ),
                    const SizedBox(height: 16),
                    
                    // Concepto
                    TextFormField(
                      controller: _conceptoController,
                      decoration: const InputDecoration(
                        labelText: 'Concepto del Gasto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el concepto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Categoría y Tipo
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoriaSeleccionada,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: GastosService.getCategorias().map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _categoriaSeleccionada = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tipoSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.swap_horiz),
                            ),
                            items: GastosService.getTipos().map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoSeleccionado = value!;
                                _calcularMontoUSD();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha
                    InkWell(
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (fecha != null) {
                          setState(() {
                            _fechaSeleccionada = fecha;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Financiera',
                      style: CorporateTheme.headingMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Monto MXN
                    TextFormField(
                      controller: _montoMXNController,
                      decoration: const InputDecoration(
                        labelText: 'Monto en MXN',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el monto';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de Cambio
                    TextFormField(
                      controller: _tipoCambioController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cambio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.currency_exchange),
                        helperText: 'Pesos mexicanos por dólar',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el tipo de cambio';
                        }
                        final tipoCambio = double.tryParse(value);
                        if (tipoCambio == null || tipoCambio <= 0) {
                          return 'Por favor ingrese un tipo de cambio válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Monto USD Calculado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Monto USD (calculado): ',
                            style: CorporateTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_montoUSDCalculado.toStringAsFixed(2)}',
                            style: CorporateTheme.bodyLarge.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campos adicionales en una fila
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _montoEnvioController,
                            decoration: const InputDecoration(
                              labelText: 'Monto Envío',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _balanceController,
                            decoration: const InputDecoration(
                              labelText: 'Balance',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Imagen (opcional)
                    TextFormField(
                      controller: _imagenController,
                      decoration: const InputDecoration(
                        labelText: 'URL de Imagen (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                        helperText: 'Enlace a la imagen del recibo o comprobante',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _enviando ? null : _limpiarFormulario,
                    child: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _enviando ? null : _guardarGasto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CorporateTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Guardar Gasto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _vinController.clear();
    _conceptoController.clear();
    _montoMXNController.clear();
    _tipoCambioController.text = '20.0';
    _montoEnvioController.text = '0';
    _balanceController.text = '0';
    _imagenController.clear();
    setState(() {
      _categoriaSeleccionada = 'Otros';
      _tipoSeleccionado = 'Gasto';
      _fechaSeleccionada = DateTime.now();
      _montoUSDCalculado = 0.0;
    });
  }

  Future<void> _guardarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
    });

    try {
      // Obtener información del usuario logueado
      final userEmail = AuthService.instance.userEmail;
      final nombreUsuario = userEmail.split('@')[0]; // Usar parte del email como nombre
      
      // Formatear fecha como string dd/mm/yyyy
      final fechaStr = '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/${_fechaSeleccionada.month.toString().padLeft(2, '0')}/${_fechaSeleccionada.year}';
      
      await GastosService.agregarGasto(
        vin: _vinController.text,
        categoria: _categoriaSeleccionada,
        concepto: _conceptoController.text,
        tipo: _tipoSeleccionado,
        montoMXN: double.parse(_montoMXNController.text),
        tipoCambio: double.parse(_tipoCambioController.text),
        fecha: fechaStr,
        montoEnvio: double.parse(_montoEnvioController.text),
        balance: double.parse(_balanceController.text),
        imagen: _imagenController.text,
        nombreUsuario: nombreUsuario,
        correoUsuario: userEmail,
      );

      if (mounted) {
        // Invalidar cache de gastos calculados para que se actualice el inventario
        GastosCalculadosService.invalidarCache();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto guardado correctamente')),
        );
        _limpiarFormulario();
        widget.onGastoCreado();
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
}

class EditarGastoForm extends StatefulWidget {
  final Map<String, dynamic> gasto;
  final VoidCallback onGastoActualizado;

  const EditarGastoForm({
    Key? key,
    required this.gasto,
    required this.onGastoActualizado,
  }) : super(key: key);

  @override
  State<EditarGastoForm> createState() => _EditarGastoFormState();
}

class _EditarGastoFormState extends State<EditarGastoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vinController;
  late TextEditingController _conceptoController;
  late TextEditingController _montoMXNController;
  late TextEditingController _tipoCambioController;
  late TextEditingController _montoEnvioController;
  late TextEditingController _balanceController;
  late TextEditingController _imagenController;
  
  late String _categoriaSeleccionada;
  late String _tipoSeleccionado;
  late DateTime _fechaSeleccionada;
  bool _enviando = false;
  double _montoUSDCalculado = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _montoMXNController.addListener(_calcularMontoUSD);
    _tipoCambioController.addListener(_calcularMontoUSD);
    _calcularMontoUSD();
  }

  void _initializeControllers() {
    // Usar las claves en minúsculas que vienen de la API
    _vinController = TextEditingController(text: widget.gasto['vin']?.toString() ?? '');
    _conceptoController = TextEditingController(text: widget.gasto['concepto']?.toString() ?? '');
    _montoMXNController = TextEditingController(text: widget.gasto['montomxn']?.toString() ?? '');
    _tipoCambioController = TextEditingController(text: widget.gasto['tipocambio']?.toString() ?? '20.0');
    _montoEnvioController = TextEditingController(text: widget.gasto['montoenvio']?.toString() ?? '0');
    _balanceController = TextEditingController(text: widget.gasto['balance']?.toString() ?? '0');
    _imagenController = TextEditingController(text: widget.gasto['imagen']?.toString() ?? '');
    
    _categoriaSeleccionada = widget.gasto['categoria']?.toString() ?? 'Otros';
    _tipoSeleccionado = widget.gasto['tipo']?.toString() ?? 'Gasto';
    
    // Parse fecha - puede venir en formato ISO o dd/mm/yyyy
    final fechaStr = widget.gasto['fecha']?.toString() ?? '';
    try {
      if (fechaStr.contains('T')) {
        // Formato ISO
        _fechaSeleccionada = DateTime.parse(fechaStr);
      } else if (fechaStr.contains('/')) {
        // Formato dd/mm/yyyy
        final parts = fechaStr.split('/');
        if (parts.length == 3) {
          _fechaSeleccionada = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          _fechaSeleccionada = DateTime.now();
        }
      } else {
        _fechaSeleccionada = DateTime.now();
      }
    } catch (e) {
      print('Error parseando fecha: $e');
      _fechaSeleccionada = DateTime.now();
    }
  }

  @override
  void dispose() {
    _vinController.dispose();
    _conceptoController.dispose();
    _montoMXNController.dispose();
    _tipoCambioController.dispose();
    _montoEnvioController.dispose();
    _balanceController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  void _calcularMontoUSD() {
    final montoMXN = double.tryParse(_montoMXNController.text) ?? 0.0;
    final tipoCambio = double.tryParse(_tipoCambioController.text) ?? 1.0;
    
    setState(() {
      if (_tipoSeleccionado == 'Gasto' && tipoCambio > 0) {
        _montoUSDCalculado = montoMXN / tipoCambio;
      } else {
        _montoUSDCalculado = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar Gasto',
                style: CorporateTheme.headingMedium,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // VIN y Concepto
                    TextFormField(
                      controller: _vinController,
                      decoration: const InputDecoration(
                        labelText: 'VIN del Vehículo (Opcional)',
                        hintText: 'Solo si el gasto es específico de un vehículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                        helperText: 'Dejar vacío para gastos generales de sucursal',
                      ),
                      // Campo opcional, sin validación requerida
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _conceptoController,
                      decoration: const InputDecoration(
                        labelText: 'Concepto del Gasto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el concepto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Categoría y Tipo
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoriaSeleccionada,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                            ),
                            items: GastosService.getCategorias().map((categoria) {
                              return DropdownMenuItem(
                                value: categoria,
                                child: Text(categoria),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _categoriaSeleccionada = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tipoSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(),
                            ),
                            items: GastosService.getTipos().map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoSeleccionado = value!;
                                _calcularMontoUSD();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Monto y Tipo de Cambio
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _montoMXNController,
                            decoration: const InputDecoration(
                              labelText: 'Monto MXN',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _tipoCambioController,
                            decoration: const InputDecoration(
                              labelText: 'Tipo Cambio',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Monto USD Calculado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_money, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'USD: \$${_montoUSDCalculado.toStringAsFixed(2)}',
                            style: CorporateTheme.bodyLarge.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha
                    InkWell(
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: _fechaSeleccionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (fecha != null) {
                          setState(() {
                            _fechaSeleccionada = fecha;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _enviando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _enviando ? null : _actualizarGasto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CorporateTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: _enviando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Actualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
    });

    try {
      // Obtener información del usuario logueado
      final userEmail = AuthService.instance.userEmail;
      final nombreUsuario = userEmail.split('@')[0]; // Usar parte del email como nombre
      
      // Formatear fecha como string dd/mm/yyyy
      final fechaStr = '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/${_fechaSeleccionada.month.toString().padLeft(2, '0')}/${_fechaSeleccionada.year}';
      
      await GastosService.actualizarGasto(
        id: widget.gasto['id']?.toString() ?? '',
        vin: _vinController.text,
        categoria: _categoriaSeleccionada,
        concepto: _conceptoController.text,
        tipo: _tipoSeleccionado,
        montoMXN: double.parse(_montoMXNController.text),
        tipoCambio: double.parse(_tipoCambioController.text),
        fecha: fechaStr,
        montoEnvio: double.parse(_montoEnvioController.text),
        balance: double.parse(_balanceController.text),
        imagen: _imagenController.text,
        nombreUsuario: nombreUsuario,
        correoUsuario: userEmail,
      );

      if (mounted) {
        // Invalidar cache de gastos calculados para que se actualice el inventario
        GastosCalculadosService.invalidarCache();
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto actualizado correctamente')),
        );
        widget.onGastoActualizado();
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
}
