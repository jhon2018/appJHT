---
trigger: always_on
---

# JHT Transport — Directrices Globales de Flutter, UX, Calidad y Seguridad

Estas reglas aplican al desarrollo y mantenimiento del frontend de **JHT Transport**, construido con Flutter y utilizado en **Web y dispositivos móviles**.

Su objetivo es mantener una aplicación estable, consistente, responsive, mantenible y segura, evitando regresiones sobre funcionalidades existentes.

---

# 1. REGLA MÁXIMA — PROTEGER EL SISTEMA EN PRODUCCIÓN

La aplicación tiene funcionalidades utilizadas por usuarios reales.

**Prioridad absoluta: no romper funcionalidades existentes.**

Antes de modificar código existente:

1. Analizar el archivo y su contexto.
2. Buscar todas las referencias al elemento que se quiere cambiar.
3. Determinar si se utiliza desde otros archivos, features, rutas, BLoCs o servicios.
4. Evaluar el impacto.
5. Mantener compatibilidad hacia atrás siempre que sea posible.

### Nunca hacer sin autorización explícita

* Eliminar funcionalidades existentes.
* Eliminar clases, métodos, variables o imports que todavía estén siendo utilizados.
* Renombrar endpoints.
* Cambiar headers o contratos HTTP.
* Cambiar autenticación JWT.
* Cambiar lógica de sesión.
* Cambiar Events o States de BLoCs compartidos.
* Renombrar callbacks públicos usados por otros componentes.
* Eliminar llamadas existentes de `AppLogger`.
* Modificar archivos críticos sin analizar sus dependencias.

### Regla de compatibilidad

Preferir:

**agregar / extender / adaptar**

antes que:

**reemplazar / eliminar / romper compatibilidad**.

Si una modificación necesariamente cambia un contrato utilizado por múltiples archivos, primero localizar y actualizar todas las referencias compatibles.

---

# 2. ANTES DE MODIFICAR — ANALIZAR

No comenzar creando archivos o código nuevo sin revisar previamente la implementación existente cuando la tarea afecte lógica, arquitectura o datos.

Analizar, según corresponda:

* estructura de `lib/`
* feature involucrada
* widgets existentes
* modelos
* DTOs
* datasources
* repositories
* services
* BLoCs
* Events
* States
* rutas
* providers
* configuración de API
* componentes reutilizables

### Regla de búsqueda de referencias

Cuando se modifique cualquiera de los siguientes elementos:

* constructor
* modelo
* DTO
* Event
* State
* método público
* callback
* servicio
* datasource
* repository
* clase compartida

se deben buscar **todas las referencias y usos** antes de dar la tarea por terminada.

No dejar llamadas incompatibles o constructores antiguos.

---

# 3. ARQUITECTURA EXISTENTE — RESPETARLA

Respetar la arquitectura que ya utiliza el proyecto.

Antes de introducir una nueva solución, comprobar si ya existe una implementación equivalente.

Priorizar:

* reutilización
* composición
* extensión
* componentes compartidos

Evitar:

* duplicación de lógica
* duplicación de modelos
* servicios paralelos innecesarios
* repositories duplicados
* widgets equivalentes con nombres distintos
* múltiples fuentes de verdad para el mismo dato

No introducir una arquitectura diferente únicamente por preferencia personal.

---

# 4. FLUTTER WEB + MÓVIL — RESPONSIVE OBLIGATORIO

Todo componente nuevo o modificado debe funcionar correctamente en:

* Flutter Web
* Desktop/Web responsive
* Tablet
* Móvil

## Breakpoints estándar

```dart
final width = MediaQuery.sizeOf(context).width;
```

Evitar usar `MediaQuery.of(context).size` para obtener únicamente el ancho cuando `sizeOf` sea suficiente.

### Rangos

| Dispositivo |      Ancho | Comportamiento                                      |
| ----------- | ---------: | --------------------------------------------------- |
| Móvil       |    `< 768` | Una columna, scroll horizontal cuando sea necesario |
| Tablet      | `768–1023` | Dos columnas o layout adaptado                      |
| Desktop     |  `>= 1024` | Layout completo                                     |

