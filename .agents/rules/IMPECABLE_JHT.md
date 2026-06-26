---
trigger: always_on
---

# Directrices de Diseño, UX y Calidad — JHT Transport (Flutter)

Eres un desarrollador Flutter experto que genera interfaces premium, optimizadas y adaptables.
Esta aplicación funciona tanto en **Web** como en **App Móvil** — todo componente DEBE ser responsive.

> ⚠️ **REGLA MÁXIMA**: La lógica backend, APIs, endpoints, variables, funciones, callbacks y estados
> existentes están **EN PRODUCCIÓN**. NUNCA eliminar, renombrar ni modificar lógica existente sin
> confirmación explícita del usuario. Un cambio descuidado rompe la aplicación para usuarios reales.

---

## 🎨 1. PALETA DE COLORES — NO MODIFICAR

Los colores del sistema ya están definidos y en uso. NUNCA uses colores genéricos
(`Colors.red`, `Colors.blue`, `Colors.green`).
Usa SIEMPRE los tokens de `MaintenanceColors` (`lib/core/theme/maintenance_colors.dart`)
o los colores definidos en `LoginPage`:

| Token                  | Hex       | Uso                                     |
|------------------------|-----------|-----------------------------------------|
| `primary`              | `#303366` | Botones, headers, texto principal        |
| `primaryLight`         | `#EEEEF6` | Fondos sutiles, badges                   |
| `webBackgroundColor`   | `#4682B4` | Fondo azul para vistas web               |
| `accentColor`          | `#22235A` | Texto/Íconos sobre fondos claros         |
| `success / successBg`  | `#16A34A` / `#DCFCE7` | Operaciones exitosas      |
| `warning / warningBg`  | `#FEF3C7` / `#F59E0B` | Advertencias              |
| `error / errorBg`      | `#DC2626` / `#FEE2E2` | Errores                   |
| `info / infoBg`        | `#2563EB` / `#DBEAFE` | Confirmaciones, guardados |
| `surface`              | `#F8F9FC` | Fondo de secciones                       |
| `border`               | `#E0E0E8` | Bordes de campos y tarjetas              |
| `textPrimary`          | `#1A1A2E` | Texto principal                          |
| `textSecondary`        | `#6B7280` | Texto secundario                         |
| `readonlyBg`           | `#F3F4F6` | Fondo para campos de solo lectura        |

Si necesitas una variante de opacidad, usa `.withOpacity()` sobre estos tokens, no inventes colores.

---

## 📱 2. RESPONSIVIDAD — WEB + MÓVIL

### Breakpoints

```dart
// ✅ CORRECTO — usar sizeOf (más eficiente, evita rebuilds innecesarios)
final width = MediaQuery.sizeOf(context).width;

// ❌ INCORRECTO — causa rebuilds cuando cambian cosas que no son el tamaño
final width = MediaQuery.of(context).size.width;
```

| Breakpoint | Rango              | Comportamiento                              |
|------------|--------------------|---------------------------------------------|
| Móvil      | `width < 768`      | Columna única, tablas con scroll horizontal  |
| Tablet     | `768 ≤ width < 1024` | 2 columnas, tablas adaptadas               |
| Desktop    | `width ≥ 1024`     | Layout completo, tablas sin scroll           |

### Reglas de adaptación

- Usar `LayoutBuilder` para adaptar tablas y formularios al ancho disponible.
- Las tablas deben usar `SingleChildScrollView` horizontal en móvil.
- Los formularios deben pasar de columnas múltiples (desktop) a columna única (móvil).
- Textos, paddings e íconos deben escalar según el breakpoint.
- Botones de acción: texto completo en desktop, solo ícono o texto corto en móvil.

---

## 📊 3. GRIDS / TABLAS DE REGISTROS

Toda tabla de datos (DataTable, grids) DEBE incluir:

1. **Botón de Refresh** visible en el header de la tabla (icono `Icons.refresh_rounded`).
   Al presionar: disparar evento de carga del BLoC, resetear página a 1, limpiar búsqueda.
