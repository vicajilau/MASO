# Manual de Usuario - MASO

## Introducción

### ¿Qué es MASO?

MASO (Simulador Multiplataforma para el Aprendizaje de Sistemas Operativos) es una herramienta educativa diseñada para ayudar a estudiantes y profesionales a comprender los conceptos fundamentales de la planificación de procesos en sistemas operativos.

### Características Principales

- **Interfaz Intuitiva**: Diseño moderno y fácil de usar que permite una experiencia de aprendizaje fluida
- **Simulación Realista**: Experimenta cómo se ejecutan los procesos en un sistema operativo a través de simulaciones precisas
- **Múltiples Algoritmos**: Incluye 8 algoritmos de planificación diferentes para comparar y estudiar
- **Visualización Dinámica**: Observa la ejecución de procesos mediante diagramas de Gantt interactivos
- **Personalización Completa**: Ajusta todos los parámetros de simulación según tus necesidades
- **Multiplataforma**: Disponible para Windows, macOS, Linux y Web

### Algoritmos Soportados

1. **FCFS** (First Come First Served - Primero en Llegar, Primero en Ser Atendido)
2. **SJF** (Shortest Job First - Trabajo Más Corto Primero)
3. **SRTF** (Shortest Remaining Time First - Tiempo Restante Más Corto Primero)
4. **Round Robin** (Planificación Circular)
5. **Prioridad**
6. **Colas Múltiples de Prioridad**
7. **Colas Múltiples de Prioridad con Retroalimentación**
8. **Límite de Tiempo**

---

## 2. Instalación

MASO requiere tener Flutter instalado en tu sistema. La forma de usar la aplicación es:

1. **Instalar Flutter**: Descarga e instala Flutter SDK desde la página oficial de Flutter siguiendo las instrucciones para tu sistema operativo
2. **Clonar el repositorio**: Obtén el código fuente del proyecto
3. **Ejecutar MASO**: Arranca la aplicación en la plataforma que desees (Windows, macOS, Linux o Web)

### Pasos detallados

**1. Instalar Flutter**

Sigue la guía oficial de instalación de Flutter para tu sistema operativo. Necesitarás:
- Flutter SDK
- Las herramientas de desarrollo correspondientes a tu plataforma objetivo

**2. Obtener el código fuente**

```bash
# Clonar el repositorio
git clone <<url del repositorio>>
cd maso

# Instalar dependencias
flutter pub get
```

**3. Ejecutar la aplicación**

```bash
# Ejecutar en modo desarrollo
flutter run

# O compilar para tu plataforma específica
flutter build windows  # Para Windows
flutter build macos    # Para macOS
flutter build linux    # Para Linux
flutter build web      # Para Web
```

---

## 3. Primeros Pasos

### Iniciar MASO

1. Abre la aplicación MASO
2. Verás la **pantalla principal** con las siguientes opciones:
   - **Crear**: Para crear un nuevo archivo de simulación
   - **Cargar**: Para abrir un archivo MASO existente
   - **Arrastrar y Soltar**: (Solo escritorio) Arrastra un archivo `.maso` a la ventana

### Tu Primera Simulación

Para crear tu primera simulación, sigue estos pasos:

1. **Haz clic en "Crear"** en la barra superior
2. Se abrirá un diálogo donde deberás ingresar:
   - **Nombre del archivo**: Un nombre descriptivo para tu simulación
   - **Descripción**: Detalles sobre el propósito de la simulación
3. Haz clic en **"Aceptar"**
4. Serás dirigido a la pantalla de configuración de procesos

---

## 4. Interfaz de Usuario

### Pantalla Principal (Home)

La pantalla principal contiene:

- **Barra Superior**:
  - Título de la aplicación
  - Botón **"Crear"**: Crea un nuevo archivo MASO
  - Botón **"Cargar"**: Abre un archivo MASO existente

- **Área Central** (Solo escritorio):
  - Zona de arrastre para archivos `.maso`
  - Muestra el logo de MASO

### Pantalla de Archivo Cargado

Una vez que cargas o creas un archivo, accedes a la pantalla principal de trabajo:

- **Barra Superior**:
  - Nombre del archivo actual
  - Botón **"Guardar"**: Guarda los cambios en el archivo
  - Botón **"Guardar Como"**: Guarda con un nuevo nombre
  - Botón **"Configuración"**: Ajusta parámetros de ejecución
  - Botón **"Ejecutar"**: Inicia la simulación

