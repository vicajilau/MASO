import 'package:flutter/material.dart';
import 'package:maso/core/service_locator.dart';

import '../../domain/models/maso_file.dart';
import '../widgets/maso_file_list.dart';

class FileLoadedScreen extends StatefulWidget {
  const FileLoadedScreen({super.key});

  @override
  State<FileLoadedScreen> createState() => _FileLoadedScreenState();
}

class _FileLoadedScreenState extends State<FileLoadedScreen> {
  final MasoFile masoFile = ServiceLocator.instance.getIt<MasoFile>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${masoFile.metadata.name} - ${masoFile.metadata.description}"),
        actions: [
          // Save Action
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () {
              // context.read<FileBloc>().add(SaveMasoFile());
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            tooltip: 'Execute',
            onPressed: () {
              // context.read<FileBloc>().add(ExecuteMasoFileProcesses());
            },
          ),
        ],
      ),
      body: MasoFileList(
        masoFile: masoFile,
      ),
    );
  }
}
