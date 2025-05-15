import 'package:maso/domain/models/scheduling_algorithm.dart';
import 'package:maso/domain/models/settings_maso.dart';

class ExecutionSetup {
  SchedulingAlgorithm algorithm;
  SettingsMaso settings;

  ExecutionSetup({required this.algorithm, required this.settings});
}