## Reglas

* Usar `LayoutBuilder` cuando el layout dependa del espacio disponible.
* Formularios: varias columnas en desktop, una columna en móvil.
* Tablas: scroll horizontal en móvil.
* Evitar overflow.
* No asumir una resolución fija.
* No colocar elementos con tamaños rígidos que puedan cortar contenido.
* Botones: texto completo en desktop; texto corto o icono cuando corresponda en móvil.
* Gráficos: deben adaptarse al ancho disponible.

---

# 5. SISTEMA VISUAL — NO INVENTAR UNA IDENTIDAD PARALELA

JHT ya posee una identidad visual.

Usar primero los tokens existentes del proyecto:

`lib/core/theme/maintenance_colors.dart`

o los tokens definidos por el Theme correspondiente.

## Colores principales

| Token                | Hex       | Uso                                     |
| -------------------- | --------- | --------------------------------------- |
| `primary`            | `#303366` | Botones, headers, elementos principales |
| `primaryLight`       | `#EEEEF6` | Fondos sutiles, badges                  |
| `webBackgroundColor` | `#4682B4` | Fondos web definidos por el sistema     |
| `accentColor`        | `#22235A` | Texto/iconos sobre fondos claros        |
| `success`            | `#16A34A` | Éxito                                   |
| `successBg`          | `#DCFCE7` | Fondo de éxito                          |
| `warning`            | `#F59E0B` | Advertencia                             |
| `warningBg`          | `#FEF3C7` | Fondo de advertencia                    |
| `error`              | `#DC2626` | Error                                   |
| `errorBg`            | `#FEE2E2` | Fondo de error                          |
| `info`               | `#2563EB` | Información                             |
| `infoBg`             | `#DBEAFE` | Fondo informativo                       |
| `surface`            | `#F8F9FC` | Fondo de secciones                      |
| `border`             | `#E0E0E8` | Bordes                                  |
| `textPrimary`        | `#1A1A2E` | Texto principal                         |
| `textSecondary`      | `#6B7280` | Texto secundario                        |
| `readonlyBg`         | `#F3F4F6` | Campos readonly                         |

### Reglas de color

1. Preferir `MaintenanceColors`.
2. Si existe un token de Theme equivalente, usarlo.
3. Usar colores literales únicamente cuando no exista token equivalente y el uso esté justificado.
4. No introducir colores arbitrarios para representar estados que ya tienen tokens.
5. No modificar la paleta global para una sola pantalla sin una razón de diseño transversal.

No usar sistemáticamente:

```dart
Colors.red
Colors.blue
Colors.green
```

cuando ya exista un token equivalente.

---

# 6. COMPONENTES REUTILIZABLES

Antes de crear un widget nuevo:

1. Buscar si ya existe un componente equivalente.
2. Reutilizarlo si cumple la necesidad.
3. Extenderlo si necesita una mejora general.
4. Crear uno nuevo solo cuando exista una diferencia funcional o de diseño real.

Los componentes compartidos deben conservar:

* consistencia visual
* comportamiento responsive
* accesibilidad
* estados de carga/error/vacío
* integración con el patrón BLoC cuando corresponda

---

# 7. TABLAS Y LISTADOS

Toda tabla o listado empresarial debe considerar:

### Funcionalidades

* Refresh visible.
* Búsqueda cuando el volumen o el uso lo justifique.
* Debounce de búsqueda de aproximadamente 350 ms.
* Paginación cuando corresponda.
* Contador de registros cuando sea útil.
* Empty state.
* Error state.
* Loading state.
* Reintento.

### Tabla

En móvil, permitir scroll horizontal cuando la estructura no pueda reducirse de forma razonable.

No sacrificar legibilidad solo para evitar el scroll.

### Refresh

Cuando exista una acción de refresh:

* disparar el mecanismo de carga correspondiente;
* preservar arquitectura BLoC/repository;
* resetear página cuando corresponda;
* limpiar búsqueda únicamente si es parte del comportamiento establecido de la feature.

No asumir automáticamente que todo refresh debe borrar filtros existentes.

