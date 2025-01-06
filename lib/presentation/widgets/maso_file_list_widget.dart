import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/maso_file.dart';

import '../../core/l10n/app_localizations.dart';
import '../../domain/models/process.dart';
import 'dialogs/process_dialog.dart';

class MasoFileListWidget extends StatefulWidget {
  final MasoFile masoFile;
  final VoidCallback onFileChange;
  const MasoFileListWidget(
      {super.key, required this.masoFile, required this.onFileChange});

  @override
  State<MasoFileListWidget> createState() => _MasoFileListWidgetState();
}

class _MasoFileListWidgetState extends State<MasoFileListWidget> {
  Future<bool> _confirmDismiss(BuildContext context, Process process) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(AppLocalizations.of(context)!
                .confirmDeleteMessage(process.name)),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: Text(AppLocalizations.of(context)!.deleteButton),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final process = widget.masoFile.processes.removeAt(oldIndex);
          widget.masoFile.processes.insert(newIndex, process);
          widget.onFileChange();
        });
      },
      children: List.generate(widget.masoFile.processes.length, (index) {
        final process = widget.masoFile.processes[index];
        return Dismissible(
          key: ValueKey(process.name),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) => _confirmDismiss(context, process),
          onDismissed: (direction) {
            setState(() {
              widget.masoFile.processes.removeAt(index);
              widget.onFileChange();
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            key: ValueKey(process.name),
            title: Text(process.name),
            subtitle: Text(
              '${AppLocalizations.of(context)!.arrivalTimeLabel(process.arrivalTime.toString())} ${AppLocalizations.of(context)!.serviceTimeLabel(process.serviceTime.toString())}',
            ),
            leading: Switch(
              value: process.enabled,
              onChanged: (value) {
                setState(() {
                  process.enabled = value;
                  widget.onFileChange();
                });
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
            onTap: () async {
              final updatedProcess = await showDialog<Process>(
                context: context,
                builder: (context) => ProcessDialog(
                  process: process,
                  existingProcesses: widget.masoFile.processes,
                  processPosition: index,
                ),
              );
              if (updatedProcess != null) {
                setState(() {
                  widget.masoFile.processes[index] = updatedProcess;
                  widget.onFileChange();
                });
              }
            },
          ),
        );
      }),
    );
  }
}
