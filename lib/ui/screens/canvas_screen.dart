import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
import '../widgets/background_options_sheet.dart';
import '../../utils/custom_snackbar.dart';
import '../../constants/color_constants.dart';

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
                icon: const Icon(Icons.more_vert, color: ColorConstants.uiIconBlack),
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
                        Icon(Icons.add, color: Colors.black54, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'New Page',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'load_pages',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open,
                            color: Colors.black54, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Saved Pages',
                          style: TextStyle(color: Colors.black87),
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
                          color: Colors.black54,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.currentPageName != null
                              ? "Save '${state.currentPageName}'"
                              : "Save Page",
                          style: const TextStyle(color: Colors.black87),
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
      body: BlocConsumer<CanvasCubit, CanvasState>(
        listener: (context, state) {
          // Show snackbar when there's a message from save/load operations
          if (state.message != null) {
            CustomSnackbar.showInfo(state.message!);
            // Clear the message after showing
            context.read<CanvasCubit>().clearMessage();
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => context.read<CanvasCubit>().deselectText(),
            child: Container(
              decoration: _buildBackgroundDecoration(state),
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
            Colors.black.withAlpha((0.1 * 255).toInt()),
            Colors.black.withAlpha((0.2 * 255).toInt()),
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
  late Offset localPosition;

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
    if (oldWidget.textItem.x != widget.textItem.x ||
        oldWidget.textItem.y != widget.textItem.y) {
      localPosition = Offset(widget.textItem.x, widget.textItem.y);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
