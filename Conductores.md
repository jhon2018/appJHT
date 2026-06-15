# Feature: Conductores — Documentación técnica
> **App:** JHT Transport Company · **Stack:** Flutter + Clean Architecture + BLoC + .NET API  
> **Última actualización:** 2026 · **Autor del análisis:** Revisión técnica completa

---

## 1. Estructura de carpetas

```
lib/features/conductor/
│
├── data/
│   ├── datasources/
│   │   └── conductor_remote_data_source.dart   ← Llama al API .NET (HTTP)
│   ├── models/
│   │   ├── persona_model.dart                  ← Modelo principal (PersonaModel, TelefonoModel, ConductorDetalleModel)
│   │   ├── persona_list_response.dart           ← Wrapper del response GET /Listar-personas
│   │   ├── persona_detalle_response.dart        ← Wrapper del response GET /persona/{id}
│   │   ├── conductor_registro_dto.dart          ← DTO para crear conductor (POST)
│   │   ├── conductor_registro_response.dart     ← Response del POST registro
│   │   ├── persona_actualizar_dto.dart          ← DTO para actualizar (PUT)
│   │   └── persona_actualizar_response.dart     ← Response del PUT actualizar
│   └── repositories/
│       └── conductor_repository_impl.dart       ← Implementación del repositorio
│
├── domain/
│   ├── entities/
│   │   └── conductor_entity.dart               ← Entidad de dominio pura
│   ├── repositories/
│   │   └── conductor_repository.dart           ← Contrato abstracto (interface)
│   └── usecases/
│       ├── listar_personas_usecase.dart         ← Caso de uso: listar
│       ├── registrar_conductor_usecase.dart     ← Caso de uso: crear
│       ├── obtener_persona_detalle_usecase.dart ← Caso de uso: detalle
│       └── actualizar_persona_usecase.dart      ← Caso de uso: actualizar
│
└── presentation/
    ├── bloc/
    │   ├── conductor_bloc.dart                  ← Orquestador de eventos/estados
    │   ├── conductor_event.dart                 ← Eventos (acciones del usuario)
    │   └── conductor_state.dart                 ← Estados (respuestas a la UI)
    ├── pages/
    │   ├── conductor_page.dart                  ← Página principal (tabla + búsqueda)
    │   └── conductor_dashboard.dart             ← Dashboard alternativo
    └── widgets/
        ├── add_conductor_modal.dart             ← Modal: crear conductor
        ├── editar_persona_modal.dart            ← Modal: editar conductor
        └── persona_detalle_modal.dart           ← Modal: ver detalle
```

---

## 2. Flujo completo UI → API (orden de ejecución)

### 2A. Inicialización — Cargar lista de conductores

```
1. base_dashboard.dart          → Usuario toca "Conductores" en el menú lateral
2. base_dashboard.dart          → Construye: ConductorRemoteDataSourceImpl()
                                            → ConductorRepositoryImpl(remoteDataSource)
                                            → ConductorBloc(todos los use cases)
                                            → ConductorBloc.add(listarPersonas)  ← dispara carga automática
3. conductor_page.dart          → initState() → add(listarPersonas)  ← segunda llamada (redundante)
4. conductor_bloc.dart          → _onListarPersonas() → emit(personasCargando)
5. listar_personas_usecase.dart → execute() → repository.listarPersonas()
6. conductor_repository_impl.dart → remoteDataSource.listarPersonas()
7. conductor_remote_data_source.dart → GET /api/admin/Listar-personas
8. .NET API                     → Response 200 con lista de PersonaModel[]
9. conductor_bloc.dart          → emit(personasCargadas(personas: response.data))
10. conductor_page.dart         → BlocBuilder reconstruye tabla con datos
```

### 2B. Editar conductor (flujo en 2 pasos — importante)

