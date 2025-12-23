import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para importar y exportar datos del inventario
class ImportExportService {
  static const String _logPrefix = 'IMPORT_EXPORT';

  /// Columnas requeridas para la importación (solo las esenciales)
  static const List<String> columnasRequeridas = [
    'ano',
    'marca',
    'modelo',
    'vin',
  ];

  /// Columnas opcionales para la importación (se pueden llenar después en la app)
  static const List<String> columnasOpcionales = [
    'color',
    'motor',
    'traccion',
    'version',
    'comercializadora',
    'costo',
    'gastos',
    'precioSugerido',
    'estado',
    'imagenesUrl',
  ];

  /// Todas las columnas disponibles
  static List<String> get todasLasColumnas => [...columnasRequeridas, ...columnasOpcionales];

  /// Genera una plantilla CSV para importación
  static String generarPlantillaCSV() {
    final headers = todasLasColumnas;
    final ejemploFila = [
      '2024',           // ano
      'Toyota',         // marca
      'Corolla',        // modelo
      'ABC123456',      // vin
      'Blanco',         // color
      '2.0L',           // motor
      'FWD',            // traccion
      'XLE',            // version
      'AutoFirme',      // comercializadora
      '15000',          // costo (opcional)
      '1500',           // gastos (opcional)
      '18000',          // precioSugerido (opcional)
      'Disponible',     // estado (opcional)
      'https://drive.google.com/drive/folders/XXXXXXX', // imagenesUrl - URL de carpeta con imágenes (opcional)
    ];
    
    final csvData = [headers, ejemploFila];
    return const ListToCsvConverter().convert(csvData);
  }

  /// Descarga la plantilla CSV usando Share Plus
  static Future<void> descargarPlantillaCSV() async {
    try {
      final csvContent = generarPlantillaCSV();
      final bytes = utf8.encode(csvContent);
      
      if (kIsWeb) {
        // En web, usar descarga HTML
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..download = 'plantilla_inventario.csv'
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        print('INFO [$_logPrefix] Plantilla CSV descargada (web)');
      } else {
        // En móvil, usar Share Plus para compartir el archivo
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/plantilla_inventario.csv');
        await file.writeAsBytes(bytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Plantilla para importar vehículos al inventario',
          subject: 'Plantilla Inventario CSV',
        );
        
        print('INFO [$_logPrefix] Plantilla CSV compartida');
      }
    } catch (e) {
      print('ERROR [$_logPrefix] Error al compartir plantilla: $e');
      rethrow;
    }
  }

  /// Importa vehículos desde un archivo CSV o Excel
  static Future<ImportResult> importarDesdeArchivo() async {
    try {
      print('INFO [$_logPrefix] Iniciando importación de archivo...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
        withData: true, // Importante para web
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          mensaje: 'No se seleccionó ningún archivo',
          vehiculos: [],
          errores: [],
        );
      }

      final file = result.files.first;
      final extension = file.extension?.toLowerCase() ?? '';
      
      print('INFO [$_logPrefix] Archivo seleccionado: ${file.name} ($extension)');

      List<List<dynamic>> rows;

      if (extension == 'csv') {
        // Procesar CSV
        String content;
        if (kIsWeb) {
          content = utf8.decode(file.bytes!);
        } else {
          final fileObj = File(file.path!);
          content = await fileObj.readAsString();
        }
        rows = const CsvToListConverter().convert(content, eol: '\n');
      } else if (extension == 'xlsx' || extension == 'xls') {
        // Para Excel, necesitamos la librería excel
        return ImportResult(
          success: false,
          mensaje: 'Para importar archivos Excel (.xlsx, .xls), por favor conviértelos a CSV primero.\n\nPuedes abrir el archivo en Excel y guardarlo como "CSV UTF-8 (delimitado por comas)".',
          vehiculos: [],
          errores: [],
        );
      } else {
        return ImportResult(
          success: false,
          mensaje: 'Formato de archivo no soportado. Use CSV.',
          vehiculos: [],
          errores: [],
        );
      }

      // Validar que hay datos
      if (rows.isEmpty) {
        return ImportResult(
          success: false,
          mensaje: 'El archivo está vacío',
          vehiculos: [],
          errores: [],
        );
      }

      // Procesar encabezados
      final headers = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      print('INFO [$_logPrefix] Encabezados encontrados: $headers');

      // Validar columnas requeridas
      final columnasNoEncontradas = <String>[];
      for (var columna in columnasRequeridas) {
        if (!headers.contains(columna.toLowerCase())) {
          columnasNoEncontradas.add(columna);
        }
      }

      if (columnasNoEncontradas.isNotEmpty) {
        return ImportResult(
          success: false,
          mensaje: 'Faltan columnas requeridas: ${columnasNoEncontradas.join(", ")}\n\nDescargue la plantilla para ver el formato correcto.',
          vehiculos: [],
          errores: [],
        );
      }

      // Mapear índices de columnas
      final columnIndices = <String, int>{};
      for (var i = 0; i < headers.length; i++) {
        columnIndices[headers[i]] = i;
      }

      // Procesar filas de datos (excluyendo encabezados)
      final vehiculos = <Map<String, dynamic>>[];
      final errores = <String>[];

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        // Saltar filas vacías
        if (row.every((cell) => cell.toString().trim().isEmpty)) {
          continue;
        }

        try {
          final vehiculo = _procesarFila(row, columnIndices, i + 1);
          
          // Validar datos obligatorios
          final erroresValidacion = _validarVehiculo(vehiculo, i + 1);
          if (erroresValidacion.isNotEmpty) {
            errores.addAll(erroresValidacion);
          } else {
            vehiculos.add(vehiculo);
          }
        } catch (e) {
          errores.add('Fila ${i + 1}: Error al procesar - $e');
        }
      }