- **Área de Procesos**:
  - Lista de procesos configurados
  - Botón **"Agregar Proceso"**: Añade un nuevo proceso
  - Opciones de edición y eliminación para cada proceso

### Pantalla de Ejecución

Después de ejecutar la simulación:

- **Diagrama de Gantt**: Visualización cronológica de la ejecución
- **Estadísticas**: Métricas de rendimiento
- **Botones de Exportación**:
  - Copiar imagen al portapapeles
  - Exportar como imagen (PNG)
  - Exportar como PDF

---

## 5. Gestión de Archivos

### Crear un Nuevo Archivo

1. Haz clic en **"Crear"** en la pantalla principal
2. Completa el formulario:
   - **Nombre**: Identifica tu simulación (ej: "Simulación FCFS")
   - **Descripción**: Propósito o detalles adicionales
3. Presiona **"Aceptar"**

El sistema creará un nuevo archivo con la extensión `.maso` y te llevará a la pantalla de edición.

### Abrir un Archivo Existente

**Método 1: Botón Cargar**
1. Haz clic en **"Cargar"** en la barra superior
2. Selecciona el archivo `.maso` desde el explorador de archivos
3. El archivo se cargará automáticamente

**Método 2: Arrastrar y Soltar** (Solo escritorio)
1. Arrastra un archivo `.maso` desde tu explorador de archivos
2. Suéltalo en el área central de la ventana MASO
3. El archivo se cargará automáticamente

**Método 3: Doble clic** (Si está configurado en tu sistema)
- Haz doble clic en un archivo `.maso` en tu explorador de archivos
- MASO se abrirá automáticamente con el archivo cargado

### Guardar Cambios

**Guardar archivo actual:**
1. Haz clic en **"Guardar"** en la barra superior
2. Si el archivo ya tiene una ubicación, se guardará automáticamente
3. Si es un archivo nuevo, se abrirá el diálogo de guardar

**Guardar como nuevo archivo:**
1. Haz clic en **"Guardar Como"**
2. Elige la ubicación y el nombre del archivo
3. Haz clic en **"Guardar"**

### Formato de Archivo MASO

Los archivos MASO (`.maso`) son archivos JSON que contienen:

- **Metadata**: Información del archivo (nombre, versión, descripción)
- **Procesos**: Lista de procesos con sus características
- **Configuración**: Parámetros de ejecución (cuando se guardan)

---

## 6. Creación de Procesos

### Tipos de Procesos

MASO soporta dos tipos de procesos:

1. **Procesos Regulares**: Procesos simples con tiempo de llegada y tiempo de servicio
2. **Procesos con Ráfagas (Bursts)**: Procesos con múltiples ráfagas de CPU e I/O

### Agregar un Proceso Regular

1. En la pantalla de archivo cargado, haz clic en **"Agregar Proceso"**
2. Completa el formulario:
   - **ID del Proceso**: Identificador único (ej: P1, P2, P3)
   - **Tiempo de Llegada**: Momento en que el proceso llega al sistema
   - **Tiempo de Servicio**: Tiempo total que necesita el CPU
   - **Prioridad**: Nivel de prioridad (si aplica al algoritmo seleccionado)
   - **Habilitado**: Marca/desmarca para incluir/excluir el proceso
3. Haz clic en **"Agregar"** o **"Guardar"**

### Agregar un Proceso con Ráfagas

1. Selecciona el modo **"Procesos con Ráfagas"** en la configuración
2. Haz clic en **"Agregar Proceso"**
3. Completa:
   - **ID del Proceso**: Identificador único
   - **Tiempo de Llegada**: Momento de llegada
   - **Hilos**: Define los hilos del proceso
4. Para cada hilo, configura sus ráfagas:
   - **Ráfaga de CPU**: Tiempo de procesamiento
   - **Ráfaga de E/S**: Tiempo de entrada/salida
5. Haz clic en **"Agregar"**

### Editar un Proceso

1. En la lista de procesos, haz clic en el icono de **edición** (lápiz) del proceso
2. Modifica los valores deseados
3. Haz clic en **"Guardar"**

### Eliminar un Proceso

1. Haz clic en el icono de **eliminación** (papelera) del proceso
2. Confirma la eliminación en el diálogo que aparece

### Habilitar/Deshabilitar Procesos

- Usa el **checkbox** junto a cada proceso para habilitarlo o deshabilitarlo
- Los procesos deshabilitados no se incluirán en la simulación
- Útil para probar diferentes escenarios sin eliminar procesos

---

## 7. Algoritmos de Planificación

### 1. FCFS (First Come First Served)

