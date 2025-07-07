import 'hardware_component.dart';

/// Represents a processor core, which is composed of a list of hardware components.
/// Each hardware component in the core could be any part of the CPU such as ALU, registers, etc.
class CoreProcessor {
  /// The list of hardware components that make up this core.
  List<HardwareComponent> core;

  /// Creates a CoreProcessor with an optional list of hardware components.
  /// Defaults to an empty list if none provided.
  CoreProcessor(this.core);
  CoreProcessor.empty() : this([]);
}
