import 'hardware_component.dart';

class TimeState {
  final List<HardwareComponent> cpus;
  final List<HardwareComponent> ioChannels;

  TimeState(this.cpus, this.ioChannels);
}