**Descripción**: El primer proceso en llegar es el primero en ser atendido.

**Características**:
- No apropiativo (non-preemptive)
- Simple de implementar
- Puede causar el "efecto convoy" (procesos cortos esperan a largos)

**Cuándo usar**: 
- Sistemas por lotes simples
- Aprendizaje de conceptos básicos

**Parámetros configurables**:
- Número de CPUs
- Tiempo de cambio de contexto

### 2. SJF (Shortest Job First)

**Descripción**: El proceso con menor tiempo de servicio se ejecuta primero.

**Características**:
- No apropiativo
- Minimiza el tiempo de espera promedio
- Requiere conocer el tiempo de servicio anticipadamente

**Cuándo usar**:
- Cuando se conocen los tiempos de ejecución
- Para optimizar el tiempo de espera

**Parámetros configurables**:
- Número de CPUs
- Tiempo de cambio de contexto

### 3. SRTF (Shortest Remaining Time First)

**Descripción**: Versión apropiativa de SJF, ejecuta el proceso con menor tiempo restante.

**Características**:
- Apropiativo (preemptive)
- Puede interrumpir procesos en ejecución
- Óptimo para minimizar tiempo de espera

**Cuándo usar**:
- Sistemas interactivos
- Cuando se priorizan procesos cortos

**Parámetros configurables**:
- Número de CPUs
- Tiempo de cambio de contexto

### 4. Round Robin

**Descripción**: Asigna un quantum de tiempo a cada proceso de forma circular.

**Características**:
- Apropiativo
- Equitativo para todos los procesos
- El rendimiento depende del tamaño del quantum

**Cuándo usar**:
- Sistemas de tiempo compartido
- Cuando se requiere equidad entre procesos

**Parámetros configurables**:
- Número de CPUs
- **Quantum**: Tiempo asignado a cada proceso
- Tiempo de cambio de contexto

### 5. Planificación por Prioridad

**Descripción**: Los procesos se ejecutan según su nivel de prioridad.

**Características**:
- Puede ser apropiativo o no apropiativo
- Riesgo de inanición (starvation) para procesos de baja prioridad
- Flexible para diferentes tipos de sistemas

**Cuándo usar**:
- Sistemas en tiempo real
- Cuando algunos procesos son más críticos

**Parámetros configurables**:
- Número de CPUs
- Prioridad de cada proceso
- Tiempo de cambio de contexto

### 6. Colas Múltiples de Prioridad

**Descripción**: Múltiples colas con diferentes prioridades, cada proceso se asigna a una cola.

**Características**:
- Organización jerárquica de procesos
- Cada cola puede tener su propio algoritmo
- Prioridades fijas por cola

**Cuándo usar**:
- Sistemas con diferentes tipos de procesos
- Cuando se requiere separación de trabajos

**Parámetros configurables**:
- Número de colas
- Quantum por cola
- Tiempo de cambio de contexto

### 7. Colas Múltiples con Retroalimentación

**Descripción**: Similar a colas múltiples, pero los procesos pueden moverse entre colas.

**Características**:
- Adaptativo al comportamiento del proceso
- Penaliza procesos que consumen mucho CPU
- Favorece procesos cortos e interactivos

**Cuándo usar**:
- Sistemas operativos modernos
- Cuando se requiere adaptación dinámica

**Parámetros configurables**:
- Número de colas
- Quantum por cola
- Reglas de promoción/degradación
- Tiempo de cambio de contexto

### 8. Límite de Tiempo (Time Limit)

**Descripción**: Asigna un límite de tiempo máximo a cada proceso.

**Características**:
- Previene monopolización del CPU
- Garantiza tiempo de respuesta máximo
- Apropiativo cuando se alcanza el límite

**Cuándo usar**:
- Sistemas con requisitos de tiempo real
- Cuando se requieren garantías de tiempo

**Parámetros configurables**:
- Número de CPUs
- Límite de tiempo
- Tiempo de cambio de contexto

---

## 8. Configuración de la Ejecución

### Acceder a la Configuración

1. En la pantalla de archivo cargado, haz clic en **"Configuración"** o el icono de engranaje
2. Se abrirá el diálogo de **"Configuración de Ejecución"**

### Parámetros Generales

**Algoritmo de Planificación**
- Selecciona uno de los 8 algoritmos disponibles
- El formulario se adaptará mostrando solo los parámetros relevantes

**Número de CPUs**
- Define cuántos procesadores virtuales usar
- Valor predeterminado: 1
- Permite simular sistemas multiprocesador