2. **Barra de búsqueda** con debounce de 350ms (`Timer` de `dart:async`).
3. **PaginationWidget** (`lib/core/widgets/pagination_widget.dart`) debajo de la tabla.
4. **Badge contador** que muestre "X de Y" registros filtrados vs totales.
5. **Empty state** con ícono, mensaje descriptivo y acción (limpiar búsqueda o reintentar).
6. **Filas alternadas** con colores: `Color(0xFFF7F8FC)` para pares, `Colors.white` para impares.
7. **Header de columnas** con fondo `Color(0xFF303366)` y texto blanco.

### Flujo al cerrar un modal por confirmación:

```
Modal confirma → Navigator.pop() → callback onXxxAdded/onXxxActualizado
→ BLoC.add(RefreshXxxEvent()) → Grid se actualiza → AppNotification.success()
```

---

## ⏳ 4. ESTADOS DE CARGA — SKELETON + SPINNERS

### 4.1 Carga inicial (primera vez que se abre una página)

Mostrar **Skeleton Loader con efecto shimmer** — cajas grises con degradado animado que
recorre de izquierda a derecha, simulando la estructura real de la tabla.

```dart
// Efecto shimmer animado (no cajas estáticas)
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  // ... implementar con AnimationController + LinearGradient animado
}
```

Siempre acompañar con un mensaje descriptivo de lo que está sucediendo:
- ✅ "Cargando mantenimientos..."
- ✅ "Obteniendo listado de vehículos..."
- ✅ "Consultando proveedores..."
- ❌ "Cargando..." (demasiado genérico)

### 4.2 Carga de acciones (guardar, actualizar, eliminar)

Mostrar un **AlertDialog de carga** con spinner y mensaje:

```dart
AlertDialog(
  backgroundColor: const Color(0xFF303366),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const CircularProgressIndicator(color: Colors.white),
      const SizedBox(height: 20),
      Text('Guardando registro...', // ← mensaje descriptivo
        style: TextStyle(color: Colors.white, fontSize: 16)),
    ],
  ),
)
```

- `barrierDismissible: false` — no permitir cerrar durante la operación.
- Cerrar el dialog programáticamente cuando la operación termine.

### 4.3 Recarga de datos (refresh con cache existente)

- Si ya hay datos en cache (`_cachedXxx != null`), **NO** mostrar skeleton ni dialog.
- Actualizar datos silenciosamente en background.
- Solo mostrar feedback si hay error (`AppNotification.error()`).

---

## 🔔 5. NOTIFICACIONES — SNACKBAR vs ALERTDIALOG

Usar SIEMPRE `AppNotification` (de `lib/core/widgets/app_notification.dart`):

| Situación | Método | Widget resultante |
|---|---|---|
| Ventana se cierra por confirmación exitosa | `AppNotification.success()` | SnackBar verde |
| Error al guardar/actualizar/eliminar | `AppNotification.error()` | SnackBar rojo |
| Advertencia (datos incompletos, conflictos) | `AppNotification.warning()` | SnackBar ámbar |
| Información general | `AppNotification.info()` | SnackBar azul |
| Cualquier notificación **dentro de un modal abierto** | Cualquier tipo + `isModal: true` | AlertDialog |

### AlertDialogs de confirmación (¿Estás seguro?)

- Mostrarse encima de la ventana actual con `showDialog`.
- Botón **"Cancelar"** → `TextButton` (texto plano).
- Botón **"Confirmar"** → `ElevatedButton` con `backgroundColor: Color(0xFF303366)`.
- Mensaje claro: "¿Desea eliminar el mantenimiento del vehículo ABC-123?"
- Nunca preguntas vagas como "¿Estás seguro?".

---

## ✨ 6. MICRO-ANIMACIONES Y TRANSICIONES

La interfaz debe sentirse **viva y responsiva**. Aplicar animaciones sutiles:

### Transiciones entre estados

```dart
// Usar AnimatedSwitcher para transiciones suaves entre loading → data → error
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: _isLoading ? _buildSkeleton() : _buildTable(),
)
```

### Apariciones de elementos

```dart
// Elementos que aparecen suavemente
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 250),
  child: myWidget,
)
```

### Hover effects (Web/Desktop)

En web, los elementos clickeables deben reaccionar al hover del cursor:

```dart
// Botones y cards con efecto hover
MouseRegion(
  cursor: SystemMouseCursors.click,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    transform: _isHovered
        ? (Matrix4.identity()..scale(1.02))
        : Matrix4.identity(),
    decoration: BoxDecoration(
      boxShadow: _isHovered
          ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)]
          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: child,
  ),
)
```

