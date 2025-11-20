import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/roles_service.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  List<Map<String, dynamic>> roles = [];
  bool isLoading = false;
  final TextEditingController _rolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  @override
  void dispose() {
    _rolController.dispose();
    super.dispose();
  }

  Future<void> _cargarRoles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final rolesData = await RolesService.obtenerRoles();
      setState(() {
        roles = rolesData;
        isLoading = false;
      });
      print('✅ Roles cargados: ${roles.length}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error cargando roles: $e');
      _showErrorSnackBar('Error al cargar roles: $e');
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
              'Administra los roles del sistema desde Google Sheets',
              style: CorporateTheme.bodyMedium,
            ),
          ],
        ),
        Row(
          children: [
            CorporateButton(
              text: 'Actualizar',
              onPressed: _cargarRoles,
              icon: Icons.refresh,
              style: CorporateButtonStyle.secondary,
            ),
            const SizedBox(width: CorporateTheme.spacingMD),
            CorporateButton(
              text: 'Nuevo Rol',
              onPressed: _showAddRoleDialog,
              icon: Icons.security,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
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
                      Icons.security,
                      color: CorporateTheme.primaryBlue,
                      size: CorporateTheme.iconSizeLarge,
                    ),
                    const SizedBox(width: CorporateTheme.spacingMD),
                    Text(
                      roles.length.toString(),
                      style: CorporateTheme.headingLarge.copyWith(
                        color: CorporateTheme.primaryBlue,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: CorporateTheme.spacingSM),
                Text(
                  'Total de Roles',
                  style: CorporateTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Icon(
              Icons.cloud_done,
              color: Colors.green,
              size: CorporateTheme.iconSizeLarge,
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
                    Icons.list,
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
      padding: const EdgeInsets.all(CorporateTheme.spacingMD),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final rol = roles[index];
        return _buildRoleCard(rol);
      },
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> rol) {
    return Container(
      margin: const EdgeInsets.only(bottom: CorporateTheme.spacingSM),
      padding: const EdgeInsets.all(CorporateTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CorporateTheme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(rol['rol']),
            child: Text(
              rol['rol'].toString().substring(0, 1).toUpperCase(),
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
                  rol['rol'],
                  style: CorporateTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: CorporateTheme.spacingXS),
                Text(
                  'ID: ${rol['id']}',
                  style: CorporateTheme.caption.copyWith(
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Activo',
                  style: CorporateTheme.caption.copyWith(
                    color: Colors.green,
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
                      Icons.delete,
                      size: 20,
                      color: CorporateTheme.accentRed,
                    ),
                    onPressed: () => _showDeleteConfirmDialog(rol),
                    tooltip: 'Eliminar rol',
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
            Icons.security,
            size: 80,
            color: CorporateTheme.textSecondary,
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          Text(
            'No hay roles registrados',
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
            text: 'Agregar Rol',
            onPressed: _showAddRoleDialog,
            icon: Icons.security,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String nombre) {
    switch (nombre.toLowerCase()) {
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

  void _showAddRoleDialog() {
    _rolController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: CorporateTheme.primaryBlue,
            ),
            const SizedBox(width: CorporateTheme.spacingMD),
            const Text('Agregar Nuevo Rol'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CorporateInput(
              controller: _rolController,
              label: 'Nombre del Rol',
              hint: 'Ej: Supervisor, Técnico, etc.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CorporateButton(
            text: 'Guardar',
            onPressed: _agregarRol,
            style: CorporateButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _agregarRol() async {
    final nombreRol = _rolController.text.trim();
    
    if (nombreRol.isEmpty) {
      _showErrorSnackBar('Por favor ingresa un nombre para el rol');
      return;
    }

    Navigator.of(context).pop(); // Cerrar diálogo
    
    setState(() {
      isLoading = true;
    });

    try {
      final resultado = await RolesService.registrarRol(nombreRol);
      
      if (resultado['success'] == true) {
        _showSuccessSnackBar('Rol agregado exitosamente');
        await _cargarRoles(); // Recargar lista
      } else {
        _showErrorSnackBar(resultado['error'] ?? 'Error al agregar rol');
      }
    } catch (e) {
      _showErrorSnackBar('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: CorporateTheme.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostrar diálogo para editar rol
  void _showEditRoleDialog(Map<String, dynamic> rol) {
    _rolController.text = rol['rol'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.edit,
              color: CorporateTheme.primaryBlue,
            ),
            const SizedBox(width: CorporateTheme.spacingMD),
            const Text('Editar Rol'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CorporateInput(
              controller: _rolController,
              label: 'Nombre del Rol',
              hint: 'Ej: Supervisor, Técnico, etc.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CorporateButton(
            text: 'Guardar Cambios',
            onPressed: () => _editarRol(rol['id'].toString()),
            style: CorporateButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  /// Editar rol existente
  Future<void> _editarRol(String id) async {
    final nuevoNombre = _rolController.text.trim();
    
    if (nuevoNombre.isEmpty) {
      _showErrorSnackBar('Por favor ingresa un nombre para el rol');
      return;
    }

    Navigator.of(context).pop(); // Cerrar diálogo
    
    setState(() {
      isLoading = true;
    });

    try {
      final resultado = await RolesService.editarRol(id, nuevoNombre);
      
      if (resultado['success'] == true) {
        _showSuccessSnackBar('Rol editado exitosamente');
        await _cargarRoles(); // Recargar lista
      } else {
        _showErrorSnackBar(resultado['error'] ?? 'Error al editar rol');
      }
    } catch (e) {
      _showErrorSnackBar('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Mostrar diálogo de confirmación para eliminar
  void _showDeleteConfirmDialog(Map<String, dynamic> rol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: CorporateTheme.accentRed,
            ),
            const SizedBox(width: CorporateTheme.spacingMD),
            const Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar el rol "${rol['rol']}"?',
              style: CorporateTheme.bodyMedium,
            ),
            const SizedBox(height: CorporateTheme.spacingSM),
            Text(
              'Esta acción no se puede deshacer.',
              style: CorporateTheme.caption.copyWith(
                color: CorporateTheme.accentRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CorporateButton(
            text: 'Eliminar',
            onPressed: () => _eliminarRol(rol['id'].toString(), rol['rol']),
            style: CorporateButtonStyle.accent,
          ),
        ],
      ),
    );
  }

  /// Eliminar rol
  Future<void> _eliminarRol(String id, String nombre) async {
    Navigator.of(context).pop(); // Cerrar diálogo
    
    setState(() {
      isLoading = true;
    });

    try {
      final resultado = await RolesService.eliminarRol(id);
      
      if (resultado['success'] == true) {
        _showSuccessSnackBar('Rol "$nombre" eliminado exitosamente');
        await _cargarRoles(); // Recargar lista
      } else {
        _showErrorSnackBar(resultado['error'] ?? 'Error al eliminar rol');
      }
    } catch (e) {
      _showErrorSnackBar('Error de conexión: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}