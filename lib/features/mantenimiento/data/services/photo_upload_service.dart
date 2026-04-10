// lib/features/mantenimiento/data/services/photo_upload_service.dart
//
// Interface + modelos para subida de fotos.
// Diseñado para migrar fácilmente de Multipart → AWS S3 u otro provider.

import 'dart:typed_data';

// ─── Estrategia de upload ────────────────────────────────────────────────────
enum PhotoUploadStrategy { multipart, s3 }

// ─── Resultado de upload ──────────────────────────────────────────────────────
class PhotoUploadResult {
  final bool success;
  final String? url;      // URL retornada por el servidor
  final String? error;
  final String? fileName;

  const PhotoUploadResult._({
    required this.success,
    this.url,
    this.error,
    this.fileName,
  });

  factory PhotoUploadResult.ok(String url, {String? fileName}) =>
      PhotoUploadResult._(success: true, url: url, fileName: fileName);

  factory PhotoUploadResult.fail(String error) =>
      PhotoUploadResult._(success: false, error: error);

  @override
  String toString() => success
      ? 'PhotoUploadResult.ok(url: $url)'
      : 'PhotoUploadResult.fail($error)';
}

// ─── Modelo de foto seleccionada (multiplataforma) ────────────────────────────
class SelectedPhoto {
  /// Ruta al archivo local (mobile/desktop). Null en web.
  final String? filePath;
  /// Bytes del archivo (web). Puede también usarse en mobile para compresión.
  final Uint8List? bytes;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  const SelectedPhoto({
    this.filePath,
    this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  bool get isWeb => filePath == null && bytes != null;
  double get sizeMb => sizeBytes / (1024 * 1024);
}

// ─── Interface de upload ──────────────────────────────────────────────────────
abstract class IPhotoUploadService {
  PhotoUploadStrategy get strategy;

  /// Sube una sola foto, retorna su URL.
  Future<PhotoUploadResult> uploadPhoto(SelectedPhoto photo, String fieldName);

  /// Sube múltiples fotos (FotosHistorico[]).
  Future<List<PhotoUploadResult>> uploadMultiplePhotos(
      List<SelectedPhoto?> photos, String fieldName);

  /// Cancela uploads en progreso.
  void cancelAll();
}