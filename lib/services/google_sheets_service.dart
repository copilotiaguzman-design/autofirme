import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  // URL de tu Google Apps Script Web App (VERSIÓN 5)
  static const String _scriptUrl = 'https://script.google.com/macros/s/AKfycbyiyYTI5kx391wReBki9RPLQBVHnGFbzaIf7kSICfpsghTWg1DRSYs5O0sXmHQf7LMcvQ/exec';
  
  static Future<bool> enviarCliente(Map<String, String> cliente) async {
    try {
      print('🚀 Enviando datos a Google Sheets...');
      print('📊 Datos: $cliente');
      
      // Construir URL con parámetros GET
      final uri = Uri.parse(_scriptUrl).replace(queryParameters: cliente);
      print('🌐 URL: $uri');
      
      final response = await http.get(uri);
      
      print('📨 Status Code: ${response.statusCode}');
      print('📝 Response Body (primeros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta es JSON válido
        if (response.body.trim().startsWith('{')) {
          final result = json.decode(response.body);
          print('✅ Resultado: $result');
          return result['success'] ?? false;
        } else {
          print('❌ Error: Respuesta no es JSON válido');
          return false;
        }
      }
      
      print('❌ Error: Status code ${response.statusCode}');
      return false;
    } catch (e) {
      print('💥 Error enviando a Google Sheets: $e');
      return false;
    }
  }

  // Método para obtener clientes desde Google Sheets
  static Future<List<Map<String, String>>> obtenerClientes() async {
    try {
      print('📥 Obteniendo clientes desde Google Sheets...');
      
      // Construir URL con parámetro action=obtener
      final uri = Uri.parse(_scriptUrl).replace(queryParameters: {'action': 'obtener'});
      print('🌐 URL: $uri');
      
      final response = await http.get(uri);
      
      print('📨 Status Code: ${response.statusCode}');
      print('📝 Response Body (primeros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          
          if (data['success'] == true) {
            print('✅ Datos obtenidos exitosamente');
            print('📊 Total de clientes: ${data['count']}');
            
            // Convertir los datos a List<Map<String, String>>
            List<Map<String, String>> clientes = [];
            for (var cliente in data['data']) {
              clientes.add({
                'timestamp': cliente['timestamp']?.toString() ?? '',
                'nombre': cliente['nombre']?.toString() ?? '',
                'telefono': cliente['telefono']?.toString() ?? '',
                'correo': cliente['correo']?.toString() ?? '',
                'vehiculo': cliente['vehiculo']?.toString() ?? '',
                'cumple': cliente['cumple']?.toString() ?? '',
                'comentarios': cliente['comentarios']?.toString() ?? '',
              });
            }
            
            return clientes;
          } else {
            print('⚠️ Error en la respuesta: ${data['error']}');
            return [];
          }
        } catch (e) {
          print('💥 Error parseando JSON: $e');
          return [];
        }
      }
      
      print('❌ Error: Status code ${response.statusCode}');
      return [];
    } catch (e) {
      print('💥 Error obteniendo clientes: $e');
      return [];
    }
  }
}