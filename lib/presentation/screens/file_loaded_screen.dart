import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/core/service_locator.dart';

import '../../domain/models/maso_file.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../widgets/exit_confirmation_screen.dart';
import '../widgets/maso_file_list.dart';

class FileLoadedScreen extends StatefulWidget {
  const FileLoadedScreen({super.key});

  @override
  State<FileLoadedScreen> createState() => _FileLoadedScreenState();
}

class _FileLoadedScreenState extends State<FileLoadedScreen> {
  final MasoFile cachedMasoFile = ServiceLocator.instance.getIt<MasoFile>();
  bool _hasFileChanged = false; // Variable to track file change status

  // Function to check if the file has changed
  Future<void> _checkFileChange() async {
    final CheckFileChangesUseCase checkFileChangesUseCase =
        ServiceLocator.instance.getIt<CheckFileChangesUseCase>();
    bool hasChanged = await checkFileChangesUseCase.execute(cachedMasoFile);
    setState(() {
      _hasFileChanged = hasChanged;
    });
  }

  Future<bool> _confirmExit() async {
    final CheckFileChangesUseCase checkFileChangesUseCase =
        ServiceLocator.instance.getIt<CheckFileChangesUseCase>();
    if (await checkFileChangesUseCase.execute(cachedMasoFile) && mounted) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => ExitConfirmationScreen(),
          ) ??
          false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkFileChange(); // Check the file change status when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${cachedMasoFile.metadata.name} - ${cachedMasoFile.metadata.description}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldExit = await _confirmExit();
            if (shouldExit && context.mounted) {
              context.pop();
            }
          },
        ),
        actions: [
          // Save Action
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _hasFileChanged
                ? () {
                    // Add your save logic here
                    // context.read<FileBloc>().add(SaveMasoFile());
                  }
                : null, // Disable button if file hasn't changed
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
        masoFile: cachedMasoFile,
        onFileChange: _checkFileChange,
      ),
    );
  }
}
