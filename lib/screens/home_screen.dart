import 'package:flutter/material.dart';
import 'dart:async';
import '../modules/recepcion/recepcion_module.dart';
import '../modules/inventario/inventario_module.dart';
import '../modules/usuarios/usuarios_module.dart';
import '../modules/ventas/ventas_module.dart';
import '../modules/gastos/gastos_module.dart';
import '../services/google_sheets_service.dart';
import '../services/auth_service.dart';
import '../core/responsive_utils.dart';
import '../core/widgets/corporate_module_card.dart';
import '../core/theme/corporate_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Precargar datos en background para mejorar rendimiento
  Future<void> precargarDatos() async {
    try {
      print('🔄 Precargando datos en background...');
      await GoogleSheetsService.obtenerClientes();
    } catch (e) {
      print('⚠️ Error al precargar datos: $e');
      // No mostrar error al usuario, es precarga en background
    }
  }

  Future<void> _handleLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: CorporateTheme.accentRed,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (result == true) {
      final authService = AuthService();
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo corporativo limpio
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          width: 300,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.directions_car, 
              size: 40, 
              color: Colors.white
            );
          },
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: CorporateTheme.accentRed),
                    const SizedBox(width: 8),
                    const Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
        shadowColor: Colors.black26,
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header corporativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            color: Color(0xFF1E3A8A),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panel de Control',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 24),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sistema de Gestión AutoFirme',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF059669).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sistema Activo',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Título de sección
              Text(
                'Módulos del Sistema',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 20),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
                
              // Grid de módulos - diseño responsivo corporativo
              Expanded(
                child: GridView.count(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                  children: [
                    // Módulo de Recepción - Todos los roles
                    Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('recepcion');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Recepción',
                          subtitle: 'Gestión de clientes',
                          icon: Icons.people,
                          color: const Color(0xFF1E3A8A),
                          onTap: () {
                            // Navegar inmediatamente, sin esperar datos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecepcionModule(),
                              ),
                            );
                            // Precargar datos en background (opcional)
                            unawaited(precargarDatos());
                          },
                        );
                      },
                    ),
                    // Módulo de Inventario - Admin, Encargado e Inventario
                    Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('inventario');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Inventario',
                          subtitle: 'Control de stock',
                          icon: Icons.inventory_2,
                          color: const Color(0xFF3B82F6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InventarioModule(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Módulo de Ventas - Admin y Encargado
                    Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('ventas');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Ventas',
                          subtitle: 'Gestión de ventas',
                          icon: Icons.point_of_sale,
                          color: const Color(0xFF059669),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VentasModule(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Módulo de Usuarios - Admin y Encargado
                    Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('usuarios');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Usuarios',
                          subtitle: 'Gestión de usuarios y roles',
                          icon: Icons.admin_panel_settings,
                          color: const Color(0xFFC43532), // Rojo corporativo
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UsuariosModule(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Módulo de Gastos - Admin y Encargado
                    Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('gastos');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Gastos',
                          subtitle: 'Control de gastos',
                          icon: Icons.receipt_long,
                          color: const Color(0xFFDC2626),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GastosModule(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Módulo de Placas - Solo para Administradores
                   /*  Builder(
                      builder: (context) {
                        final authService = AuthService();
                        final hasAccess = authService.hasAccessTo('placas');
                        
                        if (!hasAccess) return const SizedBox.shrink();
                        
                        return CorporateModuleCard(
                          title: 'Placas',
                          subtitle: 'Sistema de placas vehiculares',
                          icon: Icons.directions_car,
                          color: const Color(0xFF7C3AED),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlacasModule(),
                              ),
                            );
                          },
                        );
                      },
                    ), */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}