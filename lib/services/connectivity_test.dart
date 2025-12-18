import 'dart:io';
import 'package:http/http.dart' as http;

class ConnectivityTest {
  static Future<void> testConnectivity() async {
    print('🌐 === TEST DE CONECTIVIDAD ===');
    
    // Test 1: Resolución DNS
    try {
      List<InternetAddress> addresses = await InternetAddress.lookup('google.com');
      print('✅ DNS OK: ${addresses.first.address}');
    } catch (e) {
      print('❌ DNS FAIL: $e');
    }
    
    // Test 2: Conexión HTTP simple
    try {
      http.Response response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(const Duration(seconds: 10));
      print('✅ HTTP OK: Status ${response.statusCode}');
    } catch (e) {
      print('❌ HTTP FAIL: $e');
    }
    
    // Test 3: Google APIs específicamente
    try {
      http.Response response = await http.get(
        Uri.parse('https://firestore.googleapis.com'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(const Duration(seconds: 10));
      print('✅ Firestore API OK: Status ${response.statusCode}');
    } catch (e) {
      print('❌ Firestore API FAIL: $e');
    }
    
    // Test 4: Verificar certificados SSL
    try {
      HttpClient client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        print('⚠️ Bad certificate for $host:$port');
        return false;
      };
      
      HttpClientRequest request = await client.getUrl(Uri.parse('https://firestore.googleapis.com'));
      HttpClientResponse response = await request.close();
      print('✅ SSL OK: Status ${response.statusCode}');
      client.close();
    } catch (e) {
      print('❌ SSL FAIL: $e');
    }
    
    print('🌐 === FIN TEST CONECTIVIDAD ===');
  }
}