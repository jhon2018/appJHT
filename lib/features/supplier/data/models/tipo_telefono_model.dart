//Ruta: lib/features/supplier/data/models/tipo_telefono_model.dart

class TipoTelefonoModel {
  final int id;
  final String tipo;
  final String uso;

  TipoTelefonoModel({
    required this.id,
    required this.tipo,
    required this.uso,
  });

  factory TipoTelefonoModel.fromJson(Map<String, dynamic> json) {
    return TipoTelefonoModel(
      id: json['id'],
      tipo: json['tipo'],
      uso: json['uso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'uso': uso,
    };
  }

  // Para mostrar en el dropdown: "Celular - Personal"
  String get displayText => '$tipo - $uso';
  String get value => '$tipo - $uso';
}