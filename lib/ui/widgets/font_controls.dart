import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/font_family_list.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';

class FontControls extends StatelessWidget {
  const FontControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFontSizeWheel(context),
            const SizedBox(width: 25),
            _buildFontStyleControls(context),
            const SizedBox(width: 25),
            _buildFontFamilyControls(context),
            const SizedBox(width: 25),
            _buildColorControls(context),
            const SizedBox(width: 25), // Add spacing for the new button
            _buildCopyButton(context),
            const SizedBox(width: 25),
            _buildClearFormatButton(context), // Call your new function here
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) =>
          previous.selectedTextItemIndex != current.selectedTextItemIndex,
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Copy',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildStyleButton(
                icon: Icons.copy,
                isSelected:
                    false, // This button is never in a "selected" state.
                onPressed: isDisabled
                    ? null
                    : () {
                        context.read<CanvasCubit>().copyText(selectedIndex, context);
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClearFormatButton(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) =>
          previous.selectedTextItemIndex != current.selectedTextItemIndex,
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Restore Default',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              // re-using Button-style for consistent UI
              child: _buildStyleButton(
                icon: Icons.layers_clear,
                isSelected:
                    false, // This button is never in a "selected" state.
                onPressed: isDisabled
                    ? null
                    : () {
                        context
                            .read<CanvasCubit>()
                            .resetFormatting(selectedIndex);
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontStyleControls(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontWeight != cItem.fontWeight ||
              pItem.fontStyle != cItem.fontStyle ||
              pItem.isUnderlined != cItem.isUnderlined;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final isBold = textItem?.fontWeight == FontWeight.bold;
        final isItalic = textItem?.fontStyle == FontStyle.italic;
        final isUnderlined = textItem?.isUnderlined ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Style',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  _buildStyleButton(
                    icon: Icons.format_bold,
                    isSelected: isBold,
                    onPressed: isDisabled
                        ? null
                        : () {
                            final newWeight =
                                isBold ? FontWeight.normal : FontWeight.bold;
                            context
                                .read<CanvasCubit>()
                                .changeFontWeight(selectedIndex, newWeight);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_italic,
                    isSelected: isItalic,
                    onPressed: isDisabled
                        ? null
                        : () {
                            final newStyle =
                                isItalic ? FontStyle.normal : FontStyle.italic;
                            context
                                .read<CanvasCubit>()
                                .changeFontStyle(selectedIndex, newStyle);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_underline,
                    isSelected: isUnderlined,
                    onPressed: isDisabled
                        ? null
                        : () {
                            bool newUnderline = !isUnderlined;
                            context.read<CanvasCubit>().changeTextUnderline(
                                selectedIndex, newUnderline);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_clear,
                    isSelected: false,
                    onPressed: isDisabled
                        ? null
                        : () {
                            context.read<CanvasCubit>().changeFontStyle(
                                selectedIndex, FontStyle.normal);
                            context.read<CanvasCubit>().changeFontWeight(
                                selectedIndex, FontWeight.normal);
                            context
                                .read<CanvasCubit>()
                                .changeTextUnderline(selectedIndex, false);
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontFamilyControls(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null &&
            current.selectedTextItemIndex! < current.textItems.length) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontFamily != cItem.fontFamily;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        final currentFont =
            !isDisabled ? state.textItems[selectedIndex].fontFamily : 'Roboto';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Font',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: isDisabled
                  ? null
                  : () =>
                      _showFontPickerModal(context, selectedIndex, currentFont),
              label: Text(
                currentFont,
                style: GoogleFonts.getFont(currentFont, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[800],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFontPickerModal(
      BuildContext context, int selectedIndex, String currentFont) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return _FontPickerContent(
                  currentFont: currentFont,
                  selectedIndex: selectedIndex,
                  scrollController: scrollController,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildColorControls(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;
        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final selectedColor = textItem?.color ?? Colors.black;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Text Color',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  ...colors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => context
                              .read<CanvasCubit>()
                              .changeTextColor(selectedIndex, color),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : (color == Colors.white
                                    ? Colors.grey[400]!
                                    : Colors.transparent),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                  //More Colors Button ^_^
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.black54),
                    tooltip: 'More colors',
                    onPressed: isDisabled
                        ? null
                        : () async {
                            final pickedColor = await showColorPickerDialog(
                              context,
                              selectedColor,
                              title: const Text('Pick a color'),
                              showColorCode: true,
                              showRecentColors: false,
                              backgroundColor: Colors.white,
                              constraints: const BoxConstraints(
                                minHeight: 400,
                                minWidth: 300,
                              ),
                            );

                            if (!context.mounted) return;

                            context
                                .read<CanvasCubit>()
                                .changeTextColor(selectedIndex, pickedColor);
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeWheel(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontSize != cItem.fontSize;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled = selectedIndex == null;
        final currentSize =
            !isDisabled ? state.textItems[selectedIndex].fontSize.round() : 16;

        return StatefulBuilder(
          builder: (context, setState) {
            final controller = FixedExtentScrollController(
              initialItem: (currentSize - 8).clamp(0, 70),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final index = (currentSize - 8).clamp(0, 70);
              if (controller.hasClients && controller.selectedItem != index) {
                controller.jumpToItem(index);
              }
            });

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Size',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      _buildSizeButton(
                        icon: Icons.remove,
                        onPressed: isDisabled
                            ? null
                            : () {
                                final newSize = (currentSize - 2).clamp(8, 78);
                                context.read<CanvasCubit>().changeFontSize(
                                    selectedIndex, newSize.toDouble());
                              },
                      ),
                      SizedBox(
                        height: 40,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: controller,
                          itemExtent: 32,
                          diameterRatio: 1.2,
                          perspective: 0.003,
                          physics: isDisabled
                              ? const NeverScrollableScrollPhysics()
                              : const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            if (!isDisabled) {
                              final newSize = 8 + index;
                              context.read<CanvasCubit>().changeFontSize(
                                  selectedIndex, newSize.toDouble());
                            }
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 71,
                            builder: (context, index) {
                              final size = 8 + index;
                              return Center(
                                child: Text(
                                  '$size',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      _buildSizeButton(
                        icon: Icons.add,
                        onPressed: isDisabled
                            ? null
                            : () {
                                final newSize = (currentSize + 2).clamp(8, 78);
                                context.read<CanvasCubit>().changeFontSize(
                                    selectedIndex, newSize.toDouble());
                              },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSizeButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: isSelected
          ? Colors.blue.withAlpha((0.2 * 255).toInt())
          : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.blueAccent : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _FontPickerContent extends StatefulWidget {
  final String currentFont;
  final int selectedIndex;
  final ScrollController scrollController;

  const _FontPickerContent({
    required this.currentFont,
    required this.selectedIndex,
    required this.scrollController,
  });

  @override
  State<_FontPickerContent> createState() => _FontPickerContentState();
}

class _FontPickerContentState extends State<_FontPickerContent> {
  String searchQuery = '';
  late List<String> filteredFonts;

  @override
  void initState() {
    super.initState();
    filteredFonts = List.from(googleFontNames);
  }

  void _updateSearch(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      filteredFonts = googleFontNames
          .where((font) => font.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text("Select Font",
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: 'Search fonts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: filteredFonts.length,
            itemBuilder: (context, index) {
              final font = filteredFonts[index];
              final isSelected = font == widget.currentFont;

              return ListTile(
                title: Text(
                  font,
                  style: GoogleFonts.getFont(font, fontSize: 16),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  context
                      .read<CanvasCubit>()
                      .changeFontFamily(widget.selectedIndex, font);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
