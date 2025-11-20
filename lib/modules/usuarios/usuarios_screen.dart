import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/usuarios_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar usuarios
      final usuarios = await UsuariosService.obtenerUsuarios();

      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
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
          _buildStatsCard(),
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
              'Administra los usuarios del sistema desde Google Sheets',
              style: CorporateTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            CorporateButton(
              text: 'Actualizar',
              onPressed: _cargarDatos,
              icon: Icons.refresh,
              style: CorporateButtonStyle.secondary,
            ),
            const SizedBox(width: CorporateTheme.spacingMD),
            CorporateButton(
              text: 'Nuevo Usuario',
              onPressed: _showAddUsuarioDialog,
              icon: Icons.person_add,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    int usuariosActivos = _usuarios.where((u) => u['activo'] == true).length;
    int usuariosInactivos = _usuarios.where((u) => u['activo'] == false).length;
    
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: CorporateTheme.primaryBlue,
                      size: CorporateTheme.iconSizeLarge,
                    ),
                    const SizedBox(width: CorporateTheme.spacingMD),
                    Text(
                      'Total de Usuarios',
                      style: CorporateTheme.headingSmall,
                    ),
                  ],
                ),
                const SizedBox(height: CorporateTheme.spacingMD),
                Row(
                  children: [
                    _buildStatItem(
                      'Total',
                      _usuarios.length.toString(),
                      CorporateTheme.primaryBlue,
                    ),
                    const SizedBox(width: CorporateTheme.spacingLG),
                    _buildStatItem(
                      'Activos',
                      usuariosActivos.toString(),
                      Colors.green,
                    ),
                    const SizedBox(width: CorporateTheme.spacingLG),
                    _buildStatItem(
                      'Inactivos',
                      usuariosInactivos.toString(),
                      CorporateTheme.accentRed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: CorporateTheme.headingLarge.copyWith(
            color: color,
            fontSize: 28,
          ),
        ),
        Text(
          label,
          style: CorporateTheme.caption.copyWith(
            color: CorporateTheme.textSecondary,
          ),
        ),
      ],
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
                    'Lista de Usuarios (${_usuarios.length})',
                    style: CorporateTheme.headingSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : _usuarios.isEmpty
                          ? _buildEmptyState()
                          : _buildUsersTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: CorporateTheme.accentRed,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 16,
              color: CorporateTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CorporateButton(
            text: 'Reintentar',
            onPressed: _cargarDatos,
            icon: Icons.refresh,
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
            onPressed: _showAddUsuarioDialog,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.all(CorporateTheme.spacingMD),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return _buildUsuarioCard(usuario, index);
        },
      ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> usuario, int index) {
    final isActive = usuario['activo'] == true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              CorporateTheme.secondaryBlue.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _getRoleColor(usuario['rol']),
              radius: 25,
              child: Text(
                (usuario['nombre'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CorporateTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario['correo'] ?? 'Sin correo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(usuario['rol']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usuario['rol'] ?? 'Sin rol',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getRoleColor(usuario['rol']),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Acciones
            Column(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _handleEditUser(usuario);
                        break;
                      case 'toggle':
                        _toggleUsuarioStatus(index);
                        break;
                      case 'delete':
                        _showDeleteUsuarioDialog(usuario);
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    final authService = AuthService();
                    final canDelete = authService.canDeleteUsers();
                    final userRole = authService.getUserRole();
                    final targetUserRole = usuario['rol']?.toString().toLowerCase() ?? '';
                    
                    // Verificar si puede editar este usuario específico
                    final canEdit = userRole == UserRole.admin || 
                                  (userRole == UserRole.recepcion && targetUserRole != 'administrador');
                    
                    List<PopupMenuEntry<String>> menuItems = [];
                    
                    // Solo mostrar opción de editar si tiene permisos
                    if (canEdit) {
                      menuItems.add(
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Editar'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                      
                      menuItems.add(
                        PopupMenuItem(
                          value: 'toggle',
                          child: ListTile(
                            leading: Icon(isActive ? Icons.block : Icons.check_circle),
                            title: Text(isActive ? 'Desactivar' : 'Activar'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    }
                    
                    // Solo mostrar opción de eliminar si el usuario tiene permisos
                    if (canDelete) {
                      menuItems.add(
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    }
                    
                    // Si no hay opciones disponibles, mostrar mensaje informativo
                    if (menuItems.isEmpty) {
                      menuItems.add(
                        const PopupMenuItem(
                          enabled: false,
                          child: ListTile(
                            leading: Icon(Icons.lock, color: Colors.grey),
                            title: Text(
                              'Sin permisos',
                              style: TextStyle(color: Colors.grey),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    }
                    
                    return menuItems;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String? rol) {
    switch (rol?.toLowerCase()) {
      case 'administrador':
        return CorporateTheme.accentRed;
      case 'recepción':
      case 'recepcion':
        return CorporateTheme.primaryBlue;
      case 'inventario':
        return CorporateTheme.secondaryBlue;
      default:
        return CorporateTheme.textSecondary;
    }
  }

  void _toggleUsuarioStatus(int index) {
    final usuario = _usuarios[index];
    final authService = AuthService();
    final userRole = authService.getUserRole();
    final targetUserRole = usuario['rol']?.toString().toLowerCase() ?? '';
    
    // Verificar permisos: encargado no puede modificar administradores
    if (userRole == UserRole.recepcion && targetUserRole == 'administrador') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 No tienes permisos para modificar el estado de usuarios administradores'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final nuevoEstado = !(usuario['activo'] == true);
    
    _editarUsuario(
      usuario['id'].toString(),
      activo: nuevoEstado,
    );
  }

  void _showAddUsuarioDialog() {
    _showUsuarioDialog();
  }

  void _showEditUsuarioDialog(Map<String, dynamic> usuario) {
    _showUsuarioDialog(usuario: usuario);
  }

  void _showDeleteUsuarioDialog(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${usuario['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarUsuario(usuario['id'].toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CorporateTheme.accentRed,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUsuarioDialog({Map<String, dynamic>? usuario}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioFormScreen(usuario: usuario),
      ),
    );
    
    // Si el resultado es true, significa que se guardaron cambios
    if (result == true) {
      _cargarDatos(); // Recargar la lista de usuarios
    }
  }

  Future<void> _editarUsuario(
    String id, {
    String? nombre,
    String? correo,
    String? contrasena,
    String? rol,
    String? imagen,
    bool? activo,
  }) async {
    try {
      final result = await UsuariosService.editarUsuario(
        id: id,
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        rol: rol,
        imagen: imagen,
        activo: activo,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al actualizar usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarUsuario(String id) async {
    try {
      final result = await UsuariosService.eliminarUsuario(id);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarDatos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Manejar la edición de un usuario con validaciones de permisos
  void _handleEditUser(Map<String, dynamic> usuario) {
    final authService = AuthService();
    final userRole = authService.getUserRole();
    final targetUserRole = usuario['rol']?.toString() ?? '';
    
    // Si el usuario actual es encargado y trata de editar un administrador
    if (userRole == UserRole.recepcion && targetUserRole.toLowerCase() == 'administrador') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 No tienes permisos para editar usuarios administradores'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Si todo está bien, mostrar el diálogo de edición
    _showEditUsuarioDialog(usuario);
  }

  /// Obtener roles disponibles según permisos del usuario actual
}