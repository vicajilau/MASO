import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

enum RegularProcessError {
  emptyName,
  duplicatedName,
  invalidArrivalTime,
  invalidTimeDifference;

  String getDescriptionError(BuildContext context) {
    switch (this) {
      case RegularProcessError.emptyName:
        return AppLocalizations.of(context)!.emptyNameError;
      case RegularProcessError.duplicatedName:
        return AppLocalizations.of(context)!.duplicateNameError;
      case RegularProcessError.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeError;
      case RegularProcessError.invalidTimeDifference:
        return AppLocalizations.of(context)!.invalidTimeDifferenceError;
    }
  }

  String getDescriptionBadContent(BuildContext context) {
    switch (this) {
      case RegularProcessError.emptyName:
        return AppLocalizations.of(context)!.emptyNameProcessBadContent;
      case RegularProcessError.duplicatedName:
        return AppLocalizations.of(context)!.duplicatedNameProcessBadContent;
      case RegularProcessError.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeBadContent("paco");
      case RegularProcessError.invalidTimeDifference:
        return AppLocalizations.of(context)!.invalidTimeDifferenceBadContent;
    }
  }
}
