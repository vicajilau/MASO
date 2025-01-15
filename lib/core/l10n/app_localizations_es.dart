import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get titleAppBar => 'MASO - Simulador';

  @override
  String get create => 'Crear';

  @override
  String get load => 'Cargar';

  @override
  String fileLoaded(String filePath) {
    return 'Archivo cargado: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Archivo guardado: $filePath';
  }

  @override
  String fileError(String message) {
    return 'Error: $message';
  }

  @override
  String get dropFileHere => 'Arrastra un archivo .maso aquí';

  @override
  String get errorInvalidFile => 'Error: archivo no válido. Debe ser un archivo .maso.';

  @override
  String errorLoadingFile(String error) {
    return 'Error al cargar el archivo MASO: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error al exportar : $error';
  }

  @override
  String errorSavingFile(String error) {
    return 'Error al guardar el archivo: $error';
  }

  @override
  String arrivalTimeLabel(String arrivalTime) {
    return 'Tiempo de Llegada: $arrivalTime';
  }

  @override
  String serviceTimeLabel(String serviceTime) {
    return 'Tiempo de Servicio: $serviceTime';
  }

  @override
  String get editProcessTitle => 'Editar Proceso';

  @override
  String get createProcessTitle => 'Crear Proceso';

  @override
  String get processNameLabel => 'Nombre del Proceso';

  @override
  String get arrivalTimeDialogLabel => 'Tiempo de Llegada';

  @override
  String get serviceTimeDialogLabel => 'Tiempo de Servicio';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get confirmDeleteTitle => 'Confirmar eliminación';

  @override
  String confirmDeleteMessage(Object processName) {
    return '¿Estás seguro de que deseas eliminar el proceso `$processName`?';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get enabledLabel => 'Habilitado';

  @override
  String get disabledLabel => 'Deshabilitado';

  @override
  String get confirmExitTitle => 'Confirmar salida';

  @override
  String get confirmExitMessage => '¿Seguro que quieres salir sin guardar?';

  @override
  String get exitButton => 'Salir';

  @override
  String get saveDialogTitle => 'Por favor, seleccione un archivo de salida:';

  @override
  String get fillAllFieldsError => 'Por favor, completa todos los campos.';

  @override
  String get createMasoFileTitle => 'Crear Archivo MASO';

  @override
  String get fileNameLabel => 'Nombre del Archivo';

  @override
  String get fileDescriptionLabel => 'Descripción del Archivo';

  @override
  String get createButton => 'Crear';

  @override
  String get emptyNameError => 'El nombre no puede estar vacío.';

  @override
  String get duplicateNameError => 'Ya existe un proceso con este nombre.';

  @override
  String get invalidArrivalTimeError => 'El tiempo de llegada debe ser un número entero positivo.';

  @override
  String get invalidServiceTimeError => 'El tiempo de servicio debe ser un número entero positivo.';

  @override
  String get invalidTimeDifferenceError => 'El tiempo de servicio debe ser mayor que el tiempo de llegada.';

  @override
  String get timeDifferenceTooSmallError => 'El tiempo de servicio debe ser al menos 1 unidad mayor que el tiempo de llegada.';

  @override
  String get requestFileNameTitle => 'Introduce el nombre del archivo MASO';

  @override
  String get fileNameHint => 'Nombre del archivo';

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get errorTitle => 'Error';

  @override
  String get emptyFileNameMessage => 'El nombre del fichero no puede estar vacío.';

  @override
  String get fileNameRequiredError => 'El nombre del archivo es obligatorio.';

  @override
  String get fileDescriptionRequiredError => 'La descripción del archivo es obligatoria.';

  @override
  String get executionSetupTitle => 'Configuración de Ejecución';

  @override
  String get selectAlgorithmLabel => 'Seleccionar Algoritmo';

  @override
  String algorithmLabel(String algorithm) {
    String _temp0 = intl.Intl.selectLogic(
      algorithm,
      {
        'firstComeFirstServed': 'Primero en Llegar, Primero en Servir',
        'shortestJobFirst': 'El Trabajo Más Corto Primero',
        'shortestRemainingTimeFirst': 'El Tiempo Restante Más Corto Primero',
        'roundRobin': 'Round Robin',
        'priorityBased': 'Basado en Prioridad',
        'multiplePriorityQueues': 'Colas de Prioridad Múltiples',
        'multiplePriorityQueuesWithFeedback': 'Colas de Prioridad Múltiples con Retroalimentación',
        'timeLimit': 'Límite de Tiempo',
        'other': 'Desconocido',
      },
    );
    return '$_temp0';
  }

  @override
  String get saveTooltip => 'Guardar el archivo';

  @override
  String get saveDisabledTooltip => 'No hay cambios para guardar';

  @override
  String get executeTooltip => 'Ejecutar el proceso';

  @override
  String get executeDisabledTooltip => 'Agrega procesos para ejecutar';

  @override
  String get addTooltip => 'Agregar un nuevo proceso';

  @override
  String get backSemanticLabel => 'Botón de volver';

  @override
  String get createFileTooltip => 'Crear un nuevo archivo MASO';

  @override
  String get loadFileTooltip => 'Cargar un archivo MASO existente';

  @override
  String get executionScreenTitle => 'Resumen de Ejecución';

  @override
  String get executionTimelineTitle => 'Línea de Tiempo de Ejecución';

  @override
  String failedToCaptureImage(Object error) {
    return 'No se pudo capturar la imagen: $error';
  }

  @override
  String get imageCopiedToClipboard => 'Imagen copiada al portapapeles';

  @override
  String get exportTimelineImage => 'Exportar como Imagen';

  @override
  String get exportTimelinePdf => 'Exportar como PDF';

  @override
  String get clipboardTooltip => 'Copiar al portapapeles';

  @override
  String get exportTooltip => 'Exportar línea de tiempo de ejecución';

  @override
  String timelineProcessDescription(Object arrivalTime, Object processName, Object serviceTime) {
    return '$processName (Llegada: $arrivalTime, Servicio: $serviceTime)';
  }

  @override
  String executionTimeDescription(Object executionTime) {
    return 'Tiempo de Ejecución: $executionTime';
  }

  @override
  String get executionTimeUnavailable => 'N/D';

  @override
  String get imageExported => 'Imagen exportada';

  @override
  String get pdfExported => 'PDF exportado';

  @override
  String get metadataBadContent => 'Los metadatos del archivo son inválidos o están corruptos.';

  @override
  String get processesBadContent => 'La lista de procesos contiene datos inválidos.';

  @override
  String get unsupportedVersion => 'La versión del archivo no es compatible con la aplicación actual.';

  @override
  String get invalidExtension => 'El archivo no tiene una extensión .maso válida.';

  @override
  String get settingsDialogTitle => 'Configuración';

  @override
  String get settingsDialogWarningTitle => 'Advertencia';

  @override
  String get settingsDialogWarningContent => 'Cambiar el modo borrará todos los procesos del archivo maso. ¿Deseas continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get settingsDialogDescription => 'Selecciona el tipo de procesos que deseas configurar:';

  @override
  String get processModeRegular => 'Normales';

  @override
  String get processModeBurst => 'Con ráfagas';
}