**Canales de E/S** (Solo para procesos con ráfagas)
- Define el número de canales de entrada/salida
- Valor predeterminado: 1

**Tiempo de Cambio de Contexto**
- Tiempo que toma cambiar entre procesos
- Valor en unidades de tiempo
- Valor predeterminado: 0 (sin overhead)
- Simula el costo real del cambio de contexto

### Parámetros Específicos por Algoritmo

**Round Robin**
- **Quantum**: Tamaño del intervalo de tiempo asignado
- Valores típicos: 1-10 unidades de tiempo
- Quantum pequeño → más cambios de contexto
- Quantum grande → se aproxima a FCFS

**Colas Múltiples**
- **Quantum de Colas**: Quantum para cada nivel de cola
- Se configura como lista separada por comas (ej: "2,4,8")

**Límite de Tiempo**
- **Límite de Tiempo**: Tiempo máximo por ejecución
- Valor en unidades de tiempo

### Guardar Configuración

1. Ajusta todos los parámetros deseados
2. Haz clic en **"Aceptar"** para aplicar los cambios
3. La configuración se guardará con el archivo MASO

---

## 9. Visualización de Resultados

### Ejecutar la Simulación

1. Asegúrate de tener al menos un proceso habilitado
2. Configura el algoritmo y parámetros deseados
3. Haz clic en **"Ejecutar"**
4. MASO calculará y mostrará los resultados

### Diagrama de Gantt

El diagrama de Gantt es la visualización principal de la ejecución:

**Componentes del Diagrama**:
- **Eje Horizontal**: Línea de tiempo
- **Eje Vertical**: CPUs o canales de E/S
- **Bloques de Colores**: Representan procesos en ejecución
- **Bloques Grises**: Tiempo de cambio de contexto
- **Espacios en Blanco**: CPU inactivo

**Interpretación de Colores**:
- Cada proceso tiene un color único
- El color se mantiene consistente en toda la visualización
- Los bloques de cambio de contexto son grises
- El tiempo ocioso aparece sin color

**Información Mostrada**:
- ID del proceso en cada bloque
- Tiempo de inicio y fin de cada segmento
- Duración de cada ejecución

### Diagrama para Procesos con Ráfagas

Para procesos con ráfagas, verás:

- **Sección de CPUs**: Muestra las ráfagas de CPU
- **Sección de E/S**: Muestra las ráfagas de entrada/salida
- **Códigos de Colores**: Por proceso y por hilo

### Métricas y Estadísticas

El sistema puede calcular (según disponibilidad):

- **Tiempo de Espera**: Tiempo que el proceso espera en cola
- **Tiempo de Retorno**: Tiempo total desde llegada hasta finalización
- **Tiempo de Respuesta**: Tiempo hasta la primera ejecución
- **Utilización de CPU**: Porcentaje de tiempo que el CPU está ocupado

### Navegación en Resultados

- **Zoom**: Usa la rueda del mouse para acercar/alejar (si está disponible)
- **Desplazamiento**: Usa las barras de desplazamiento para ver toda la línea de tiempo
- **Información detallada**: Pasa el cursor sobre los bloques para más detalles

---

## 10. Exportación de Resultados

### Copiar al Portapapeles

**Para copiar la visualización como imagen**:
1. En la pantalla de resultados, busca el icono de **copiar** o **portapapeles**
2. Haz clic en él
3. La imagen del diagrama de Gantt se copiará al portapapeles
4. Pégala en cualquier aplicación (Word, PowerPoint, etc.)

### Exportar como Imagen (PNG)

1. Haz clic en el botón **"Exportar"** o el icono de compartir
2. Selecciona **"Exportar como Imagen"**
3. En plataformas de escritorio:
   - Elige la ubicación para guardar
   - El archivo se guardará automáticamente
4. En Web:
   - Ingresa el nombre del archivo
   - El archivo se descargará automáticamente

**Características de la imagen exportada**:
- Formato: PNG
- Alta resolución (3x pixel ratio)
- Incluye todo el diagrama visible
- Fondo transparente o blanco (según el tema)

### Exportar como PDF

1. Haz clic en **"Exportar"**
2. Selecciona **"Exportar como PDF"**
3. Ingresa el nombre del archivo (si es necesario)
4. El PDF se guardará o descargará

**Características del PDF**:
- Formato: PDF tamaño A4
- Imagen centrada
- Calidad de impresión
- Ideal para informes y documentación

### Usos de las Exportaciones

