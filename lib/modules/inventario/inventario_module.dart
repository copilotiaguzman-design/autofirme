import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/inventario_service.dart';
import '../../services/gastos_calculados_service.dart';
import '../../services/auth_service.dart';
import 'vehiculo_form_screen.dart';

class InventarioModule extends StatefulWidget {
  const InventarioModule({super.key});

  @override
  State<InventarioModule> createState() => _InventarioModuleState();
}

class _InventarioModuleState extends State<InventarioModule> {
  List<Map<String, dynamic>> _vehiculos = [];

  Map<String, dynamic> _estadisticas = {};
  bool _isLoading = true;
  String _filtroEstado = 'Todos';
  String _filtroMarca = 'Todas';
  List<String> _marcas = ['Todas'];
  bool _vistaTabla = true; // true = tabla, false = galería
  
  final TextEditingController _searchController = TextEditingController();
  String _textoBusqueda = '';
  
  // Control de acceso y gastos calculados
  bool _canViewFinancialInfo = false;
  Map<String, double> _gastosCalculados = {};

  @override
  void initState() {
    super.initState();
    _checkUserPermissions();
    _cargarDatos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _textoBusqueda = _searchController.text;
    });
  }

  void _checkUserPermissions() {
    try {
      // Obtener el rol del usuario actual desde AuthService
      final userRole = AuthService.instance.getUserRole();
      setState(() {
        // Solo administrador e inventario pueden ver información financiera
        _canViewFinancialInfo = userRole == UserRole.admin || userRole == UserRole.inventario;
      });
    } catch (e) {
      print('Error al verificar permisos de usuario: $e');
      setState(() {
        _canViewFinancialInfo = false;
      });
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final vehiculos = await InventarioService.obtenerInventario();
      final estadisticas = await InventarioService.obtenerEstadisticas();
      final marcas = await InventarioService.obtenerMarcas();
      
      // Cargar gastos calculados si el usuario tiene permisos
      Map<String, double> gastosCalculados = {};
      if (_canViewFinancialInfo && vehiculos.isNotEmpty) {
        final vins = vehiculos.map((v) => v['vin']?.toString() ?? '').where((vin) => vin.isNotEmpty).toList();
        gastosCalculados = await GastosCalculadosService.obtenerGastosParaVins(vins);
      }
      
      setState(() {
        _vehiculos = vehiculos;
        _estadisticas = estadisticas;
        _marcas = ['Todas', ...marcas];
        _gastosCalculados = gastosCalculados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _vehiculosFiltrados {
    return _vehiculos.where((vehiculo) {
      final cumpleEstado = _filtroEstado == 'Todos' || 
          vehiculo['estado']?.toString() == _filtroEstado;
      final cumpleMarca = _filtroMarca == 'Todas' || 
          vehiculo['marca']?.toString() == _filtroMarca;
      
      // Filtro de búsqueda por texto
      final cumpleBusqueda = _textoBusqueda.isEmpty ||
          vehiculo['marca']?.toString().toLowerCase().contains(_textoBusqueda.toLowerCase()) == true ||
          vehiculo['modelo']?.toString().toLowerCase().contains(_textoBusqueda.toLowerCase()) == true ||
          vehiculo['vin']?.toString().toLowerCase().contains(_textoBusqueda.toLowerCase()) == true ||
          vehiculo['vinCompleto']?.toString().toLowerCase().contains(_textoBusqueda.toLowerCase()) == true ||
          vehiculo['color']?.toString().toLowerCase().contains(_textoBusqueda.toLowerCase()) == true ||
          vehiculo['ano']?.toString().contains(_textoBusqueda) == true;
      
      return cumpleEstado && cumpleMarca && cumpleBusqueda;
    }).toList();
  }

  // Métodos responsive
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;

  double get responsivePadding {
    if (isDesktop) return 24.0;
    if (isTablet) return 20.0;
    return 16.0;
  }

  double get responsiveSpacing {
    if (isDesktop) return 24.0;
    if (isTablet) return 20.0;
    return 16.0;
  }

  int get galeriaCrossAxisCount {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 1; // Móvil una columna para evitar overflow
  }

  double get galeriaAspectRatio {
    if (isDesktop) return 1.2;
    if (isTablet) return 1.0;
    return 0.6; // Móvil más compacto
  }

  int get statsColumns {
    if (isDesktop) return 4;
    return 2;
  }

  double get statsAspectRatio {
    if (isDesktop) return 2.2;
    if (isTablet) return 2.0;
    return 1.6; // Móvil más compacto
  }

  // Helper para truncar VIN de manera segura
  String _truncateVin(String? vin) {
    if (vin == null) return 'N/A';
    final vinStr = vin.toString();
    return vinStr.length > 8 ? vinStr.substring(0, 8) : vinStr;
  }

  // Helper para obtener el estado correcto desde los datos
  String _getEstadoNormalizado(Map<String, dynamic> vehiculo) {
    // Los datos parecen tener el estado en 'nombreUsuario' por error
    String estado = vehiculo['estado']?.toString() ?? '';
    String nombreUsuario = vehiculo['nombreUsuario']?.toString() ?? '';
    
    // Si el estado está vacío pero nombreUsuario tiene un valor como "Disponible", "Vendido", etc.
    if (estado.isEmpty && ['Disponible', 'Vendido', 'Reservado', 'En Reparación', 'En Tránsito'].contains(nombreUsuario)) {
      return nombreUsuario;
    }
    
    return estado.isEmpty ? 'Disponible' : estado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: 'Inventario de Vehículos',
        actions: [
          IconButton(
            icon: Icon(_vistaTabla ? Icons.view_module : Icons.table_rows),
            onPressed: () {
              setState(() {
                _vistaTabla = !_vistaTabla;
              });
            },
            tooltip: _vistaTabla ? 'Vista Galería' : 'Vista Tabla',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEstadisticasCard(),
                    SizedBox(height: isMobile ? 8 : 12),
                    _buildFiltrosSection(),
                    SizedBox(height: isMobile ? 8 : 12),
                    _vistaTabla ? _buildVehiculosTabla() : _buildVehiculosGaleria(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarVehiculo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar Vehículo', style: TextStyle(color: Colors.white),),
        backgroundColor: CorporateTheme.primaryBlue,
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header más compacto
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: CorporateTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.analytics,
                  color: CorporateTheme.primaryBlue,
                  size: isMobile ? 16 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Estadísticas',
                style: CorporateTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Grid más compacto
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 5 : (isTablet ? 4 : 2),
            crossAxisSpacing: isMobile ? 4 : 8,
            mainAxisSpacing: isMobile ? 4 : 8,
            childAspectRatio: isDesktop ? 2.8 : (isTablet ? 2.5 : 2.0),
            children: [
              _buildEstadisticaItem(
                'Total Vehículos',
                _estadisticas['totalVehiculos']?.toString() ?? '0',
                Icons.directions_car,
                Colors.blue,
              ),
              _buildEstadisticaItem(
                'Disponibles',
                _estadisticas['disponibles']?.toString() ?? '0',
                Icons.check_circle,
                Colors.green,
              ),
              _buildEstadisticaItem(
                'Vendidos',
                _estadisticas['vendidos']?.toString() ?? '0',
                Icons.sell,
                Colors.orange,
              ),
              _buildEstadisticaItem(
                'Promedio Días',
                _estadisticas['promedioInventario']?.toString() ?? '0',
                Icons.schedule,
                Colors.purple,
              ),
            ],
          ),
          // Valor total más compacto e integrado
          if (_estadisticas['valorTotal'] != null && !isMobile) ...[
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_money, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Total: \$${(_estadisticas['valorTotal'] as double).toStringAsFixed(0)}',
                    style: CorporateTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: isMobile ? 14 : 16),
          SizedBox(width: isMobile ? 3 : 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: CorporateTheme.caption.copyWith(
                    color: color,
                    fontSize: isMobile ? 9 : 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  valor,
                  style: CorporateTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosSection() {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono y título compactos
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CorporateTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.filter_list,
              color: CorporateTheme.primaryBlue,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Filtros:',
            style: CorporateTheme.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 12),
          // Campo de búsqueda y filtros horizontales compactos
          Expanded(
            child: Row(
              children: [
                // Campo de búsqueda
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por marca, modelo, VIN...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey.shade600),
                        suffixIcon: _textoBusqueda.isNotEmpty 
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _searchController.clear();
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: CorporateTheme.primaryBlue, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildFiltroDropdown('Estado', _filtroEstado, 
                    ['Todos', ...InventarioService.obtenerEstadosDisponibles()], 
                    (value) => setState(() => _filtroEstado = value ?? 'Todos')),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildFiltroDropdown('Marca', _filtroMarca, _marcas, 
                    (value) => setState(() => _filtroMarca = value ?? 'Todas')),
                ),
                SizedBox(width: 8),
                // Botón de limpiar filtros
                IconButton(
                  onPressed: () {
                    setState(() {
                      _filtroEstado = 'Todos';
                      _filtroMarca = 'Todas';
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.clear_all, size: 16),
                  tooltip: 'Limpiar filtros y búsqueda',
                  constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  padding: EdgeInsets.all(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 8, 
          vertical: 4
        ),
        labelStyle: TextStyle(fontSize: 11),
      ),
      style: TextStyle(fontSize: 12, color: Colors.black87),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(fontSize: 12)),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildVehiculosTabla() {
    final vehiculosFiltrados = _vehiculosFiltrados;
    
    if (vehiculosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile ? 
        // Vista de lista para móvil (no tabla)
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(responsivePadding),
              decoration: BoxDecoration(
                color: CorporateTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.list, color: CorporateTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Lista de Vehículos',
                    style: CorporateTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CorporateTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehiculosFiltrados.length,
              itemBuilder: (context, index) {
                final vehiculo = vehiculosFiltrados[index];
                return _buildMobileListItem(vehiculo, index);
              },
            ),
          ],
        ) :
        // Vista de tabla para desktop/tablet
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(responsivePadding),
              decoration: BoxDecoration(
                color: CorporateTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _buildTableHeader('Vehículo', flex: 3),
                  _buildTableHeader('VIN', flex: 2),
                  _buildTableHeader('Estado', flex: 2),
                  if (_canViewFinancialInfo) _buildTableHeader('Precio', flex: 2),
                  if (_canViewFinancialInfo) _buildTableHeader('Gastos', flex: 2),
                  _buildTableHeader('Días', flex: 1),
                  _buildTableHeader('', flex: 1),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehiculosFiltrados.length,
              itemBuilder: (context, index) {
                final vehiculo = vehiculosFiltrados[index];
                return _buildTableRow(vehiculo, index);
              },
            ),
          ],
        ),
    );
  }

  Widget _buildMobileListItem(Map<String, dynamic> vehiculo, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsivePadding, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () => _editarVehiculo(vehiculo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con título y estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de vehículo
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CorporateTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: CorporateTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehiculo['ano']} ${vehiculo['marca']} ${vehiculo['modelo']}',
                          style: CorporateTheme.bodyLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CorporateTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${vehiculo['color'] ?? 'N/A'} • Motor: ${vehiculo['motor'] ?? 'N/A'}',
                          style: CorporateTheme.caption.copyWith(
                            color: CorporateTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(_getEstadoNormalizado(vehiculo)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getEstadoNormalizado(vehiculo),
                      style: CorporateTheme.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Información secundaria en cards pequeñas
              Row(
                children: [
                  _buildInfoCard('VIN', vehiculo['vin']?.toString() ?? 'N/A', Icons.confirmation_number),
                  SizedBox(width: 12),
                  _buildInfoCard('Días', '${vehiculo['diasInventario'] ?? 0}', Icons.calendar_today),
                  Spacer(),
                  // Precios en columna (solo para admin)
                  if (_canViewFinancialInfo) Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Precio destacado
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '\$${(vehiculo['total']?.toDouble() ?? 0).toStringAsFixed(0)}',
                          style: CorporateTheme.bodyLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // Gastos calculados
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          'Gastos: \$${(_gastosCalculados[vehiculo['vin']] ?? 0.0).toStringAsFixed(0)}',
                          style: CorporateTheme.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: CorporateTheme.textSecondary),
          SizedBox(width: 4),
          Text(
            '$label: $value',
            style: CorporateTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: CorporateTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculosGaleria() {
    final vehiculosFiltrados = _vehiculosFiltrados;
    
    if (vehiculosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: galeriaCrossAxisCount,
        crossAxisSpacing: responsiveSpacing * 0.5,
        mainAxisSpacing: responsiveSpacing * 0.5,
        childAspectRatio: galeriaAspectRatio,
      ),
      itemCount: vehiculosFiltrados.length,
      itemBuilder: (context, index) {
        final vehiculo = vehiculosFiltrados[index];
        return _buildVehiculoCardGaleria(vehiculo);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(responsivePadding * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: isMobile ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: responsiveSpacing),
          Text(
            'No hay vehículos',
            style: CorporateTheme.bodyLarge.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsiveSpacing * 0.5),
          Text(
            'Agrega tu primer vehículo al inventario',
            style: CorporateTheme.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: CorporateTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: CorporateTheme.primaryBlue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> vehiculo, int index) {
    return Container(
      padding: EdgeInsets.all(responsivePadding * 0.75),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () => _editarVehiculo(vehiculo),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehiculo['ano']} ${vehiculo['marca']}',
                    style: CorporateTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${vehiculo['modelo']} • ${vehiculo['color']}',
                    style: CorporateTheme.caption.copyWith(
                      color: CorporateTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _truncateVin(vehiculo['vin']),
                style: CorporateTheme.caption,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEstadoColor(_getEstadoNormalizado(vehiculo)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getEstadoNormalizado(vehiculo),
                  style: CorporateTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (_canViewFinancialInfo)
              Expanded(
                flex: 2,
                child: Text(
                  '\$${(vehiculo['total']?.toDouble() ?? 0).toStringAsFixed(0)}',
                  style: CorporateTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_canViewFinancialInfo)
              Expanded(
                flex: 2,
                child: Text(
                  '\$${(_gastosCalculados[vehiculo['vin']] ?? 0.0).toStringAsFixed(0)}',
                  style: CorporateTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              flex: 1,
              child: Text(
                '${vehiculo['diasInventario'] ?? 0}',
                style: CorporateTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      _editarVehiculo(vehiculo);
                      break;
                    case 'eliminar':
                      _eliminarVehiculo(vehiculo);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiculoCardGaleria(Map<String, dynamic> vehiculo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editarVehiculo(vehiculo),
        child: Padding(
          padding: EdgeInsets.all(responsivePadding * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(_getEstadoNormalizado(vehiculo)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: _getEstadoColor(_getEstadoNormalizado(vehiculo)),
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 4 : 6, 
                      vertical: 2
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(_getEstadoNormalizado(vehiculo)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getEstadoNormalizado(vehiculo),
                      style: CorporateTheme.caption.copyWith(
                        color: Colors.white,
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsiveSpacing * 0.5),
              Text(
                '${vehiculo['ano']} ${vehiculo['marca']}',
                style: CorporateTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                vehiculo['modelo'] ?? '',
                style: CorporateTheme.caption.copyWith(
                  color: CorporateTheme.textSecondary,
                  fontSize: isMobile ? 10 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isMobile) ...[
                SizedBox(height: responsiveSpacing * 0.25),
                Text(
                  '${vehiculo['color']} • ${vehiculo['version'] ?? 'N/A'}',
                  style: CorporateTheme.caption.copyWith(
                    color: CorporateTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              if (!isMobile) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIN: ${_truncateVin(vehiculo['vin'])}',
                            style: CorporateTheme.caption.copyWith(
                              color: CorporateTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Días: ${vehiculo['diasInventario'] ?? 0}',
                            style: CorporateTheme.caption.copyWith(
                              color: CorporateTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsiveSpacing * 0.5),
              ],
              if (_canViewFinancialInfo) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '\$${(vehiculo['total']?.toDouble() ?? 0).toStringAsFixed(0)}',
                    style: CorporateTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: responsiveSpacing * 0.25),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Gastos: \$${(_gastosCalculados[vehiculo['vin']] ?? 0.0).toStringAsFixed(0)}',
                    style: CorporateTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      fontSize: isMobile ? 10 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
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

  Future<void> _agregarVehiculo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehiculoFormScreen(),
      ),
    );
    
    if (result == true && mounted) {
      _cargarDatos();
    }
  }

  Future<void> _editarVehiculo(Map<String, dynamic> vehiculo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehiculoFormScreen(vehiculo: vehiculo),
      ),
    );
    
    if (result == true && mounted) {
      _cargarDatos();
    }
  }

  Future<void> _eliminarVehiculo(Map<String, dynamic> vehiculo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el vehículo ${vehiculo['ano']} ${vehiculo['marca']} ${vehiculo['modelo']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await InventarioService.eliminarVehiculo(
          vehiculo['id'].toString(),
        );

        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Vehículo eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            _cargarDatos();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'Error al eliminar vehículo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}