import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/models/text_item_model.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/font_controls.dart';

class CanvasScreen extends StatefulWidget {
  const  CanvasScreen({super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen>{
  bool showTray = false;
  static const List<Color> backgroundColors = [
    Color(0xFF1A1A1A), // Dark Gray (default)
    Color(0xFF2E1065), // Deep Purple
    Color(0xFF1E3A8A), // Deep Blue
    Color(0xFF166534), // Deep Green
    Color(0xFF7C2D12), // Deep Brown/Orange
    Color.fromARGB(255, 255, 255, 255) // White
  ];

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
          //Button to change the color of the background
          IconButton(
            tooltip: "Change Background Color",
            onPressed: (){
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) {
                
                  final cubit = context.read<CanvasCubit>();
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:Wrap(
                      spacing :12,
                      children: backgroundColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            cubit.changeBackgroundColor(color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );

                }
              );
            },
            icon: const Icon(
              Icons.color_lens,
              color: Colors.black54,
            ),
          ),
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
          onPressed: () => context.read<CanvasCubit>().addText('New Text'),
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