### Reglas generales de animación

- Duración estándar: **150–300ms** (rápido pero perceptible).
- Curva estándar: `Curves.easeInOut` para la mayoría, `Curves.elasticOut` para bounces.
- NO animar todo — solo transiciones de estado, hover, y apariciones.
- En **móvil**: omitir hover effects, priorizar animaciones de tap (`InkWell` splash).

---

## 📝 7. FORMULARIOS Y VALIDACIÓN

### Estructura consistente

```dart
// Todo formulario debe usar Form + GlobalKey
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    ),
  ]),
)

// Al guardar:
if (_formKey.currentState!.validate()) {
  // Proceder con el guardado
}
```

### Reglas de validación

- Campos obligatorios: mostrar `*` rojo junto al label.
- Validar antes de enviar al backend — no desperdiciar llamadas API.
- Mensajes de error en español, descriptivos: "La placa del vehículo es obligatoria".
- Campos readonly: usar fondo `MaintenanceColors.readonlyBg` (`#F3F4F6`).
- Layouts de formulario: `Wrap` o `Row` con `Expanded` en desktop, `Column` en móvil.

---

## ♿ 8. ACCESIBILIDAD

### Mínimos obligatorios

- **Tooltip** en todo botón de solo ícono (refresh, editar, eliminar, menú):
  ```dart
  Tooltip(
    message: 'Actualizar registros',
    child: IconButton(
      icon: const Icon(Icons.refresh_rounded),
      onPressed: _onRefresh,
    ),
  )
  ```

- **Semantics** en elementos visuales que transmiten información:
  ```dart
  Semantics(
    label: 'Estado: Pendiente',
    child: _buildStatusBadge('Pendiente'),
  )
  ```

- **SelectionArea** para textos que el usuario podría querer copiar (web):
  ```dart
  // Envolver tablas o secciones de texto en web
  if (kIsWeb) SelectionArea(child: _buildTable())
  ```

- Contraste de texto: el texto sobre `#303366` debe ser siempre **blanco**.
- El texto sobre fondo blanco/claro debe ser `textPrimary` (`#1A1A2E`) o `textSecondary` (`#6B7280`).

---

## ⚡ 9. RENDIMIENTO Y OPTIMIZACIÓN

### Widgets

- Usar `const` constructors en todo widget inmutable — esto evita rebuilds.
- Usar `ListView.builder` / `SliverList` para listas largas (nunca `Column` con `.map()`).
- Envolver widgets complejos con `RepaintBoundary` para aislar repaints:
  ```dart
  RepaintBoundary(child: _buildComplexChart())
  ```

### Rebuilds

- Preferir `BlocBuilder` con `buildWhen` para evitar rebuilds innecesarios:
  ```dart
  BlocBuilder<MyBloc, MyState>(
    buildWhen: (prev, curr) => prev.items != curr.items,
    builder: (context, state) => _buildList(state.items),
  )
  ```
- NO usar `setState` cuando hay un BLoC disponible — preferir estados tipados.

### Búsquedas

- Implementar **debounce** de 350ms mínimo en todas las barras de búsqueda.
- Cachear datos en el `State` (`_cachedXxx`) para evitar parpadeos durante recargas.

### Scroll

- No anidar `ScrollView` dentro de `ScrollView` sin `NeverScrollableScrollPhysics`.
- Usar `CustomScrollView` con Slivers para layouts complejos con AppBar.

### Datos

- Paginación local con `_getPageItems()` para conjuntos pequeños-medianos.
- Evitar recargar datos si la última carga fue hace menos de 30 segundos (salvo refresh manual).

---

## 🔒 10. SEGURIDAD ASYNC — `context.mounted`

Después de **todo** `await`, verificar que el contexto sigue vivo antes de usarlo:

```dart
// ✅ CORRECTO — siempre verificar mounted después de await
Future<void> _guardarRegistro() async {
  final result = await _repository.guardar(datos);
  if (!context.mounted) return; // ← OBLIGATORIO

  if (result.isRight) {
    AppNotification.success(context, 'Registro guardado');
    Navigator.pop(context);
  } else {
    AppNotification.error(context, 'Error al guardar');
  }
}

// ❌ INCORRECTO — puede crashear si el widget fue desmontado
Future<void> _guardarRegistro() async {
  final result = await _repository.guardar(datos);
  AppNotification.success(context, 'Registro guardado'); // 💥 CRASH
}
```

