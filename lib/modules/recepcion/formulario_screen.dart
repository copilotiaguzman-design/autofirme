import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../services/google_sheets_service.dart';
import '../../core/exports.dart';

// Validadores corporativos
class CorporateValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido (ej: usuario@dominio.com)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    // Remover espacios y caracteres especiales para validar solo números
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 10) {
      return 'Ingresa un teléfono válido de 10 dígitos';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La fecha de cumpleaños es requerida';
    }
    
    final dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return 'Formato: DD/MM/AAAA (ej: 15/03/1990)';
    }
    
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        return 'La fecha no puede ser futura';
      }
      
      if (year < 1900 || year > now.year) {
        return 'Año inválido';
      }
      
      if (month < 1 || month > 12) {
        return 'Mes inválido';
      }
      
      if (day < 1 || day > 31) {
        return 'Día inválido';
      }
      
    } catch (e) {
      return 'Fecha inválida';
    }
    
    return null;
  }
}

// Formatters para campos específicos
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length <= 10) {
      String formatted = '';
      for (int i = 0; i < text.length; i++) {
        if (i == 3 || i == 6) {
          formatted += ' ';
        }
        formatted += text[i];
      }
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length <= 8) {
      String formatted = '';
      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 4) {
          formatted += '/';
        }
        formatted += text[i];
      }
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}

class FormularioScreen extends StatefulWidget {
  final Function(Map<String, String>) onClienteAgregado;

  const FormularioScreen({super.key, required this.onClienteAgregado});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _vehiculoController = TextEditingController();
  final TextEditingController _cumpleController = TextEditingController();
  final TextEditingController _comentariosController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _vehiculoController.dispose();
    _cumpleController.dispose();
    _comentariosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CorporateTheme.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con icono
                Container(
                  padding: const EdgeInsets.all(CorporateTheme.spacingLG),
                  decoration: BoxDecoration(
                    gradient: CorporateTheme.primaryGradient,
                    borderRadius: CorporateTheme.cardRadius,
                    boxShadow: CorporateTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(CorporateTheme.spacingMD),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: CorporateTheme.iconSizeXLarge,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: CorporateTheme.spacingMD),
                      Text(
                        'Registro de Cliente',
                        style: CorporateTheme.headingMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: CorporateTheme.spacingSM),
                      Text(
                        'Complete los siguientes datos para registrar un nuevo cliente',
                        style: CorporateTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: CorporateTheme.spacingXL),
                
                // Campos del formulario
                _buildFormCard(),
                
                const SizedBox(height: CorporateTheme.spacingXL),
                
                // Botón de envío
                CorporateButton(
                  text: _isLoading ? 'Guardando...' : 'Registrar Cliente',
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading ? null : Icons.save,
                  isLoading: _isLoading,
                  width: double.infinity,
                  style: CorporateButtonStyle.primary,
                ),
                
                const SizedBox(height: CorporateTheme.spacingMD),
                
                // Botón de limpiar
                CorporateButton(
                  text: 'Limpiar Formulario',
                  onPressed: _isLoading ? null : _clearForm,
                  icon: Icons.clear_all,
                  width: double.infinity,
                  style: CorporateButtonStyle.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(CorporateTheme.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: CorporateTheme.cardRadius,
        boxShadow: CorporateTheme.cardShadow,
      ),
      child: Column(
        children: [
          CorporateInput(
            label: 'Nombre completo',
            hint: 'Ingrese el nombre completo del cliente',
            controller: _nombreController,
            prefixIcon: Icons.person,
            validator: (value) => CorporateValidators.validateRequired(value, 'El nombre'),
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Teléfono',
            hint: '123 456 7890',
            controller: _telefonoController,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: CorporateValidators.validatePhone,
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Correo electrónico',
            hint: 'cliente@ejemplo.com',
            controller: _correoController,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: CorporateValidators.validateEmail,
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Vehículo de interés',
            hint: 'Marca y modelo del vehículo',
            controller: _vehiculoController,
            prefixIcon: Icons.directions_car,
            validator: (value) => CorporateValidators.validateRequired(value, 'El vehículo de interés'),
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Fecha de cumpleaños',
            hint: 'DD/MM/AAAA',
            controller: _cumpleController,
            prefixIcon: Icons.cake,
            keyboardType: TextInputType.datetime,
            validator: CorporateValidators.validateDate,
          ),
          
          const SizedBox(height: CorporateTheme.spacingLG),
          
          CorporateInput(
            label: 'Comentarios adicionales',
            hint: 'Notas o comentarios sobre el cliente (opcional)',
            controller: _comentariosController,
            prefixIcon: Icons.comment,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Convertir fecha al formato ISO
        String fechaISO = '';
        if (_cumpleController.text.isNotEmpty) {
          final parts = _cumpleController.text.split('/');
          final day = parts[0];
          final month = parts[1];
          final year = parts[2];
          fechaISO = '$year-$month-$day';
        }

        // Crear cliente
        final cliente = {
          'nombre': _nombreController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'correo': _correoController.text.trim(),
          'vehiculo': _vehiculoController.text.trim(),
          'cumple': fechaISO,
          'comentarios': _comentariosController.text.trim(),
        };

        // Agregar a Google Sheets
        await GoogleSheetsService.enviarCliente(cliente);
        
        // Notificar al módulo padre
        widget.onClienteAgregado(cliente);

        if (mounted) {
          _showSuccessDialog();
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error al registrar cliente: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _telefonoController.clear();
    _correoController.clear();
    _vehiculoController.clear();
    _cumpleController.clear();
    _comentariosController.clear();
    
    // Limpiar validaciones
    _formKey.currentState?.reset();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: CorporateTheme.cardRadius,
        ),
        icon: Container(
          padding: const EdgeInsets.all(CorporateTheme.spacingMD),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: CorporateTheme.iconSizeXLarge,
          ),
        ),
        title: Text(
          '¡Cliente registrado!',
          style: CorporateTheme.headingSmall.copyWith(
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'El cliente ha sido registrado exitosamente en el sistema.',
          style: CorporateTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          CorporateButton(
            text: 'Continuar',
            onPressed: () => Navigator.of(context).pop(),
            style: CorporateButtonStyle.primary,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: CorporateTheme.cardRadius,
        ),
        icon: Container(
          padding: const EdgeInsets.all(CorporateTheme.spacingMD),
          decoration: BoxDecoration(
            color: CorporateTheme.accentRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.error,
            color: CorporateTheme.accentRed,
            size: CorporateTheme.iconSizeXLarge,
          ),
        ),
        title: Text(
          'Error',
          style: CorporateTheme.headingSmall.copyWith(
            color: CorporateTheme.accentRed,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: CorporateTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          CorporateButton(
            text: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            style: CorporateButtonStyle.accent,
          ),
        ],
      ),
    );
  }
}