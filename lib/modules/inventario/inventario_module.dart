import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/inventario_service.dart';
import '../../services/sync_service.dart';
import '../../services/gastos_calculados_service.dart';
import '../../services/auth_service.dart';
import '../../services/import_export_service.dart';
import '../../widgets/vehiculo_imagenes.dart';
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

  /// Convierte el campo imagenesUrl (que puede ser String o List) a List<String>
  List<String> _obtenerImagenesComoLista(Map<String, dynamic> vehiculo) {
    final imagenes = vehiculo['imagenesUrl'];
    if (imagenes == null) return [];
    if (imagenes is List) {
      return imagenes.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (imagenes is String && imagenes.isNotEmpty) {
      // Si es string, puede tener múltiples URLs separadas por comas o saltos de línea
      return imagenes.split(RegExp(r'[,\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
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
      // Solo cargar de Firestore
      final vehiculos = await SyncService.obtenerInventario();
      
      // Calcular estadísticas localmente (no ir a Sheets)
      final estadisticas = _calcularEstadisticasLocales(vehiculos);
      
      // Obtener marcas localmente (no ir a Sheets)
      final marcas = _obtenerMarcasLocales(vehiculos);
      
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
    return 2; // Móvil 2 columnas
  }

  double get galeriaAspectRatio {
    if (isDesktop) return 1.2;
    if (isTablet) return 1.0;
    return 0.75; // Móvil: tarjetas más cuadradas
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

  // Calcular estadísticas localmente desde los datos de Firestore
  Map<String, dynamic> _calcularEstadisticasLocales(List<Map<String, dynamic>> vehiculos) {
    int disponibles = 0;
    int vendidos = 0;
    int reservados = 0;
    int enReparacion = 0;
    int enTransito = 0;
    double valorTotal = 0;
    int totalDias = 0;

    for (var v in vehiculos) {
      final estado = v['estado']?.toString() ?? 'Disponible';
      switch (estado) {
        case 'Disponible':
          disponibles++;
          break;
        case 'Vendido':
          vendidos++;
          break;
        case 'Reservado':
          reservados++;
          break;
        case 'En Reparación':
          enReparacion++;
          break;
        case 'En Tránsito':
          enTransito++;
          break;
      }
      valorTotal += double.tryParse(v['precioSugerido']?.toString() ?? '0') ?? 0;
      totalDias += int.tryParse(v['diasInventario']?.toString() ?? '0') ?? 0;
    }

    return {
      'totalVehiculos': vehiculos.length,
      'disponibles': disponibles,
      'vendidos': vendidos,
      'reservados': reservados,
      'enReparacion': enReparacion,
      'enTransito': enTransito,
      'valorTotal': valorTotal,
      'promedioInventario': vehiculos.isEmpty ? 0 : (totalDias / vehiculos.length).round(),
    };
  }

  // Obtener marcas únicas localmente
  List<String> _obtenerMarcasLocales(List<Map<String, dynamic>> vehiculos) {
    final marcasSet = <String>{};
    for (var v in vehiculos) {
      final marca = v['marca']?.toString() ?? '';
      if (marca.isNotEmpty) {
        marcasSet.add(marca);
      }
    }
    final marcas = marcasSet.toList()..sort();
    return marcas;
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
          // Botón de menú de importación/exportación
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Más opciones',
            onSelected: (value) async {
              switch (value) {
                case 'importar':
                  await _importarDesdeArchivo();
                  break;
                case 'exportar':
                  await _exportarInventario();
                  break;
                case 'plantilla':
                  await _descargarPlantilla();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'importar',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Importar CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'exportar',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Exportar CSV'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'plantilla',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Descargar Plantilla'),
                  ],
                ),
              ),
            ],
          ),
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
                    SizedBox(height: 12),
                    _buildFiltrosSection(),
                    SizedBox(height: 8),
                    _vistaTabla ? _buildVehiculosTabla() : _buildVehiculosGaleria(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarVehiculo,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: CorporateTheme.primaryBlue,
        elevation: 2,
      ),
    );
  }

  Widget _buildEstadisticasCard() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CorporateTheme.dividerColor.withOpacity(0.5)),
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
                'Total',
                _estadisticas['totalVehiculos']?.toString() ?? '0',
                Icons.directions_car_rounded,
                CorporateTheme.primaryBlue,
              ),
              _buildEstadisticaItem(
                'Disponibles',
                _estadisticas['disponibles']?.toString() ?? '0',
                Icons.check_circle_outline_rounded,
                Color(0xFF10B981),
              ),
              _buildEstadisticaItem(
                'Vendidos',
                _estadisticas['vendidos']?.toString() ?? '0',
                Icons.sell_rounded,
                Color(0xFFF59E0B),
              ),
              _buildEstadisticaItem(
                'Prom. Días',
                _estadisticas['promedioInventario']?.toString() ?? '0',
                Icons.schedule_rounded,
                Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  titulo,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosSection() {
    if (isMobile) {
      // Layout vertical para móvil
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CorporateTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Campo de búsqueda
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade600),
                  suffixIcon: _textoBusqueda.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.close, size: 16, color: CorporateTheme.textSecondary),
                        onPressed: () => _searchController.clear(),
                        padding: EdgeInsets.zero,
                      )
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: TextStyle(fontSize: 13, color: CorporateTheme.textPrimary),
              ),
            ),
            SizedBox(height: 8),
            // Filtros en fila
            Row(
              children: [
                Expanded(
                  child: _buildFiltroDropdown('Estado', _filtroEstado, 
                    ['Todos', ...InventarioService.obtenerEstadosDisponibles()], 
                    (value) => setState(() => _filtroEstado = value ?? 'Todos')),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildFiltroDropdown('Marca', _filtroMarca, _marcas, 
                    (value) => setState(() => _filtroMarca = value ?? 'Todas')),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _filtroEstado = 'Todos';
                        _filtroMarca = 'Todas';
                        _searchController.clear();
                      });
                    },
                    icon: Icon(Icons.refresh, size: 18, color: CorporateTheme.textSecondary),
                    tooltip: 'Limpiar filtros',
                    constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Layout horizontal para tablet/desktop
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CorporateTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icono
          Icon(
            Icons.search_rounded,
            color: CorporateTheme.textSecondary,
            size: 20,
          ),
          SizedBox(width: 10),
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
                              icon: Icon(Icons.close, size: 16, color: CorporateTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CorporateTheme.primaryBlue, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(fontSize: 13, color: CorporateTheme.textPrimary),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildFiltroDropdown('Estado', _filtroEstado, 
                    ['Todos', ...InventarioService.obtenerEstadosDisponibles()], 
                    (value) => setState(() => _filtroEstado = value ?? 'Todos')),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildFiltroDropdown('Marca', _filtroMarca, _marcas, 
                    (value) => setState(() => _filtroMarca = value ?? 'Todas')),
                ),
                SizedBox(width: 6),
                // Botón de limpiar filtros
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _filtroEstado = 'Todos';
                        _filtroMarca = 'Todas';
                        _searchController.clear();
                      });
                    },
                    icon: Icon(Icons.refresh, size: 18, color: CorporateTheme.textSecondary),
                    tooltip: 'Limpiar filtros',
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: CorporateTheme.textSecondary),
          style: TextStyle(fontSize: 12, color: CorporateTheme.textPrimary),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
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
        border: Border.all(color: CorporateTheme.dividerColor.withOpacity(0.5)),
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
    final tieneImagenes = vehiculo['imagenesUrl']?.toString().isNotEmpty == true;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsivePadding, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CorporateTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editarVehiculo(vehiculo),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con título y estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen o icono de vehículo
                    tieneImagenes
                        ? VehiculoImagenMiniatura(
                            imagenesUrl: _obtenerImagenesComoLista(vehiculo),
                            size: 50,
                          )
                        : Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CorporateTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: CorporateTheme.primaryBlue,
                              size: 22,
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CorporateTheme.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${vehiculo['color'] ?? 'N/A'} • ${vehiculo['motor'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: CorporateTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Estado
                    _buildEstadoChip(_getEstadoNormalizado(vehiculo)),
                  ],
                ),
                SizedBox(height: 12),
                // Información secundaria
                Row(
                  children: [
                    _buildInfoChip(vehiculo['vin']?.toString() ?? 'N/A', Icons.tag),
                    SizedBox(width: 8),
                    _buildInfoChip('${vehiculo['diasInventario'] ?? 0} días', Icons.schedule),
                    Spacer(),
                    // Precios (solo para admin)
                    if (_canViewFinancialInfo) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${(vehiculo['total']?.toDouble() ?? 0).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getEstadoColor(estado).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: _getEstadoColor(estado),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CorporateTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: CorporateTheme.textSecondary),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: CorporateTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    final tieneImagenes = vehiculo['imagenesUrl']?.toString().isNotEmpty == true;
    
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
            // Miniatura de imagen
            SizedBox(
              width: 45,
              child: tieneImagenes
                  ? VehiculoImagenMiniatura(
                      imagenesUrl: _obtenerImagenesComoLista(vehiculo),
                      size: 40,
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
            SizedBox(width: 12),
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
    final tieneImagenes = vehiculo['imagenesUrl']?.toString().isNotEmpty == true;
    
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del vehículo
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: tieneImagenes
                          ? VehiculoImagenes(
                              imagenesUrl: _obtenerImagenesComoLista(vehiculo),
                              height: constraints.maxHeight,
                              showControls: false,
                              allowFullscreen: false,
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.directions_car,
                                size: isMobile ? 32 : 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            // Información del vehículo
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(responsivePadding * 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${vehiculo['ano']} ${vehiculo['marca']}',
                            style: CorporateTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 11 : 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4, 
                            vertical: 2
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(_getEstadoNormalizado(vehiculo)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getEstadoNormalizado(vehiculo),
                            style: CorporateTheme.caption.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehiculo['modelo'] ?? '',
                      style: CorporateTheme.caption.copyWith(
                        color: CorporateTheme.textSecondary,
                        fontSize: isMobile ? 10 : 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${vehiculo['color']} • ${vehiculo['version'] ?? 'N/A'}',
                      style: CorporateTheme.caption.copyWith(
                        color: CorporateTheme.textSecondary,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (_canViewFinancialInfo)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '\$${(vehiculo['precioSugerido'] ?? 0).toStringAsFixed(0)}',
                          style: CorporateTheme.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
        // Usar SyncService para eliminar (Firestore + sincronizar con Sheets)
        await SyncService.eliminarVehiculo(vehiculo['docId']?.toString() ?? vehiculo['id'].toString());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Vehículo eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _cargarDatos();
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

  /// Importar vehículos desde archivo CSV
  Future<void> _importarDesdeArchivo() async {
    try {
      final result = await ImportExportService.importarDesdeArchivo();
      
      if (!mounted) return;

      if (!result.success && result.vehiculos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.mensaje),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Mostrar diálogo de confirmación con preview
      final confirmed = await _mostrarDialogoImportacion(result);
      
      if (confirmed == true && mounted) {
        await _procesarImportacion(result.vehiculos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al importar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Muestra diálogo de confirmación para la importación
  Future<bool?> _mostrarDialogoImportacion(ImportResult result) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, color: CorporateTheme.primaryBlue),
            const SizedBox(width: 12),
            const Text('Confirmar Importación'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      '${result.vehiculos.length} vehículos listos para importar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              if (result.errores.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            '${result.errores.length} errores encontrados:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: result.errores.length > 5 ? 5 : result.errores.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• ${result.errores[index]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (result.errores.length > 5)
                        Text(
                          '... y ${result.errores.length - 5} errores más',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              const Text(
                'Vista previa de vehículos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: result.vehiculos.length > 5 ? 5 : result.vehiculos.length,
                  itemBuilder: (context, index) {
                    final v = result.vehiculos[index];
                    return Card(
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.directions_car, size: 20),
                        title: Text(
                          '${v['ano']} ${v['marca']} ${v['modelo']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          'VIN: ${v['vin']} • ${v['color']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (result.vehiculos.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... y ${result.vehiculos.length - 5} vehículos más',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.upload, size: 18),
            label: Text('Importar ${result.vehiculos.length} vehículos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CorporateTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Procesa la importación de vehículos
  Future<void> _procesarImportacion(List<Map<String, dynamic>> vehiculos) async {
    setState(() => _isLoading = true);
    
    int exitosos = 0;
    int fallidos = 0;
    final authService = AuthService();
    final userEmail = authService.userEmail;
    
    for (var vehiculo in vehiculos) {
      try {
        // Agregar información del usuario
        vehiculo['nombreUsuario'] = 'Importación CSV';
        vehiculo['correoUsuario'] = userEmail;
        
        await SyncService.agregarVehiculo(vehiculo);
        exitosos++;
      } catch (e) {
        print('Error al importar vehículo: $e');
        fallidos++;
      }
    }
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fallidos == 0 
              ? '✅ Se importaron $exitosos vehículos exitosamente'
              : '⚠️ Importados: $exitosos, Fallidos: $fallidos',
          ),
          backgroundColor: fallidos == 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Recargar datos
      _cargarDatos();
    }
  }

  /// Exportar inventario a CSV
  Future<void> _exportarInventario() async {
    try {
      if (_vehiculos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay vehículos para exportar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await ImportExportService.exportarInventarioCSV(_vehiculos);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Se exportaron ${_vehiculos.length} vehículos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Descargar plantilla CSV
  Future<void> _descargarPlantilla() async {
    try {
      await ImportExportService.descargarPlantillaCSV();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Plantilla descargada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar plantilla: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}