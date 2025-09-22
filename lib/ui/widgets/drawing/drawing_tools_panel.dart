import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class DrawingToolsPanel extends StatelessWidget {
  final Color currentColor;
  final double currentStrokeWidth;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;

  const DrawingToolsPanel({
    super.key,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
  });

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
      Color(0xFF000000), // Black
      Color(0xFFFFFFFF), // White
      Color(0xFFFF0000), // Red
      Color(0xFF0000FF), // Blue
      Color(0xFF00FF00), // Green
      Color(0xFFFFFF00), // Yellow
      Color(0xFF800080), // Purple
      Color(0xFFFF8000), // Orange
    ];

    return Container(
      width: 120, // Increased width to accommodate brush size controls
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Color picker section
          Text(
            'Color',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // Color display box with color code
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 8,
                      color: currentColor.computeLuminance() > 0.5
                          ? Colors.black54
                          : Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Material(
            color: Colors.transparent,
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
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.5),
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

          const SizedBox(height: 16),

          // Brush size section
          Text(
            'Size',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // Size preview circle
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 1),
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

          const SizedBox(height: 8),

          // Size slider
          Container(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: currentColor.withValues(alpha: 0.8),
                inactiveTrackColor: Colors.grey.shade200,
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

          const SizedBox(height: 4),

          // Size value display
          Text(
            '${currentStrokeWidth.round()}px',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
