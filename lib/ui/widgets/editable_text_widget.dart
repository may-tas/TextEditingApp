import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => EditTextDialog(initialText: textItem.text),
        );

        if (result == 'delete') {
          context.read<CanvasCubit>().deleteText(index);
        } else if (result != null) {
          context.read<CanvasCubit>().editText(index, result);
        }
      },
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
                  onPressed: () => Navigator.pop(context, "delete"),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text field cannot be empty'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.fixed,
                          duration: Duration(seconds: 2),
                        ),
                      );
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
