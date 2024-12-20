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
        final newText = await showDialog<String>(
          context: context,
          builder: (context) {
            return EditTextDialog(initialText: textItem.text);
          },
        );
        if (newText != null) {
          context.read<CanvasCubit>().editText(index, newText);
        }
      },
      child: Text(
        textItem.text,
        style: TextStyle(
          fontSize: textItem.fontSize,
          fontFamily: textItem.fontFamily,
        ),
      ),
    );
  }
}

class EditTextDialog extends StatelessWidget {
  final String initialText;

  const EditTextDialog({Key? key, required this.initialText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);

    return AlertDialog(
      title: const Text('Edit Text'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Text'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
