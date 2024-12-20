import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/ui/widgets/font_control.dart';
import 'package:celebrare_assignment/ui/widgets/text_canvas.dart';
import 'package:celebrare_assignment/ui/widgets/undo_redo_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Canvas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CanvasCubit>().addText('New Text');
        },
        child: const Icon(Icons.add),
      ),
      body: const Column(
        children: [
          Expanded(child: TextCanvas()),
          FontControls(),
          UndoRedoControls(),
        ],
      ),
    );
  }
}