- **Presentaciones**: Incluye en diapositivas educativas
- **Informes**: Añade a documentos de análisis
- **Tareas**: Entrega resultados de ejercicios
- **Comparaciones**: Guarda múltiples ejecuciones para comparar
- **Documentación**: Archiva resultados de estudios

---

## 11. Preguntas Frecuentes

### ¿Qué formatos de archivo soporta?

MASO utiliza su propio formato `.maso` (JSON) para guardar simulaciones. También puede exportar resultados como PNG y PDF.

### ¿Puedo usar MASO sin conexión a Internet?

- **Versión de escritorio**: Sí, funciona completamente offline
- **Versión web**: Requiere conexión inicial, pero puede funcionar offline con caché del navegador

### ¿MASO funciona en móviles o tablets?

Sí, MASO es compatible con dispositivos móviles y tablets, aunque la experiencia óptima es en pantallas más grandes (escritorio).

### ¿Puedo compartir mis archivos MASO con otros?

Sí, los archivos `.maso` son portables. Puedes compartirlos por email, plataformas educativas, o repositorios.

### ¿Cómo sé qué algoritmo usar?

Depende del concepto que quieras estudiar:
- **FCFS**: Para entender conceptos básicos
- **SJF/SRTF**: Para optimización de tiempo de espera
- **Round Robin**: Para sistemas de tiempo compartido
- **Prioridad**: Para sistemas con diferentes criticidades

### ¿Puedo simular sistemas multiprocesador?

Sí, configura el número de CPUs en la configuración de ejecución.

### ¿Los resultados son determinísticos?

Sí, dada la misma configuración y procesos, MASO siempre producirá los mismos resultados.

---

## 12. Solución de Problemas

### El archivo no se carga

**Problema**: Al intentar abrir un archivo `.maso`, aparece un error.

**Soluciones**:
1. Verifica que el archivo tenga la extensión `.maso`
2. Asegúrate de que el archivo no esté corrupto
3. Revisa que el formato JSON sea válido
4. Intenta crear un nuevo archivo y migrar los procesos manualmente

### Error al guardar archivo

**Problema**: No se puede guardar el archivo.

**Soluciones**:
1. Verifica que tengas permisos de escritura en la carpeta destino
2. Asegúrate de que hay espacio suficiente en el disco
3. Intenta guardar en una ubicación diferente
4. Cierra otras aplicaciones que puedan estar bloqueando el archivo

### La simulación no se ejecuta

**Problema**: Al hacer clic en "Ejecutar", no sucede nada o aparece error.

**Soluciones**:
1. Verifica que tengas al menos un proceso habilitado
2. Asegúrate de que todos los procesos tengan valores válidos
3. Revisa que el algoritmo esté configurado correctamente
4. Comprueba que los parámetros (quantum, límite de tiempo) sean válidos

### El diagrama de Gantt no se ve correctamente

**Problema**: El diagrama aparece vacío, cortado o con errores visuales.

**Soluciones**:
1. Actualiza la ventana (F5 en web)
2. Ajusta el zoom de la ventana
3. Intenta exportar para ver si el problema persiste
4. Verifica la resolución de pantalla

### Proceso con valores negativos

**Problema**: Error al crear procesos con tiempos negativos.

**Solución**:
- Los tiempos de llegada y servicio deben ser valores positivos o cero
- Revisa y corrige los valores del proceso

### Exportación falla

**Problema**: No se puede exportar a imagen o PDF.

**Soluciones**:
1. Asegúrate de tener permisos de descarga/guardado
2. Verifica el espacio en disco
3. Intenta copiar al portapapeles como alternativa
4. En web, verifica que los popups no estén bloqueados

### Rendimiento lento

**Problema**: MASO funciona lento con muchos procesos.

**Soluciones**:
1. Reduce el número de procesos en la simulación
2. Reduce el número de CPUs simulados
3. Cierra otras aplicaciones para liberar memoria
4. Considera usar la versión de escritorio para mejor rendimiento

### Idioma incorrecto

**Problema**: La aplicación no muestra el idioma esperado.

**Solución**:
- MASO detecta automáticamente el idioma del sistema
- Soporta español e inglés
- Cambia el idioma del sistema para cambiar el idioma de MASO

### El quantum no tiene efecto en Round Robin

**Problema**: Cambiar el quantum no modifica los resultados.

**Soluciones**:
1. Asegúrate de haber guardado la configuración (clic en "Aceptar")
2. Verifica que el algoritmo seleccionado sea Round Robin
3. Revisa que el quantum sea mayor que 0
4. Vuelve a ejecutar la simulación después de cambiar

