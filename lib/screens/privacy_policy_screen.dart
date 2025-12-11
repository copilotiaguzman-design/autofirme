import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/corporate_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas de Privacidad'),
        backgroundColor: CorporateTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CorporateTheme.primaryBlue,
              CorporateTheme.backgroundLight,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header con logo
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: CorporateTheme.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Autofirme',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sistema Interno de Gestión Vehicular',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: const PrivacyPolicyContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Información General',
          'Autofirme es la aplicación oficial de uso interno para el personal de la empresa Autofirme, dedicada a la venta y gestión de vehículos. Esta app permite a los colaboradores administrar procesos internos de manera eficiente.',
        ),
        _buildSection(
          'Uso Interno Exclusivo',
          'Esta aplicación está destinada exclusivamente al personal autorizado de Autofirme. El acceso está restringido a empleados y colaboradores con credenciales válidas.',
        ),
        _buildListSection(
          'Información que Recopilamos',
          [
            'Correo electrónico corporativo',
            'Contraseñas encriptadas',
            'Información de vehículos gestionados',
            'Registros de transacciones y ventas',
            'Reportes y documentos generados',
          ],
        ),
        _buildListSection(
          'Cómo Usamos la Información',
          [
            'Autenticación y autorización de usuarios',
            'Procesamiento de transacciones comerciales',
            'Generación de reportes y análisis',
            'Mantenimiento de registros empresariales',
            'Optimización de procesos internos',
          ],
        ),
        _buildListSection(
          'Seguridad de los Datos',
          [
            'Encriptación de datos sensibles',
            'Conexiones seguras (HTTPS/SSL)',
            'Acceso restringido por roles y permisos',
            'Respaldos regulares de información',
            'Auditorías regulares de seguridad',
          ],
        ),
        _buildSection(
          'Compartición de Información',
          'La información se comparte únicamente entre personal autorizado de Autofirme con acceso basado en roles y necesidad operacional. No compartimos información con terceros externos sin consentimiento explícito.',
        ),
        _buildListSection(
          'Derechos de los Usuarios',
          [
            'Derecho a acceder a sus datos personales',
            'Solicitar corrección de información inexacta',
            'Actualización de datos de perfil',
          ],
        ),
        _buildContactSection(),
        _buildVersionSection(),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: CorporateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: CorporateTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: CorporateTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: CorporateTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CorporateTheme.dividerColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Si tiene preguntas sobre esta Política de Privacidad:',
            style: TextStyle(
              fontSize: 14,
              color: CorporateTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Email: privacidad@autofirme.com\n• Departamento: Administración y Recursos Humanos',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: CorporateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Fecha de vigencia: 10 de diciembre de 2025',
            style: TextStyle(
              fontSize: 12,
              color: CorporateTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Versión 1.0',
            style: TextStyle(
              fontSize: 12,
              color: CorporateTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}