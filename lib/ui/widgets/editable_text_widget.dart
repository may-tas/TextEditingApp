// lib/ui/widgets/editable_text_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../../models/text_item_model.dart';

class EditableTextWidget extends StatelessWidget {
  final int index;
  final TextItem textItem;

  const EditableTextWidget({
    super.key,
    required this.index,
    required this.textItem,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final isSelected = state.selectedIndex == index;

        return GestureDetector(
          onTap: () async {
            context.read<CanvasCubit>().selectTextItem(index);

            final result = await showDialog<String>(
              context: context,
              builder: (context) => EditTextDialog(initialText: textItem.text),
            );
            if (!context.mounted) return;
            if (result == '_delete_') {
              context.read<CanvasCubit>().deleteText(index);
            } else if (result != null) {
              context.read<CanvasCubit>().editText(index, result);
            }
          },
          onPanUpdate: (details) {
            context.read<CanvasCubit>().selectTextItem(index);

            const speedFactor = 2.0;
            context.read<CanvasCubit>().moveText(
                  index,
                  textItem.x + details.delta.dx * speedFactor,
                  textItem.y + details.delta.dy * speedFactor,
                );
          },
          child: Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.blueAccent, width: 2.0)
                  : Border.all(color: Colors.transparent, width: 2.0),
            ),
            padding: const EdgeInsets.all(4.0),
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
        );
        if (!context.mounted) return;
        if (result == '_delete_') {
          context.read<CanvasCubit>().deleteText(index);
        } else if (result != null) {
          context.read<CanvasCubit>().editText(index, result);
        }
      },
    );
  }
}

class EditTextDialog extends StatelessWidget {
  final String initialText;

  const EditTextDialog({super.key, required this.initialText});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Text cannot be empty'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, '_delete_'),
                  child: Text(
                    'Remove',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final trimmedText = controller.text.trim();

                    if (trimmedText.isEmpty) {
                      formKey.currentState?.validate();
                    } else {
                      Navigator.pop(context, trimmedText);
                    }
                  },
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
