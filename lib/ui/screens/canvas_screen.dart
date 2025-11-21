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
import '../widgets/text_box_widget.dart';
import '../widgets/font_controls.dart';
import '../widgets/background_color_tray.dart';
import '../widgets/background_options_sheet.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/history_timeline.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/web_utils.dart';

class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

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

  void _showHistoryTimeline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: HistoryTimeline(),
      ),
    );
  }

  // Handle keyboard shortcut actions
  void _handleSave(BuildContext context) {
    final cubit = context.read<CanvasCubit>();
    cubit.handleSaveAction().then((wasHandled) {
      if (!wasHandled && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => BlocProvider.value(
            value: cubit,
            child: const SavePageDialog(),
          ),
        );
      }
    });
  }

  void _handleUndo(BuildContext context) {
    final cubit = context.read<CanvasCubit>();
    if (cubit.state.currentHistoryIndex > 0) {
      cubit.undo();
    } else {
      CustomSnackbar.showInfo('Nothing to undo');
    }
  }

  void _handleRedo(BuildContext context) {
    final cubit = context.read<CanvasCubit>();
    if (cubit.state.currentHistoryIndex < cubit.state.history.length - 1) {
      cubit.redo();
    } else {
      CustomSnackbar.showInfo('Nothing to redo');
    }
  }

  void _handleNew(BuildContext context) {
    context.read<CanvasCubit>().createNewPage();
  }

  void _handleClear(BuildContext context) {
    final cubit = context.read<CanvasCubit>();
    if (cubit.state.textItems.isNotEmpty ||
        cubit.state.backgroundImagePath != null) {
      cubit.clearCanvas();
    } else if (cubit.state.drawPaths.isNotEmpty) {
      cubit.clearDrawings();
    } else {
      CustomSnackbar.showInfo('Canvas is already empty');
    }
  }

  void _handleToggleDrawing(BuildContext context) {
    context.read<CanvasCubit>().toggleDrawingMode();
  }

  void _handleAddText(BuildContext context) {
    context.read<CanvasCubit>().addText('New Text');
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
      onSave: () => _handleSave(context),
      onUndo: () => _handleUndo(context),
      onRedo: () => _handleRedo(context),
      onNew: () => _handleNew(context),
      onClear: () => _handleClear(context),
      onToggleDrawing: () => _handleToggleDrawing(context),
      onAddText: () => _handleAddText(context),
      child: Scaffold(
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
            tooltip: kIsWeb ? "Clear Canvas (Ctrl+Del)" : "Clear Canvas",
            icon: const Icon(Icons.delete, color: ColorConstants.uiIconBlack),
            onPressed: () => _handleClear(context),
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Background options',
              icon: const Icon(Icons.wallpaper,
                  color: ColorConstants.uiIconBlack),
              onPressed: () => _showBackgroundOptions(context),
            ),
            IconButton(
              tooltip: kIsWeb ? "Undo (Ctrl+Z)" : "Undo",
              icon: const Icon(Icons.undo, color: ColorConstants.uiIconBlack),
              onPressed: () => _handleUndo(context),
            ),
            IconButton(
              tooltip: kIsWeb ? "Redo (Ctrl+Shift+Z)" : "Redo",
              icon: const Icon(Icons.redo, color: ColorConstants.uiIconBlack),
              onPressed: () => _handleRedo(context),
            ),
            IconButton(
              tooltip: "History Timeline",
              icon: const Icon(Icons.timeline, color: ColorConstants.uiIconBlack),
              onPressed: () => _showHistoryTimeline(context),
            ),
            BlocBuilder<CanvasCubit, CanvasState>(
              builder: (context, state) {
                return PopupMenuButton<String>(
                  tooltip: "More options",
                  icon: const Icon(Icons.more_vert,
                      color: ColorConstants.uiIconBlack),
                  color: ColorConstants.uiWhite,
                  onSelected: (value) async {
                    final cubit = context.read<CanvasCubit>();

                    switch (value) {
                      case 'new_page':
                        cubit.createNewPage();
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
                        _handleSave(context);
                        break;
                      case 'shortcuts':
                        if (kIsWeb) {
                          _showKeyboardShortcuts(context);
                        }
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'new_page',
                      child: Row(
                        children: [
                          const Icon(Icons.add,
                              color: ColorConstants.uiIconBlack, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            kIsWeb ? 'New Page (Ctrl+N)' : 'New Page',
                            style: const TextStyle(
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
                          Text('Saved Pages',
                              style: TextStyle(
                                  color: ColorConstants.dialogTextBlack87)),
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
                                ? kIsWeb
                                    ? "Save '${state.currentPageName}' (Ctrl+S)"
                                    : "Save '${state.currentPageName}'"
                                : kIsWeb
                                    ? "Save Page (Ctrl+S)"
                                    : "Save Page",
                            style: const TextStyle(
                                color: ColorConstants.dialogTextBlack87),
                          ),
                        ],
                      ),
                    ),
                    if (kIsWeb)
                      const PopupMenuItem<String>(
                        value: 'shortcuts',
                        child: Row(
                          children: [
                            Icon(Icons.keyboard,
                                color: ColorConstants.uiIconBlack, size: 20),
                            SizedBox(width: 12),
                            Text('Keyboard Shortcuts',
                                style: TextStyle(
                                    color: ColorConstants.dialogTextBlack87)),
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
                if (!state.isDrawingMode) {
                  context.read<CanvasCubit>().deselectText();
                }
              },
              behavior: HitTestBehavior.deferToChild,
              child: Container(
                decoration: _buildBackgroundDecoration(state),
                child: Stack(
                  children: [
                    DrawingCanvas(
                      paths: state.drawPaths,
                      isDrawingMode: state.isDrawingMode,
                      currentDrawColor: state.currentDrawColor,
                      currentStrokeWidth: state.currentStrokeWidth,
                      currentBrushType: state.currentBrushType,
                      onStartDrawing: (offset) {
                        context.read<CanvasCubit>().startNewDrawPath(offset);
                      },
                      onUpdateDrawing: (offset) {
                        context.read<CanvasCubit>().updateDrawPath(offset);
                      },
                      onEndDrawing: () {},
                      onColorChanged: (color) {
                        context.read<CanvasCubit>().setDrawColor(color);
                      },
                      onStrokeWidthChanged: (width) {
                        context.read<CanvasCubit>().setStrokeWidth(width);
                      },
                      onBrushTypeChanged: (brushType) {
                        context.read<CanvasCubit>().setBrushType(brushType);
                      },
                      onUndoDrawing: () {
                        context.read<CanvasCubit>().undoLastDrawing();
                      },
                      onClearDrawing: () {
                        context.read<CanvasCubit>().clearDrawings();
                      },
                    ),
                    for (int index = 0; index < state.textItems.length; index++)
                      Positioned(
                        left: state.textItems[index].x,
                        top: state.textItems[index].y,
                        child: IgnorePointer(
                          ignoring: state.isDrawingMode,
                          child: _DraggableTextBox(
                            key: ValueKey('text_item_$index'),
                            index: index,
                            textItem: state.textItems[index],
                            isSelected: !state.isDrawingMode &&
                                state.selectedTextItemIndex == index,
                          ),
                        ),
                      ),
                    if (state.isDrawingMode)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                ColorConstants.getBlackWithValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.brush,
                                  color: state.currentDrawColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                kIsWeb
                                    ? 'Drawing Mode (Ctrl+D to exit)'
                                    : 'Drawing Mode',
                                style: const TextStyle(
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
                    color:
                        ColorConstants.getBlackWithAlpha((0.05 * 255).toInt()),
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
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: FloatingActionButton(
                backgroundColor: ColorConstants.dialogWhite,
                elevation: 0.5,
                onPressed: () {
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
                              title: const Text(
                                  kIsWeb ? 'Add Text (Ctrl+T)' : 'Add Text'),
                              subtitle:
                                  const Text('Add and format text on canvas'),
                              onTap: () {
                                Navigator.pop(context);
                                if (state.isDrawingMode) {
                                  context
                                      .read<CanvasCubit>()
                                      .setDrawingMode(false);
                                }
                                context.read<CanvasCubit>().addText('New Text');
                              },
                            ),
                            const Divider(),
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
                              title: Text(kIsWeb ? 'Draw (Ctrl+D)' : 'Draw'),
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
                            if (state.isDrawingMode &&
                                state.drawPaths.isNotEmpty)
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
                            if (state.isDrawingMode &&
                                state.drawPaths.isNotEmpty)
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
                                subtitle: const Text(
                                    'Remove all drawings from canvas'),
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
                child: Icon(
                  state.isDrawingMode ? Icons.brush : Icons.add,
                  color: state.isDrawingMode
                      ? ColorConstants.dialogButtonBlue
                      : ColorConstants.dialogTextBlack,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(CanvasState state) {
    if (state.backgroundImagePath != null) {
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

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shortcutItem('Ctrl + S', 'Save page'),
              _shortcutItem('Ctrl + N', 'New page'),
              _shortcutItem('Ctrl + T', 'Add text'),
              _shortcutItem('Ctrl + Z', 'Undo'),
              _shortcutItem('Ctrl + Shift + Z', 'Redo'),
              _shortcutItem('Ctrl + Y', 'Redo (alternative)'),
              _shortcutItem('Ctrl + D', 'Toggle drawing mode'),
              _shortcutItem('Ctrl + Del', 'Clear canvas'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _shortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorConstants.gray100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ColorConstants.gray300),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _DraggableTextBox extends StatefulWidget {
  final int index;
  final TextItem textItem;
  final bool isSelected;

  const _DraggableTextBox({
    super.key,
    required this.index,
    required this.textItem,
    required this.isSelected,
  });

  @override
  State<_DraggableTextBox> createState() => _DraggableTextBoxState();
}

class _DraggableTextBoxState extends State<_DraggableTextBox> {
  Offset? _startPosition;
  Offset? _dragStartPosition;
  bool _isRotating = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (!_isRotating) {
          context.read<CanvasCubit>().selectText(widget.index);
          _startPosition = Offset(widget.textItem.x, widget.textItem.y);
          _dragStartPosition = details.localPosition;
        }
      },
      onPanUpdate: (details) {
        if (!_isRotating &&
            _startPosition != null &&
            _dragStartPosition != null) {
          final delta = details.localPosition - _dragStartPosition!;
          final newPosition = _startPosition! + delta;
          context.read<CanvasCubit>().moveText(
                widget.index,
                newPosition.dx,
                newPosition.dy,
              );
        }
      },
      onPanEnd: (details) {
        if (!_isRotating &&
            _startPosition != null &&
            _dragStartPosition != null) {
          final delta = details.localPosition - _dragStartPosition!;
          final newPosition = _startPosition! + delta;
          context.read<CanvasCubit>().moveTextWithHistory(
                widget.index,
                newPosition.dx,
                newPosition.dy,
              );
          _startPosition = null;
          _dragStartPosition = null;
        }
      },
      child: TextBoxWidget(
        index: widget.index,
        textItem: widget.textItem,
        isSelected: widget.isSelected,
        onRotationStateChanged: (isRotating) {
          setState(() {
            _isRotating = isRotating;
          });
        },
      ),
    );
  }
}
