import 'package:flutter/material.dart';
import 'package:maso/domain/models/core_processor.dart';
import 'package:maso/domain/models/hardware_state.dart';
import 'package:maso/domain/models/maso/regular_process.dart';

/// Widget that renders a Gantt chart with time labels representing CPU usage over time.
class RegularGanttChart extends StatelessWidget {
  final CoreProcessor cpuExecution;

  const RegularGanttChart({super.key, required this.cpuExecution});

  @override
  Widget build(BuildContext context) {
    final components = cpuExecution.core;

    /// Step 1: Build the list of time units
    final timeUnits = <_GanttBlock>[];
    int currentTime = 0;

    for (var component in components) {
      final process = component.process;
      final duration = (process as RegularProcess).serviceTime;

      timeUnits.add(_GanttBlock(
        label: process.id,
        state: component.state,
        startTime: currentTime,
        duration: duration,
      ));

      currentTime += duration;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Processor Usage Timeline",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// Time label row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(currentTime, (i) {
              return Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  "$i",
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),

        /// Gantt blocks
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: timeUnits.map((block) {
              return _buildCell(block.label, block.state, block.duration);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds a single block (cell) of the Gantt chart.
  Widget _buildCell(String text, HardwareState state, int timeUnits) {
    final baseColor = _colorForState(state);

    return Container(
      width: 40.0 * timeUnits,
      height: 50,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.3),
        border: Border.all(color: baseColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Returns a color based on the hardware state.
  Color _colorForState(HardwareState state) {
    switch (state) {
      case HardwareState.busy:
        return Colors.green;
      case HardwareState.free:
        return Colors.grey;
      case HardwareState.switchingContext:
        return Colors.orange;
    }
  }
}

/// Helper class to store information for each block in the Gantt chart.
class _GanttBlock {
  final String label;
  final HardwareState state;
  final int startTime;
  final int duration;

  _GanttBlock({
    required this.label,
    required this.state,
    required this.startTime,
    required this.duration,
  });
}
