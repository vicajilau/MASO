import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleAppBar => 'MASO - Simulator';

  @override
  String get create => 'Create';

  @override
  String get load => 'Load';

  @override
  String fileLoaded(String filePath) {
    return 'File loaded: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'File saved: $filePath';
  }

  @override
  String fileError(String message) {
    return 'Error: $message';
  }

  @override
  String get dropFileHere => 'Drag a .maso file here';

  @override
  String get errorInvalidFile => 'Error: Invalid file. Must be a .maso file.';

  @override
  String errorLoadingFile(String error) {
    return 'Error loading the MASO file: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error exporting the file: $error';
  }

  @override
  String errorSavingFile(String error) {
    return 'Error saving file: $error';
  }

  @override
  String arrivalTimeLabel(String arrivalTime) {
    return 'Arrival Time: $arrivalTime';
  }

  @override
  String serviceTimeLabel(String serviceTime) {
    return 'Service Time: $serviceTime';
  }

  @override
  String get editProcessTitle => 'Edit Process';

  @override
  String get createProcessTitle => 'Create Process';

  @override
  String get processNameLabel => 'Process Name';

  @override
  String get arrivalTimeDialogLabel => 'Arrival Time';

  @override
  String get serviceTimeDialogLabel => 'Service Time';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String confirmDeleteMessage(Object processName) {
    return 'Are you sure you want to delete `$processName` process?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get confirmExitTitle => 'Confirm Exit';

  @override
  String get confirmExitMessage => 'Are you sure you want to leave without saving?';

  @override
  String get exitButton => 'Exit';

  @override
  String get saveDialogTitle => 'Please select an output file:';

  @override
  String get fillAllFieldsError => 'Please fill in all the fields.';

  @override
  String get createMasoFileTitle => 'Create MASO File';

  @override
  String get fileNameLabel => 'File Name';

  @override
  String get fileDescriptionLabel => 'File Description';

  @override
  String get createButton => 'Create';

  @override
  String get emptyNameError => 'The name cannot be empty.';

  @override
  String get duplicateNameError => 'A process with this name already exists.';

  @override
  String get invalidArrivalTimeError => 'Arrival time must be a positive integer.';

  @override
  String get invalidServiceTimeError => 'Service time must be a positive integer.';

  @override
  String get invalidTimeDifferenceError => 'Service time must be greater than arrival time.';

  @override
  String get timeDifferenceTooSmallError => 'Service time must be at least 1 unit greater than arrival time.';

  @override
  String get requestFileNameTitle => 'Enter the MASO file name';

  @override
  String get fileNameHint => 'File name';

  @override
  String get acceptButton => 'Accept';

  @override
  String get errorTitle => 'Error';

  @override
  String get emptyFileNameMessage => 'The file name cannot be empty.';

  @override
  String get fileNameRequiredError => 'The file name is required.';

  @override
  String get fileDescriptionRequiredError => 'The file description is required.';

  @override
  String get executionSetupTitle => 'Execution Setup';

  @override
  String get selectAlgorithmLabel => 'Select Algorithm';

  @override
  String algorithmLabel(String algorithm) {
    String _temp0 = intl.Intl.selectLogic(
      algorithm,
      {
        'firstComeFirstServed': 'First Come First Served',
        'shortestJobFirst': 'Shortest Job First',
        'shortestRemainingTimeFirst': 'Shortest Remaining Time First',
        'roundRobin': 'Round Robin',
        'priorityBased': 'Priority Based',
        'multiplePriorityQueues': 'Multiple Priority Queues',
        'multiplePriorityQueuesWithFeedback': 'Multiple Priority Queues with Feedback',
        'timeLimit': 'Time Limit',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get saveTooltip => 'Save the file';

  @override
  String get saveDisabledTooltip => 'No changes to save';

  @override
  String get executeTooltip => 'Execute the process';

  @override
  String get executeDisabledTooltip => 'Add processes to execute';

  @override
  String get addTooltip => 'Add a new process';

  @override
  String get backSemanticLabel => 'Back button';

  @override
  String get createFileTooltip => 'Create a new MASO file';

  @override
  String get loadFileTooltip => 'Load an existing MASO file';

  @override
  String get executionScreenTitle => 'Execution Overview';

  @override
  String get executionTimelineTitle => 'Execution Timeline';

  @override
  String failedToCaptureImage(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String get imageCopiedToClipboard => 'Image copied to clipboard';

  @override
  String get exportTimelineImage => 'Export as Image';

  @override
  String get exportTimelinePdf => 'Export as PDF';

  @override
  String get clipboardTooltip => 'Copy to clipboard';

  @override
  String get exportTooltip => 'Export execution timeline';

  @override
  String timelineProcessDescription(Object arrivalTime, Object processName, Object serviceTime) {
    return '$processName (Arrival: $arrivalTime, Service: $serviceTime)';
  }

  @override
  String executionTimeDescription(Object executionTime) {
    return 'Execution Time: $executionTime';
  }

  @override
  String get executionTimeUnavailable => 'N/A';

  @override
  String get imageExported => 'Image exported';

  @override
  String get pdfExported => 'PDF exported';

  @override
  String get metadataBadContent => 'The file metadata is invalid or corrupted.';

  @override
  String get processesBadContent => 'The process list contains invalid data.';

  @override
  String get unsupportedVersion => 'The file version is not supported by the current application.';

  @override
  String get invalidExtension => 'The file does not have a valid .maso extension.';
}
