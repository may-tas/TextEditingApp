import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/ui/widgets/editable_text_widget.dart';
import 'package:celebrare_assignment/ui/widgets/font_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Canvas Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => context.read<CanvasCubit>().undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => context.read<CanvasCubit>().redo(),
          ),
        ],
      ),
      body: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return Stack(
            children: [
              ...state.textItems.asMap().entries.map((entry) {
                final index = entry.key;
                final textItem = entry.value;

                return Positioned(
                  left: textItem.x,
                  top: textItem.y,
                  child: EditableTextWidget(index: index, textItem: textItem),
                );
              }),
            ],
          );
        },
      ),
      bottomNavigationBar: const FontControls(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CanvasCubit>().addText('New Text'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
