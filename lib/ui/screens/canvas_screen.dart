import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/models/text_item_model.dart';
import 'package:texterra/ui/screens/save_page_dialog.dart';
import 'package:texterra/ui/screens/saved_pages.dart';
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
        title: BlocBuilder<CanvasCubit, CanvasState>(
          builder: (context, state) {
            return Column(
              children: [
                const Text(
                  'Text Editor',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                if (state.currentPageName != null)
                  Text(
                    state.currentPageName!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            );
          },
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
        actions: <Widget>[
          // New page button
          IconButton(
            tooltip: "New Page",
            icon: const Icon(Icons.add, color: Colors.black54),
            onPressed: () {
              final cubit = context.read<CanvasCubit>();
              cubit.createNewPage();
              CustomSnackbar.showInfo('New page created');
            },
          ),
          // Load saved pages button
          IconButton(
            tooltip: "Load Saved Pages",
            icon: const Icon(Icons.folder_open, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<CanvasCubit>(),
                    child: const SavedPagesScreen(),
                  ),
                ),
              );
            },
          ),
          // Save page button
          BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              return IconButton(
                tooltip: state.currentPageName != null
                    ? "Save '${state.currentPageName}'"
                    : "Save Page",
                icon: Icon(
                  state.currentPageName != null ? Icons.save : Icons.save_as,
                  color: Colors.black54,
                ),
                onPressed: () async {
                  final cubit = context.read<CanvasCubit>();
                  final wasHandled = await cubit.handleSaveAction();

                  if (!wasHandled) {
                    // Show dialog only if auto-save wasn't possible
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: const SavePageDialog(),
                      ),
                    );
                  }
                },
              );
            },
          ),
          // Change background color button
          IconButton(
            tooltip: 'Change background color',
            icon: const Icon(
              Icons.color_lens,
              color: Colors.black54,
            ),
            onPressed: () => context.read<CanvasCubit>().toggleTray(),
          ),
          // Undo button
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
          // Redo button
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
      body: BlocConsumer<CanvasCubit, CanvasState>(
        listener: (context, state) {
          // Show snackbar when there's a message from save/load operations
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
              ),
            );
            // Clear the message after showing
            context.read<CanvasCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => context.read<CanvasCubit>().deselectText(),
            child: Container(
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
                children: [
                  ...List.generate(state.textItems.length, (index) {
                    final textItem = state.textItems[index];
                    final isSelected = state.selectedTextItemIndex == index;
                    return _DraggableText(
                      key: ValueKey('text_item_$index'),
                      index: index,
                      textItem: textItem,
                      isSelected: isSelected,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return Container(
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
                Visibility(
                  visible: state.isTrayShown,
                  child: Container(
                    color: Colors.white,
                    child: const BackgroundColorTray(),
                  ),
                ),
                const FontControls(),
              ],
            ),
          );
        },
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
    super.key,
    required this.index,
    required this.textItem,
    required this.isSelected,
  });

  @override
  State<_DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<_DraggableText>
    with AutomaticKeepAliveClientMixin {
  late Offset localPosition;
  bool _isDragging = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    localPosition = Offset(widget.textItem.x, widget.textItem.y);
  }

  @override
  void didUpdateWidget(covariant _DraggableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update position if we're not currently dragging
    if (!_isDragging &&
        (oldWidget.textItem.x != widget.textItem.x ||
            oldWidget.textItem.y != widget.textItem.y)) {
      localPosition = Offset(widget.textItem.x, widget.textItem.y);
    }
  }

  void _safeUpdatePosition() {
    if (!mounted) return; // Early exit if widget is unmounted

    Future.microtask(() {
      if (!mounted) return; // Check again after microtask delay

      try {
        final cubit = context.read<CanvasCubit>();
        cubit.moveText(
          widget.index,
          localPosition.dx,
          localPosition.dy,
        );
      } catch (e) {
        debugPrint('Error during position update: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Positioned(
      left: localPosition.dx,
      top: localPosition.dy,
      child: GestureDetector(
        onPanStart: (_) {
          _isDragging = true;
        },
        onPanUpdate: (details) {
          if (mounted) {
            setState(() {
              localPosition += details.delta;
            });
          }
        },
        onPanEnd: (_) {
          _isDragging = false;
          _safeUpdatePosition();
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