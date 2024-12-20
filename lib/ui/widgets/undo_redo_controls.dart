import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UndoRedoControls extends StatelessWidget {
  const UndoRedoControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<CanvasCubit>().undo();
            },
            child: const Text('Undo'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CanvasCubit>().redo();
            },
            child: const Text('Redo'),
          ),
        ],
      ),
    );
  }
}