```
PASO 1: Cargar detalle
1. conductor_page.dart          → Usuario toca ícono editar en la fila
2. conductor_page.dart          → _mostrarOpcionEditar(persona) → add(obtenerPersonaDetalle(personaId))
3. conductor_bloc.dart          → _onObtenerPersonaDetalle() → emit(personaDetalleCargando)
4. obtener_persona_detalle_usecase.dart → execute(personaId)
5. conductor_remote_data_source.dart → GET /api/admin/persona/{personaId}
6. .NET API                     → Response 200 con PersonaModel completo (con teléfonos y licencia)
7. conductor_bloc.dart          → emit(personaDetalleCargado(persona: data))

PASO 2: Mostrar modal y actualizar
8. conductor_page.dart          → BlocListener detecta personaDetalleCargado
9. conductor_page.dart          → showDialog(EditarPersonaModal(persona: personaDetalleCompleta))
10. editar_persona_modal.dart   → Usuario edita campos y toca "Guardar"
11. editar_persona_modal.dart   → Construye PersonaActualizarDto y llama dataSource.actualizarPersona(dto)
    ⚠️ ATENCIÓN: El modal llama directo al dataSource, NO al BLoC
12. conductor_remote_data_source.dart → PUT /api/admin/actualizar-persona
13. .NET API                    → Response 200
14. conductor_page.dart         → await showDialog() retorna
15. conductor_page.dart         → conductorBloc.add(listarPersonas) para refrescar grid
```

### 2C. Registrar nuevo conductor

```
1. conductor_page.dart          → Usuario toca "Agregar conductor"
2. conductor_page.dart          → showDialog(AddConductorModal)
3. add_conductor_modal.dart     → Carga tipos de teléfono → add(cargarTiposTelefono)
4. conductor_bloc.dart          → GET /api/admin/consulta_tipo_telefono
5. add_conductor_modal.dart     → Usuario llena formulario y toca "Registrar"
6. add_conductor_modal.dart     → add(registrarConductor(dto))
7. conductor_bloc.dart          → _onRegistrarConductor() → emit(loading)
8. registrar_conductor_usecase.dart → execute(dto)
9. conductor_remote_data_source.dart → POST /api/admin/registrar_colaborador
10. .NET API                    → Response 200
11. conductor_bloc.dart         → emit(success(response))
12. add_conductor_modal.dart    → BlocListener detecta success → onConductorAdded()
13. conductor_page.dart         → add(listarPersonas) + AppNotification.success()
```

---

## 3. Endpoints API .NET

| Método | Endpoint | Uso | DTO de entrada | Response |
|--------|----------|-----|----------------|----------|
| GET | `/api/admin/Listar-personas` | Cargar grid | — | `PersonaListResponse` |
| GET | `/api/admin/persona/{id}` | Detalle antes de editar | — | `PersonaDetalleResponse` |
| POST | `/api/admin/registrar_colaborador` | Crear conductor | `ConductorRegistroDto` | `ConductorRegistroResponse` |
| PUT | `/api/admin/actualizar-persona` | Editar conductor | `PersonaActualizarDto` | `PersonaActualizarResponse` |
| GET | `/api/admin/consulta_tipo_telefono` | Tipos de teléfono (compartido con Proveedores) | — | `List<TipoTelefonoModel>` |

**Autenticación:** Todas las llamadas requieren `Authorization: Bearer {token}` — el token se obtiene via `TokenService.getToken()` (almacenado en `flutter_secure_storage`).

---

## 4. Modelos de datos clave

### PersonaModel (modelo principal)
```dart
PersonaModel {
  personaId: int        // ID único — usado para editar/detalle
  dni: int              // Documento de identidad
  primerNombre: String
  segundoNombre: String
  apellidoPaterno: String
  apellidoMaterno: String
  fechaNacimiento: String?
  correo: String?
  cargo: String?        // "Conductor" o "Administrador" — controla si tiene datos de licencia
  salario: double?
  estado: String        // "Activo" / "Inactivo"
  fechaRegistro: String
  fechaIngreso: String?
  fechaSalida: String?
  telefonos: List<TelefonoModel>    // Puede ser lista vacía
  conductor: ConductorDetalleModel? // NULL si cargo != "Conductor"
}
```

