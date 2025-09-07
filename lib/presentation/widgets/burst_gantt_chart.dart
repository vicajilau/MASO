import 'package:flutter/material.dart';
import 'package:maso/domain/models/hardware_state.dart';
import 'package:maso/domain/models/maso/regular_process.dart';

import '../../core/color_manager.dart';
import '../../domain/models/machine.dart';

/// Widget that renders a Gantt chart for burst processes with time labels and multiple CPU/IO rows.
class BurstGanttChart extends StatelessWidget {
  final Machine machine;
  final double cellSpacing = 5.0;
  final regularPadding = 60.0;
  final colorManager = ColorManager();

  BurstGanttChart({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    // Step 1: Calculate total time across all CPUs and I/O channels
    int globalTime = 0;
    final cpuBlocks = <List<_GanttBlock>>[];
    final ioBlocks = <List<_GanttBlock>>[];

    // Process CPU blocks
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

    // Process I/O channel blocks
    for (var ioChannel in machine.ioChannels) {
      final blocks = <_GanttBlock>[];
      int currentTime = 0;

      for (var component in ioChannel.core) {
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

      ioBlocks.add(blocks);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Processor and I/O Usage Timeline (Burst Processes)",
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
                  SizedBox(width: regularPadding), // for CPU/IO label spacing
                  ...List.generate(globalTime + 1, (i) {
                    return Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text("$i"),
                    );
                  }),
                ],
              ),

              /// Each CPU row
              for (int cpuIndex = 0; cpuIndex < cpuBlocks.length; cpuIndex++)
                _buildResourceRow(
                    cpuBlocks[cpuIndex], "CPU ${cpuIndex + 1}", globalTime),

              /// Separator between CPUs and I/O channels
              if (ioBlocks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.only(left: regularPadding),
                  child: const Divider(thickness: 2),
                ),
                const SizedBox(height: 8),
              ],

              /// Each I/O channel row
              for (int ioIndex = 0; ioIndex < ioBlocks.length; ioIndex++)
                _buildResourceRow(
                    ioBlocks[ioIndex], "I/O ${ioIndex + 1}", globalTime),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a row for a single CPU or I/O channel with its blocks and label
  Widget _buildResourceRow(
      List<_GanttBlock> blocks, String resourceLabel, int globalTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Arrow row
          _buildArrowRow(blocks, globalTime),
          const SizedBox(height: 4),

          /// Resource label + blocks
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: regularPadding,
                alignment: Alignment.centerLeft,
                child: Text(
                  resourceLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(
                width: globalTime * 40.0 + 40,
                height: regularPadding,
                child: Stack(
                  children: blocks
                      .map((block) => Positioned(
                            left: block.startTime * 40.0 + 20,
                            child: _buildCell(
                              block.label,
                              block.state,
                              block.duration,
                              spacingRight: 0.0,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a row of arrows indicating when a process starts and ends
  Widget _buildArrowRow(List<_GanttBlock> blocks, int globalTime) {
    final Map<int, List<_ArrowInfo>> arrows = {};

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final processId = _extractProcessId(block.label);
      final isProcessBlock = block.state == HardwareState.busy;
      final color = _colorForState(block.state, block.label);

      if (!isProcessBlock) continue;

      // Add down arrow to the start of the process burst
      if (block.startTime == _getArrivalTimeOfProcess(processId, blocks)) {
        arrows.putIfAbsent(block.startTime, () => []);
        arrows[block.startTime]!.add(_ArrowInfo(Icons.arrow_downward, color));
      }

      // Add up arrow to the end of every process burst execution
      final endTime = block.startTime + block.duration;
      arrows.putIfAbsent(endTime, () => []);
      arrows[endTime]!.add(_ArrowInfo(Icons.arrow_upward, color));
    }

    return Padding(
      padding: EdgeInsets.only(left: regularPadding),
      child: Row(
        children: List.generate(globalTime + 1, (i) {
          final arrowList = arrows[i];
          return Container(
            width: 40,
            alignment: Alignment.center,
            child: arrowList != null && arrowList.isNotEmpty
                ? arrowList.length == 1
                    ? Icon(arrowList.first.icon,
                        size: 15, color: arrowList.first.color)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: arrowList
                            .map((arrow) =>
                                Icon(arrow.icon, size: 15, color: arrow.color))
                            .toList(),
                      )
                : null,
          );
        }),
      ),
    );
  }

  /// Extracts the process ID from a burst label (e.g., "P1.T1" -> "P1")
  String _extractProcessId(String label) {
    if (label.contains('.')) {
      return label.split('.').first;
    }
    return label;
  }

  /// Returns the arrivalTime (startTime) of the first block of that process.
  int _getArrivalTimeOfProcess(String processId, List<_GanttBlock> blocks) {
    for (var block in blocks) {
      if (_extractProcessId(block.label) == processId) {
        return block.startTime;
      }
    }
    return -1; // Not found
  }

  /// Builds a single process/state block.
  Widget _buildCell(String text, HardwareState state, int timeUnits,
      {double spacingRight = 0.0}) {
    final baseColor = _colorForState(state, text);
    final isFree = state == HardwareState.free;

    return Container(
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  /// Maps each HardwareState to a color, using process ID for consistent coloring
  Color _colorForState(HardwareState state, String text) {
    switch (state) {
      case HardwareState.busy:
        // Use the process ID for consistent coloring across threads
        final processId = _extractProcessId(text);
        return colorManager.getColorForProcess(processId);
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

class _ArrowInfo {
  final IconData icon;
  final Color color;

  _ArrowInfo(this.icon, this.color);
}
