// lib/features/mantenimiento/data/services/photo_file_helper.dart
//
// Helper multiplataforma para selección, validación y compresión de fotos.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'photo_upload_service.dart';

// ─── Límites de tamaño por plataforma ────────────────────────────────────────
const _maxMbMobile  = 10.0;
const _maxMbWeb     = 5.0;
const _maxMbDesktop = 15.0;

// ─── Formatos permitidos ──────────────────────────────────────────────────────
const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const _allowedMimes = [
  'image/jpeg', 'image/png', 'image/webp'
];

// ─── Resultado de validación ──────────────────────────────────────────────────
class PhotoValidationResult {
  final bool valid;
  final String? error;
  final SelectedPhoto? photo; // foto optimizada si valid == true
  const PhotoValidationResult._({required this.valid, this.error, this.photo});
  factory PhotoValidationResult.ok(SelectedPhoto p) =>
      PhotoValidationResult._(valid: true, photo: p);
  factory PhotoValidationResult.fail(String e) =>
      PhotoValidationResult._(valid: false, error: e);
}

// ─── Helper principal ─────────────────────────────────────────────────────────
class PhotoFileHelper {
  PhotoFileHelper._();

  static bool get isWeb     => kIsWeb;
  static bool get isMobile  => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static double get _maxMb =>
      isWeb ? _maxMbWeb : isMobile ? _maxMbMobile : _maxMbDesktop;

  // ── Selección de foto con FilePicker ────────────────────────────────────────
  static Future<SelectedPhoto?> pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
      withData: kIsWeb, // en web necesitamos los bytes directamente
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final mime = _mimeFromExtension(file.extension ?? '');
    final size = file.size;

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) return null;
      return SelectedPhoto(
        bytes: bytes,
        fileName: file.name,
        mimeType: mime,
        sizeBytes: size,
      );
    } else {
      return SelectedPhoto(
        filePath: file.path,
        fileName: file.name,
        mimeType: mime,
        sizeBytes: size,
      );
    }
  }

  // ── Validación + compresión ─────────────────────────────────────────────────
  static Future<PhotoValidationResult> validateAndCompress(
      SelectedPhoto photo) async {
    // 1. Formato
    if (!_allowedMimes.contains(photo.mimeType)) {
      return PhotoValidationResult.fail(
          'Formato no permitido. Use JPG, PNG o WebP.');
    }

    // 2. Tamaño
    if (photo.sizeMb > _maxMb) {
      // Intentar comprimir
      final compressed = await _compress(photo);
      if (compressed == null) {
        return PhotoValidationResult.fail(
            'La imagen supera el límite de ${_maxMb.toStringAsFixed(0)} MB '
            'y no se pudo comprimir.');
      }
      return PhotoValidationResult.ok(compressed);
    }

    return PhotoValidationResult.ok(photo);
  }

  // ── Obtener bytes de la foto (mobile o web) ─────────────────────────────────
  static Future<Uint8List?> getBytes(SelectedPhoto photo) async {
    if (photo.bytes != null) return photo.bytes;
    if (photo.filePath != null) {
      return await File(photo.filePath!).readAsBytes();
    }
    return null;
  }

  // ── Compresión básica ───────────────────────────────────────────────────────
  /// Intenta reducir tamaño reescribiendo los bytes.
  /// Para compresión avanzada integrar flutter_image_compress.
  static Future<SelectedPhoto?> _compress(SelectedPhoto photo) async {
    try {
      Uint8List? bytes = await getBytes(photo);
      if (bytes == null) return null;

      // Reducción simple: si el archivo es muy grande, indicar al usuario.
      // Para producción: usar flutter_image_compress con quality 70-85.
      // Aquí dejamos el hook listo:
      //
      // final compressed = await FlutterImageCompress.compressWithList(
      //   bytes, quality: 75, minWidth: 1280, minHeight: 720,
      // );
      //
      // Por ahora retornamos null para que el validador informe al usuario.
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── MIME desde extensión ────────────────────────────────────────────────────
  static String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      default:     return 'image/jpeg';
    }
  }

  // ── Metadata display ────────────────────────────────────────────────────────
  static String formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}