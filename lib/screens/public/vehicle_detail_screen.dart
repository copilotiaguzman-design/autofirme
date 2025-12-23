import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/corporate_theme.dart';
import '../../widgets/vehiculo_imagenes.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  /// Helper para convertir imagenesUrl a List<String>
  List<String> _obtenerImagenesComoLista() {
    final imagenesUrl = widget.vehicle['imagenesUrl'];
    if (imagenesUrl == null) return [];
    if (imagenesUrl is List) {
      return imagenesUrl.map((e) => e.toString()).toList();
    }
    if (imagenesUrl is String && imagenesUrl.isNotEmpty) {
      return [imagenesUrl];
    }
    return [];
  }

  List<String> get _images {
    // Primero intentar con imagenesUrl (formato nuevo)
    final imagenesUrlList = _obtenerImagenesComoLista();
    if (imagenesUrlList.isNotEmpty) return imagenesUrlList;
    
    // Fallback al formato antiguo
    final imagenes = widget.vehicle['imagenes']?.toString() ?? 
                     widget.vehicle['imagen']?.toString() ?? '';
    if (imagenes.isEmpty) return [];
    return imagenes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty && e.startsWith('http')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final marca = widget.vehicle['marca'] ?? 'Sin marca';
    final modelo = widget.vehicle['modelo'] ?? 'Sin modelo';
    final anio = widget.vehicle['anio'] ?? widget.vehicle['ano'] ?? '';
    final precio = widget.vehicle['precioSugerido'] ?? widget.vehicle['precio'] ?? widget.vehicle['precioVenta'] ?? 0;
    final color = widget.vehicle['color'] ?? '';
    final kilometraje = widget.vehicle['kilometraje'] ?? '';
    final transmision = widget.vehicle['transmision'] ?? '';
    final combustible = widget.vehicle['combustible'] ?? '';
    final motor = widget.vehicle['motor'] ?? '';
    final descripcion = widget.vehicle['descripcion'] ?? widget.vehicle['notas'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(marca.toString(), modelo.toString(), anio, precio),
                  const SizedBox(height: 24),
                  _buildSpecsSection(
                    color.toString(), 
                    kilometraje, 
                    transmision.toString(), 
                    combustible.toString(), 
                    motor.toString()
                  ),
                  if (descripcion.toString().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDescriptionSection(descripcion.toString()),
                  ],
                  const SizedBox(height: 32),
                  _buildContactInfo(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: CorporateTheme.primaryBlue,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareVehicle,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImageGallery(),
      ),
    );
  }

  Widget _buildImageGallery() {
    final imagenes = _obtenerImagenesComoLista();
    
    if (imagenes.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Sin imagen disponible',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Usar VehiculoImagenes para manejar URLs de Google Drive (incluyendo carpetas)
    return VehiculoImagenes(
      imagenesUrl: imagenes,
      height: 300,
      showControls: true,
    );
  }

  Widget _buildTitleSection(String marca, String modelo, dynamic anio, dynamic precio) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marca,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                modelo,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CorporateTheme.textPrimary,
                ),
              ),
              if (anio.toString().isNotEmpty)
                Text(
                  'Modelo $anio',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${_formatPrice(precio)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CorporateTheme.primaryBlue,
              ),
            ),
            Text('MXN', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecsSection(String color, dynamic km, String trans, String comb, String motor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CorporateTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (color.isNotEmpty)
              _buildSpecItem(Icons.palette_outlined, 'Color', color),
            if (km.toString().isNotEmpty && km.toString() != '0')
              _buildSpecItem(Icons.speed, 'Kilometraje', '${_formatPrice(km)} km'),
            if (trans.isNotEmpty)
              _buildSpecItem(Icons.settings, 'Transmision', trans),
            if (comb.isNotEmpty)
              _buildSpecItem(Icons.local_gas_station, 'Combustible', comb),
            if (motor.isNotEmpty)
              _buildSpecItem(Icons.engineering, 'Motor', motor),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CorporateTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: CorporateTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CorporateTheme.textPrimary,
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

  Widget _buildDescriptionSection(String descripcion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripcion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CorporateTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          descripcion,
          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: CorporateTheme.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Te interesa este vehiculo?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CorporateTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Contactanos para mas informacion, agendar una cita o realizar una prueba de manejo.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _contactWhatsApp,
                icon: const Icon(Icons.chat, size: 20),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _callPhone,
                icon: const Icon(Icons.phone, size: 20),
                label: const Text('Llamar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CorporateTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareVehicle() {
    final marca = widget.vehicle['marca'] ?? '';
    final modelo = widget.vehicle['modelo'] ?? '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartir: $marca $modelo'),
        backgroundColor: CorporateTheme.primaryBlue,
      ),
    );
  }

  void _contactWhatsApp() async {
    final marca = widget.vehicle['marca'] ?? '';
    final modelo = widget.vehicle['modelo'] ?? '';
    final mensaje = 'Hola, me interesa el $marca $modelo que vi en la app Autofirme';
    final url = 'https://wa.me/521XXXXXXXXXX?text=${Uri.encodeComponent(mensaje)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _callPhone() async {
    const url = 'tel:+521XXXXXXXXXX';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
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
