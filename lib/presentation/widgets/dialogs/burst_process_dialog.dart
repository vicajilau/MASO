import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/maso/burst.dart';
import 'package:maso/domain/models/maso/burst_process.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/maso/burst_type.dart';
import '../../../domain/models/maso/maso_file.dart';
import '../../../domain/models/maso/thread.dart';

class BurstProcessDialog extends StatefulWidget {
  final BurstProcess? process; // Optional process for editing.
  final MasoFile masoFile; // The file containing all processes.
  final int? processPosition; // Optional index for editing a specific process.

  const BurstProcessDialog({
    super.key,
    this.process,
    required this.masoFile,
    this.processPosition,
  });

  @override
  State<BurstProcessDialog> createState() => _BurstProcessDialogState();
}

class _BurstProcessDialogState extends State<BurstProcessDialog> {
  late BurstProcess process;

  @override
  void initState() {
    super.initState();
    process = widget.process ??
        BurstProcess(
          id: '',
          arrivalTime: 0,
          threads: [],
          enabled: true,
        );
  }

  void _addThread() {
    setState(() {
      process.threads.add(
        Thread(
          id: 'Thread ${process.threads.length + 1}',
          bursts: [],
          enabled: true,
        ),
      );
    });
  }

  void _addBurst(Thread thread) {
    setState(() {
      thread.bursts.add(Burst(type: BurstType.cpu, duration: 0));
    });
  }

  void _removeThread(Thread thread) {
    setState(() {
      process.threads.remove(thread);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createBurstProcessTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            // Process ID
            TextFormField(
              initialValue: process.id,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.processIdLabel,
              ),
              onChanged: (value) => process.id = value,
            ),
            // Arrival Time
            TextFormField(
              initialValue: process.arrivalTime.toString(),
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.arrivalTimeLabelDecorator,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  process.arrivalTime = int.tryParse(value) ?? 0,
            ),
            // Threads List
            ...process.threads.map((thread) {
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    Text(thread.id),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!
                                .deleteThreadTitle),
                            content: Text(AppLocalizations.of(context)!
                                .deleteThreadConfirmation(thread.id)),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                    AppLocalizations.of(context)!.cancelButton),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _removeThread(thread);
                                  context.pop();
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .confirmButton),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                children: [
                  // Bursts within Thread
                  ...thread.bursts.map((burst) {
                    return TextFormField(
                      initialValue: burst.duration.toString(),
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.burstDurationLabel,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          burst.duration = int.tryParse(value) ?? 0,
                    );
                  }),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _addBurst(thread),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addBurstButton),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            ElevatedButton.icon(
              onPressed: _addThread,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addThreadButton),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.processPosition != null) {
              widget.masoFile.processes.elements[widget.processPosition!] =
                  process;
            } else {
              widget.masoFile.processes.elements.add(process);
            }
            context.pop();
          },
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
