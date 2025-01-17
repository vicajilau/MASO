import 'package:flutter/material.dart';
import 'package:maso/domain/models/maso/maso_file.dart';

import '../../../domain/models/maso/process_mode.dart';
import 'burst_process_dialog.dart';
import 'regular_process_dialog.dart';

/// A dialog widget that redirects to the appropriate process dialog
/// based on the current `ProcessesMode` of the `masoFile`.
class ProcessDialog extends StatelessWidget {
  final MasoFile masoFile; // Contains the processes and their mode.
  final dynamic process; // Can be RegularProcess or BurstProcess.
  final int? processPosition; // Optional index of the process.

  /// Constructor for initializing the `ProcessDialog`.
  const ProcessDialog({
    super.key,
    required this.masoFile,
    this.process,
    this.processPosition,
  });

  @override
  Widget build(BuildContext context) {
    if (masoFile.processes.mode == ProcessesMode.regular) {
      return RegularProcessDialog(
        masoFile: masoFile,
        process: process,
        processPosition: processPosition,
      );
    } else if (masoFile.processes.mode == ProcessesMode.burst) {
      return BurstProcessDialog(
        masoFile: masoFile,
        process: process,
        processPosition: processPosition,
      );
    } else {
      return const SizedBox.shrink(); // No valid mode, return an empty widget.
    }
  }
}
