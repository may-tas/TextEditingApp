import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/canvas_cubit.dart';
import '../../constants/color_constants.dart';

class SavePageDialog extends StatefulWidget {
  const SavePageDialog({super.key});

  @override
  State<SavePageDialog> createState() => _SavePageDialogState();
}

class _SavePageDialogState extends State<SavePageDialog> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  Color _selectedColor = ColorConstants.dialogButtonBlue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  List<String> _existingPages = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPages();
  }

  Future<void> _loadExistingPages() async {
    try {
      final pages = await context.read<CanvasCubit>().getSavedPages();
      if (mounted) {
        setState(() {
          _existingPages = pages;
        });
      }
    } catch (e) {
      // Handle error silently or show a message
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validatePageName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a page name';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length > 50) {
      return 'Page name must be 50 characters or less';
    }

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(trimmedValue)) {
      return 'Page name contains invalid characters';
    }

    return null;
  }

  bool _pageExists(String pageName) {
    return _existingPages.contains(pageName.trim());
  }

  Future<void> _savePage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pageName = _controller.text.trim();
    final label = _labelController.text.trim();
    final color = _selectedColor;

    // Check if page already exists and show confirmation
    if (_pageExists(pageName)) {
      final shouldOverwrite = await _showOverwriteConfirmation(pageName);
      if (!shouldOverwrite) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (mounted) {
        await context
            .read<CanvasCubit>()
            .savePage(pageName, label: label, color: color.toARGB32());
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _showOverwriteConfirmation(String pageName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning, color: ColorConstants.dialogWarningOrange),
                SizedBox(width: 8),
                Text('Page Already Exists'),
              ],
            ),
            content: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstants.uiTextBlack,
                ),
                children: [
                  const TextSpan(text: 'A page named '),
                  TextSpan(
                    text: '"$pageName"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                      text: ' already exists. Do you want to overwrite it?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.dialogWarningOrange,
                  foregroundColor: ColorConstants.dialogWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Overwrite'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.save, color: ColorConstants.dialogButtonBlue),
          SizedBox(width: 8),
          Text(
            'Save Page',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a name for this page:',
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.uiTextBlack,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'e.g., My Design, Project 1, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: ColorConstants.dialogButtonBlue, width: 2),
                ),
                prefixIcon: const Icon(Icons.description),
                counterText: '', // Hide character counter
                suffixIcon: (_controller.text.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                      )
                    : null,
              ),
              autofocus: true,
              maxLength: 50,
              validator: _validatePageName,
              onFieldSubmitted: (_) => _savePage(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: 'Add a label (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.label),
              ),
              maxLength: 30,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Choose a color: ', style: TextStyle(fontSize: 14)),
                ...[
                  ColorConstants.dialogTextBlack,
                  ColorConstants.dialogRed,
                  ColorConstants.dialogGreen,
                  ColorConstants.dialogWarningOrange,
                  ColorConstants.dialogPurple,
                  ColorConstants.dialogButtonBlue,
                ].map((color) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? ColorConstants.dialogTextBlack
                                : ColorConstants.dialogGray,
                            width: 2,
                          ),
                        ),
                      ),
                    ))
              ],
            ),
            if (_existingPages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Existing pages: ${_existingPages.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstants.gray600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: ColorConstants.dialogGray),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.dialogButtonBlue,
            foregroundColor: ColorConstants.dialogWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _isSaving ? null : _savePage,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorConstants.dialogWhite,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
