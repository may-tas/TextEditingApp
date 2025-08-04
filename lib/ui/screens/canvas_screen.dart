import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/models/text_item_model.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/font_controls.dart';
import '../widgets/background_color_tray.dart';
import '../../utils/custom_snackbar.dart';

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
          onPressed: () {
            final cubit = context.read<CanvasCubit>();
            if (cubit.state.textItems.isNotEmpty) {
              cubit.clearCanvas();
              CustomSnackbar.showInfo('Canvas cleared');
            } else {
              CustomSnackbar.showInfo('Canvas is already empty');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: "Undo",
            icon: const Icon(Icons.undo, color: Colors.black54),
            onPressed: () {
              final cubit = context.read<CanvasCubit>();
              if (cubit.state.history.isNotEmpty) {
                cubit.undo();
                CustomSnackbar.showInfo('Action undone');
              } else {
                CustomSnackbar.showInfo('Nothing to undo');
              }
            },
          ),
          IconButton(
            tooltip: "Redo",
            icon: const Icon(Icons.redo, color: Colors.black54),
            onPressed: () {
              final cubit = context.read<CanvasCubit>();
              if (cubit.state.future.isNotEmpty) {
                cubit.redo();
                CustomSnackbar.showInfo('Action redone');
              } else {
                CustomSnackbar.showInfo('Nothing to redo');
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  state.backgroundColor,
                  state.backgroundColor.withAlpha((0.95 * 255).toInt()),
                ],
              ),
            ),
            child: Stack(
              children: state.textItems.asMap().entries.map((entry) {
                final index = entry.key;
                final textItem = entry.value;
                final isSelected = state.selectedTextItemIndex == index;
                return _DraggableText(index: index, textItem: textItem, isSelected: isSelected);
              }).toList(),
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              child: const BackgroundColorTray(),
            ),
            const FontControls(),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 0.5,
          onPressed: () {
            context.read<CanvasCubit>().addText('New Text');
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}

class _DraggableText extends StatefulWidget {
  final int index;
  final TextItem textItem;
  final bool isSelected;

  const _DraggableText({
    required this.index,
    required this.textItem,
    required this.isSelected,
  });

  @override
  State<_DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<_DraggableText> {
  late Offset localPosition;

  @override
  void initState() {
    super.initState();
    localPosition = Offset(widget.textItem.x, widget.textItem.y);
  }

  @override
  void didUpdateWidget(covariant _DraggableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textItem.x != widget.textItem.x ||
        oldWidget.textItem.y != widget.textItem.y) {
      localPosition = Offset(widget.textItem.x, widget.textItem.y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: localPosition.dx,
      top: localPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            localPosition += details.delta;
          });
        },
        onPanEnd: (_) {
          context.read<CanvasCubit>().moveText(
                widget.index,
                localPosition.dx,
                localPosition.dy,
              );
        },
        child: EditableTextWidget(
          index: widget.index,
          textItem: widget.textItem,
          isSelected: widget.isSelected,
        ),
      ),
    );
  }
}
