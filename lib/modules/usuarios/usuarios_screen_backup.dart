import 'package:flutter/material.dart';
import '../../core/exports.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      isLoading = true;
    });

    // Simular carga de usuarios (solo admin por ahora)
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      usuarios = [
        {
          'id': '1',
          'nombre': 'Administrador Sistema',
          'email': 'admin',
          'rol': 'Administrador',
          'activo': true,
          'fechaCreacion': '2025-01-01',
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
          _buildUsersList(),
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
              'Gestión de Usuarios',
              style: CorporateTheme.headingLarge,
            ),
            const SizedBox(height: CorporateTheme.spacingSM),
            Text(
              'Administra los usuarios del sistema',
              style: CorporateTheme.bodyMedium,
            ),
          ],
        ),
        CorporateButton(
          text: 'Nuevo Usuario',
          onPressed: _showAddUserDialog,
          icon: Icons.person_add,
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    int usuariosActivos = usuarios.where((u) => u['activo'] == true).length;
    int usuariosInactivos = usuarios.where((u) => u['activo'] == false).length;
    
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              _buildStatCard(
                title: 'Usuarios Activos',
                value: usuariosActivos.toString(),
                icon: Icons.person_outline,
                color: CorporateTheme.primaryBlue,
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              _buildStatCard(
                title: 'Usuarios Inactivos',
                value: usuariosInactivos.toString(),
                icon: Icons.person_off_outlined,
                color: CorporateTheme.accentRed,
              ),
              const SizedBox(height: CorporateTheme.spacingMD),
              _buildStatCard(
                title: 'Total Usuarios',
                value: usuarios.length.toString(),
                icon: Icons.people_outline,
                color: CorporateTheme.secondaryBlue,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Usuarios Activos',
                  value: usuariosActivos.toString(),
                  icon: Icons.person_outline,
                  color: CorporateTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: _buildStatCard(
                  title: 'Usuarios Inactivos',
                  value: usuariosInactivos.toString(),
                  icon: Icons.person_off_outlined,
                  color: CorporateTheme.accentRed,
                ),
              ),
              const SizedBox(width: CorporateTheme.spacingMD),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Usuarios',
                  value: usuarios.length.toString(),
                  icon: Icons.people_outline,
                  color: CorporateTheme.secondaryBlue,
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

  Widget _buildUsersList() {
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
                    Icons.people,
                    color: CorporateTheme.primaryBlue,
                    size: CorporateTheme.iconSizeMedium,
                  ),
                  const SizedBox(width: CorporateTheme.spacingMD),
                  Text(
                    'Lista de Usuarios',
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
                  : usuarios.isEmpty
                      ? _buildEmptyState()
                      : _buildUsersTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    return ListView.builder(
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        return _buildUserCard(usuario, index);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> usuario, int index) {
    final isActive = usuario['activo'] as bool;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: CorporateTheme.spacingMD,
        vertical: CorporateTheme.spacingSM,
      ),
      padding: const EdgeInsets.all(CorporateTheme.spacingMD),
      decoration: BoxDecoration(
        color: isActive 
            ? Colors.white 
            : CorporateTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? CorporateTheme.dividerColor 
              : CorporateTheme.accentRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(usuario['rol']),
            child: Text(
              usuario['nombre'].toString().substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: CorporateTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario['nombre'],
                  style: CorporateTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive 
                        ? CorporateTheme.textPrimary 
                        : CorporateTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: CorporateTheme.spacingXS),
                Text(
                  usuario['email'],
                  style: CorporateTheme.bodyMedium.copyWith(
                    color: isActive 
                        ? CorporateTheme.textSecondary 
                        : CorporateTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: CorporateTheme.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(usuario['rol']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    usuario['rol'],
                    style: CorporateTheme.caption.copyWith(
                      color: _getRoleColor(usuario['rol']),
                      fontWeight: FontWeight.w600,
                    ),
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
                  color: isActive 
                      ? Colors.green.withOpacity(0.1) 
                      : CorporateTheme.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Activo' : 'Inactivo',
                  style: CorporateTheme.caption.copyWith(
                    color: isActive ? Colors.green : CorporateTheme.accentRed,
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
                    onPressed: () => _showEditUserDialog(usuario),
                    tooltip: 'Editar usuario',
                  ),
                  IconButton(
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 20,
                      color: isActive ? CorporateTheme.accentRed : Colors.green,
                    ),
                    onPressed: () => _toggleUserStatus(index),
                    tooltip: isActive ? 'Desactivar usuario' : 'Activar usuario',
                  ),
                ],
              ),
            ],
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
            Icons.people_outline,
            size: 80,
            color: CorporateTheme.textSecondary,
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          Text(
            'No hay usuarios registrados',
            style: CorporateTheme.headingSmall.copyWith(
              color: CorporateTheme.textSecondary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            'Agrega el primer usuario al sistema',
            style: CorporateTheme.bodyMedium,
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          CorporateButton(
            text: 'Agregar Usuario',
            onPressed: _showAddUserDialog,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return CorporateTheme.accentRed;
      case 'recepción':
        return CorporateTheme.primaryBlue;
      case 'inventario':
        return CorporateTheme.secondaryBlue;
      default:
        return CorporateTheme.textSecondary;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Usuario'),
        content: const Text('Funcionalidad de agregar usuario en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar: ${usuario['nombre']}'),
        content: const Text('Funcionalidad de editar usuario en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(int index) {
    setState(() {
      usuarios[index]['activo'] = !usuarios[index]['activo'];
    });
    
    final usuario = usuarios[index];
    final mensaje = usuario['activo'] 
        ? 'Usuario ${usuario['nombre']} activado'
        : 'Usuario ${usuario['nombre']} desactivado';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: usuario['activo'] ? Colors.green : CorporateTheme.accentRed,
      ),
    );
  }
}