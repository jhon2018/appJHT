// lib/features/supplier/data/models/telefono_detail_model.dart
class TelefonoDetailModel {
  final int telefonoId;
  final String numero;
  final int tipoId;
  final String tipo;
  final String uso;

  TelefonoDetailModel({
    required this.telefonoId,
    required this.numero,
    required this.tipoId,
    required this.tipo,
    required this.uso,
  });

  factory TelefonoDetailModel.fromJson(Map<String, dynamic> json) {
    return TelefonoDetailModel(
      telefonoId: json['TelefonoId'] ?? 0,
      numero: json['Numero'] ?? '',
      tipoId: json['TipoId'] ?? 0,
      tipo: json['Tipo'] ?? '',
      uso: json['Uso'] ?? '',
    );
  }
}