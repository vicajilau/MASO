import 'package:maso/domain/models/custom_exceptions/validate_maso_state.dart';
import 'package:maso/domain/models/maso/list_processes_extension.dart';
import 'package:maso/domain/models/maso/maso_file.dart';

class ValidateMasoProcessUseCase {
  /// Validate the input fields.
  static RegularProcessError? validateInput(
      String nameString,
      String arrivalTimeString,
      String serviceTimeString,
      int? processPosition,
      MasoFile masoFile) {
    final name = nameString.trim();
    final arrivalTime = int.tryParse(arrivalTimeString);
    final serviceTime = int.tryParse(serviceTimeString);

    // Validate name input.
    if (name.isEmpty) {
      return RegularProcessError.emptyName;
    }

    // Check for duplicate process names.
    if (masoFile.processes.elements
        .containProcessWithName(name, position: processPosition)) {
      return RegularProcessError.duplicatedName;
    }

    // Validate arrival time input.
    if (arrivalTime == null || arrivalTime < 0) {
      return RegularProcessError.invalidArrivalTime;
    }

    // Validate service time input.
    if (serviceTime == null || serviceTime <= arrivalTime) {
      return RegularProcessError.invalidTimeDifference;
    }

    return null; // Input is valid.
  }
}
