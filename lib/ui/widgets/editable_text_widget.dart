// lib/ui/widgets/editable_text_widget.dart
import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditableTextWidget extends StatelessWidget {
  // Removed 'index' as it's no longer needed for identification
  final TextItem textItem;

  const EditableTextWidget({
    super.key,
    required this.textItem,
  });

  @override
  Widget build(BuildContext context) {
    final canvasCubit = context.read<CanvasCubit>();

    return BlocBuilder<CanvasCubit, CanvasState>(
      // Rebuild only when the selectedTextItemId changes or the specific textItem's properties change
      // This helps optimize rebuilds for individual text widgets.
      buildWhen: (previous, current) {
        final bool wasSelected = previous.selectedTextItemId == textItem.id;
        final bool isSelected = current.selectedTextItemId == textItem.id;

        // Rebuild if selection status changes for this item
        if (wasSelected != isSelected) {
          return true;
        }

        // Rebuild if this specific textItem's properties have changed
        // (assuming textItems list itself is immutable and items are replaced, not mutated)
        final previousTextItem = previous.textItems.firstWhere(
          (item) => item.id == textItem.id,
          orElse: () => textItem, // Fallback if item somehow not found (shouldn't happen)
        );
        final currentTextItem = current.textItems.firstWhere(
          (item) => item.id == textItem.id,
          orElse: () => textItem, // Fallback
        );

        return previousTextItem != currentTextItem; // Check if the item itself has changed
      },
      builder: (context, state) {
        final isSelected = state.selectedTextItemId == textItem.id;

        return Positioned(
          left: textItem.x,
          top: textItem.y,
          child: GestureDetector(
            onTap: () async {
              // First, select this item
              canvasCubit.selectTextItem(textItem.id);

              // Then, show the edit dialog
              final newText = await showDialog<String>(
                context: context,
                builder: (context) => EditTextDialog(initialText: textItem.text),
              );

              // If text was edited and an item is still selected (this one)
              if (newText != null && state.selectedTextItemId == textItem.id) {
                canvasCubit.editText(newText); // Call editText without index
              }
            },
            onPanUpdate: (details) {
              // Ensure this item is selected before moving it
              if (!isSelected) {
                canvasCubit.selectTextItem(textItem.id);
              }
              // Move the selected text item (Cubit's moveText now operates on selected item)
              canvasCubit.moveText(
                textItem.x + details.delta.dx,
                textItem.y + details.delta.dy,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 2) // Visual highlight for selected item
                    : Border.all(color: Colors.transparent, width: 2), // Keep width consistent when not selected
              ),
              child: Text(
                textItem.text,
                style: TextStyle(
                  fontStyle: textItem.fontStyle,
                  fontWeight: textItem.fontWeight,
                  fontSize: textItem.fontSize,
                  fontFamily: textItem.fontFamily,
                  color: textItem.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditTextDialog extends StatelessWidget {
  final String initialText;

  const EditTextDialog({super.key, required this.initialText});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    foregroundColor: Colors.deepPurple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
