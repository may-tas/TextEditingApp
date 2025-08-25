import 'dart:io';
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

  // NEW: Method to show background options
  void _showBackgroundOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Background Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BackgroundOptionTile(
                    icon: Icons.photo_library,
                    title: 'Upload Image',
                    subtitle: 'From gallery',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<CanvasCubit>().uploadBackgroundImage();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BackgroundOptionTile(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Use camera',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<CanvasCubit>().takePhotoForBackground();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BackgroundOptionTile(
                    icon: Icons.color_lens,
                    title: 'Solid Color',
                    subtitle: 'Pick a color',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<CanvasCubit>().toggleTray();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<CanvasCubit, CanvasState>(
                  builder: (context, state) {
                    return Expanded(
                      child: _BackgroundOptionTile(
                        icon: Icons.clear,
                        title: 'Remove Image',
                        subtitle: 'Clear background',
                        enabled: state.backgroundImagePath != null,
                        onTap: state.backgroundImagePath != null
                            ? () {
                                Navigator.pop(context);
                                context.read<CanvasCubit>().removeBackgroundImage();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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
            if (cubit.state.textItems.isNotEmpty || cubit.state.backgroundImagePath != null) {
              cubit.clearCanvas();
              CustomSnackbar.showInfo('Canvas cleared');
            } else {
              CustomSnackbar.showInfo('Canvas is already empty');
            }
          },
        ),
        actions: <Widget>[
          // UPDATED: Change background button (now opens background options)
          IconButton(
            tooltip: 'Background options',
            icon: const Icon(
              Icons.wallpaper,
              color: Colors.black54,
            ),
            onPressed: () => _showBackgroundOptions(context),
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
          // More options dropdown menu
          BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                tooltip: "More options",
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                color: Colors.white, // White background for dropdown
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
                  PopupMenuItem<String>(
                    value: 'new_page',
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.black54, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'New Page',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'load_pages',
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open,
                            color: Colors.black54, size: 20),
                        const SizedBox(width: 12),
                        const Text(
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
          image: FileImage(File(state.backgroundImagePath!)),
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
}

// Custom widget for background option tiles
class _BackgroundOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _BackgroundOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.grey[50] : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled ? Colors.black87 : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: enabled ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled ? Colors.grey[600] : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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