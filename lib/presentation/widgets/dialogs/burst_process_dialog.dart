import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/maso/burst_process.dart';
import 'package:maso/domain/models/maso/list_processes_extension.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/maso/burst.dart';
import '../../../domain/models/maso/burst_type.dart';
import '../../../domain/models/maso/maso_file.dart';
import '../../../domain/models/maso/thread.dart';

class BurstProcessDialog extends StatefulWidget {
  final BurstProcess? process;
  final MasoFile masoFile;
  final int? processPosition;

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
  late TextEditingController _idController;
  late TextEditingController _arrivalTimeController;
  late BurstProcess process;
  String? _idError;
  String? _arrivalTimeError;
  String? _burstSequenceError;

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

    _idController = TextEditingController(text: widget.process?.id);
    _arrivalTimeController =
        TextEditingController(text: widget.process?.arrivalTime.toString());
  }

  @override
  void dispose() {
    _idController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  bool _validateInput() {
    final id = _idController.text.trim();
    final arrivalTime = int.tryParse(_arrivalTimeController.text);

    setState(() {
      _idError = null;
      _arrivalTimeError = null;
      _burstSequenceError = null;
    });

    if (id.isEmpty) {
      setState(() {
        _idError = AppLocalizations.of(context)!.emptyNameError;
      });
      return false;
    }

    if (widget.masoFile.processes.elements
        .containProcessWithName(id, position: widget.processPosition)) {
      setState(() {
        _idError = AppLocalizations.of(context)!.duplicateNameError;
      });
      return false;
    }

    if (arrivalTime == null || arrivalTime < 0) {
      setState(() {
        _arrivalTimeError =
            AppLocalizations.of(context)!.invalidArrivalTimeError;
      });
      return false;
    }

    for (final thread in process.threads) {
      if (!_validateBurstSequence(thread.bursts)) {
        setState(() {
          _burstSequenceError =
              AppLocalizations.of(context)!.invalidBurstSequenceError;
        });
        return false;
      }
    }

    return true;
  }

  bool _validateBurstSequence(List<Burst> bursts) {
    if (bursts.isEmpty) return false;
    if (bursts.first.type != BurstType.cpu ||
        bursts.last.type != BurstType.cpu) {
      return false;
    }
    for (int i = 0; i < bursts.length - 1; i++) {
      if (bursts[i].type == BurstType.io &&
          bursts[i + 1].type == BurstType.io) {
        return false;
      }
    }
    return true;
  }

  void _submit() {
    if (_validateInput()) {
      context.pop(BurstProcess(
        id: _idController.text.trim(),
        arrivalTime: int.parse(_arrivalTimeController.text),
        threads: process.threads,
        enabled: process.enabled,
      ));
    }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectBurstType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BurstType.values.map((type) {
            return ListTile(
              title: Text(type.name),
              onTap: () {
                setState(() {
                  thread.bursts.add(Burst(type: type, duration: 0));
                });
                context.pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _removeThread(Thread thread) {
    setState(() {
      process.threads.remove(thread);
    });
  }

  void _removeBurst(Thread thread, Burst burst) {
    setState(() {
      thread.bursts.remove(burst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createBurstProcessTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            // Process ID
            TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.processIdLabel,
                  errorText: _idError,
                  errorMaxLines: 2,
                ),
                onChanged: (value) => setState(() => _idError = null)),
            // Arrival Time
            TextFormField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.arrivalTimeLabelDecorator,
                errorText: _arrivalTimeError,
                errorMaxLines: 2,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _arrivalTimeError = null),
            ),
            if (_burstSequenceError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _burstSequenceError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ...process.threads.map((thread) {
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(thread.id),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeThread(thread),
                    ),
                  ],
                ),
                children: [
                  // Bursts within Thread
                  ...thread.bursts.map((burst) {
                    return ListTile(
                      title: TextFormField(
                        initialValue: burst.duration.toString(),
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.burstDurationLabel,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            burst.duration = int.tryParse(value) ?? 0,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!
                                  .deleteBurstTitle),
                              content: Text(AppLocalizations.of(context)!
                                  .deleteBurstConfirmation(
                                      burst.duration.toString())),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(AppLocalizations.of(context)!
                                      .cancelButton),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _removeBurst(thread, burst);
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
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
