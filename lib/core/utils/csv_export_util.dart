import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class CsvExportUtil {
  /// Exporta una lista de datos a un archivo CSV y maneja la descarga o el share interactivo.
  /// [data] debe ser una lista de listas, donde la primera lista contiene las cabeceras.
  static Future<void> exportAndDownloadCSV({
    required List<List<dynamic>> data,
    required String fileName,
  }) async {
    try {
      // Usar punto y coma (;) como separador para compatibilidad con Excel en español
      String csvContent = const ListToCsvConverter(fieldDelimiter: ';').convert(data);

      // Agregar BOM (Byte Order Mark) para UTF-8, crucial para Excel y caracteres especiales
      final List<int> bytes = [0xEF, 0xBB, 0xBF] + utf8.encode(csvContent);

      if (kIsWeb) {
        // Implementación para Web
        final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.csv')
          ..click();
          
        html.Url.revokeObjectUrl(url);
      } else {
        // Implementación para Android/iOS
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName.csv';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        // Compartir o guardar el archivo
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Reporte CSV generado: $fileName',
        );
      }
    } catch (e) {
      debugPrint('Error al exportar CSV: $e');
      rethrow;
    }
  }
}
