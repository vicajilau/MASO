import 'maso/i_process.dart';

/// Represents the current state of a CPU during process scheduling.
///
/// - `executing`: The process currently being executed, if any.
/// - `executionRemaining`: Time units left for the current process's time slice (quantum).
/// - `executedQuantum`: Time units executed for the current process in this quantum.
/// - `contextSwitchRemaining`: Time units remaining for a context switch, if one is in progress.
/// - `idle`: Indicates whether the CPU is idle (no process executing and no context switch pending).
class CPUState {
  IProcess? executing;
  int executionRemaining = 0;
  int executedQuantum = 0;
  int contextSwitchRemaining = 0;

  bool get idle => executing == null && contextSwitchRemaining == 0;
}
