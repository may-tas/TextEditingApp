import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../constants/color_constants.dart';
import '../../../models/draw_model.dart';

class DrawingToolsPanel extends StatelessWidget {
  final Color currentColor;
  final double currentStrokeWidth;
  final BrushType currentBrushType;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(BrushType) onBrushTypeChanged;

  const DrawingToolsPanel({
    super.key,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.currentBrushType,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onBrushTypeChanged,
  });

  String _getBrushTypeName(BrushType brushType) {
    switch (brushType) {
      case BrushType.brush:
        return 'Brush';
      case BrushType.marker:
        return 'Marker';
      case BrushType.highlighter:
        return 'Highlighter';
      case BrushType.pencil:
        return 'Pencil';
      case BrushType.watercolor:
        return 'Watercolor';
      case BrushType.oilPaint:
        return 'Oil Paint';
      case BrushType.charcoal:
        return 'Charcoal';
      case BrushType.sprayPaint:
        return 'Spray Paint';
    }
  }

  IconData _getBrushTypeIcon(BrushType brushType) {
    switch (brushType) {
      case BrushType.brush:
        return Icons.brush;
      case BrushType.marker:
        return Icons.edit;
      case BrushType.highlighter:
        return Icons.highlight;
      case BrushType.pencil:
        return Icons.create;
      case BrushType.watercolor:
        return Icons.water_drop;
      case BrushType.oilPaint:
        return Icons.palette;
      case BrushType.charcoal:
        return Icons.blur_on;
      case BrushType.sprayPaint:
        return Icons.grain;
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = currentColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerTypeLabels: const <ColorPickerType, String>{
                ColorPickerType.wheel: 'Color Ring',
              },
              enableShadesSelection: true,
              colorCodeHasColor: true,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.wheel: true,
                ColorPickerType.accent: false,
                ColorPickerType.primary: false,
                ColorPickerType.custom: false,
                ColorPickerType.customSecondary: false,
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define available colors for drawing
    final colors = [
      ColorConstants.dialogTextBlack, // Black
      ColorConstants.dialogWhite, // White
      ColorConstants.dialogRed, // Red
      ColorConstants.dialogButtonBlue, // Blue
      ColorConstants.dialogGreen, // Green
      ColorConstants.highlightYellow, // Yellow
      ColorConstants.dialogPurple, // Purple
      ColorConstants.dialogWarningOrange, // Orange
    ];

    return Container(
      width: 120, // Increased width to accommodate brush size controls
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.dialogWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.dialogTextBlack,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: ColorConstants.gray300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: ColorConstants.gray300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Brush Type section
          Text(
            'Brush Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),

          // Brush type grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.2,
            ),
            itemCount: BrushType.values.length,
            itemBuilder: (context, index) {
              final brushType = BrushType.values[index];
              final isSelected = currentBrushType == brushType;

              return InkWell(
                onTap: () => onBrushTypeChanged(brushType),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConstants.dialogButtonBlue.withValues(alpha: 0.1)
                        : ColorConstants.gray50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? ColorConstants.dialogButtonBlue
                          : ColorConstants.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getBrushTypeIcon(brushType),
                        size: 18,
                        color: isSelected
                            ? ColorConstants.dialogButtonBlue
                            : ColorConstants.gray600,
                      ),
                      // const SizedBox(height: 4),
                      Text(
                        _getBrushTypeName(brushType),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ColorConstants.dialogButtonBlue
                              : ColorConstants.gray600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Color picker section
          Text(
            'Color',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),

          // Color display box with color code
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.getBlackWithValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to pick',
                    style: TextStyle(
                      fontSize: 8,
                      color: currentColor.computeLuminance() > 0.5
                          ? ColorConstants.dialogTextBlack
                          : ColorConstants.dialogWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 8,
                      color: currentColor.computeLuminance() > 0.5
                          ? ColorConstants.uiIconBlack
                          : ColorConstants.dialogWhite.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Material(
            color: ColorConstants.transparent,
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 8.0, // gap between lines
              children: colors.map((color) {
                final isSelected = currentColor.toARGB32() == color.toARGB32();
                return InkWell(
                  onTap: () {
                    onColorChanged(color);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 30,
                    height: 30,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? ColorConstants.dialogButtonBlue
                            : ColorConstants.gray300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: ColorConstants.dialogButtonBlue
                                    .withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: color,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // const SizedBox(height: 16),

          // Brush size section
          Text(
            'Size',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // const SizedBox(height: 8),

          // Size preview circle
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: ColorConstants.gray50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorConstants.gray200, width: 1),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: currentStrokeWidth.clamp(3.0, 20.0),
                height: currentStrokeWidth.clamp(3.0, 20.0),
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.3),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // const SizedBox(height: 8),

          // Size slider
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: currentColor.withValues(alpha: 0.8),
                inactiveTrackColor: ColorConstants.gray200,
                thumbColor: currentColor,
                trackHeight: 3.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                overlayColor: currentColor.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: currentStrokeWidth.clamp(1.0, 20.0),
                min: 1.0,
                max: 20.0,
                divisions: 19,
                onChanged: (value) {
                  onStrokeWidthChanged(value);
                },
              ),
            ),
          ),

          // const SizedBox(height: 4),

          // Size value display
          Text(
            '${currentStrokeWidth.round()}px',
            style: TextStyle(
              fontSize: 10,
              color: ColorConstants.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
