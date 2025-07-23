import 'package:flutter/material.dart';
import 'package:maso/domain/models/hardware_state.dart';
import 'package:maso/domain/models/maso/regular_process.dart';

import '../../core/color_manager.dart';
import '../../domain/models/machine.dart';

/// Widget that renders a Gantt chart with time labels and multiple CPU rows.
class RegularGanttChart extends StatelessWidget {
  final Machine machine;
  final double cellSpacing = 5.0;
  final colorManager = ColorManager();

  RegularGanttChart({super.key, required this.machine});

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
                      alignment: Alignment.centerLeft,
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
    const double cellWidth = 40.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            alignment: Alignment.centerLeft,
            child: Text(
              "CPU $cpuNumber",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          SizedBox(
            width: blocks.fold(
                0.0, (sum, b) => sum! + cellWidth * b.duration + cellSpacing),
            height: 60,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: blocks.fold(
                        0.0,
                        (sum, b) => sum! + cellWidth * b.duration + cellSpacing,
                      ),
                      child: Row(
                        children: blocks
                            .map((block) => _buildCell(
                                  block.label,
                                  block.state,
                                  block.duration,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double currentOffset = 0;
                      final arrows = <Widget>[];

                      arrows.add(Positioned(
                        left: 4,
                        top: 2,
                        child: const Icon(Icons.arrow_downward, size: 16),
                      ));

                      for (int i = 0; i < blocks.length; i++) {
                        currentOffset += blocks[i].duration * 40 + cellSpacing;

                        if (i < blocks.length - 1) {
                          arrows.add(Positioned(
                            left: currentOffset - 8,
                            top: 2,
                            child: const Icon(Icons.import_export, size: 16),
                          ));
                        }
                      }

                      arrows.add(Positioned(
                        left: currentOffset - 16,
                        top: 2,
                        child: const Icon(Icons.arrow_upward, size: 16),
                      ));

                      return Stack(children: arrows);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single process/state block.
  Widget _buildCell(String text, HardwareState state, int timeUnits,
      {double spacingRight = 5.0}) {
    final baseColor = _colorForState(state, text);
    final isFree = state == HardwareState.free;

    return Padding(
      padding: EdgeInsets.only(right: spacingRight),
      child: Container(
        width: 40.0 * timeUnits,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFree ? null : baseColor.withValues(alpha: 0.3),
          border: isFree ? null : Border.all(color: baseColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isFree
            ? null
            : Text(
                text,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Maps each HardwareState to a color.
  Color _colorForState(HardwareState state, String text) {
    switch (state) {
      case HardwareState.busy:
        return colorManager.getColorForProcess(text);
      case HardwareState.free:
        return Colors.transparent;
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
