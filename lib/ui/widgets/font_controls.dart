// lib/ui/widgets/font_controls.dart
import 'package:celebrare_assignment/constants/font_family_list.dart';
import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // <--- NEW: Import for firstWhereOrNull

class FontControls extends StatelessWidget {
  const FontControls({super.key});

  @override
  Widget build(BuildContext context) {
    // We use BlocBuilder here to react to CanvasState changes
    return BlocBuilder<CanvasCubit, CanvasState>(
      // Optimize rebuilds: only rebuild if selectedTextItemId changes,
      // or if the properties of the currently selected item change.
      buildWhen: (previous, current) {
        final prevSelected = previous.textItems.firstWhereOrNull(
          (item) => item.id == previous.selectedTextItemId,
        );
        final currentSelected = current.textItems.firstWhereOrNull(
          (item) => item.id == current.selectedTextItemId,
        );

        // Rebuild if selection status changes OR if selected item's properties differ
        return previous.selectedTextItemId != current.selectedTextItemId ||
               (prevSelected?.fontSize != currentSelected?.fontSize) ||
               (prevSelected?.fontFamily != currentSelected?.fontFamily) ||
               (prevSelected?.color != currentSelected?.color) ||
               (prevSelected?.fontStyle != currentSelected?.fontStyle) ||
               (prevSelected?.fontWeight != currentSelected?.fontWeight);
      },
      builder: (context, state) {
        final canvasCubit = context.read<CanvasCubit>();

        // Find the currently selected text item from the state
        final TextItem? selectedTextItem = state.textItems.firstWhereOrNull(
          (item) => item.id == state.selectedTextItemId,
        );
        final bool isItemSelected = selectedTextItem != null;

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFontSizeControls(context, isItemSelected, selectedTextItem, canvasCubit),
                const SizedBox(width: 25),
                _buildFontStyleControls(context, isItemSelected, selectedTextItem, canvasCubit),
                const SizedBox(width: 25),
                _buildFontFamilyControls(context, isItemSelected, selectedTextItem, canvasCubit),
                const SizedBox(width: 25),
                _buildColorControls(context, isItemSelected, selectedTextItem, canvasCubit),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSizeControls(
    BuildContext context,
    bool isItemSelected,
    TextItem? selectedTextItem,
    CanvasCubit canvasCubit,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Size',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSizeButton(
                context: context,
                icon: Icons.remove,
                onPressed: isItemSelected
                    ? () => canvasCubit.changeFontSize(selectedTextItem!.fontSize - 2)
                    : null, // Disable if no item selected
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isItemSelected ? '${selectedTextItem!.fontSize.round()}' : '-', // Show actual size or placeholder
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildSizeButton(
                context: context,
                icon: Icons.add,
                onPressed: isItemSelected
                    ? () => canvasCubit.changeFontSize(selectedTextItem!.fontSize + 2)
                    : null, // Disable if no item selected
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilyControls(
    BuildContext context,
    bool isItemSelected,
    TextItem? selectedTextItem,
    CanvasCubit canvasCubit,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Font',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
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
              menuWidth: 170,
              value: isItemSelected ? selectedTextItem!.fontFamily : null, // Set current font family or null
              hint: const Text('Select Font'), // Hint when nothing is selected
              items: fontFamilyList.map((family) {
                return DropdownMenuItem<String>(
                  value: family,
                  child: Text(family),
                );
              }).toList(),
              onChanged: isItemSelected // Disable if no item selected
                  ? (value) {
                      if (value != null) {
                        canvasCubit.changeFontFamily(value);
                      }
                    }
                  : null,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed, // onPressed can now be null
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed, // Will be null if disabled
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null ? Colors.grey[700] : Colors.grey[400], // Change color when disabled
          ),
        ),
      ),
    );
  }

  Widget _buildColorControls(
    BuildContext context,
    bool isItemSelected,
    TextItem? selectedTextItem,
    CanvasCubit canvasCubit,
  ) {
    final colors = [
      Colors.black,
      Colors.white, // Added white for variety based on default text color
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: colors.map((color) {
              final isSelectedColor = isItemSelected && selectedTextItem!.color == color;
              return GestureDetector(
                onTap: isItemSelected // Disable if no item selected
                    ? () => canvasCubit.changeTextColor(color)
                    : null,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelectedColor
                          ? Colors.blue // Highlight selected color
                          : Colors.grey.withOpacity(0.3),
                      width: isSelectedColor ? 2 : 1,

          child: BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              final selectedColor = state.textItems.isNotEmpty
                  ? state.textItems.last.color
                  : Colors.black;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: colors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      final selectedIndex = state.textItems.length - 1;
                      if (selectedIndex >= 0) {
                        context.read<CanvasCubit>().changeTextColor(
                          selectedIndex,
                          color,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),

                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFontStyleControls(
    BuildContext context,
    bool isItemSelected,
    TextItem? selectedTextItem,
    CanvasCubit canvasCubit,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Style',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyleButton(
                context: context,
                icon: Icons.format_bold,
                onPressed: isItemSelected
                    ? () {
                        // Toggle bold
                        canvasCubit.changeFontWeight(
                          selectedTextItem!.fontWeight == FontWeight.bold
                              ? FontWeight.normal
                              : FontWeight.bold,
                        );
                      }
                    : null,
                // Highlight button if selected item is bold
                isActive: isItemSelected && selectedTextItem!.fontWeight == FontWeight.bold,
              ),
              const SizedBox(width: 8),
              _buildStyleButton(
                context: context,
                icon: Icons.format_italic,
                onPressed: isItemSelected
                    ? () {
                        // Toggle italic
                        canvasCubit.changeFontStyle(
                          selectedTextItem!.fontStyle == FontStyle.italic
                              ? FontStyle.normal
                              : FontStyle.italic,
                        );
                      }
                    : null,
                // Highlight button if selected item is italic
                isActive: isItemSelected && selectedTextItem!.fontStyle == FontStyle.italic,
              ),
              const SizedBox(width: 8),
              _buildStyleButton(
                context: context,
                icon: Icons.format_clear,
                onPressed: () => _resetFontStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Modified _buildStyleButton to include an 'isActive' parameter for visual feedback
  Widget _buildStyleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isActive = false, // <--- NEW: For highlighting active style
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? (isActive ? Colors.blueAccent : Colors.grey[700]) // Active color vs default
                : Colors.grey[400], // Disabled color
          ),
        ),
      ),
    );
  }


 
  // The logic is now inline within the onPressed callbacks in _buildXControls methods

  void _changeFontStyle(BuildContext context, FontStyle fontStyle) {
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      context.read<CanvasCubit>().changeFontStyle(selectedIndex, fontStyle);
    }
  }

  void _changeFontWeight(BuildContext context, FontWeight fontWeight) {
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      context.read<CanvasCubit>().changeFontWeight(selectedIndex, fontWeight);
    }
  }

  void _resetFontStyle(BuildContext context) {
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      context.read<CanvasCubit>().changeFontWeight(selectedIndex, FontWeight.normal);
      context.read<CanvasCubit>().changeFontStyle(selectedIndex, FontStyle.normal);
    }
  }

  void _changeFontSize(BuildContext context, {required bool decrease}) {
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      final currentSize =
          context.read<CanvasCubit>().state.textItems[selectedIndex].fontSize;
      final newSize = decrease ? currentSize - 2 : currentSize + 2;
      context.read<CanvasCubit>().changeFontSize(
        selectedIndex,
        newSize,
      );
    }
  }

  void _changeFontFamily(BuildContext context, String? fontFamily) {
    if (fontFamily != null) {
      final selectedIndex =
          context.read<CanvasCubit>().state.textItems.length - 1;
      if (selectedIndex >= 0) {
        context.read<CanvasCubit>().changeFontFamily(selectedIndex, fontFamily);
      }
    }
  }

}
