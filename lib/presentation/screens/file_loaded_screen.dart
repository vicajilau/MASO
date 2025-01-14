import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/core/constants/maso_metadata.dart';
import 'package:maso/core/context_extension.dart';
import 'package:maso/core/service_locator.dart';
import 'package:maso/domain/models/execution_setup.dart';
import 'package:maso/routes/app_router.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../core/l10n/app_localizations.dart';
import '../../domain/models/maso/i_process.dart';
import '../../domain/models/maso/maso_file.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import '../widgets/dialogs/execution_setup_dialog.dart';
import '../widgets/dialogs/exit_confirmation_dialog.dart';
import '../widgets/dialogs/process_dialog.dart';
import '../widgets/maso_file_list_widget.dart';
import '../widgets/request_file_name_dialog.dart';

class FileLoadedScreen extends StatefulWidget {
  final FileBloc fileBloc;
  final CheckFileChangesUseCase checkFileChangesUseCase;
  final MasoFile masoFile;

  const FileLoadedScreen({
    super.key,
    required this.fileBloc,
    required this.checkFileChangesUseCase,
    required this.masoFile,
  });

  @override
  State<FileLoadedScreen> createState() => _FileLoadedScreenState();
}

class _FileLoadedScreenState extends State<FileLoadedScreen> {
  late MasoFile cachedMasoFile;
  bool _hasFileChanged = false; // Variable to track file change status

  // Function to check if the file has changed
  void _checkFileChange() {
    final hasChanged = widget.checkFileChangesUseCase.execute(cachedMasoFile);
    setState(() {
      _hasFileChanged = hasChanged;
    });
  }

  Future<bool> _confirmExit() async {
    if (widget.checkFileChangesUseCase.execute(cachedMasoFile)) {
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
    cachedMasoFile = widget.masoFile;
    _checkFileChange(); // Check the file change status when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileBloc>(
      create: (_) => widget.fileBloc,
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) {
          if (state is FileLoaded) {
            context.presentSnackBar(AppLocalizations.of(context)!
                .fileSaved(state.masoFile.filePath!));
            _checkFileChange();
          }
          if (state is FileError) {
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
                  icon: Icon(Icons.arrow_back,
                      semanticLabel:
                          AppLocalizations.of(context)!.backSemanticLabel),
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
                        final createdProcess = await showDialog<IProcess>(
                          context: context,
                          builder: (context) => ProcessDialog(
                            masoFile: cachedMasoFile,
                          ),
                        );
                        if (createdProcess != null) {
                          setState(() {
                            cachedMasoFile.processes.elements.add(createdProcess);
                            _checkFileChange();
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: AppLocalizations.of(context)!.addTooltip),
                  // Save Action
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: _hasFileChanged
                        ? AppLocalizations.of(context)!.saveTooltip
                        : AppLocalizations.of(context)!.saveDisabledTooltip,
                    onPressed: _hasFileChanged
                        ? () async {
                            await _onSavePressed(context);
                          }
                        : null, // Disable button if file hasn't changed
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: cachedMasoFile.processes.elements.isNotEmpty
                        ? AppLocalizations.of(context)!.executeTooltip
                        : AppLocalizations.of(context)!.executeDisabledTooltip,
                    onPressed: cachedMasoFile.processes.elements.isNotEmpty
                        ? () async {
                            final executionSetup =
                                await showDialog<ExecutionSetup>(
                              context: context,
                              builder: (context) => ExecutionSetupDialog(),
                            );
                            if (executionSetup != null) {
                              ServiceLocator.instance
                                  .registerExecutionSetup(executionSetup);
                              if (context.mounted) {
                                context.push(AppRoutes.masoFileExecutionScreen);
                              }
                            }
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

  Future<void> _onSavePressed(BuildContext context) async {
    final String? fileName;
    if (PlatformDetail.isWeb) {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => RequestFileNameDialog(
          format: '.maso',
        ),
      );
      fileName = result;
    } else {
      fileName = AppLocalizations.of(context)!.saveDialogTitle;
    }
    if (fileName != null && context.mounted) {
      context.read<FileBloc>().add(MasoFileSaveRequested(
          cachedMasoFile, fileName, MasoMetadata.masoFileName));
    }
  }
}
