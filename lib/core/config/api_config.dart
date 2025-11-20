/// Configuración centralizada de URLs de la API
class ApiConfig {
  /// URL base del Google Apps Script para todos los servicios
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbxL63dTUizKlElvlre2-AbLmEqWQU2tpEzcLUy5jAv_BcssELoQGT3cFLEa5r4u0-2Y/exec';

  /// URLs específicas por servicio (mantienen la misma URL base por ahora)
  static const String usuariosUrl = baseUrl;
  static const String rolesUrl = baseUrl;
  static const String inventarioUrl = baseUrl;
  static const String gastosUrl = baseUrl;

  // Posibles configuraciones adicionales para el futuro
  static const int timeoutSeconds = 30;
  static const String apiVersion = 'v1';
}