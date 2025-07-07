import 'package:flutter/material.dart';
import 'package:maso/core/extensions/string_extension.dart';
import 'package:maso/domain/models/core_processor.dart';
import 'package:maso/domain/models/maso/regular_process.dart';

import '../../core/extensions/color_extension.dart';

class RegularGanttChart extends StatelessWidget {
  final CoreProcessor cpuExecution;
  const RegularGanttChart({super.key, required this.cpuExecution});

  @override
  Widget build(BuildContext context) {
    List<RegularProcess> regularProcesses = cpuExecution.core
        .map((hardwareComponent) => hardwareComponent.process as RegularProcess)
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
            for (var entry in regularProcesses.asMap().entries)
              entry.key: FlexColumnWidth(entry.value.serviceTime.toDouble()),
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
