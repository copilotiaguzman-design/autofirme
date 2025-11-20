import 'package:flutter/material.dart';
import '../../core/exports.dart';
import 'placas_screens.dart' as placas_screens;

class PlacasModule extends StatefulWidget {
  const PlacasModule({Key? key}) : super(key: key);

  @override
  State<PlacasModule> createState() => _PlacasModuleState();
}

class _PlacasModuleState extends State<PlacasModule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: 'Gestión de Placas',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CorporateTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: CorporateTheme.spacingXL),
            _buildModulesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CorporateTheme.primaryBlue,
            CorporateTheme.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CorporateTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: CorporateTheme.spacingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema de Placas Vehiculares',
                  style: CorporateTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestión completa de placas y documentación vehicular',
                  style: CorporateTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid() {
    final modules = [
      {
        'title': 'Generador de Placas',
        'subtitle': 'Crear y personalizar placas vehiculares',
        'icon': Icons.credit_card,
        'color': const Color(0xFF10B981),
        'onTap': () => _navigateToPlacasGenerator(),
      },
      {
        'title': 'Contratos de Compra-Venta',
        'subtitle': 'Generar contratos vehiculares',
        'icon': Icons.description,
        'color': const Color(0xFF3B82F6),
        'onTap': () => _navigateToCompraVenta(),
      },
      {
        'title': 'Historial',
        'subtitle': 'Ver placas y contratos generados',
        'icon': Icons.history,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _showComingSoon('Historial'),
      },
      {
        'title': 'Configuración',
        'subtitle': 'Ajustes del sistema de placas',
        'icon': Icons.settings,
        'color': const Color(0xFFF59E0B),
        'onTap': () => _showComingSoon('Configuración'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: CorporateTheme.spacingLG,
        mainAxisSpacing: CorporateTheme.spacingLG,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(
          title: module['title'] as String,
          subtitle: module['subtitle'] as String,
          icon: module['icon'] as IconData,
          color: module['color'] as Color,
          onTap: module['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(CorporateTheme.spacingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              Text(
                title,
                style: CorporateTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CorporateTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CorporateTheme.spacingSM),
              Text(
                subtitle,
                style: CorporateTheme.caption.copyWith(
                  color: CorporateTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPlacasGenerator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const placas_screens.PlacasScreen(),
      ),
    );
  }

  void _navigateToCompraVenta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const placas_screens.CompraVentaScreen(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature próximamente disponible'),
        backgroundColor: CorporateTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}