# Evidencias — Recetario UTEZ

**Nombre: Jonathan Alberto Barrera Calderon**
**Matrícula:I20233tn110**
**Fecha:** 3 de noviembre de 2026
**Dispositivo donde se probó:** Google Chrome en Windows, con la app en localhost:8080. Porque mi compu esta muriendo y no tengo tanto espacio y tuve que borrar cosas con las cuales ya no puedo emular ni en web jaja

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla |
|---|---|---|---|
| `id` | `id` | `int` | Obligatorio. Si falta o no es entero, se lanza `FormatException`. |
| `name` | `nombre` | `String` | Obligatorio. Debe ser texto. |
| `cuisine` | `cocina` | `String` | Obligatorio. Debe ser texto. |
| `prepTimeMinutes` | `minutosPreparacion` | `int` | Obligatorio. Debe ser entero. |
| `cookTimeMinutes` | `minutosCoccion` | `int` | Obligatorio. Debe ser entero. |
| `servings` | `porciones` | `int` | Obligatorio. Debe ser entero. |
| `rating` | `calificacion` | `double` | Obligatorio. Acepta un entero o un decimal y se convierte con `toDouble()`. |
| `difficulty` | `dificultad` | `Dificultad` | `Easy`, `Medium` y `Hard` se convierten en `facil`, `media` y `dificil`. Si falta o llega otro valor, se usa `desconocida`. |
| `tags` | `etiquetas` | `List<String>` | Opcional. Si falta, queda vacía. Si viene, debe ser una lista formada solo por textos; de lo contrario, se lanza `FormatException`. |
| `ingredients` | `ingredientes` | `List<String>` | Opcional. Tiene la misma validación que `tags`. |
| `recipes` | `recetas` | `List<Receta>` | Obligatorio en la página. Cada elemento debe ser un objeto válido y se convierte con `recetaDesdeJson`. Una lista vacía es válida. |
| `total` | `total` | `int` | Obligatorio en la página. Conserva el total que responde el servidor. |

Los campos que no utiliza la app se ignoran. El tiempo total se obtiene sumando preparación y cocción. Una receta se considera rápida cuando tarda 30 minutos o menos.

## 2. Escenarios probados con el servicio real

| Escenario | Cómo lo provoqué | Qué vio la persona | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|---|---|---|---|
| Éxito | Busqué `Chicken` con la conexión activa. | Aparecieron las tarjetas y el encabezado “Mostrando 8 de 8 recetas · Rápidas: 1”. Cada tarjeta mostró nombre, cocina, dificultad, tiempo, porciones y calificación. | `← 200 GET /recipes/search (969 ms)` | [Éxito](capturas/1_exito.png) | `etapa3_datos_test.dart`: “200 → PaginaRecetas”; `etapa5_vistas_test.dart`: “texto + botón → indicador y botón apagado → tarjetas”. |
| Vacío | Busqué `zzzz`, un texto sin coincidencias. | Apareció “No encontramos recetas para "zzzz".” y no se mostraron tarjetas. | `← 200 GET /recipes/search (311 ms)` | [Vacío](capturas/2_vacio.png) | `etapa3_datos_test.dart`: “200 sin resultados → página vacía”; `etapa5_vistas_test.dart`: “vacío con texto dice qué se buscó; sin texto, otro mensaje”. |
| Error del servidor | Usé el cambio temporal A para dirigir la petición a `/http/503` en DummyJSON y presioné Buscar recetas. | Apareció “El recetario no está disponible (503). Intenta más tarde.” junto al botón Reintentar. | `✗ badResponse 503 GET /http/503 (723 ms)` | [Error del servidor](capturas/3_ErrorServidor.png) | `etapa3_datos_test.dart`: “503 → ErrorDelServidor(503)” y “en un error escribe una línea con ✗ y el código”. |
| Sin red | Usé el cambio temporal C para dirigir la petición a `https://recetario.invalid`, un dominio que no existe. | Apareció “Sin conexión. Revisa tu red e intenta de nuevo.” junto al botón Reintentar. | `✗ connectionError GET /recipes (29 ms)` | [Sin red](capturas/4_SinRed.png) | `etapa3_datos_test.dart`: “sin red → SinConexion”; `etapa5_vistas_test.dart`: “error → mensaje y Reintentar repite la misma búsqueda”. |
| Tiempo agotado | Usé el cambio temporal B: agregué `delay: 5000` a la petición y bajé los tiempos de conexión y recepción a 2 segundos. | Apareció “El recetario tardó demasiado en responder. Intenta de nuevo.” junto al botón Reintentar. | `✗ receiveTimeout GET /recipes (2115 ms)` | [Tiempo agotado](capturas/5_TiempoAgotado.png) | `etapa3_datos_test.dart`: “connectTimeout → TiempoAgotado” y “receiveTimeout → TiempoAgotado”. |

Las capturas corresponden a la ejecución en Chrome. Las líneas de bitácora se obtuvieron al repetir los cinco escenarios con el mismo repositorio y cliente Dio desde Dart. Las duraciones corresponden a esa repetición y pueden variar entre ejecuciones.

La versión final de `main.dart` utiliza la conexión normal con DummyJSON. Los cambios A, B y C se utilizaron únicamente para provocar los escenarios.

## 3. Preguntas de reflexión

### 1. ¿En qué se diferencian el escenario “Error del servidor” y “Sin red” desde el punto de vista de HTTP?

En el error del servidor sí llegó una respuesta HTTP: el servicio contestó con el código 503. En el caso sin red no se consiguió una respuesta HTTP del servicio, por lo que no hay un código de estado que mostrar. Aunque ambos impiden consultar las recetas, la causa es diferente.

### 2. ¿Por qué “Vacío” no es un error?

Porque la petición se pudo completar y el servidor respondió correctamente con un 200. Simplemente no encontró recetas para ese texto y devolvió una lista vacía. Por eso la pantalla muestra que no hubo coincidencias en lugar de un mensaje de falla.

### 3. La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?

La bitácora usa la ruta de la petición, como `/recipes/search`, sin incluir sus parámetros. Con el método, la ruta, el código y la duración alcanza para revisar cómo salió la consulta. No hace falta guardar lo que escribió la persona ni el contenido de la respuesta.

### 4. Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?

En el código de la app cambiaría `lib/datos/recetas_json.dart`, porque ahí se lee la llave `rating` y se convierte al campo `calificacion`. El modelo, el ViewModel y las tarjetas seguirían usando `calificacion`, así que no necesitarían cambiar. Para comprobar el nuevo contrato también harían falta ejemplos y pruebas que usaran `score`; el kit entregado para esta práctica se conserva sin modificar.
