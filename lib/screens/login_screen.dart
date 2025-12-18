import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/exports.dart';
import 'migration_screen.dart';
import 'firestore_test_screen.dart';
import 'manual_migration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(CorporateTheme.spacingLG),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildLoginCard(context),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.isMobile(context) ? double.infinity : 400,
      ),
      padding: const EdgeInsets.all(CorporateTheme.spacingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: CorporateTheme.primaryBlue.withOpacity(0.05),
            blurRadius: 64,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: CorporateTheme.spacingXL),
            _buildTitle(),
            const SizedBox(height: CorporateTheme.spacingXL),
            _buildEmailField(),
            const SizedBox(height: CorporateTheme.spacingLG),
            _buildPasswordField(),
            const SizedBox(height: CorporateTheme.spacingMD),
            _buildRememberMe(),
            const SizedBox(height: CorporateTheme.spacingXL),
            _buildLoginButton(),
            const SizedBox(height: CorporateTheme.spacingLG),
            _buildCredentialsHelp(),
            const SizedBox(height: CorporateTheme.spacingMD),
            _buildMigrationButton(),
            _buildFirestoreTestButton(),
            _buildManualTestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: CorporateTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: CorporateTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: CorporateTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.business,
                size: 60,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Iniciar Sesión',
          style: CorporateTheme.headingLarge.copyWith(
            color: CorporateTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: CorporateTheme.spacingSM),
        Text(
          'Accede a tu cuenta corporativa',
          style: CorporateTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CorporateInput(
      label: 'Correo electrónico',
      hint: 'ejemplo@autofirme.com',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El correo es requerido';
        }
        // Validar formato de email
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CorporateInput(
      label: 'Contraseña',
      hint: 'Ingresa tu contraseña',
      controller: _passwordController,
      obscureText: _obscurePassword,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
      onSuffixIconPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'La contraseña es requerida';
        }
        // Permitir "admin" como contraseña especial
        if (value.trim() == 'admin') {
          return null;
        }
        // Para otras contraseñas, mínimo 6 caracteres
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: CorporateTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: CorporateTheme.spacingSM),
        Expanded(
          child: Text(
            'Recordar mi sesión',
            style: CorporateTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return CorporateButton(
      text: _isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión',
      onPressed: _isLoading ? null : _handleLogin,
      isLoading: _isLoading,
      width: double.infinity,
      icon: Icons.login,
    );
  }

  Widget _buildCredentialsHelp() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingMD),
      decoration: BoxDecoration(
        color: CorporateTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CorporateTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: CorporateTheme.primaryBlue,
              ),
              const SizedBox(width: CorporateTheme.spacingSM),
              Text(
                'Información de acceso:',
                style: CorporateTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: CorporateTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            'Para acceder al sistema, utiliza las credenciales de usuario que te han sido asignadas por el administrador.',
            style: CorporateTheme.caption,
          ),
          const SizedBox(height: CorporateTheme.spacingSM),
          Text(
            'Si no tienes credenciales de acceso, contacta al administrador del sistema.',
            style: CorporateTheme.caption.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );

      if (result.success) {
        if (mounted) {
          // Navegación exitosa al home
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error desconocido'),
              backgroundColor: CorporateTheme.accentRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: CorporateTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMigrationButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MigrationScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.cloud_sync,
        size: 16,
        color: Colors.grey.shade600,
      ),
      label: Text(
        'Migración Firebase (Dev)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFirestoreTestButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FirestoreTestScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.storage,
        size: 16,
        color: Colors.grey.shade600,
      ),
      label: Text(
        'Test Firestore (Dev)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildManualTestButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ManualMigrationScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.science,
        size: 16,
        color: Colors.red.shade600,
      ),
      label: Text(
        'Test Manual (Dev)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade600,
        ),
      ),
    );
  }
}