Esta regla aplica a:
- Llamadas a la API (`await http.get/post/put`)
- Operaciones de BLoC que usan context después
- `showDialog` / `Navigator.pop` después de operaciones async
- Cualquier uso de `ScaffoldMessenger.of(context)` después de un await

---

## 🛡️ 11. PROTECCIÓN DEL CÓDIGO EXISTENTE — REGLA CRÍTICA

### ⚠️ PRODUCCIÓN ACTIVA — NO ROMPER

La aplicación tiene usuarios reales. Cualquier cambio descuidado puede dejar la app inoperativa.

**NUNCA hacer sin confirmación explícita del usuario:**
- ❌ Eliminar funciones, variables, imports o clases existentes
- ❌ Cambiar endpoints, headers, body o lógica de autenticación (JWT)
- ❌ Modificar la estructura de Events/States de BLoCs existentes
- ❌ Renombrar callbacks (`onXxxAdded`, `onXxxActualizado`, `onXxxDeleted`)
- ❌ Cambiar la firma de constructores de widgets que se usan en múltiples lugares
- ❌ Eliminar o modificar `AppLogger` calls existentes

**SIEMPRE hacer antes de cualquier cambio:**
- ✅ Verificar que el código a modificar no es usado en otro archivo (buscar referencias)
- ✅ Explicar qué vas a cambiar y por qué antes de hacerlo
- ✅ Mantener compatibilidad hacia atrás — agregar, no reemplazar
- ✅ Si hay duda, preguntar al usuario

### Archivos críticos — modificar con extremo cuidado:
- `lib/main.dart` — punto de entrada, providers, rutas
- `lib/core/network/` — configuración HTTP, interceptores, token
- `lib/core/services/` — servicios compartidos
- `lib/features/login/` — autenticación, JWT, sesión
- `lib/features/shared/` — widgets y mixins compartidos entre features
- `.agents/rules/API_JHT.md` — endpoints reales del backend

---

## 🧩 12. PATRONES EXISTENTES A RESPETAR

Estos patrones ya están implementados y funcionan. Seguirlos en toda feature nueva:

| Patrón | Implementación |
|---|---|
| **Navegación** | `NavigationHelperMixin` + `SideMenu` con `endDrawer` |
| **Estado** | BLoC con Events tipados → States tipados → UI reacciona con `BlocBuilder`/`BlocListener` |
| **Modales** | `showDialog` + `barrierDismissible: false` + `BlocProvider.value` para pasar el BLoC |
| **AppBar** | `SliverAppBar` pinned, título "JHT TRANSPORT" en `Color(0xFF303366)` |
| **Notificaciones** | `AppNotification.success/error/warning/info()` |
| **Paginación** | `PaginationWidget` con cache local + búsqueda con debounce |
| **Footer** | `_buildCopyright()` al final de cada página |
| **Logging** | `AppLogger` para navegación, errores y acciones críticas |
| **Colores** | `MaintenanceColors` como design tokens centralizados |

---

## 🎯 13. EXPERIENCIA DE USUARIO — PRINCIPIOS

El usuario debe sentirse confiado y cómodo en cada interacción:

1. **Feedback inmediato**: Toda acción produce respuesta visual (spinner, snackbar, cambio de estado).
2. **Sin pantallas en blanco**: Siempre skeleton, empty state, o error — nunca espacio vacío.
3. **Mensajes descriptivos**: Describir QUÉ está pasando, no mensajes genéricos.
4. **Flujo natural**: Crear/editar → cerrar modal → refrescar grid → confirmar con snackbar.
5. **Consistencia**: Todas las páginas siguen el mismo patrón visual y de interacción.
6. **Prevención de errores**: Validar formularios antes de enviar, confirmar acciones destructivas.
7. **Recuperación fácil**: Botón reintentar en errores, botón refresh siempre visible.
8. **Optimización**: La app debe fluir sin lag en web y móvil — evitar sobrecarga.
