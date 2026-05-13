// lib/features/mantenimiento/data/services/multipart_photo_upload_service.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';
import 'photo_upload_service.dart';

final _emptyPng = Uint8List.fromList([
  0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,
  0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
  0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
  0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
  0x89,0x00,0x00,0x00,0x0B,0x49,0x44,0x41,
  0x54,0x78,0x9C,0x62,0x00,0x00,0x00,0x02,
  0x00,0x01,0xE2,0x21,0xBC,0x33,0x00,0x00,
  0x00,0x00,0x49,0x45,0x4E,0x44,0xAE,0x42,
  0x60,0x82,
]);

class MultipartPhotoUploadService implements IPhotoUploadService {
  bool _cancelled = false;

  @override
  PhotoUploadStrategy get strategy => PhotoUploadStrategy.multipart;

  @override
  void cancelAll() => _cancelled = true;

  @override
  Future<PhotoUploadResult> uploadPhoto(SelectedPhoto photo, String fieldName) async {
    return PhotoUploadResult.ok(photo.fileName);
  }

  @override
  Future<List<PhotoUploadResult>> uploadMultiplePhotos(List<SelectedPhoto?> photos, String fieldName) async {
    return photos.map((p) => PhotoUploadResult.ok(p?.fileName ?? '')).toList();
  }

  Future<http.Response> buildAndSendRegistroRequest({
    required Map<String, String> bitacoraFields,
    required String              historicoJson,
    required Map<String, String> gastoFields,
    required List<SelectedPhoto?> fotosHistorico,
    required SelectedPhoto?       fotoGasto,
  }) async {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('Sin token de autenticación');

    final url = Uri.parse('${EnvironmentConfig.baseUrl}/api/general/registrar-mantenimiento');
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = '*/*';

    bitacoraFields.forEach((k, v) => request.fields[k] = v);
    request.fields['HistoricoMantenimientosJson'] = historicoJson;
    gastoFields.forEach((k, v) => request.fields['Gasto.$k'] = v);

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

    if (fotoGasto != null) {
      final mf = await _buildMultipartFile(fotoGasto, 'Gasto.gas_vlink_foto');
      if (mf != null) request.files.add(mf);
    }

    _debugLog(request, historicoJson);
    
    // ✅ Log de auditoría
    final stopwatch = Stopwatch()..start();
    AppLogger.httpRequest('POST (MULTIPART) /registrar-mantenimiento', source: 'MultipartPhotoUploadService');

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      // ✅ Log de respuesta
      AppLogger.httpResponse(
        'POST (MULTIPART) /registrar-mantenimiento', 
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        source: 'MultipartPhotoUploadService'
      );

      return response;
    } catch (e, stack) {
      AppLogger.error('Fallo en upload multipart', error: e, stackTrace: stack, source: 'MultipartPhotoUploadService');
      rethrow;
    }
  }

  Future<http.MultipartFile?> _buildMultipartFile(SelectedPhoto photo, String fieldName) async {
    try {
      if (photo.isWeb && photo.bytes != null) {
        return http.MultipartFile.fromBytes(fieldName, photo.bytes!, filename: photo.fileName);
      }
      if (photo.filePath != null) {
        return await http.MultipartFile.fromPath(fieldName, photo.filePath!, filename: photo.fileName);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error creando MultipartFile ($fieldName)', error: e, source: 'MultipartPhotoUploadService');
      return null;
    }
  }

  http.MultipartFile _emptyMultipartFile(String fieldName, int index) {
    return http.MultipartFile.fromBytes(fieldName, _emptyPng, filename: 'empty_$index.png');
  }

  void _debugLog(http.MultipartRequest request, String historicoJson) {
    // Mantengo el print local para desarrollo rápido, pero el AppLogger es el que va a Render
    print('📡 Multipart request ready: ${request.files.length} files');
  }
}