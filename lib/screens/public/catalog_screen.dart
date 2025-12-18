import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/corporate_theme.dart';
import '../../services/sync_service.dart';
import 'vehicle_detail_screen.dart';
import '../login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _filteredVehicles = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Todos', 'Sedan', 'SUV', 'Pickup', 'Deportivo', 'Compacto'];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await SyncService.obtenerInventario();
      setState(() {
        _vehicles = vehicles.where((v) => 
          v['estado']?.toString().toLowerCase() == 'disponible'
        ).toList();
        _filteredVehicles = _vehicles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading vehicles: $e');
      setState(() {
        _isLoading = false;
        _vehicles = [];
        _filteredVehicles = [];
      });
    }
  }

  void _filterVehicles(String query) {
    setState(() {
      _filteredVehicles = _vehicles.where((vehicle) {
        final marca = vehicle['marca']?.toString().toLowerCase() ?? '';
        final modelo = vehicle['modelo']?.toString().toLowerCase() ?? '';
        final tipo = vehicle['tipo']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        
        final matchesSearch = marca.contains(searchLower) || 
                             modelo.contains(searchLower) ||
                             tipo.contains(searchLower);
        
        final matchesFilter = _selectedFilter == 'Todos' || 
                             tipo.toLowerCase() == _selectedFilter.toLowerCase();
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilters()),
          _isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            : _buildVehicleGrid(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Center(
            child: Image(
              image: AssetImage('assets/icono.jpg'),
              width: 130,
              height: 130,
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _showLoginDialog(),
          icon: const Icon(Icons.login, size: 18, color: CorporateTheme.textSecondary),
          label: const Text(
            'Acceso Interno',
            style: TextStyle(
              color: CorporateTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showLoginDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: CorporateTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acceso para Personal Interno',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CorporateTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta seccion es exclusiva para empleados y colaboradores de Autofirme',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CorporateTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Iniciar Sesion'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encuentra tu',
            style: TextStyle(
              fontSize: 16,
              color: CorporateTheme.textSecondary,
            ),
          ),
          const Text(
            'Auto Ideal',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredVehicles.length} vehiculos disponibles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterVehicles,
        decoration: InputDecoration(
          hintText: 'Buscar marca, modelo...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
              _filterVehicles(_searchController.text);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? CorporateTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? CorporateTheme.primaryBlue : Colors.grey[300]!,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : CorporateTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleGrid() {
    if (_filteredVehicles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No hay vehiculos disponibles',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildVehicleCard(_filteredVehicles[index]),
          childCount: _filteredVehicles.length,
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final marca = vehicle['marca'] ?? 'Sin marca';
    final modelo = vehicle['modelo'] ?? 'Sin modelo';
    final anio = vehicle['anio'] ?? vehicle['ano'] ?? '';
    final precio = vehicle['precio'] ?? vehicle['precioVenta'] ?? '0';
    final imagen = vehicle['imagen'] ?? vehicle['imagenes']?.toString().split(',').first ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imagen.toString().isNotEmpty && imagen.toString().startsWith('http')
                    ? Image.network(
                        imagen.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marca.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: CorporateTheme.textSecondary,
                          ),
                        ),
                        Text(
                          modelo.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CorporateTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (anio.toString().isNotEmpty)
                          Text(
                            anio.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '\$${_formatPrice(precio)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CorporateTheme.primaryBlue,
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

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  String _formatPrice(dynamic precio) {
    try {
      final number = double.parse(precio.toString().replaceAll(',', ''));
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return precio.toString();
    }
  }
}
