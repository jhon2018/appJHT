---
trigger: always_on
---

15. RENDIMIENTO

Priorizar rendimiento sin sobreingeniería.

Widgets
Usar const cuando sea válido.
Usar ListView.builder para listas potencialmente largas.
Evitar reconstrucciones innecesarias.
Usar RepaintBoundary cuando realmente aporte beneficio.
BLoC

Cuando sea apropiado, utilizar:

buildWhen

para evitar rebuilds innecesarios.

No utilizar setState para lógica que ya pertenece a un BLoC.

Datos
Evitar llamadas API innecesarias.
Reutilizar cache cuando exista una estrategia establecida.
No implementar cache improvisado que contradiga el comportamiento existente.
Regla

No optimizar prematuramente a costa de complicar la arquitectura.

16. ASYNC — context.mounted

Después de una operación await, antes de utilizar context, verificar que el widget siga montado.

Ejemplo:

final result = await repository.guardar(datos);

if (!context.mounted) return;

if (result.isRight) {
  AppNotification.success(context, 'Registro guardado');
}

Aplica especialmente a:

HTTP
repository calls
dialogs
Navigator
SnackBar
ScaffoldMessenger
BLoC callbacks que utilicen context
17. API Y BACKEND — NO DUPLICAR RESPONSABILIDADES

Antes de crear un filtro, cálculo o transformación, determinar dónde corresponde la responsabilidad:

Backend

Preferir backend cuando:

se consulta un volumen grande de datos;
se requiere agregación sobre información que no está cargada en frontend;
se necesitan GROUP BY, filtros complejos o cálculos globales;
la API ya expone una consulta agregada;
existe una razón de seguridad o autorización.
Frontend

Puede resolverlo Flutter cuando:

los datos necesarios ya fueron descargados;
solo necesita filtrado local sencillo;
se requiere ordenar o presentar información;
el cálculo es de UI y no de lógica de negocio central.
Regla

No duplicar un cálculo en Flutter si el backend ya entrega el resultado agregado y ese resultado representa el contrato oficial.

No crear endpoints nuevos únicamente porque Flutter puede resolver el problema localmente.

18. MOCK DATA

Los datos Mock deben servir para desarrollar y validar la interfaz, no para ocultar problemas.

Cuando exista una API real:

el Mock debe respetar el contrato conceptual de la API;
los nombres y significados de campos deben ser coherentes;
los estados deben representar casos reales;
las combinaciones de filtros deben producir resultados lógicos.
Prohibido

Cambiar números arbitrariamente únicamente para que:

“parezca que el filtro funciona”.

Ejemplo no válido:

Si año = 2025, dividir todos los costos entre 2.

Preferido

Usar un conjunto de registros Mock coherente y aplicar sobre ellos la misma lógica conceptual de filtrado/agregación que utilizaría la API.

Cuando posteriormente se conecte la API real, la UI debería requerir cambios mínimos.

19. CAMBIOS EN MODELOS Y CONTRATOS

Cuando un modelo existente cambie:

Revisar todos sus constructores.
Buscar todas las instancias.
Revisar serialización/deserialización.
Revisar mocks.
Revisar datasource.
Revisar repositories.
Revisar widgets que consumen el campo.
Ejecutar validación completa.
Regla crítica

Nunca modificar un constructor para agregar un parámetro requerido y dar por terminada la tarea sin actualizar todas las instancias afectadas.

No convertir automáticamente un campo en opcional solo para hacer desaparecer errores.

Primero determinar si el campo debe ser realmente obligatorio.

20. NAVEGACIÓN

Respetar los mecanismos de navegación existentes.

En JHT se utilizan patrones establecidos como:

NavigationHelperMixin
SideMenu
endDrawer

No introducir un sistema paralelo de navegación sin una razón de arquitectura.

No modificar rutas existentes sin revisar todas sus referencias.

21. PATRONES DEL PROYECTO

Respetar los patrones existentes:

Área	Patrón
Estado	BLoC con Events y States tipados
UI reactiva	BlocBuilder / BlocListener
Navegación	patrones existentes de JHT
Modales	showDialog
Notificaciones	AppNotification
Paginación	PaginationWidget cuando corresponda
Colores	MaintenanceColors / Theme
Logging	AppLogger
Responsive	LayoutBuilder + breakpoints
API	datasource/repository existentes

No reemplazar estos patrones por otros solo por preferencia personal.

22. ARCHIVOS CRÍTICOS

Modificar con extremo cuidado:

lib/main.dart
lib/core/network/
lib/core/services/
lib/features/login/
lib/features/shared/
.agents/rules/API_JHT.md

Antes de tocar cualquiera de ellos:

Analizar referencias.
Determinar impacto.
Mantener compatibilidad.
Validar regresiones.
23. LOGGING

Respetar los mecanismos existentes de logging.

No eliminar llamadas de AppLogger porque parezcan innecesarias sin analizar su propósito.

Cuando se agreguen logs:

registrar acciones relevantes;
registrar errores;
evitar información sensible;
evitar tokens, contraseñas o credenciales.
24. SEGURIDAD

Nunca exponer:

tokens JWT
contraseñas
credenciales
secretos
información sensible

en:

logs
mensajes al usuario
Mock
commits
código de UI

