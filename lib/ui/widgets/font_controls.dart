// lib/ui/widgets/font_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/models/text_item_model.dart';

import '../../constants/font_family_list.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';

class FontControls extends StatelessWidget {
  const FontControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to CanvasCubit's state to react to selection changes
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final isTextSelected = state.selectedIndex != null;
        // Get the selected text item, or null if nothing is selected
        final selectedTextItem =
            isTextSelected ? state.textItems[state.selectedIndex!] : null;

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
              mainAxisSize: MainAxisSize
                  .min, // Corrected typo here (MainAxisSize.min, not MainAxisSize.AxisSize.min)
              children: [
                // Pass selectedTextItem and isTextSelected to child control builders
                _buildFontSizeControls(
                    context, selectedTextItem, isTextSelected),
                const SizedBox(width: 25),
                _buildFontStyleControls(
                    context, selectedTextItem, isTextSelected),
                const SizedBox(width: 25),
                _buildFontFamilyControls(
                    context, selectedTextItem, isTextSelected),
                const SizedBox(width: 25),
                _buildColorControls(context, selectedTextItem, isTextSelected),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Font Size Controls ---
  Widget _buildFontSizeControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
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
            color: isEnabled
                ? Colors.grey[100]
                : Colors.grey[200], // Background color based on enabled state
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[400]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSizeButton(
                context: context,
                icon: Icons.remove,
                onPressed: isEnabled
                    ? () => _changeFontSize(context, decrease: true)
                    : null, // Disable if not enabled
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  selectedTextItem != null
                      ? selectedTextItem.fontSize.round().toString()
                      : 'N/A', // Display current size or "N/A"
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isEnabled
                        ? Colors.grey[800]
                        : Colors.grey[500], // Text color for disabled state
                  ),
                ),
              ),
              _buildSizeButton(
                context: context,
                icon: Icons.add,
                onPressed: isEnabled
                    ? () => _changeFontSize(context, decrease: false)
                    : null, // Disable if not enabled
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Font Family Controls ---
  Widget _buildFontFamilyControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
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
            color: isEnabled ? Colors.grey[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[400]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              menuWidth: 170,
              value: selectedTextItem?.fontFamily ??
                  'Arial', // Display selected font or default
              items:
                  items, // 'items' comes from constants/font_family_list.dart
              onChanged: isEnabled
                  ? (value) => _changeFontFamily(context, value)
                  : null, // Disable if not enabled
              style: TextStyle(
                color: isEnabled ? Colors.grey[800] : Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(Icons.arrow_drop_down,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400]),
              hint: !isEnabled
                  ? const Text('Select Text')
                  : null, // Hint when disabled
            ),
          ),
        ),
      ],
    );
  }

  // --- Color Controls ---
  Widget _buildColorControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.white, // Added white for common use
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
            color: isEnabled ? Colors.grey[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[400]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: colors.map((color) {
              final selectedColor = selectedTextItem?.color ??
                  Colors.black; // Default if no item selected
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap: isEnabled
                    ? () => _changeTextColor(context, color)
                    : null, // Disable if not enabled
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isEnabled
                              ? Colors.blue
                              : Colors
                                  .grey) // Blue if selected and enabled, grey if disabled
                          : Colors.grey.withAlpha((0.3 * 255)
                              .toInt()), // Transparent if not selected
                      width: isSelected ? 2 : 1,
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

  // --- Font Style Controls ---
  Widget _buildFontStyleControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
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
            color: isEnabled ? Colors.grey[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[400]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyleButton(
                context: context,
                icon: Icons.format_bold,
                onPressed: isEnabled
                    ? () => _changeFontWeight(context, FontWeight.bold)
                    : null,
              ),
              const SizedBox(width: 8),
              _buildStyleButton(
                context: context,
                icon: Icons.format_italic,
                onPressed: isEnabled
                    ? () => _changeFontStyle(context, FontStyle.italic)
                    : null,
              ),
              const SizedBox(width: 8),
              _buildStyleButton(
                context: context,
                icon: Icons.format_clear,
                onPressed: isEnabled ? () => _resetFontStyle(context) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Buttons ---
  Widget _buildSizeButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed, // Made nullable to enable/disable tap
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed, // Pass the nullable onPressed directly
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null
                ? Colors.grey[700]
                : Colors.grey[400], // Dim icon if disabled
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed, // Made nullable to enable/disable tap
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed, // Pass the nullable onPressed directly
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? Colors.grey[700]
                : Colors.grey[400], // Dim icon if disabled
          ),
        ),
      ),
    );
  }

  // --- Font Modification Callbacks ---
  // These methods now call the CanvasCubit methods without an index,
  // as the cubit will use its internally tracked selectedIndex.
  void _changeFontStyle(BuildContext context, FontStyle fontStyle) {
    context.read<CanvasCubit>().changeFontStyle(fontStyle);
  }

  void _changeFontWeight(BuildContext context, FontWeight fontWeight) {
    context.read<CanvasCubit>().changeFontWeight(fontWeight);
  }

  void _resetFontStyle(BuildContext context) {
    final cubit = context.read<CanvasCubit>();
    cubit.changeFontWeight(FontWeight.normal);
    cubit.changeFontStyle(FontStyle.normal);
  }

  void _changeFontSize(BuildContext context, {required bool decrease}) {
    final cubit = context.read<CanvasCubit>();
    final state = cubit.state;
    if (state.selectedIndex == null)
      return; // Do nothing if no item is selected

    final currentSize = state.textItems[state.selectedIndex!].fontSize;
    final newSize = decrease ? currentSize - 2 : currentSize + 2;
    cubit.changeFontSize(newSize);
  }

  void _changeFontFamily(BuildContext context, String? fontFamily) {
    if (fontFamily != null) {
      context.read<CanvasCubit>().changeFontFamily(fontFamily);
    }
  }

  void _changeTextColor(BuildContext context, Color color) {
    context.read<CanvasCubit>().changeTextColor(color);
  }
}
