import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/models/text_item_model.dart';
import 'package:texterra/ui/screens/save_page_dialog.dart';
import 'package:texterra/ui/screens/saved_pages.dart';
import '../../constants/color_constants.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/font_controls.dart';
import '../widgets/background_color_tray.dart';
import '../widgets/background_options_sheet.dart';
import '../widgets/drawing_canvas.dart';
import '../../utils/custom_snackbar.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  // Method to show background options
  void _showBackgroundOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConstants.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const BackgroundOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.uiWhite,
      appBar: AppBar(
        backgroundColor: ColorConstants.uiWhite,
        elevation: 0.5,
        title: BlocBuilder<CanvasCubit, CanvasState>(
          builder: (context, state) {
            return Column(
              children: [
                const Text(
                  'Text Editor',
                  style: TextStyle(
                    color: ColorConstants.dialogTextBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                if (state.currentPageName != null)
                  Text(
                    state.currentPageName!,
                    style: const TextStyle(
                      color: ColorConstants.uiGrayMedium,
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
          icon: const Icon(Icons.delete, color: ColorConstants.uiIconBlack),
          onPressed: () {
            final cubit = context.read<CanvasCubit>();
            if (cubit.state.textItems.isNotEmpty ||
                cubit.state.backgroundImagePath != null) {
              cubit.clearCanvas();
              CustomSnackbar.showInfo('Canvas cleared');
            } else if (cubit.state.drawPaths.isNotEmpty) {
              cubit.clearDrawings();
              CustomSnackbar.showInfo('Drawings cleared');
            } else {
              CustomSnackbar.showInfo('Canvas is already empty');
            }
          },
        ),
        actions: <Widget>[
          // Background options button
          IconButton(
            tooltip: 'Background options',
            icon: const Icon(
              Icons.wallpaper,
              color: ColorConstants.uiIconBlack,
            ),
            onPressed: () => _showBackgroundOptions(context),
          ),
          // Undo button
          IconButton(
            tooltip: "Undo",
            icon: const Icon(Icons.undo, color: ColorConstants.uiIconBlack),
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
            icon: const Icon(Icons.redo, color: ColorConstants.uiIconBlack),
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
          // More options dropdown menu
          BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                tooltip: "More options",
                icon: const Icon(Icons.more_vert,
                    color: ColorConstants.uiIconBlack),
                color: ColorConstants.uiWhite, // White background for dropdown
                onSelected: (value) async {
                  final cubit = context.read<CanvasCubit>();

                  switch (value) {
                    case 'new_page':
                      cubit.createNewPage();
                      CustomSnackbar.showInfo('New page created');
                      break;
                    case 'load_pages':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<CanvasCubit>(),
                            child: const SavedPagesScreen(),
                          ),
                        ),
                      );
                      break;
                    case 'save_page':
                      final wasHandled = await cubit.handleSaveAction();
                      if (!wasHandled) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => BlocProvider.value(
                            value: cubit,
                            child: const SavePageDialog(),
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'new_page',
                    child: Row(
                      children: [
                        Icon(Icons.add,
                            color: ColorConstants.uiIconBlack, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'New Page',
                          style: TextStyle(
                              color: ColorConstants.dialogTextBlack87),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'load_pages',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open,
                            color: ColorConstants.uiIconBlack, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Saved Pages',
                          style: TextStyle(
                              color: ColorConstants.dialogTextBlack87),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'save_page',
                    child: Row(
                      children: [
                        Icon(
                          state.currentPageName != null
                              ? Icons.save
                              : Icons.save_as,
                          color: ColorConstants.uiIconBlack,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.currentPageName != null
                              ? "Save '${state.currentPageName}'"
                              : "Save Page",
                          style: const TextStyle(
                              color: ColorConstants.dialogTextBlack87),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              // Only deselect if we're not in drawing mode
              if (!state.isDrawingMode) {
                context.read<CanvasCubit>().deselectText();
              }
            },
            behavior: HitTestBehavior.deferToChild,
            child: Container(
              decoration: _buildBackgroundDecoration(state),
              child: Stack(
                children: [
                  // Drawing Canvas
                  DrawingCanvas(
                    paths: state.drawPaths,
                    isDrawingMode: state.isDrawingMode,
                    currentDrawColor: state.currentDrawColor,
                    currentStrokeWidth: state.currentStrokeWidth,
                    onStartDrawing: (offset) {
                      context.read<CanvasCubit>().startNewDrawPath(offset);
                    },
                    onUpdateDrawing: (offset) {
                      context.read<CanvasCubit>().updateDrawPath(offset);
                    },
                    onEndDrawing: () {
                      // Nothing needed here for now
                    },
                    onColorChanged: (color) {
                      context.read<CanvasCubit>().setDrawColor(color);
                    },
                    onStrokeWidthChanged: (width) {
                      context.read<CanvasCubit>().setStrokeWidth(width);
                    },
                    onUndoDrawing: () {
                      context.read<CanvasCubit>().undoLastDrawing();
                    },
                    onClearDrawing: () {
                      context.read<CanvasCubit>().clearDrawings();
                    },
                  ),

                  // Text Items
                  for (int index = 0; index < state.textItems.length; index++)
                    Positioned(
                      left: state.textItems[index].x,
                      top: state.textItems[index].y,
                      child: IgnorePointer(
                        ignoring: state.isDrawingMode,
                        child: _DraggableText(
                          key: ValueKey('text_item_$index'),
                          index: index,
                          textItem: state.textItems[index],
                          isSelected: !state.isDrawingMode &&
                              state.selectedTextItemIndex == index,
                        ),
                      ),
                    ),

                  // Drawing Mode Indicator
                  if (state.isDrawingMode)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ColorConstants.getBlackWithValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.brush,
                                color: state.currentDrawColor, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Drawing Mode',
                              style: TextStyle(
                                  color: ColorConstants.dialogWhite,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  color: ColorConstants.getBlackWithAlpha((0.05 * 255).toInt()),
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
                    color: ColorConstants.dialogWhite,
                    child: const BackgroundColorTray(),
                  ),
                ),
                const FontControls(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<CanvasCubit, CanvasState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: FloatingActionButton(
              backgroundColor: ColorConstants.dialogWhite,
              elevation: 0.5,
              onPressed: () {
                // Show options for text or drawing
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: ColorConstants.dialogWhite,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text Option
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorConstants.dialogButtonBlue
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.text_fields,
                                  color: ColorConstants.dialogButtonBlue),
                            ),
                            title: const Text('Add Text'),
                            subtitle:
                                const Text('Add and format text on canvas'),
                            onTap: () {
                              Navigator.pop(context);
                              // Exit drawing mode if active
                              if (state.isDrawingMode) {
                                context
                                    .read<CanvasCubit>()
                                    .setDrawingMode(false);
                              }
                              context.read<CanvasCubit>().addText('New Text');
                            },
                          ),
                          const Divider(),
                          // Drawing Option
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColorConstants.dialogGreen
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.brush,
                                  color: ColorConstants.dialogGreen),
                            ),
                            title: const Text('Draw'),
                            subtitle: Text(state.isDrawingMode
                                ? 'Currently in drawing mode'
                                : 'Switch to drawing mode'),
                            onTap: () {
                              Navigator.pop(context);
                              context.read<CanvasCubit>().toggleDrawingMode();
                              if (!state.isDrawingMode) {
                                CustomSnackbar.showInfo(
                                    'Drawing mode activated. Tap to draw.');
                              }
                            },
                          ),
                          // If in drawing mode, add option to undo last drawing
                          if (state.isDrawingMode && state.drawPaths.isNotEmpty)
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorConstants.dialogButtonBlue
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.undo,
                                    color: ColorConstants.dialogButtonBlue),
                              ),
                              title: const Text('Undo Last Drawing'),
                              subtitle: const Text(
                                  'Remove the most recent drawing stroke'),
                              onTap: () {
                                Navigator.pop(context);
                                context.read<CanvasCubit>().undoLastDrawing();
                              },
                            ),
                          // If in drawing mode, add option to clear drawings
                          if (state.isDrawingMode && state.drawPaths.isNotEmpty)
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorConstants.dialogRed
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: ColorConstants.dialogRed),
                              ),
                              title: const Text('Clear Drawings'),
                              subtitle:
                                  const Text('Remove all drawings from canvas'),
                              onTap: () {
                                Navigator.pop(context);
                                context.read<CanvasCubit>().clearDrawings();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Icon(state.isDrawingMode ? Icons.brush : Icons.add,
                  color: state.isDrawingMode
                      ? ColorConstants.dialogButtonBlue
                      : ColorConstants.dialogTextBlack),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build background decoration
  BoxDecoration _buildBackgroundDecoration(CanvasState state) {
    if (state.backgroundImagePath != null) {
      // Show background image with overlay gradient
      return BoxDecoration(
        image: DecorationImage(
          image: _getImageProvider(state.backgroundImagePath!),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorConstants.getBlackWithAlpha((0.1 * 255).toInt()),
            ColorConstants.getBlackWithAlpha((0.2 * 255).toInt()),
          ],
        ),
      );
    } else {
      // Show solid color gradient
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            state.backgroundColor,
            state.backgroundColor.withAlpha((0.95 * 255).toInt()),
          ],
        ),
      );
    }
  }

  // Helper method to get appropriate image provider for web and mobile
  ImageProvider _getImageProvider(String imagePath) {
    if (kIsWeb && imagePath.startsWith('data:')) {
      // On web, if it's a data URL, decode it and use MemoryImage
      final String base64String = imagePath.split(',')[1];
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } else {
      // On mobile or if it's a file path, use FileImage
      return FileImage(File(imagePath));
    }
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
  Offset? _startPosition;
  Offset? _dragStartPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        // Select this text item when tapped
        context.read<CanvasCubit>().selectText(widget.index);
      },
      onPanStart: (details) {
        // Select this text item when starting to drag
        context.read<CanvasCubit>().selectText(widget.index);
        _startPosition = Offset(widget.textItem.x, widget.textItem.y);
        _dragStartPosition = details.localPosition;
      },
      onPanUpdate: (details) {
        if (_startPosition != null && _dragStartPosition != null) {
          final delta = details.localPosition - _dragStartPosition!;
          final newPosition = _startPosition! + delta;

          // Update position in real-time during drag
          context.read<CanvasCubit>().moveText(
                widget.index,
                newPosition.dx,
                newPosition.dy,
              );
        }
      },
      onPanEnd: (_) {
        _startPosition = null;
        _dragStartPosition = null;
      },
      behavior: HitTestBehavior.opaque,
      child: EditableTextWidget(
        index: widget.index,
        textItem: widget.textItem,
        isSelected: widget.isSelected,
      ),
    );
  }
}