### TelefonoModel
```dart
TelefonoModel {
  telId: int?    // ID del teléfono — REQUERIDO para actualizar, opcional para crear
  numero: String
  uso: String    // "Personal" | "Trabajo"
  titId: int?    // Foreign key a TipoTelefonoModel
}
```
> ⚠️ El API usa nombres de campo inconsistentes: en el GET devuelve `tipoId`, en el POST espera `tit_iid`, en el PUT espera `titId`. El `fromJson()` maneja los 3 casos.

### ConductorRegistroDto → JSON al API
```json
{
  "persona": {
    "per_idni": 12345678,
    "per_vprimer_nom": "Juan",
    ...
  },
  "conductor": {           // Omitido si cargo = "Administrador"
    "con_vnumero_licencia": "A1-12345",
    ...
  },
  "telefonos": [
    { "tel_vnumero": "999888777", "tit_iid": 1 }
  ]
}
```

### PersonaActualizarDto → JSON al API (estructura diferente al registro)
```json
{
  "personaId": 1,
  "primerNombre": "Juan",      // camelCase (diferente al registro que usa per_vprimer_nom)
  "numeroLicencia": "A1-12345", // campos de conductor aplanados, no anidados
  "telefonos": [
    { "telId": 5, "numero": "999888777", "titId": 1 }  // telId requerido para update
  ]
}
```

---

## 5. Estados del BLoC

```
ConductorState
│
├── initial()                           → Estado inicial al crear el BLoC
├── loading()                           → Registrando conductor (POST)
├── success(response)                   → Registro exitoso
│
├── personasCargando()                  → GET lista en progreso
├── personasCargadas(personas)          → GET lista completado ← TABLA SE RENDERIZA AQUÍ
│
├── personaDetalleCargando()            → GET detalle en progreso (muestra spinner en modal)
├── personaDetalleCargado(persona)      → GET detalle OK → abre EditarPersonaModal
├── personaDetalleError(message)        → GET detalle falló
│
├── personaActualizando()               → PUT en progreso
├── personaActualizada(response)        → PUT OK
├── personaActualizacionError(message)  → PUT falló
│
├── tiposTelefonoCargando()             → Cargando dropdown en modal
├── tiposTelefonoCargados(tipos)        → Dropdown listo
└── tiposTelefonoError(message)         → Error cargando dropdown
```

> **IMPORTANTE — buildWhen en conductor_page.dart:**  
> El BlocBuilder de la tabla usa `buildWhen` que EXCLUYE `personaDetalleCargado`.  
> Esto fue un bug crítico corregido: incluirlo causaba que la tabla retornara `SizedBox.shrink()` → pantalla en blanco al actualizar un conductor.

---

## 6. Inyección de dependencias (cómo se construye el BLoC)

No se usa GetIt ni ningún DI container. El BLoC se construye manualmente en `base_dashboard.dart` cada vez que el usuario navega a la página de Conductores:

```dart
// base_dashboard.dart — case 'Conductores':
final remoteDataSource = ConductorRemoteDataSourceImpl();
final repository = ConductorRepositoryImpl(remoteDataSource: remoteDataSource);

return BlocProvider(
  create: (context) => ConductorBloc(
    registrarConductorUseCase: RegistrarConductorUseCase(repository: repository),
    listarPersonasUseCase: ListarPersonasUseCase(repository: repository),
    obtenerPersonaDetalleUseCase: ObtenerPersonaDetalleUseCase(repository: repository),
    actualizarPersonaUseCase: ActualizarPersonaUseCase(repository: repository),
    conductorRepository: repository,   // ← también pasa el repo directamente (para getTiposTelefono)
  )..add(const ConductorEvent.listarPersonas()),   // ← carga automática al entrar
  child: ConductorPage(
    userName: widget.userName,
    userRole: widget.userRole,
    dataSource: remoteDataSource,   // ← la página recibe el dataSource directamente (para editar)
  ),
);
```

