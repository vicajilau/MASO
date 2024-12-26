import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/service_locator.dart';
import '../blocs/file_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MASO - Simulador'), actions: [
        TextButton(
          onPressed: () => context.go('/home'),
          child: const Text('Inicio', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => context.go('/settings'),
          child: const Text('Configuración',
              style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => context.go('/about'),
          child: const Text('Acerca de', style: TextStyle(color: Colors.white)),
        ),
      ]),
      body: BlocProvider(
        create: (_) => getIt<FileBloc>(),
        child: BlocListener<FileBloc, FileState>(
          listener: (context, state) {
            if (state is FileLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Archivo cargado: ${state.filePath}')),
              );
            }
            if (state is FileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
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
                        child: const Text('Arrastra un archivo .maso aquí'),
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
