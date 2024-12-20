import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/ui/widgets/editable_text_widget.dart';
import 'package:celebrare_assignment/ui/widgets/font_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Text Canvas Editor',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.delete, color: Colors.black54),
          onPressed: () => context.read<CanvasCubit>().clearCanvas(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.black54),
            onPressed: () => context.read<CanvasCubit>().undo(),
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.black54),
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
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      context.read<CanvasCubit>().moveText(
                            index,
                            textItem.x + details.delta.dx,
                            textItem.y + details.delta.dy,
                          );
                    },
                    child: EditableTextWidget(index: index, textItem: textItem),
                  ),
                );
              }),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FontControls(),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.purple[100],
          elevation: 0,
          onPressed: () => context.read<CanvasCubit>().addText('New Text'),
          child: const Icon(Icons.add, color: Colors.deepPurple),
        ),
      ),
    );
  }
}