---

## 7. Malas prácticas detectadas / Deuda técnica

| # | Problema | Ubicación | Impacto | Solución recomendada |
|---|----------|-----------|---------|----------------------|
| 1 | **Modal de edición llama al dataSource directamente**, bypaseando el BLoC y los UseCases | `editar_persona_modal.dart` | Medio — Si el API cambia, hay que actualizar en 2 lugares | Crear evento `ConductorEvent.actualizarPersona` y manejar todo por el BLoC |
| 2 | **Doble llamada listarPersonas al iniciar** | `base_dashboard.dart` + `conductor_page.dart` initState | Bajo — 2 requests HTTP al entrar | Eliminar el `add(listarPersonas)` del initState ya que el BLoC lo dispara con `..add()` |
| 3 | **TipoTelefonoModel importado desde feature Supplier** | `conductor_state.dart`, `conductor_remote_data_source.dart` | Medio — acoplamiento entre features | Mover `TipoTelefonoModel` a `core/models/` o crear uno propio en conductor |
| 4 | **`ConductorPage` recibe `dataSource` como parámetro** | `conductor_page.dart` constructor | Medio — viola Clean Architecture (la UI no debería conocer el data source) | Mover la lógica de edición al BLoC |
| 5 | **Muchos `print()` en producción** | `conductor_remote_data_source.dart` | Bajo — expone tokens JWT en logs | Reemplazar con `RemoteLoggerService` ya disponible en el proyecto |
| 6 | **`conductorRepository` pasado al BLoC Y como use cases** | `conductor_bloc.dart` constructor | Bajo — redundante | El `getTiposTelefono` debería tener su propio UseCase |
| 7 | **`ConductorState` importa `editar_persona_modal.dart`** | `conductor_state.dart` línea 1 | Alto — capas invertidas (domain/data importando presentation) | Eliminar esa importación (probablemente quedó por accidente) |

---

## 8. Si quieres hacer un cambio...

### Agregar un campo nuevo al formulario de creación
1. `persona_model.dart` → agregar el campo
2. `conductor_registro_dto.dart` → agregar al DTO y al `toJson()`
3. `add_conductor_modal.dart` → agregar el TextField en el formulario
4. **No necesitas tocar** el BLoC ni los UseCases

### Agregar un campo nuevo al formulario de edición
1. `persona_model.dart` → asegurarte que el campo viene del API en `fromJson()`
2. `persona_actualizar_dto.dart` → agregar al DTO y al `toJson()`
3. `editar_persona_modal.dart` → agregar el TextField y conectar al DTO

### Cambiar el endpoint del API
1. Solo `conductor_remote_data_source.dart` → cambiar la URL en el método correspondiente

### Agregar un nuevo filtro de búsqueda en la tabla
1. Solo `conductor_page.dart` → método `_filterPersonas()` → agregar condición al `where()`

### Cambiar columnas de la tabla
1. Solo `conductor_page.dart` → método `_buildTableColumns()` y `_buildDataRowFromPersona()`

---

## 9. Notas de configuración

- **URL base del API:** definida en `lib/features/config/environment_config.dart` → `EnvironmentConfig.baseUrl`
- **Token JWT:** guardado con `flutter_secure_storage` → accedido via `TokenService.getToken()`
- **Errores HTTP manejados:** 200 ✅, 401 (token expirado), 403 (sin permisos), 404 (no encontrado), otros → mensaje genérico
- **Parsing de errores del API:** método `_getErrorMessage()` en el data source — busca el campo `error` → `mensaje` → `message` → `errors{}` → `title`