// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conductor_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConductorEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConductorEventCopyWith<$Res> {
  factory $ConductorEventCopyWith(
    ConductorEvent value,
    $Res Function(ConductorEvent) then,
  ) = _$ConductorEventCopyWithImpl<$Res, ConductorEvent>;
}

/// @nodoc
class _$ConductorEventCopyWithImpl<$Res, $Val extends ConductorEvent>
    implements $ConductorEventCopyWith<$Res> {
  _$ConductorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RegistrarConductorImplCopyWith<$Res> {
  factory _$$RegistrarConductorImplCopyWith(
    _$RegistrarConductorImpl value,
    $Res Function(_$RegistrarConductorImpl) then,
  ) = __$$RegistrarConductorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ConductorRegistroDto dto});
}

/// @nodoc
class __$$RegistrarConductorImplCopyWithImpl<$Res>
    extends _$ConductorEventCopyWithImpl<$Res, _$RegistrarConductorImpl>
    implements _$$RegistrarConductorImplCopyWith<$Res> {
  __$$RegistrarConductorImplCopyWithImpl(
    _$RegistrarConductorImpl _value,
    $Res Function(_$RegistrarConductorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dto = null}) {
    return _then(
      _$RegistrarConductorImpl(
        dto: null == dto
            ? _value.dto
            : dto // ignore: cast_nullable_to_non_nullable
                  as ConductorRegistroDto,
      ),
    );
  }
}

/// @nodoc

class _$RegistrarConductorImpl implements _RegistrarConductor {
  const _$RegistrarConductorImpl({required this.dto});

  @override
  final ConductorRegistroDto dto;

