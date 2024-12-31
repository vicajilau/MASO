import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/core/context_extension.dart';
import 'package:maso/core/service_locator.dart';
import 'package:maso/presentation/widgets/request_file_name_dialog.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../domain/models/maso_file.dart';
import '../../domain/models/process.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import '../widgets/dialogs/exit_confirmation_dialog.dart';
import '../widgets/dialogs/process_dialog.dart';
import '../widgets/maso_file_list_widget.dart';

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
            builder: (context) => ExitConfirmationDialog(),
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
    return BlocProvider<FileBloc>(
      create: (_) => ServiceLocator.instance.getIt<FileBloc>(),
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) async {
          if (state is FileLoaded) {
            context.presentSnackBar(AppLocalizations.of(context)!
                .fileSaved(state.masoFile.filePath!));
            await _checkFileChange();
          }
          if (state is FileError && context.mounted) {
            context.presentSnackBar(state.getDescription(context));
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    "${cachedMasoFile.metadata.name} - ${cachedMasoFile.metadata.description}"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    final shouldExit = await _confirmExit();
                    if (shouldExit && context.mounted) {
                      context.pop();
                    }
                  },
                ),
                actions: [
                  IconButton(
                      onPressed: () async {
                        final createdProcess = await showDialog<Process>(
                          context: context,
                          builder: (context) => ProcessDialog(
                            existingProcesses: cachedMasoFile.processes,
                          ),
                        );
                        if (createdProcess != null) {
                          setState(() {
                            cachedMasoFile.processes.add(createdProcess);
                            _checkFileChange();
                          });
                        }
                      },
                      icon: const Icon(Icons.add)),
                  // Save Action
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: 'Save',
                    onPressed: _hasFileChanged
                        ? () async {
                            final String? fileName;
                            if (PlatformDetail.isWeb) {
                              // Crea el dialogo para obtener el nombre del fichero pasandole el nombre del antiguo fichero si lo tuvo
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) => RequestFileNameDialog(),
                              );
                              fileName = result;
                            } else {
                              fileName =
                                  AppLocalizations.of(context)!.saveDialogTitle;
                            }
                            if (fileName != null && context.mounted) {
                              context.read<FileBloc>().add(FileSaveRequested(
                                    cachedMasoFile,
                                    fileName,
                                  ));
                            }
                          }
                        : null, // Disable button if file hasn't changed
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Execute',
                    onPressed: cachedMasoFile.processes.isNotEmpty
                        ? () {
                            // context.read<FileBloc>().add(FileSaveRequested(cachedMasoFile, AppLocalizations.of(context)!.saveDialogTitle));
                          }
                        : null, // Disable button if file hasn't changed
                  ),
                ],
              ),
              body: MasoFileListWidget(
                masoFile: cachedMasoFile,
                onFileChange: _checkFileChange,
              ),
            );
          },
        ),
      ),
    );
  }
}