---

# 8. ESTADOS DE UI

Toda pantalla que dependa de datos debe contemplar al menos:

### Loading

Usar Skeleton cuando la pantalla tenga una estructura conocida.

### Empty

Mostrar:

* icono o elemento visual apropiado
* mensaje descriptivo
* acción de recuperación cuando exista

### Error

Mostrar:

* mensaje claro
* botón de reintentar cuando corresponda

### Success

Mostrar los datos normalmente.

### Regla

Nunca dejar una pantalla simplemente en blanco cuando la ausencia de contenido sea consecuencia de:

* carga
* error
* consulta sin resultados

---

# 9. CARGA Y FEEDBACK

## Carga inicial

Preferir Skeleton Loader cuando exista una estructura de contenido identificable.

Los mensajes deben describir la operación:

* `Cargando mantenimientos...`
* `Obteniendo vehículos...`
* `Consultando proveedores...`

Evitar mensajes genéricos como:

`Cargando...`

cuando pueda especificarse qué se está cargando.

## Acciones de escritura

Para operaciones como:

* guardar
* actualizar
* eliminar

mostrar feedback visual apropiado.

No permitir que una acción crítica parezca congelada.

---

# 10. NOTIFICACIONES

Utilizar el componente establecido en el proyecto:

`AppNotification`

según corresponda.

### Convenciones

| Situación         | Tipo      |
| ----------------- | --------- |
| Operación exitosa | `success` |
| Error             | `error`   |
| Advertencia       | `warning` |
| Información       | `info`    |

Usar SnackBar cuando la interacción sea ligera.

Usar diálogo cuando la notificación deba permanecer dentro de un modal o requiera interacción.

No introducir múltiples sistemas de notificación sin necesidad.

---

# 11. MODALES Y ACCIONES DESTRUCTIVAS

Para confirmar acciones destructivas:

* usar `showDialog`
* botón Cancelar claramente visible
* botón Confirmar claramente diferenciado
* mensaje específico
* no utilizar mensajes vagos como `¿Estás seguro?`

Ejemplo:

> ¿Desea eliminar el mantenimiento del vehículo ABC-123?

Después de una operación exitosa:

* cerrar modal según corresponda
* actualizar la fuente de datos
* mostrar confirmación

Respetar los callbacks y Events existentes.

---

# 12. MICROINTERACCIONES Y ANIMACIONES

Las animaciones deben mejorar la percepción de calidad sin perjudicar rendimiento.

Preferir:

* `AnimatedSwitcher`
* `AnimatedOpacity`
* transiciones breves
* hover sutil en Web/Desktop
* feedback de tap en móvil

### Duración recomendada

Entre:

`150–300 ms`

### Regla

No animar todo.

Animar principalmente:

* entrada/salida
* cambios de estado
* hover
* feedback de interacción

En móvil no depender del hover.

---

# 13. ACCESIBILIDAD

Los elementos interactivos y visuales importantes deben ser comprensibles.

### Tooltips

Usar `Tooltip` en botones de solo icono:

* refresh
* editar
* eliminar
* menú
* ayuda

### Semantics

Usar `Semantics` cuando un elemento visual transmita información relevante que no sea obvia para tecnologías asistivas.

### Selección de texto

Cuando sea útil en Web, considerar `SelectionArea`.

### Contraste

Mantener contraste adecuado entre texto y fondo.

No utilizar texto claro sobre fondos claros ni texto oscuro sobre fondos oscuros.

---

# 14. FORMULARIOS

Todo formulario nuevo debe seguir el patrón existente del proyecto.

Preferir:

```dart
final _formKey = GlobalKey<FormState>();
```

Validar antes de llamar al backend.

### Mensajes

Los errores deben ser específicos:

Correcto:

> La placa del vehículo es obligatoria.

Incorrecto:

> Error.

### Layout

* Desktop: varias columnas cuando sea apropiado.
* Móvil: una columna.
* Usar `Wrap`, `Expanded`, `Flexible` o `LayoutBuilder` según el contexto.

No fijar anchos que produzcan overflow.
