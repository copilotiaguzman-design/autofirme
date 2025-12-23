import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para obtener imágenes desde Google Drive
class GoogleDriveService {
  static const String _logPrefix = 'GOOGLE_DRIVE';
  
  // API Key de Google (necesitarás configurar una en Google Cloud Console)
  // Para producción, considera usar variables de entorno
  static const String? _apiKey = null; // TODO: Configurar API Key
  
  /// Extrae el ID de una carpeta de Google Drive desde una URL
  static String? extraerFolderId(String url) {
    try {
      // Patrones de URL de Google Drive
      // https://drive.google.com/drive/folders/FOLDER_ID
      // https://drive.google.com/drive/folders/FOLDER_ID?usp=share_link
      // https://drive.google.com/drive/u/0/folders/FOLDER_ID
      
      final uri = Uri.tryParse(url);
      if (uri == null) return null;
      
      if (!uri.host.contains('drive.google.com')) return null;
      
      final pathSegments = uri.pathSegments;
      final foldersIndex = pathSegments.indexOf('folders');
      
      if (foldersIndex != -1 && foldersIndex + 1 < pathSegments.length) {
        return pathSegments[foldersIndex + 1];
      }
      
      return null;
    } catch (e) {
      print('ERROR [$_logPrefix] Error extrayendo folder ID: $e');
      return null;
    }
  }
  
  /// Extrae el ID de un archivo de Google Drive desde una URL
  static String? extraerFileId(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;
      
      if (!uri.host.contains('drive.google.com')) return null;
      
      // Patrón: /file/d/FILE_ID/view
      final pathSegments = uri.pathSegments;
      final fileIndex = pathSegments.indexOf('d');
      
      if (fileIndex != -1 && fileIndex + 1 < pathSegments.length) {
        return pathSegments[fileIndex + 1];
      }
      
      // Patrón: ?id=FILE_ID
      final id = uri.queryParameters['id'];
      if (id != null) return id;
      
      return null;
    } catch (e) {
      print('ERROR [$_logPrefix] Error extrayendo file ID: $e');
      return null;
    }
  }
  
  /// Verifica si una URL es de Google Drive
  static bool esUrlGoogleDrive(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.contains('drive.google.com');
  }
  
  /// Obtiene las imágenes de una carpeta de Google Drive
  /// Requiere que la carpeta esté compartida públicamente
  static Future<List<String>> obtenerImagenesDeCarpeta(String folderUrl) async {
    try {
      final folderId = extraerFolderId(folderUrl);
      if (folderId == null) {
        print('WARN [$_logPrefix] No se pudo extraer folder ID de: $folderUrl');
        return [];
      }
      
      print('INFO [$_logPrefix] Obteniendo imágenes de carpeta: $folderId');
      
      // Si no hay API Key, intentar método alternativo
      if (_apiKey == null) {
        return await _obtenerImagenesSinApiKey(folderId);
      }
      
      // Con API Key, usar la API de Google Drive
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files'
        '?q=\'$folderId\'+in+parents+and+mimeType+contains+\'image\''
        '&key=$_apiKey'
        '&fields=files(id,name,mimeType,thumbnailLink,webContentLink)'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = data['files'] as List<dynamic>? ?? [];
        
        return files.map<String>((file) {
          final fileId = file['id'] as String;
          // URL directa para ver la imagen
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }).toList();
      } else {
        print('ERROR [$_logPrefix] Error API: ${response.statusCode} - ${response.body}');
        return await _obtenerImagenesSinApiKey(folderId);
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Error obteniendo imágenes: $e');
      return [];
    }
  }
  
  /// Método alternativo sin API Key
  /// Genera URLs de vista previa basadas en el folder ID
  /// Las imágenes deben estar compartidas públicamente
  static Future<List<String>> _obtenerImagenesSinApiKey(String folderId) async {
    // Sin API Key, solo podemos devolver la URL de la carpeta
    // El usuario puede hacer clic para abrir en Google Drive
    print('INFO [$_logPrefix] Sin API Key, retornando URL de carpeta');
    return ['folder:$folderId'];
  }
  
  /// Convierte un ID de archivo de Google Drive a URL de imagen directa
  static String convertirAUrlDirecta(String fileId) {
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }
  
  /// Convierte un ID de archivo a URL de thumbnail
  static String convertirAUrlThumbnail(String fileId, {int width = 400}) {
    return 'https://drive.google.com/thumbnail?id=$fileId&sz=w$width';
  }
  
  /// Obtiene la URL de vista previa para una carpeta
  static String obtenerUrlVistaPrevia(String folderUrl) {
    final folderId = extraerFolderId(folderUrl);
    if (folderId == null) return folderUrl;
    
    // URL embebida de Google Drive
    return 'https://drive.google.com/embeddedfolderview?id=$folderId#grid';
  }
  
  /// Parsea una URL de imagen que puede ser de diferentes fuentes
  static ImagenInfo parsearUrlImagen(String? url) {
    if (url == null || url.isEmpty) {
      return ImagenInfo(tipo: TipoImagen.ninguna, url: '');
    }
    
    if (esUrlGoogleDrive(url)) {
      final folderId = extraerFolderId(url);
      if (folderId != null) {
        return ImagenInfo(
          tipo: TipoImagen.carpetaGoogleDrive,
          url: url,
          id: folderId,
          urlVistaPrevia: obtenerUrlVistaPrevia(url),
        );
      }
      
      final fileId = extraerFileId(url);
      if (fileId != null) {
        return ImagenInfo(
          tipo: TipoImagen.archivoGoogleDrive,
          url: url,
          id: fileId,
          urlDirecta: convertirAUrlDirecta(fileId),
          urlThumbnail: convertirAUrlThumbnail(fileId),
        );
      }
    }
    
    // URL directa de imagen
    if (url.contains('.jpg') || url.contains('.jpeg') || 
        url.contains('.png') || url.contains('.gif') ||
        url.contains('.webp')) {
      return ImagenInfo(
        tipo: TipoImagen.urlDirecta,
        url: url,
        urlDirecta: url,
      );
    }
    
    // URL genérica
    return ImagenInfo(
      tipo: TipoImagen.urlGenerica,
      url: url,
    );
  }
}

/// Tipos de imagen soportados
enum TipoImagen {
  ninguna,
  urlDirecta,
  urlGenerica,
  archivoGoogleDrive,
  carpetaGoogleDrive,
}

/// Información de una imagen
class ImagenInfo {
  final TipoImagen tipo;
  final String url;
  final String? id;
  final String? urlDirecta;
  final String? urlThumbnail;
  final String? urlVistaPrevia;
  
  ImagenInfo({
    required this.tipo,
    required this.url,
    this.id,
    this.urlDirecta,
    this.urlThumbnail,
    this.urlVistaPrevia,
  });
  
  bool get tieneImagen => tipo != TipoImagen.ninguna;
  bool get esGoogleDrive => tipo == TipoImagen.archivoGoogleDrive || tipo == TipoImagen.carpetaGoogleDrive;
  bool get esCarpeta => tipo == TipoImagen.carpetaGoogleDrive;
}
