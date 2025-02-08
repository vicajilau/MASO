import 'package:flutter/material.dart';
import 'package:maso/domain/models/custom_exceptions/regular_process_error_type.dart';

import '../../../core/l10n/app_localizations.dart';

class RegularProcessError {
  final RegularProcessErrorType errorType;
  final Object? param1;
  final Object? param2;
  final Object? param3;
  final bool success;

  RegularProcessError(
      {required this.errorType,
        this.param1,
        this.param2,
        this.param3,
        this.success = false});

  RegularProcessError.success()
      : this(success: true, errorType: RegularProcessErrorType.emptyName);


  String getDescriptionError(BuildContext context) {
    switch (errorType) {
      case RegularProcessErrorType.emptyName:
        return AppLocalizations.of(context)!.emptyNameError;
      case RegularProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicateNameError;
      case RegularProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeError;
      case RegularProcessErrorType.invalidTimeDifference:
        return AppLocalizations.of(context)!.invalidTimeDifferenceError;
    }
  }

  String getDescriptionBadContent(BuildContext context) {
    switch (errorType) {
      case RegularProcessErrorType.emptyName:
        return AppLocalizations.of(context)!.emptyNameProcessBadContent(param1!);
      case RegularProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicatedNameProcessBadContent;
      case RegularProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeBadContent(param1!);
      case RegularProcessErrorType.invalidTimeDifference:
        return AppLocalizations.of(context)!.invalidTimeDifferenceBadContent(param1!);
    }
  }
}
