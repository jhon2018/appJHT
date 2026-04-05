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
      // ✅ BUG FIX #1: La API devuelve claves en camelCase minúscula,
      //    no PascalCase. Se corrigen todas las claves.
      telefonoId: json['telefonoId'] ?? 0,
      numero:     json['numero']     ?? '',
      tipoId:     json['tipoId']     ?? 0,
      tipo:       json['tipo']       ?? '',
      uso:        json['uso']        ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'telefonoId': telefonoId,
    'numero':     numero,
    'tipoId':     tipoId,
    'tipo':       tipo,
    'uso':        uso,
  };
}