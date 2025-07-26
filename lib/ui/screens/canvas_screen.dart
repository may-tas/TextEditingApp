import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/font_controls.dart';

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
          'Text Editor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          tooltip: "Clear Canvas",
          icon: const Icon(Icons.delete, color: Colors.black54),
          onPressed: () => context.read<CanvasCubit>().clearCanvas(),
        ),
        actions: [
          IconButton(
            tooltip: "Undo",
            icon: const Icon(Icons.undo, color: Colors.black54),
            onPressed: () => context.read<CanvasCubit>().undo(),
          ),
          IconButton(
            tooltip: "Redo",
            icon: const Icon(Icons.redo, color: Colors.black54),
            onPressed: () => context.read<CanvasCubit>().redo(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF1A1A1A).withOpacity(0.95),
            ],
          ),
        ),
        child: BlocBuilder<CanvasCubit, CanvasState>(
          builder: (context, state) {
            return Stack(
              children: [
                ...state.textItems.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final textItem = entry.value;
                    return Positioned(
                      left: textItem.x,
                      top: textItem.y,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          const speedFactor = 2.0;
                          context.read<CanvasCubit>().moveText(
                                index,
                                textItem.x + details.delta.dx * speedFactor,
                                textItem.y + details.delta.dy * speedFactor,
                              );
                        },
                        child: EditableTextWidget(
                            index: index, textItem: textItem),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: FontControls(),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.blueGrey[100],
          elevation: 0.5,
          onPressed: () => context.read<CanvasCubit>().addText('New Text'),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
