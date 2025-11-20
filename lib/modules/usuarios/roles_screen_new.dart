import 'package:flutter/material.dart';
import '../../core/exports.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  List<Map<String, dynamic>> roles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  Future<void> _cargarRoles() async {
    setState(() {
      isLoading = true;
    });

    // Simular carga de roles (en producción vendría de una API)
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      roles = [
        {
          'id': '1',
          'nombre': 'Administrador',
          'descripcion': 'Acceso completo a todas las funcionalidades del sistema',
          'permisos': [
            'Gestión de usuarios',
            'Gestión de roles', 
            'Módulo de recepción',
            'Módulo de inventario',
            'Configuración del sistema',
            'Reportes y estadísticas',
          ],
          'usuariosCount': 1,
          'activo': true,
          'colorValue': 0xFFC43532,
          'iconCode': Icons.admin_panel_settings.codePoint,
        },
        {
          'id': '2',
          'nombre': 'Recepción',
          'descripcion': 'Gestión de clientes y recepción de vehículos',
          'permisos': [
            'Módulo de recepción',
            'Gestión de clientes',
            'Registro de vehículos',
            'Consulta de servicios',
          ],
          'usuariosCount': 2,
          'activo': true,
          'colorValue': 0xFF1E3A8A,
          'iconCode': Icons.how_to_reg.codePoint,
        },
        {
          'id': '3',
          'nombre': 'Inventario',
          'descripcion': 'Control y gestión del inventario de partes y servicios',
          'permisos': [
            'Módulo de inventario',
            'Gestión de productos',
            'Control de stock',
            'Actualización de precios',
          ],
          'usuariosCount': 1,
          'activo': true,
          'colorValue': 0xFF3B82F6,
          'iconCode': Icons.inventory.codePoint,
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: CorporateTheme.spacingLG),
          _buildStatsCards(),
          const SizedBox(height: CorporateTheme.spacingLG),
          _buildRolesList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Roles',
              style: CorporateTheme.headingLarge,
            ),
            const SizedBox(height: CorporateTheme.spacingSM),
            Text(
              'Define permisos y accesos del sistema',
              style: CorporateTheme.bodyMedium,
            ),
          ],
        ),
        CorporateButton(
          text: 'Nuevo Rol',
          onPressed: _showAddRoleDialog,
          icon: Icons.add_moderator,
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    int rolesActivos = roles.where((r) => r['activo'] == true).length;
    int totalUsuarios = roles.fold(0, (sum, rol) => sum + (rol['usuariosCount'] as int));
    
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              _buildStatCard(
                title: 'Roles Activos',
                value: rolesActivos.toString(),
                icon: Icons.admin_panel_settings,
                color: CorporateTheme.primaryBlue,
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              _buildStatCard(
                title: 'Total Usuarios',
                value: totalUsuarios.toString(),
                icon: Icons.people,
                color: CorporateTheme.secondaryBlue,
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              _buildStatCard(
                title: 'Total Roles',
                value: roles.length.toString(),
                icon: Icons.security,
                color: CorporateTheme.accentRed,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Roles Activos',
                  value: rolesActivos.toString(),
                  icon: Icons.admin_panel_settings,
                  color: CorporateTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Usuarios',
                  value: totalUsuarios.toString(),
                  icon: Icons.people,
                  color: CorporateTheme.secondaryBlue,
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Roles',
                  value: roles.length.toString(),
                  icon: Icons.security,
                  color: CorporateTheme.accentRed,
                ),
              ),
            ],
          );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: CorporateTheme.cardRadius,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: CorporateTheme.iconSizeLarge),
              Text(
                value,
                style: CorporateTheme.headingLarge.copyWith(
                  color: color,
                  fontSize: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            title,
            style: CorporateTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: CorporateTheme.cardRadius,
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
            Container(
              padding: const EdgeInsets.all(CorporateTheme.spacingLG),
              decoration: BoxDecoration(
                color: CorporateTheme.backgroundLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: CorporateTheme.primaryBlue,
                    size: CorporateTheme.iconSizeMedium,
                  ),
                  const SizedBox(width: CorporateTheme.spacingMD),
                  Text(
                    'Lista de Roles',
                    style: CorporateTheme.headingSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : roles.isEmpty
                      ? _buildEmptyState()
                      : _buildRolesTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesTable() {
    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final rol = roles[index];
        return _buildRoleCard(rol, index);
      },
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> rol, int index) {
    final isActive = rol['activo'] as bool;
    final roleColor = Color(rol['colorValue'] as int);
    final permisos = rol['permisos'] as List<dynamic>;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: CorporateTheme.spacingMD,
        vertical: CorporateTheme.spacingSM,
      ),
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : CorporateTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? roleColor.withOpacity(0.3)
              : CorporateTheme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(rol['iconCode'] as int, fontFamily: 'MaterialIcons'),
                  color: roleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rol['nombre'],
                      style: CorporateTheme.headingSmall.copyWith(
                        color: roleColor,
                      ),
                    ),
                    const SizedBox(height: CorporateTheme.spacingXS),
                    Text(
                      rol['descripcion'],
                      style: CorporateTheme.bodyMedium.copyWith(
                        color: CorporateTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${rol['usuariosCount']} usuarios',
                      style: CorporateTheme.caption.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: CorporateTheme.spacingSM),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: CorporateTheme.primaryBlue,
                        ),
                        onPressed: () => _showEditRoleDialog(rol),
                        tooltip: 'Editar rol',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          size: 20,
                          color: CorporateTheme.secondaryBlue,
                        ),
                        onPressed: () => _showPermissionsDialog(rol),
                        tooltip: 'Ver permisos',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CorporateTheme.spacingMD),
          Text(
            'Permisos principales:',
            style: CorporateTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: CorporateTheme.textSecondary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Wrap(
            spacing: CorporateTheme.spacingSM,
            runSpacing: CorporateTheme.spacingSM,
            children: permisos.take(3).map<Widget>((permiso) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: roleColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  permiso.toString(),
                  style: CorporateTheme.caption.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          if (permisos.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: CorporateTheme.spacingSM),
              child: Text(
                '+${permisos.length - 3} más...',
                style: CorporateTheme.caption.copyWith(
                  color: CorporateTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: CorporateTheme.textSecondary,
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          Text(
            'No hay roles configurados',
            style: CorporateTheme.headingSmall.copyWith(
              color: CorporateTheme.textSecondary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            'Agrega el primer rol al sistema',
            style: CorporateTheme.bodyMedium,
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          CorporateButton(
            text: 'Crear Rol',
            onPressed: _showAddRoleDialog,
            icon: Icons.add_moderator,
          ),
        ],
      ),
    );
  }

  void _showAddRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Rol'),
        content: const Text('Funcionalidad de crear rol en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(Map<String, dynamic> rol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: ${rol['nombre']}'),
        content: const Text('Funcionalidad de editar rol en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(Map<String, dynamic> rol) {
    final permisos = rol['permisos'] as List<dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permisos: ${rol['nombre']}'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rol['descripcion'],
                style: CorporateTheme.bodyMedium.copyWith(
                  color: CorporateTheme.textSecondary,
                ),
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              Text(
                'Permisos asignados:',
                style: CorporateTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: CorporateTheme.spacingSM),
              ...permisos.map<Widget>((permiso) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: CorporateTheme.spacingSM),
                      Expanded(
                        child: Text(
                          permiso.toString(),
                          style: CorporateTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}