// lib/features/supplier/data/models/telefono_detail_model.dart
// PARSING DEFENSIVO: acepta múltiples nombres de clave del API
// para evitar lista vacía cuando el API cambia el casing o el nombre.

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
      // Acepta: telefonoId | telId | tel_iid | id
      telefonoId: (json['telefonoId'] ?? json['telId'] ?? json['tel_iid'] ?? json['id'] ?? 0) as int,
      // Acepta: numero | tel_vnumero | number
      numero: (json['numero'] ?? json['tel_vnumero'] ?? json['number'] ?? '').toString(),
      // Acepta: tipoId | titId | tit_iid | tipo_id
      tipoId: (json['tipoId'] ?? json['titId'] ?? json['tit_iid'] ?? json['tipo_id'] ?? 0) as int,
      // Acepta: tipo | tit_vtipo | tipNombre | tipoNombre
      tipo: (json['tipo'] ?? json['tit_vtipo'] ?? json['tipNombre'] ?? json['tipoNombre'] ?? '').toString(),
      // Acepta: uso | tit_vuso | usoNombre
      uso: (json['uso'] ?? json['tit_vuso'] ?? json['usoNombre'] ?? '').toString(),
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