  @override
  String toString() {
    return 'ConductorEvent.registrarConductor(dto: $dto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegistrarConductorImpl &&
            (identical(other.dto, dto) || other.dto == dto));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dto);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegistrarConductorImplCopyWith<_$RegistrarConductorImpl> get copyWith =>
      __$$RegistrarConductorImplCopyWithImpl<_$RegistrarConductorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) {
    return registrarConductor(dto);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) {
    return registrarConductor?.call(dto);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (registrarConductor != null) {
      return registrarConductor(dto);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) {
    return registrarConductor(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) {
    return registrarConductor?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (registrarConductor != null) {
      return registrarConductor(this);
    }
    return orElse();
  }
}

abstract class _RegistrarConductor implements ConductorEvent {
  const factory _RegistrarConductor({required final ConductorRegistroDto dto}) =
      _$RegistrarConductorImpl;

  ConductorRegistroDto get dto;

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegistrarConductorImplCopyWith<_$RegistrarConductorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ListarPersonasImplCopyWith<$Res> {
  factory _$$ListarPersonasImplCopyWith(
    _$ListarPersonasImpl value,
    $Res Function(_$ListarPersonasImpl) then,
  ) = __$$ListarPersonasImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ListarPersonasImplCopyWithImpl<$Res>
    extends _$ConductorEventCopyWithImpl<$Res, _$ListarPersonasImpl>
    implements _$$ListarPersonasImplCopyWith<$Res> {
  __$$ListarPersonasImplCopyWithImpl(
    _$ListarPersonasImpl _value,
    $Res Function(_$ListarPersonasImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ListarPersonasImpl implements _ListarPersonas {
  const _$ListarPersonasImpl();

  @override
  String toString() {
    return 'ConductorEvent.listarPersonas()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ListarPersonasImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) {
    return listarPersonas();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) {
    return listarPersonas?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (listarPersonas != null) {
      return listarPersonas();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) {
    return listarPersonas(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) {
    return listarPersonas?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (listarPersonas != null) {
      return listarPersonas(this);
    }
    return orElse();
  }
}

abstract class _ListarPersonas implements ConductorEvent {
  const factory _ListarPersonas() = _$ListarPersonasImpl;
}

/// @nodoc
abstract class _$$ObtenerPersonaDetalleImplCopyWith<$Res> {
  factory _$$ObtenerPersonaDetalleImplCopyWith(
    _$ObtenerPersonaDetalleImpl value,
    $Res Function(_$ObtenerPersonaDetalleImpl) then,
  ) = __$$ObtenerPersonaDetalleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int personaId});
}

/// @nodoc
class __$$ObtenerPersonaDetalleImplCopyWithImpl<$Res>
    extends _$ConductorEventCopyWithImpl<$Res, _$ObtenerPersonaDetalleImpl>
    implements _$$ObtenerPersonaDetalleImplCopyWith<$Res> {
  __$$ObtenerPersonaDetalleImplCopyWithImpl(
    _$ObtenerPersonaDetalleImpl _value,
    $Res Function(_$ObtenerPersonaDetalleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? personaId = null}) {
    return _then(
      _$ObtenerPersonaDetalleImpl(
        personaId: null == personaId
            ? _value.personaId
            : personaId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ObtenerPersonaDetalleImpl implements _ObtenerPersonaDetalle {
  const _$ObtenerPersonaDetalleImpl({required this.personaId});

  @override
  final int personaId;

  @override
  String toString() {
    return 'ConductorEvent.obtenerPersonaDetalle(personaId: $personaId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ObtenerPersonaDetalleImpl &&
            (identical(other.personaId, personaId) ||
                other.personaId == personaId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, personaId);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ObtenerPersonaDetalleImplCopyWith<_$ObtenerPersonaDetalleImpl>
  get copyWith =>
      __$$ObtenerPersonaDetalleImplCopyWithImpl<_$ObtenerPersonaDetalleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) {
    return obtenerPersonaDetalle(personaId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) {
    return obtenerPersonaDetalle?.call(personaId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (obtenerPersonaDetalle != null) {
      return obtenerPersonaDetalle(personaId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) {
    return obtenerPersonaDetalle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) {
    return obtenerPersonaDetalle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (obtenerPersonaDetalle != null) {
      return obtenerPersonaDetalle(this);
    }
    return orElse();
  }
}

abstract class _ObtenerPersonaDetalle implements ConductorEvent {
  const factory _ObtenerPersonaDetalle({required final int personaId}) =
      _$ObtenerPersonaDetalleImpl;

  int get personaId;

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ObtenerPersonaDetalleImplCopyWith<_$ObtenerPersonaDetalleImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ActualizarPersonaImplCopyWith<$Res> {
  factory _$$ActualizarPersonaImplCopyWith(
    _$ActualizarPersonaImpl value,
    $Res Function(_$ActualizarPersonaImpl) then,
  ) = __$$ActualizarPersonaImplCopyWithImpl<$Res>;
  @useResult
  $Res call({PersonaActualizarDto dto});
}

/// @nodoc
class __$$ActualizarPersonaImplCopyWithImpl<$Res>
    extends _$ConductorEventCopyWithImpl<$Res, _$ActualizarPersonaImpl>
    implements _$$ActualizarPersonaImplCopyWith<$Res> {
  __$$ActualizarPersonaImplCopyWithImpl(
    _$ActualizarPersonaImpl _value,
    $Res Function(_$ActualizarPersonaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dto = null}) {
    return _then(
      _$ActualizarPersonaImpl(
        dto: null == dto
            ? _value.dto
            : dto // ignore: cast_nullable_to_non_nullable
                  as PersonaActualizarDto,
      ),
    );
  }
}

/// @nodoc

class _$ActualizarPersonaImpl implements _ActualizarPersona {
  const _$ActualizarPersonaImpl({required this.dto});

  @override
  final PersonaActualizarDto dto;

  @override
  String toString() {
    return 'ConductorEvent.actualizarPersona(dto: $dto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActualizarPersonaImpl &&
            (identical(other.dto, dto) || other.dto == dto));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dto);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActualizarPersonaImplCopyWith<_$ActualizarPersonaImpl> get copyWith =>
      __$$ActualizarPersonaImplCopyWithImpl<_$ActualizarPersonaImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) {
    return actualizarPersona(dto);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) {
    return actualizarPersona?.call(dto);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (actualizarPersona != null) {
      return actualizarPersona(dto);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) {
    return actualizarPersona(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) {
    return actualizarPersona?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (actualizarPersona != null) {
      return actualizarPersona(this);
    }
    return orElse();
  }
}

abstract class _ActualizarPersona implements ConductorEvent {
  const factory _ActualizarPersona({required final PersonaActualizarDto dto}) =
      _$ActualizarPersonaImpl;

  PersonaActualizarDto get dto;

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActualizarPersonaImplCopyWith<_$ActualizarPersonaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CargarTiposTelefonoImplCopyWith<$Res> {
  factory _$$CargarTiposTelefonoImplCopyWith(
    _$CargarTiposTelefonoImpl value,
    $Res Function(_$CargarTiposTelefonoImpl) then,
  ) = __$$CargarTiposTelefonoImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CargarTiposTelefonoImplCopyWithImpl<$Res>
    extends _$ConductorEventCopyWithImpl<$Res, _$CargarTiposTelefonoImpl>
    implements _$$CargarTiposTelefonoImplCopyWith<$Res> {
  __$$CargarTiposTelefonoImplCopyWithImpl(
    _$CargarTiposTelefonoImpl _value,
    $Res Function(_$CargarTiposTelefonoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConductorEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CargarTiposTelefonoImpl implements _CargarTiposTelefono {
  const _$CargarTiposTelefonoImpl();

  @override
  String toString() {
    return 'ConductorEvent.cargarTiposTelefono()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CargarTiposTelefonoImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ConductorRegistroDto dto) registrarConductor,
    required TResult Function() listarPersonas,
    required TResult Function(int personaId) obtenerPersonaDetalle,
    required TResult Function(PersonaActualizarDto dto) actualizarPersona,
    required TResult Function() cargarTiposTelefono,
  }) {
    return cargarTiposTelefono();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ConductorRegistroDto dto)? registrarConductor,
    TResult? Function()? listarPersonas,
    TResult? Function(int personaId)? obtenerPersonaDetalle,
    TResult? Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult? Function()? cargarTiposTelefono,
  }) {
    return cargarTiposTelefono?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ConductorRegistroDto dto)? registrarConductor,
    TResult Function()? listarPersonas,
    TResult Function(int personaId)? obtenerPersonaDetalle,
    TResult Function(PersonaActualizarDto dto)? actualizarPersona,
    TResult Function()? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (cargarTiposTelefono != null) {
      return cargarTiposTelefono();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegistrarConductor value) registrarConductor,
    required TResult Function(_ListarPersonas value) listarPersonas,
    required TResult Function(_ObtenerPersonaDetalle value)
    obtenerPersonaDetalle,
    required TResult Function(_ActualizarPersona value) actualizarPersona,
    required TResult Function(_CargarTiposTelefono value) cargarTiposTelefono,
  }) {
    return cargarTiposTelefono(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegistrarConductor value)? registrarConductor,
    TResult? Function(_ListarPersonas value)? listarPersonas,
    TResult? Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult? Function(_ActualizarPersona value)? actualizarPersona,
    TResult? Function(_CargarTiposTelefono value)? cargarTiposTelefono,
  }) {
    return cargarTiposTelefono?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegistrarConductor value)? registrarConductor,
    TResult Function(_ListarPersonas value)? listarPersonas,
    TResult Function(_ObtenerPersonaDetalle value)? obtenerPersonaDetalle,
    TResult Function(_ActualizarPersona value)? actualizarPersona,
    TResult Function(_CargarTiposTelefono value)? cargarTiposTelefono,
    required TResult orElse(),
  }) {
    if (cargarTiposTelefono != null) {
      return cargarTiposTelefono(this);
    }
    return orElse();
  }
}

abstract class _CargarTiposTelefono implements ConductorEvent {
  const factory _CargarTiposTelefono() = _$CargarTiposTelefonoImpl;
}