      print('INFO [$_logPrefix] Vehículos procesados: ${vehiculos.length}, Errores: ${errores.length}');

      return ImportResult(
        success: vehiculos.isNotEmpty,
        mensaje: vehiculos.isNotEmpty 
          ? 'Se encontraron ${vehiculos.length} vehículos válidos para importar'
          : 'No se encontraron vehículos válidos para importar',
        vehiculos: vehiculos,
        errores: errores,
      );
    } catch (e) {
      print('ERROR [$_logPrefix] Error en importación: $e');
      return ImportResult(
        success: false,
        mensaje: 'Error al procesar el archivo: $e',
        vehiculos: [],
        errores: [],
      );
    }
  }

  /// Procesa una fila del CSV y la convierte en un mapa de vehículo
  static Map<String, dynamic> _procesarFila(List<dynamic> row, Map<String, int> columnIndices, int numeroFila) {
    String getCellValue(String columnName) {
      final index = columnIndices[columnName.toLowerCase()];
      if (index == null || index >= row.length) return '';
      return row[index].toString().trim();
    }

    double getCellDouble(String columnName) {
      final value = getCellValue(columnName);
      if (value.isEmpty) return 0.0;
      
      // Limpiar formato de moneda mexicana: $389,000.00
      String cleaned = value
          .replaceAll('\$', '')     // Quitar símbolo $
          .replaceAll(' ', '')      // Quitar espacios
          .trim();
      
      // Si tiene coma Y punto, la coma es separador de miles (formato: 389,000.00)
      if (cleaned.contains(',') && cleaned.contains('.')) {
        cleaned = cleaned.replaceAll(',', ''); // Solo quitar comas (miles)
      } 
      // Si solo tiene coma, puede ser separador decimal (formato europeo: 389000,00)
      else if (cleaned.contains(',') && !cleaned.contains('.')) {
        cleaned = cleaned.replaceAll(',', '.');
      }
      
      return double.tryParse(cleaned) ?? 0.0;
    }

    return {
      'ano': getCellValue('ano'),
      'marca': getCellValue('marca'),
      'modelo': getCellValue('modelo'),
      'vin': getCellValue('vin'),
      'color': getCellValue('color'),
      'motor': getCellValue('motor'),
      'traccion': getCellValue('traccion'),
      'version': getCellValue('version'),
      'comercializadora': getCellValue('comercializadora'),
      'costo': getCellDouble('costo'),
      'gastos': getCellDouble('gastos'),
      'precioSugerido': getCellDouble('preciosugerido'),
      'estado': getCellValue('estado').isNotEmpty ? getCellValue('estado') : 'Disponible',
      'imagenesUrl': getCellValue('imagenesurl'),
    };
  }

  /// Valida que el vehículo tenga los campos esenciales
  static List<String> _validarVehiculo(Map<String, dynamic> vehiculo, int numeroFila) {
    final errores = <String>[];

    // Solo validar campos realmente esenciales
    if (vehiculo['ano']?.toString().isEmpty ?? true) {
      errores.add('Fila $numeroFila: El año es requerido');
    } else {
      final ano = int.tryParse(vehiculo['ano'].toString());
      if (ano == null || ano < 1900 || ano > DateTime.now().year + 1) {
        errores.add('Fila $numeroFila: Año inválido (${vehiculo['ano']})');
      }
    }

    if (vehiculo['marca']?.toString().isEmpty ?? true) {
      errores.add('Fila $numeroFila: La marca es requerida');
    }

    if (vehiculo['modelo']?.toString().isEmpty ?? true) {
      errores.add('Fila $numeroFila: El modelo es requerido');
    }

    if (vehiculo['vin']?.toString().isEmpty ?? true) {
      errores.add('Fila $numeroFila: El VIN es requerido');
    } else {
      final vin = vehiculo['vin'].toString();
      if (vin.length < 3) {
        errores.add('Fila $numeroFila: El VIN debe tener al menos 3 caracteres');
      }
    }

    // Validar estado si está presente (pero no es requerido)
    final estado = vehiculo['estado']?.toString() ?? '';
    if (estado.isNotEmpty) {
      final estadosValidos = ['Disponible', 'Reservado', 'Vendido', 'En Reparación', 'En Tránsito'];
      if (!estadosValidos.contains(estado)) {
        errores.add('Fila $numeroFila: Estado inválido ($estado). Use: ${estadosValidos.join(", ")}');
      }
    }

    return errores;
  }

  /// Exporta el inventario actual a CSV
  static Future<void> exportarInventarioCSV(List<Map<String, dynamic>> vehiculos) async {
    try {
      final headers = [
        'ID',
        'Fecha Recibido',
        'Año',
        'Marca',
        'Modelo',
        'VIN',
        'Color',
        'Motor',
        'Tracción',
        'Versión',
        'Comercializadora',
        'Costo',
        'Gastos',
        'Precio Sugerido',
        'Total',
        'Estado',
        'Días en Inventario',
        'Imágenes URL',
      ];

      final rows = <List<dynamic>>[headers];

      for (var vehiculo in vehiculos) {
        rows.add([
          vehiculo['id'] ?? '',
          vehiculo['fechaRecibido'] ?? '',
          vehiculo['ano'] ?? '',
          vehiculo['marca'] ?? '',
          vehiculo['modelo'] ?? '',
          vehiculo['vinCompleto'] ?? vehiculo['vin'] ?? '',
          vehiculo['color'] ?? '',
          vehiculo['motor'] ?? '',
          vehiculo['traccion'] ?? '',
          vehiculo['version'] ?? '',
          vehiculo['comercializadora'] ?? '',
          vehiculo['costo'] ?? 0,
          vehiculo['gastos'] ?? 0,
          vehiculo['precioSugerido'] ?? 0,
          vehiculo['total'] ?? 0,
          vehiculo['estado'] ?? 'Disponible',
          vehiculo['diasInventario'] ?? 0,
          vehiculo['imagenesUrl'] ?? vehiculo['imagen'] ?? '',
        ]);
      }

      final csvContent = const ListToCsvConverter().convert(rows);
      final fileName = 'inventario_${DateTime.now().toIso8601String().split('T')[0]}.csv';
      final bytes = utf8.encode(csvContent);

      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..download = fileName
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // En móvil, usar Share Plus para compartir el archivo
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Exportación del inventario de vehículos',
          subject: 'Inventario AutoFirme',
        );
        
        print('INFO [$_logPrefix] Inventario compartido');
      }

      print('INFO [$_logPrefix] Inventario exportado: ${vehiculos.length} vehículos');
    } catch (e) {
      print('ERROR [$_logPrefix] Error al exportar: $e');
      rethrow;
    }
  }
}

/// Resultado de una operación de importación
class ImportResult {
  final bool success;
  final String mensaje;
  final List<Map<String, dynamic>> vehiculos;
  final List<String> errores;

  ImportResult({
    required this.success,
    required this.mensaje,
    required this.vehiculos,
    required this.errores,
  });
}
