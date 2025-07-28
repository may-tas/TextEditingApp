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
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final isTextSelected = state.selectedIndex != null;
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
              mainAxisSize: MainAxisSize.min,
              children: [
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
            color: isEnabled ? Colors.grey[100] : Colors.grey[200],
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
                    ? () => _changeFontSizeWithStep(context, -2)
                    : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  selectedTextItem != null
                      ? selectedTextItem.fontSize.round().toString()
                      : 'N/A',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isEnabled ? Colors.grey[800] : Colors.grey[500],
                  ),
                ),
              ),
              _buildSizeButton(
                context: context,
                icon: Icons.add,
                onPressed: isEnabled
                    ? () => _changeFontSizeWithStep(context, 2)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _changeFontSizeWithStep(
    BuildContext context,
    int step,
  ) {
    final cubit = context.read<CanvasCubit>();
    final state = cubit.state;
    if (state.selectedIndex == null) return;

    final currentSize = state.textItems[state.selectedIndex!].fontSize;
    final newSize = (currentSize + step).clamp(8, 78);
    cubit.changeFontSize(newSize.toDouble());
  }

  // --- Font Family Controls ---
  Widget _buildFontFamilyControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
          child: StatefulBuilder(
            builder: (context, setState) {
              final state = context.watch<CanvasCubit>().state;
              final selectedIndex = _getSelectedTextIndex(state);
              final currentFontSize = _getCurrentFontSize(state, selectedIndex);
              final controller = FixedExtentScrollController(
                initialItem: (currentFontSize - 8).clamp(0, 70),
              );

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSizeButton(
                    context: context,
                    icon: Icons.remove,
                    onPressed: selectedIndex != null
                        ? () => _changeFontSizeWithStep(
                              context,
                              controller,
                              selectedIndex,
                              currentFontSize,
                              -2,
                            )
                        : null,
                  ),
                  _buildFontSizeWheel(
                    context,
                    controller,
                    selectedIndex,
                  ),
                  _buildSizeButton(
                    context: context,
                    icon: Icons.add,
                    onPressed: selectedIndex != null
                        ? () => _changeFontSizeWithStep(
                              context,
                              controller,
                              selectedIndex,
                              currentFontSize,
                              2,
                            )
                        : null,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  int? _getSelectedTextIndex(CanvasState state) {
    return state.textItems.isNotEmpty ? state.textItems.length - 1 : null;
  }

  int _getCurrentFontSize(CanvasState state, int? selectedIndex) {
    if (selectedIndex != null) {
      return state.textItems[selectedIndex].fontSize.round();
    }
    return 16;
  }

  void _changeFontSizeWithStep(
    BuildContext context,
    FixedExtentScrollController controller,
    int selectedIndex,
    int currentSize,
    int step,
  ) {
    final newSize = (currentSize + step).clamp(8, 78);
    controller.jumpToItem((newSize - 8).clamp(0, 70));
    context
        .read<CanvasCubit>()
        .changeFontSize(selectedIndex, newSize.toDouble());
  }

  Widget _buildFontSizeWheel(
    BuildContext context,
    FixedExtentScrollController controller,
    int? selectedIndex,
  ) {
    return SizedBox(
      height: 40,
      width: 60,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 32,
        diameterRatio: 1.2,
        perspective: 0.003,
        controller: controller,
        physics: selectedIndex == null
            ? const NeverScrollableScrollPhysics()
            : const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          if (selectedIndex != null) {
            final newSize = 8 + index;
            context
                .read<CanvasCubit>()
                .changeFontSize(selectedIndex, newSize.toDouble());
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFontFamilyControls(BuildContext context) {
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
              value: selectedTextItem?.fontFamily ?? 'Arial',
              items: items,
              onChanged: isEnabled
                  ? (value) => _changeFontFamily(context, value)
                  : null,
              style: TextStyle(
                color: isEnabled ? Colors.grey[800] : Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(Icons.arrow_drop_down,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400]),
              hint: !isEnabled ? const Text('Select Text') : null,
            ),
          ),
        ),
      ],
    );
  }
  // --- Color Controls ---
  Widget _buildColorControls(
      BuildContext context, TextItem? selectedTextItem, bool isEnabled) {
  Widget _buildSizeButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
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
            size: 16,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildColorControls(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.white,
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
              final selectedColor = selectedTextItem?.color ?? Colors.black;
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap:
                    isEnabled ? () => _changeTextColor(context, color) : null,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isEnabled ? Colors.blue : Colors.grey)
                          : Colors.grey.withAlpha((0.3 * 255).toInt()),
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
    required VoidCallback? onPressed,
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
            size: 16,
            color: onPressed != null ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
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
            color: onPressed != null ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  // --- Font Modification Callbacks ---
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
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      context
          .read<CanvasCubit>()
          .changeFontWeight(selectedIndex, FontWeight.normal);
      context
          .read<CanvasCubit>()
          .changeFontStyle(selectedIndex, FontStyle.normal);
    }
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
