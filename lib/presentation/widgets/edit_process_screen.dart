import 'package:flutter/material.dart';
import 'package:maso/domain/models/process.dart';

class EditProcessScreen extends StatefulWidget {
  final Process process;

  const EditProcessScreen({super.key, required this.process});

  @override
  State<EditProcessScreen> createState() => _EditProcessScreenState();
}

class _EditProcessScreenState extends State<EditProcessScreen> {
  late TextEditingController _nameController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _serviceTimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.process.name);
    _arrivalTimeController =
        TextEditingController(text: widget.process.arrivalTime.toString());
    _serviceTimeController =
        TextEditingController(text: widget.process.serviceTime.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arrivalTimeController.dispose();
    _serviceTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    final updatedProcess = Process(
      name: _nameController.text,
      arrivalTime: int.tryParse(_arrivalTimeController.text) ?? 0,
      serviceTime: int.tryParse(_serviceTimeController.text) ?? 0,
    );
    Navigator.of(context).pop(updatedProcess);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Process'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Process Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText: 'Arrival Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _serviceTimeController,
              decoration: InputDecoration(
                labelText: 'Service Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text('Save'),
        ),
      ],
    );
  }
}