No cambiar el mecanismo de autenticación sin autorización explícita.

25. VALIDACIÓN — NO DECLARAR ÉXITO PREMATURAMENTE

Una tarea de desarrollo no está terminada únicamente porque el código parezca correcto.

La validación debe incluir, cuando corresponda:

Análisis estático
flutter analyze
Tests
flutter test

si existen tests aplicables.

Compilación / ejecución

Probar la plataforma afectada, por ejemplo:

flutter run -d chrome

para Flutter Web, o la plataforma correspondiente.

Regla crítica

flutter analyze no sustituye la compilación.

No declarar:

“Implementación completa”

si la aplicación sigue sin compilar en la plataforma objetivo.

26. VALIDACIÓN DE REGRESIÓN

Después de una modificación importante, verificar:

la pantalla afectada;
navegación;
APIs relacionadas;
componentes compartidos;
estados loading/error/empty;
formularios relacionados;
acciones CRUD;
responsive;
autenticación si fue tocada;
funcionalidades directamente dependientes del cambio.

Si se modifica un modelo compartido, validar todas las features que lo utilizan.

27. MANEJO DE ERRORES DE COMPILACIÓN

Cuando aparezcan errores:

No corregir solamente el primer error.
Agrupar errores por causa raíz.
Identificar si un error produce muchos errores secundarios.
Corregir la causa raíz.
Volver a ejecutar flutter analyze.
Volver a compilar.
Repetir hasta obtener un resultado limpio o dejar documentados los bloqueos externos.
Importante

No ocultar errores haciendo cambios superficiales.

No comentar código simplemente para conseguir una compilación verde.

No convertir tipos estrictos en dynamic sin justificación.

28. COMUNICACIÓN Y AUTONOMÍA DEL AGENTE

Antes de modificar arquitectura, contratos, APIs, modelos compartidos o archivos críticos:

analizar primero;
explicar brevemente el impacto;
ejecutar la solución segura.

Para cambios locales de UI de bajo riesgo:

no es necesario detenerse para pedir aprobación por cada detalle;
implementar directamente respetando estas reglas.
Cuando exista ambigüedad

Primero:

inspeccionar el proyecto;
buscar referencias;
revisar modelos;
revisar API;
revisar patrones existentes.

Preguntar al usuario únicamente cuando:

existan varias alternativas técnicamente válidas con impactos distintos;
se requiera una decisión de negocio;
exista riesgo real de romper una funcionalidad;
falte información que no puede obtenerse del proyecto.

No preguntar por detalles que pueden resolverse razonablemente mediante inspección.

29. PRINCIPIOS DE UX

La experiencia debe transmitir:

Feedback inmediato

Toda acción importante debe producir una respuesta visual.

No pantallas en blanco

Siempre debe existir loading, contenido, empty state o error.

Mensajes claros

Explicar qué ocurre y qué puede hacer el usuario.

Consistencia

Una misma acción debe comportarse igual en diferentes módulos.

Prevención

Validar formularios y confirmar acciones destructivas.

Recuperación

Permitir reintentar cuando exista una operación fallida.

Claridad

La interfaz debe priorizar información útil sobre decoración.

30. DASHBOARDS Y VISUALIZACIÓN

Cuando una feature corresponda a un Dashboard:

priorizar jerarquía de información;
separar operación de análisis cuando el contexto lo justifique;
utilizar KPIs relevantes;
evitar gráficos decorativos;
asegurar que cada gráfico tenga significado;
proporcionar contexto mediante títulos y Tooltips cuando sea útil;
respetar los filtros aplicados;
evitar contradicciones entre tarjetas, gráficos y tablas.

Los Mock Data utilizados para dashboards deben representar comportamientos coherentes.

31. REGLA DE NEGOCIO VS REGLA DE PRESENTACIÓN

No mover lógica de negocio al UI simplemente porque sea más fácil.

Distinción:

Lógica de negocio

Debe mantenerse donde corresponda según la arquitectura.

Lógica de presentación

Puede vivir en widgets, selectors o helpers específicos.

Formateo

Moneda, fecha, porcentaje y labels son principalmente presentación, salvo que formen parte de una regla de negocio oficial.

32. DEFINICIÓN DE “TERMINADO”

Una tarea se considera terminada cuando:

la implementación cumple el requerimiento;
no rompe funcionalidades existentes;
las referencias fueron revisadas;
los modelos y constructores son compatibles;
flutter analyze está correcto o los problemas restantes están documentados;
la aplicación compila en la plataforma objetivo cuando corresponde;
la UI fue validada en el contexto afectado;
no quedan errores conocidos introducidos por el cambio.
No considerar terminado si:
solo se escribió código;
solo pasó flutter analyze;
existen errores de compilación;
existen imports rotos;
existen referencias incompatibles;
se ocultaron errores con dynamic, comentarios o código muerto.
33. PRINCIPIO FINAL

Cuando exista duda entre:

hacer un cambio rápido

y

hacer un cambio seguro y compatible con la arquitectura existente,

priorizar siempre la segunda opción.

El objetivo no es únicamente producir código.

El objetivo es mantener y evolucionar JHT Transport de forma:

segura + profesional + mantenible + responsive + consistente + verificable.