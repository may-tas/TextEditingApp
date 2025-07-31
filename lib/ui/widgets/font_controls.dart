import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            const SizedBox(width: 25),
            _buildBackgroundColorButton(context), // Added background color button
          ],
        ),
      ),
    );
  }

  // New method for background color button
  Widget _buildBackgroundColorButton(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Background',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                context.read<CanvasCubit>().toggleBackgroundColorTray();
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: state.isBackgroundColorTrayVisible 
                      ? Colors.blue.shade50 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.isBackgroundColorTrayVisible 
                        ? Colors.blue.shade300 
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: state.backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      state.isBackgroundColorTrayVisible 
                          ? Icons.keyboard_arrow_up 
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: state.isBackgroundColorTrayVisible 
                          ? Colors.blue.shade700 
                          : Colors.black54,
                    ),
                  ],
                ),
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
              pItem.fontStyle != cItem.fontStyle;
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
                    icon: Icons.format_clear,
                    isSelected: false,
                    onPressed: isDisabled
                        ? null
                        : () {
                            context.read<CanvasCubit>().changeFontStyle(
                                selectedIndex, FontStyle.normal);
                            context.read<CanvasCubit>().changeFontWeight(
                                selectedIndex, FontWeight.normal);
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
            !isDisabled ? state.textItems[selectedIndex].fontFamily : 'Arial';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Font',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentFont,
                  items: items,
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          if (value != null) {
                            context
                                .read<CanvasCubit>()
                                .changeFontFamily(selectedIndex, value);
                          }
                        },
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
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
            const Text('Color',
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
                children: colors.map((color) {
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
                }).toList(),
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