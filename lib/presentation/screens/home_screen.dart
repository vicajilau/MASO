import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/service_locator.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.titleAppBar),
          actions: [
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(AppLocalizations.of(context)!.home,
                  style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => context.go('/settings'),
              child: Text(AppLocalizations.of(context)!.settings,
                  style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => context.go('/about'),
              child: Text(AppLocalizations.of(context)!.about,
                  style: const TextStyle(color: Colors.white)),
            ),
          ]),
      body: BlocProvider(
        create: (_) => getIt<FileBloc>(),
        child: BlocListener<FileBloc, FileState>(
          listener: (context, state) {
            if (state is FileLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context)!
                        .fileLoaded(state.filePath))),
              );
            }
            if (state is FileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.getDescription(context))),
              );
            }
          },
          child: Builder(
            builder: (context) {
              return DropTarget(
                onDragDone: (details) {
                  context
                      .read<FileBloc>()
                      .add(FileDropped(details.files.first.path));
                },
                child: Center(
                  child: DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(AppLocalizations.of(context)!.dropFileHere),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
