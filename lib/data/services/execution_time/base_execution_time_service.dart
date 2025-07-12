import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/execution_setup.dart';
import '../../../domain/models/maso/i_process.dart';

/// Abstract base class for execution time calculation services.
///
/// This class defines the shared structure for services that calculate
/// how a list of processes will be executed on a machine,
/// according to a given setup (number of CPUs, context switch time, etc.).
///
/// Subclasses are expected to override one or both of the provided methods,
/// depending on whether they support regular or burst-based processes.
abstract class BaseExecutionTimeService {
  /// The list of processes to be scheduled.
  final List<IProcess> processes;

  /// The setup configuration for execution, including hardware and algorithm settings.
  final ExecutionSetup executionSetup;

  /// Constructs the base service with the provided process list and setup.
  BaseExecutionTimeService(this.processes, this.executionSetup);

  /// Calculates the machine execution using regular (non-burst) processes.
  ///
  /// Should be overridden by subclasses that support regular processes.
  Machine calculateMachineWithRegularProcesses();

  /// Calculates the machine execution using burst-based processes.
  ///
  /// Should be overridden by subclasses that support burst processes.
  Machine calculateMachineWithBurstProcesses();
}
