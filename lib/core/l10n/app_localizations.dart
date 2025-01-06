import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Title of the application displayed in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'MASO - Simulator'**
  String get titleAppBar;

  /// Label for the Create MASO file button in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Label for the Load MASO file button in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// Message displayed when a file is successfully loaded.
  ///
  /// In en, this message translates to:
  /// **'File loaded: {filePath}'**
  String fileLoaded(String filePath);

  /// Message displayed when a file is successfully saved.
  ///
  /// In en, this message translates to:
  /// **'File saved: {filePath}'**
  String fileSaved(String filePath);

  /// Message displayed when there is an error loading or saving a file.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String fileError(String message);

  /// Text displayed inside the drop area for dragging files.
  ///
  /// In en, this message translates to:
  /// **'Drag a .maso file here'**
  String get dropFileHere;

  /// Message displayed when the dropped file is not a .maso file.
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid file. Must be a .maso file.'**
  String get errorInvalidFile;

  /// Message displayed when there is an error while loading a MASO file.
  ///
  /// In en, this message translates to:
  /// **'Error loading the MASO file: {error}'**
  String errorLoadingFile(String error);

  /// Message displayed when there is an error while exporting a file.
  ///
  /// In en, this message translates to:
  /// **'Error exporting the file: {error}'**
  String errorExportingFile(String error);

  /// Message displayed when there is an error while saving a file.
  ///
  /// In en, this message translates to:
  /// **'Error saving file: {error}'**
  String errorSavingFile(String error);

  /// Label for displaying the arrival time of a process.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time: {arrivalTime}'**
  String arrivalTimeLabel(String arrivalTime);

  /// Label for displaying the service time of a process.
  ///
  /// In en, this message translates to:
  /// **'Service Time: {serviceTime}'**
  String serviceTimeLabel(String serviceTime);

  /// Title of the screen for editing a process.
  ///
  /// In en, this message translates to:
  /// **'Edit Process'**
  String get editProcessTitle;

  /// Title of the screen for creating a process.
  ///
  /// In en, this message translates to:
  /// **'Create Process'**
  String get createProcessTitle;

  /// Label for the process name input field.
  ///
  /// In en, this message translates to:
  /// **'Process Name'**
  String get processNameLabel;

  /// Label for the arrival time input field.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeDialogLabel;

  /// Label for the service time input field.
  ///
  /// In en, this message translates to:
  /// **'Service Time'**
  String get serviceTimeDialogLabel;

  /// Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Title for the confirmation dialog when deleting a process.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteTitle;

  /// Message in the confirmation dialog for deletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete `{processName}` process?'**
  String confirmDeleteMessage(Object processName);

  /// Button text for confirming deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @confirmExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExitTitle;

  /// No description provided for @confirmExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave without saving?'**
  String get confirmExitMessage;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @saveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Please select an output file:'**
  String get saveDialogTitle;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all the fields.'**
  String get fillAllFieldsError;

  /// No description provided for @createMasoFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create MASO File'**
  String get createMasoFileTitle;

  /// No description provided for @fileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileNameLabel;

  /// No description provided for @fileDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'File Description'**
  String get fileDescriptionLabel;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @emptyNameError.
  ///
  /// In en, this message translates to:
  /// **'The name cannot be empty.'**
  String get emptyNameError;

  /// No description provided for @duplicateNameError.
  ///
  /// In en, this message translates to:
  /// **'A process with this name already exists.'**
  String get duplicateNameError;

  /// No description provided for @invalidArrivalTimeError.
  ///
  /// In en, this message translates to:
  /// **'Arrival time must be a positive integer.'**
  String get invalidArrivalTimeError;

  /// No description provided for @invalidServiceTimeError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be a positive integer.'**
  String get invalidServiceTimeError;

  /// No description provided for @invalidTimeDifferenceError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be greater than arrival time.'**
  String get invalidTimeDifferenceError;

  /// No description provided for @timeDifferenceTooSmallError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be at least 1 unit greater than arrival time.'**
  String get timeDifferenceTooSmallError;

  /// No description provided for @requestFileNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the MASO file name'**
  String get requestFileNameTitle;

  /// No description provided for @fileNameHint.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileNameHint;

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @emptyFileNameMessage.
  ///
  /// In en, this message translates to:
  /// **'The file name cannot be empty.'**
  String get emptyFileNameMessage;

  /// No description provided for @fileNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'The file name is required.'**
  String get fileNameRequiredError;

  /// No description provided for @fileDescriptionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'The file description is required.'**
  String get fileDescriptionRequiredError;

  /// No description provided for @executionSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Setup'**
  String get executionSetupTitle;

  /// No description provided for @selectAlgorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Algorithm'**
  String get selectAlgorithmLabel;

  /// No description provided for @algorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'{algorithm, select, firstComeFirstServed {First Come First Served} shortestJobFirst {Shortest Job First} shortestRemainingTimeFirst {Shortest Remaining Time First} roundRobin {Round Robin} priorityBased {Priority Based} multiplePriorityQueues {Multiple Priority Queues} multiplePriorityQueuesWithFeedback {Multiple Priority Queues with Feedback} timeLimit {Time Limit} other {Unknown}}'**
  String algorithmLabel(String algorithm);

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save the file'**
  String get saveTooltip;

  /// No description provided for @saveDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get saveDisabledTooltip;

  /// No description provided for @executeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Execute the process'**
  String get executeTooltip;

  /// No description provided for @executeDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add processes to execute'**
  String get executeDisabledTooltip;

  /// No description provided for @addTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a new process'**
  String get addTooltip;

  /// No description provided for @backSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Back button'**
  String get backSemanticLabel;

  /// No description provided for @createFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create a new MASO file'**
  String get createFileTooltip;

  /// No description provided for @loadFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Load an existing MASO file'**
  String get loadFileTooltip;

  /// No description provided for @executionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Overview'**
  String get executionScreenTitle;

  /// No description provided for @executionTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Timeline'**
  String get executionTimelineTitle;

  /// No description provided for @failedToCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String failedToCaptureImage(Object error);

  /// No description provided for @imageCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard'**
  String get imageCopiedToClipboard;

  /// No description provided for @exportTimelineImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportTimelineImage;

  /// No description provided for @exportTimelinePdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportTimelinePdf;

  /// No description provided for @clipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get clipboardTooltip;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export execution timeline'**
  String get exportTooltip;

  /// No description provided for @timelineProcessDescription.
  ///
  /// In en, this message translates to:
  /// **'{processName} (Arrival: {arrivalTime}, Service: {serviceTime})'**
  String timelineProcessDescription(Object arrivalTime, Object processName, Object serviceTime);

  /// No description provided for @executionTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Execution Time: {executionTime}'**
  String executionTimeDescription(Object executionTime);

  /// No description provided for @executionTimeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get executionTimeUnavailable;

  /// No description provided for @imageExported.
  ///
  /// In en, this message translates to:
  /// **'Image exported'**
  String get imageExported;

  /// No description provided for @pdfExported.
  ///
  /// In en, this message translates to:
  /// **'PDF exported'**
  String get pdfExported;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
