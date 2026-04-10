// lib/features/mantenimiento/data/services/multipart_photo_upload_service.dart
//
// El backend recibe las fotos via multipart y las sube a AWS S3.
// Flutter solo necesita enviar los archivos como MultipartFile.
//
// IMPORTANTE del backend (ProcesarMantenimiento):
//   for (int i = 0; i < historicos.Count; i++) {
//     var foto = dto.FotosHistorico[i];  ← accede por índice
//   }
// Por eso SIEMPRE debemos enviar exactamente N archivos en FotosHistorico,
// donde N = cantidad de ítems del histórico.
// Si un ítem no tiene foto → enviamos un archivo vacío (1x1 pixel PNG transparent).

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'photo_upload_service.dart';

// ─── PNG 1x1 transparente (placeholder cuando no hay foto) ───────────────────
// Esto asegura que FotosHistorico[i] siempre exista en el backend
final _emptyPng = Uint8List.fromList([
  0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A, // PNG signature
  0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52, // IHDR chunk
  0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01, // 1x1
  0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4, // 8-bit RGBA
  0x89,0x00,0x00,0x00,0x0B,0x49,0x44,0x41, // IDAT chunk
  0x54,0x78,0x9C,0x62,0x00,0x00,0x00,0x02,
  0x00,0x01,0xE2,0x21,0xBC,0x33,0x00,0x00,
  0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42, // IEND
  0x60,0x82,
]);

class MultipartPhotoUploadService implements IPhotoUploadService {
  bool _cancelled = false;

  @override
  PhotoUploadStrategy get strategy => PhotoUploadStrategy.multipart;

  @override
  void cancelAll() => _cancelled = true;

  @override
  Future<PhotoUploadResult> uploadPhoto(
      SelectedPhoto photo, String fieldName) async {
    return PhotoUploadResult.ok(photo.fileName);
  }

  @override
  Future<List<PhotoUploadResult>> uploadMultiplePhotos(
      List<SelectedPhoto?> photos, String fieldName) async {
    return photos
        .map((p) => PhotoUploadResult.ok(p?.fileName ?? ''))
        .toList();
  }

  // ─── Request completo para API16 ─────────────────────────────────────────
  Future<http.Response> buildAndSendRegistroRequest({
    required Map<String, String> bitacoraFields,
    required String              historicoJson,
    required Map<String, String> gastoFields,
    required List<SelectedPhoto?> fotosHistorico,
    required SelectedPhoto?       fotoGasto,
  }) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Sin token de autenticación');

    final url = Uri.parse(
        '${EnvironmentConfig.baseUrl}/api/general/registrar-mantenimiento');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = '*/*';

    // ── Bitácora ────────────────────────────────────────────────────────────
    bitacoraFields.forEach((k, v) => request.fields[k] = v);

    // ── HistoricoMantenimientosJson ─────────────────────────────────────────
    request.fields['HistoricoMantenimientosJson'] = historicoJson;

    // ── Gasto (con prefijo "Gasto.") ────────────────────────────────────────
    gastoFields.forEach((k, v) => request.fields['Gasto.$k'] = v);

    // ── FotosHistorico[] — SIEMPRE N archivos (uno por ítem) ────────────────
    // El backend hace dto.FotosHistorico[i], por lo que el índice debe coincidir.
    // Si no hay foto → enviamos PNG vacío para mantener el índice correcto.
    for (int i = 0; i < fotosHistorico.length; i++) {
      final foto = fotosHistorico[i];
      http.MultipartFile mf;

      if (foto != null) {
        final built = await _buildMultipartFile(foto, 'FotosHistorico');
        mf = built ?? _emptyMultipartFile('FotosHistorico', i);
      } else {
        mf = _emptyMultipartFile('FotosHistorico', i);
      }
      request.files.add(mf);
    }

    // ── Foto del gasto (campo "Gasto.gas_vlink_foto") ───────────────────────
    if (fotoGasto != null) {
      final mf = await _buildMultipartFile(fotoGasto, 'Gasto.gas_vlink_foto');
      if (mf != null) request.files.add(mf);
    }

    // ── Debug log ───────────────────────────────────────────────────────────
    _debugLog(request, historicoJson);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('══ API16 Response ══════════════════════════════════');
    print('Status: ${response.statusCode}');
    print('Body:   ${response.body}');
    print('════════════════════════════════════════════════════');

    return response;
  }

  // ── Construir MultipartFile desde SelectedPhoto ────────────────────────────
  Future<http.MultipartFile?> _buildMultipartFile(
      SelectedPhoto photo, String fieldName) async {
    try {
      if (photo.isWeb && photo.bytes != null) {
        return http.MultipartFile.fromBytes(
          fieldName,
          photo.bytes!,
          filename: photo.fileName,
        );
      }
      if (photo.filePath != null) {
        return await http.MultipartFile.fromPath(
          fieldName,
          photo.filePath!,
          filename: photo.fileName,
        );
      }
      return null;
    } catch (e) {
      print('❌ Error creando MultipartFile ($fieldName): $e');
      return null;
    }
  }

  // ── PNG vacío placeholder ─────────────────────────────────────────────────
  http.MultipartFile _emptyMultipartFile(String fieldName, int index) {
    return http.MultipartFile.fromBytes(
      fieldName,
      _emptyPng,
      filename: 'empty_$index.png',
    );
  }

  // ── Debug log detallado ───────────────────────────────────────────────────
  void _debugLog(http.MultipartRequest request, String historicoJson) {
    print('\n══ API16 Request ═══════════════════════════════════');
    print('URL: ${request.url}');
    print('── Fields ──────────────────────────────────────────');
    request.fields.forEach((k, v) {
      if (k == 'HistoricoMantenimientosJson') {
        print('  $k: [JSON - ${v.length} chars]');
        print('  JSON: $v');
      } else {
        print('  $k: $v');
      }
    });
    print('── Files (${request.files.length}) ─────────────────');
    for (final f in request.files) {
      print('  field="${f.field}" name="${f.filename}" '
            'length=${f.length}B');
    }
    print('════════════════════════════════════════════════════\n');
  }
}