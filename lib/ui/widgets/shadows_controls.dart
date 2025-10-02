import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../../constants/color_constants.dart';

class ShadowControls extends StatelessWidget {
  const ShadowControls({super.key});

  // Shadow color palette 
  static const shadowColors = [
    Colors.black,
    Color(0xFF424242),
    Color(0xFF757575),
    Color(0xFF1976D2),
    Color(0xFFD32F2F),
    Color(0xFF388E3C),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.hasShadow != cItem.hasShadow ||
              pItem.shadowColor != cItem.shadowColor ||
              pItem.shadowBlurRadius != cItem.shadowBlurRadius ||
              pItem.shadowOffset != cItem.shadowOffset;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;
        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final hasShadow = textItem?.hasShadow ?? false;
        final shadowColor = textItem?.shadowColor ?? Colors.black;
        final shadowBlur = textItem?.shadowBlurRadius ?? 4.0;
        final shadowOffset = textItem?.shadowOffset ?? const Offset(2.0, 2.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Shadow',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: Row(
                children: [
                  // Toggle shadow on/off
                  _buildStyleButton(
                    icon: Icons.blur_on,
                    isSelected: hasShadow,
                    onPressed: isDisabled
                        ? null
                        : () => context
                            .read<CanvasCubit>()
                            .toggleTextShadow(selectedIndex),
                  ),

                  if (hasShadow) ...[
                    const SizedBox(width: 8),
                    // Shadow color swatches
                    ...shadowColors.map((color) {
                      final isSelected = shadowColor == color;
                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () => context
                                .read<CanvasCubit>()
                                .changeShadowColor(selectedIndex, color),
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? ColorConstants.gray800
                                  : ColorConstants.gray400,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    // More colors button
                    _buildStyleButton(
                      icon: Icons.colorize,
                      isSelected: false,
                      tooltip: 'More colors',
                      onPressed: isDisabled
                          ? null
                          : () => _showColorPicker(
                                context,
                                selectedIndex,
                                shadowColor,
                              ),
                    ),
                    const SizedBox(width: 8),
                    // Shadow presets button
                    _buildStyleButton(
                      icon: Icons.auto_awesome,
                      isSelected: false,
                      tooltip: 'Shadow presets',
                      onPressed: isDisabled
                          ? null
                          : () =>
                              _showShadowPresetsDialog(context, selectedIndex),
                    ),
                    const SizedBox(width: 8),
                    // Advanced settings button
                    _buildStyleButton(
                      icon: Icons.tune,
                      isSelected: false,
                      tooltip: 'Shadow settings',
                      onPressed: isDisabled
                          ? null
                          : () => _showShadowSettingsSheet(
                                context,
                                selectedIndex,
                                shadowColor,
                                shadowBlur,
                                shadowOffset,
                              ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onPressed,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: isSelected
            ? ColorConstants.gray800.withValues(alpha: 0.2)
            : ColorConstants.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: isSelected
                  ? ColorConstants.gray800
                  : ColorConstants.gray700,
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    int selectedIndex,
    Color currentColor,
  ) async {
    final pickedColor = await showColorPickerDialog(
      context,
      currentColor,
      title: const Text('Pick shadow color'),
      showColorCode: true,
      showRecentColors: false,
      backgroundColor: ColorConstants.uiWhite,
    );
    if (context.mounted) {
      context.read<CanvasCubit>().changeShadowColor(selectedIndex, pickedColor);
    }
  }

  void _showShadowPresetsDialog(BuildContext context, int selectedIndex) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: ColorConstants.gray800),
            SizedBox(width: 8),
            Text('Shadow Presets'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.soft,
                'Soft Shadow',
                'Light, subtle shadow',
                Icons.wb_cloudy,
              ),
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.medium,
                'Medium Shadow',
                'Balanced shadow effect',
                Icons.filter_drama,
              ),
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.hard,
                'Hard Shadow',
                'Strong, defined shadow',
                Icons.wb_sunny,
              ),
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.glow,
                'White Glow',
                'Soft white glow effect',
                Icons.lightbulb_outline,
              ),
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.coloredGlow,
                'Colored Glow',
                'Glow matching text color',
                Icons.color_lens,
              ),
              _buildPresetTile(
                context,
                selectedIndex,
                ShadowPreset.outline,
                'Outline',
                'Sharp text outline',
                Icons.border_outer,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: ColorConstants.gray800,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    int selectedIndex,
    ShadowPreset preset,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: ColorConstants.gray800),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: () {
          context.read<CanvasCubit>().applyShadowPreset(selectedIndex, preset);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showShadowSettingsSheet(
    BuildContext context,
    int selectedIndex,
    Color currentColor,
    double currentBlur,
    Offset currentOffset,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConstants.dialogWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<CanvasCubit>(),
        child: BlocBuilder<CanvasCubit, CanvasState>(
          builder: (builderContext, state) {
            final textItem = state.selectedTextItemIndex != null &&
                    state.selectedTextItemIndex! < state.textItems.length
                ? state.textItems[state.selectedTextItemIndex!]
                : null;

            final shadowColor = textItem?.shadowColor ?? currentColor;
            final shadowBlur = textItem?.shadowBlurRadius ?? currentBlur;
            final shadowOffset = textItem?.shadowOffset ?? currentOffset;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shadow Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Shadow color picker
                  const Text('Shadow Color',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: shadowColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: ColorConstants.gray300, width: 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final pickedColor = await showColorPickerDialog(
                              sheetContext,
                              shadowColor,
                              title: const Text('Pick shadow color'),
                              showColorCode: true,
                              showRecentColors: false,
                            );
                            if (builderContext.mounted) {
                              builderContext
                                  .read<CanvasCubit>()
                                  .changeShadowColor(selectedIndex, pickedColor);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.gray800,
                            foregroundColor: ColorConstants.uiWhite,
                          ),
                          child: const Text('Choose Color'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Blur radius slider
                  const Text('Blur Radius',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: shadowBlur,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          label: shadowBlur.toStringAsFixed(1),
                          activeColor: ColorConstants.gray800,
                          onChanged: (value) {
                            builderContext
                                .read<CanvasCubit>()
                                .changeShadowBlur(selectedIndex, value);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          shadowBlur.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Offset controls
                  const Text('Shadow Offset',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Horizontal',
                                style: TextStyle(fontSize: 12)),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: shadowOffset.dx,
                                    min: -20,
                                    max: 20,
                                    divisions: 40,
                                    label: shadowOffset.dx.toStringAsFixed(1),
                                    activeColor: ColorConstants.gray800,
                                    onChanged: (value) {
                                      builderContext
                                          .read<CanvasCubit>()
                                          .changeShadowOffset(selectedIndex,
                                              Offset(value, shadowOffset.dy));
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    shadowOffset.dx.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vertical', style: TextStyle(fontSize: 12)),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: shadowOffset.dy,
                                    min: -20,
                                    max: 20,
                                    divisions: 40,
                                    label: shadowOffset.dy.toStringAsFixed(1),
                                    activeColor: ColorConstants.gray800,
                                    onChanged: (value) {
                                      builderContext
                                          .read<CanvasCubit>()
                                          .changeShadowOffset(selectedIndex,
                                              Offset(shadowOffset.dx, value));
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    shadowOffset.dy.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.gray800,
                        foregroundColor: ColorConstants.dialogWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}