import 'package:flutter/material.dart';
import '../../core/exports.dart';
import '../../services/usuarios_service.dart';
import '../../services/roles_service.dart';
import '../../services/auth_service.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final bool isEditing;

  const UsuarioFormScreen({
    Key? key,
    this.usuario,
  }) : isEditing = usuario != null, super(key: key);

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _imagenController = TextEditingController();
  
  List<Map<String, dynamic>> _roles = [];
  String? _selectedRol;
  bool _activo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _cargarRoles();
  }

  void _initializeForm() {
    if (widget.isEditing && widget.usuario != null) {
      _nombreController.text = widget.usuario!['nombre'] ?? '';
      _correoController.text = widget.usuario!['correo'] ?? '';
      _imagenController.text = widget.usuario!['imagen'] ?? '';
      _selectedRol = widget.usuario!['rol'];
      _activo = widget.usuario!['activo'] ?? true;
      
      // Validar que el rol seleccionado esté disponible para el usuario actual
      final authService = AuthService();
      final availableRoles = authService.getAssignableRoles();
      if (_selectedRol != null && !availableRoles.contains(_selectedRol)) {
        _selectedRol = null; // Reset si no está disponible
      }
    }
  }

  Future<void> _cargarRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await RolesService.obtenerRoles();
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar roles: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getAvailableRoles() {
    final authService = AuthService();
    final assignableRoles = authService.getAssignableRoles();
    
    return _roles.where((rol) {
      return assignableRoles.contains(rol['rol']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: widget.isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _guardarUsuario,
              child: Text(
                'GUARDAR',
                style: CorporateTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(CorporateTheme.spacingLG),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: CorporateTheme.spacingXL),
                  _buildFormSection(),
                  const SizedBox(height: CorporateTheme.spacingXL),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CorporateTheme.primaryBlue.withOpacity(0.1),
                  CorporateTheme.primaryBlue.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              widget.isEditing ? Icons.edit : Icons.person_add,
              size: 40,
              color: CorporateTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingMD),
          Text(
            widget.isEditing ? 'Modificar Usuario' : 'Agregar Nuevo Usuario',
            style: CorporateTheme.bodyLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            widget.isEditing 
              ? 'Actualiza la información del usuario'
              : 'Completa los datos para crear una nueva cuenta',
            style: CorporateTheme.bodyMedium.copyWith(
              color: CorporateTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Información Personal',
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Nombre completo
          CorporateInput(
            label: 'Nombre completo',
            hint: 'Ingresa el nombre completo',
            controller: _nombreController,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Correo electrónico
          CorporateInput(
            label: 'Correo electrónico',
            hint: 'ejemplo@autofirme.com',
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El correo es requerido';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Contraseña
          CorporateInput(
            label: widget.isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña',
            hint: widget.isEditing ? 'Dejar en blanco para mantener actual' : 'Ingresa una contraseña segura',
            controller: _contrasenaController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (!widget.isEditing && (value == null || value.isEmpty)) {
                return 'La contraseña es requerida';
              }
              if (value != null && value.isNotEmpty && value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Separador
          Container(
            width: double.infinity,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: CorporateTheme.spacingMD),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  CorporateTheme.dividerColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          const SizedBox(height: CorporateTheme.spacingMD),
          
          Text(
            'Configuración de Acceso',
            style: CorporateTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: CorporateTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Dropdown de roles
          _buildRoleDropdown(),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // URL de imagen
          CorporateInput(
            label: 'URL de imagen (opcional)',
            hint: 'https://ejemplo.com/avatar.jpg',
            controller: _imagenController,
            prefixIcon: Icons.image_outlined,
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          // Estado activo
          _buildActivoSwitch(),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    final availableRoles = _getAvailableRoles();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CorporateTheme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRol,
        decoration: const InputDecoration(
          labelText: 'Rol de usuario',
          prefixIcon: Icon(Icons.admin_panel_settings),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: availableRoles.map((rol) {
          return DropdownMenuItem<String>(
            value: rol['rol'],
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getRoleColor(rol['rol']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(rol['rol']),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRol = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Debes seleccionar un rol';
          }
          return null;
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Colors.red;
      case 'encargado':
        return Colors.blue;
      case 'vendedor':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActivoSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CorporateTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CorporateTheme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            _activo ? Icons.check_circle : Icons.cancel,
            color: _activo ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la cuenta',
                  style: CorporateTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _activo ? 'Usuario activo - Puede iniciar sesión' : 'Usuario inactivo - No puede iniciar sesión',
                  style: CorporateTheme.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: _activo,
            onChanged: (value) {
              setState(() {
                _activo = value;
              });
            },
            activeColor: CorporateTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: CorporateTheme.dividerColor),
            ),
          ),
        ),
        const SizedBox(width: CorporateTheme.spacingMD),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _guardarUsuario,
            icon: _isLoading 
              ? const SizedBox(
                  width: 16, 
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(widget.isEditing ? Icons.save : Icons.add),
            label: Text(widget.isEditing ? 'Actualizar' : 'Crear Usuario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CorporateTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nombre = _nombreController.text.trim();
      final correo = _correoController.text.trim();
      final contrasena = _contrasenaController.text.trim();
      final imagen = _imagenController.text.trim();

      Map<String, dynamic> result;

      if (widget.isEditing) {
        // Editar usuario existente
        result = await UsuariosService.editarUsuario(
          id: widget.usuario!['id'].toString(),
          nombre: nombre,
          correo: correo,
          contrasena: contrasena.isNotEmpty ? contrasena : null,
          rol: _selectedRol!,
          imagen: imagen.isNotEmpty ? imagen : null,
          activo: _activo,
        );
      } else {
        // Crear nuevo usuario
        result = await UsuariosService.registrarUsuario(
          nombre: nombre,
          correo: correo,
          contrasena: contrasena,
          rol: _selectedRol!,
          imagen: imagen.isNotEmpty ? imagen : null,
          activo: _activo,
        );
      }

      if (result['success'] == true) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing 
              ? '✅ Usuario actualizado exitosamente' 
              : '✅ Usuario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Retornar true para indicar cambios
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al guardar usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _imagenController.dispose();
    super.dispose();
  }
}