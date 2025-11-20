import 'package:flutter/material.dart';
import '../../core/exports.dart';
import 'usuarios_screen.dart';
import 'roles_screen.dart';

class UsuariosModule extends StatefulWidget {
  const UsuariosModule({super.key});

  @override
  State<UsuariosModule> createState() => _UsuariosModuleState();
}

class _UsuariosModuleState extends State<UsuariosModule> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Obtener la instancia del AuthService
    final authService = AuthService();
    
    // Debug: Mostrar información del usuario actual
    print('🔍 Usuario actual: ${authService.userEmail}, Rol: ${authService.getUserRole()}');
    
    // Verificar permisos (admin y encargado pueden acceder)
    final userRole = authService.getUserRole();
    if (userRole != UserRole.admin && userRole != UserRole.recepcion) {
      return _buildAccessDenied();
    }

    // Determinar si mostrar pestaña de roles (solo admin)
    final showRoles = userRole == UserRole.admin;
    final tabTitle = showRoles 
        ? (_currentIndex == 0 ? 'Gestión de Usuarios' : 'Gestión de Roles')
        : 'Gestión de Usuarios';

    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: tabTitle,
      ),
      body: _getBodyWidget(showRoles),
      bottomNavigationBar: showRoles ? _buildBottomNavigation() : null,
    );
  }

  Widget _getBodyWidget(bool showRoles) {
    if (!showRoles) {
      // Si no se muestran roles, siempre mostrar usuarios
      return const UsuariosScreen();
    }
    
    // Si se muestran roles, usar el índice actual
    return _currentIndex == 0 ? const UsuariosScreen() : const RolesScreen();
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: CorporateTheme.primaryBlue,
        unselectedItemColor: CorporateTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Roles',
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: 'Acceso Denegado',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: CorporateTheme.accentRed,
            ),
            const SizedBox(height: CorporateTheme.spacingLG),
            Text(
              'Acceso Denegado',
              style: CorporateTheme.headingMedium.copyWith(
                color: CorporateTheme.accentRed,
              ),
            ),
            const SizedBox(height: CorporateTheme.spacingMD),
            Text(
              'Solo los administradores y encargados pueden acceder\na la gestión de usuarios',
              style: CorporateTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CorporateTheme.spacingXL),
            CorporateButton(
              text: 'Volver al Inicio',
              onPressed: () => Navigator.of(context).pop(),
              style: CorporateButtonStyle.secondary,
              icon: Icons.home,
            ),
          ],
        ),
      ),
    );
  }
}