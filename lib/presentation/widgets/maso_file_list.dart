import 'package:flutter/material.dart';
import 'package:maso/domain/models/maso_file.dart';

import '../../domain/models/process.dart';
import 'edit_process_screen.dart';

class MasoFileList extends StatefulWidget {
  final MasoFile masoFile;
  const MasoFileList({super.key, required this.masoFile});

  @override
  State<MasoFileList> createState() => _MasoFileListState();
}

class _MasoFileListState extends State<MasoFileList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.masoFile.processes.length,
      itemBuilder: (context, index) {
        final process = widget.masoFile.processes[index];
        return ListTile(
          title: Text(process.name),
          subtitle: Text(
            'Arrival Time: ${process.arrivalTime}, Service Time: ${process.serviceTime}',
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                widget.masoFile.processes.removeAt(index);
              });
            },
          ),
          onTap: () async {
            final updatedProcess = await showDialog<Process>(
              context: context,
              builder: (context) => EditProcessScreen(process: process),
            );
            if (updatedProcess != null) {
              setState(() {
                widget.masoFile.processes[index] = updatedProcess;
              });
            }
          },
        );
      },
    );
  }
}
