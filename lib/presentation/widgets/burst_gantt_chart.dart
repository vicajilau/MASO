import 'package:flutter/material.dart';
import 'package:maso/core/extensions/string_extension.dart';
import 'package:maso/domain/models/core_processor.dart';
import 'package:maso/domain/models/maso/burst_process.dart';

import '../../core/extensions/color_extension.dart';

class BurstGanttChart extends StatelessWidget {
  final CoreProcessor cpuExecution;
  const BurstGanttChart({super.key, required this.cpuExecution});

  @override
  Widget build(BuildContext context) {
    List<BurstProcess> burstProcesses = cpuExecution.core
        .map((hardwareComponent) => hardwareComponent.process as BurstProcess)
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Uso del procesador",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            for (var entry in burstProcesses.asMap().entries)
              entry.key: FlexColumnWidth(entry.value.arrivalTime.toDouble()),
          },
          children: [
            TableRow(
              children: cpuExecution.core.map((hardwareComponent) {
                return buildCell(
                    hardwareComponent.process?.id ??
                        hardwareComponent.state.name.capitalize(),
                    ColorExtension.random);
              }).toList(),
            )
          ],
        ),
      ],
    );
  }

  Widget buildCell(String text, Color color) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      color: color.withValues(alpha: 0.3),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
