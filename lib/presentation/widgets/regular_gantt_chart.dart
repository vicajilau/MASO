import 'package:flutter/material.dart';
import 'package:maso/domain/models/hardware_state.dart';
import 'package:maso/domain/models/maso/regular_process.dart';

import '../../domain/models/machine.dart';

/// Widget that renders a Gantt chart with time labels and multiple CPU rows.
class RegularGanttChart extends StatelessWidget {
  final Machine machine;

  const RegularGanttChart({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    // Step 1: Calculate total time across all CPUs (max timeline)
    int globalTime = 0;
    final cpuBlocks = <List<_GanttBlock>>[];

    for (var cpu in machine.cpus) {
      final blocks = <_GanttBlock>[];
      int currentTime = 0;

      for (var component in cpu.core) {
        final process = component.process as RegularProcess;
        final duration = process.serviceTime;

        blocks.add(_GanttBlock(
          label: process.id,
          state: component.state,
          startTime: currentTime,
          duration: duration,
        ));

        currentTime += duration;
      }

      if (currentTime > globalTime) {
        globalTime = currentTime;
      }

      cpuBlocks.add(blocks);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Processor Usage Timeline",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        /// Unified scrollable area
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Time header row
              Row(
                children: [
                  const SizedBox(width: 60), // for CPU label spacing
                  ...List.generate(globalTime + 1, (i) {
                    return Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text("$i"),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 6),

              /// Each CPU row
              for (int cpuIndex = 0; cpuIndex < cpuBlocks.length; cpuIndex++)
                _buildCpuRow(cpuBlocks[cpuIndex], cpuIndex + 1),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a row for a single CPU with its blocks and label
  Widget _buildCpuRow(List<_GanttBlock> blocks, int cpuNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CPU label
          Container(
            width: 60,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              "CPU $cpuNumber",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Blocks with arrows
          Row(
            children: [
              for (int i = 0; i < blocks.length; i++) ...[
                _buildCell(
                  blocks[i].label,
                  blocks[i].state,
                  blocks[i].duration,
                ),
                if (i < blocks.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("↑↓", style: TextStyle(fontSize: 16)),
                  ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single process/state block.
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

  /// Maps each HardwareState to a color.
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

/// Internal model to represent each block in the Gantt chart.
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
