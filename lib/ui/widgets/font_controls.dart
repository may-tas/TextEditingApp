import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/font_family_list.dart';
import '../../constants/color_constants.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../widgets/shadows_controls.dart';

class FontControls extends StatefulWidget {
  const FontControls({super.key});

  @override
  State<FontControls> createState() => _FontControlsState();
}

class _FontControlsState extends State<FontControls> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
    // Check initial state after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _showLeftArrow = _scrollController.offset > 10;
      _showRightArrow = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust height based on platform
    final controlsHeight = kIsWeb ? 90.0 : 80.0;

    return Container(
      height: controlsHeight,
      decoration: BoxDecoration(
        color: ColorConstants.uiWhite,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.getBlackWithAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main scrollable content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  kIsWeb ? 48.0 : 16.0, // Extra padding for arrows on web
              vertical: 8.0,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildFontSizeWheel(context),
                  const SizedBox(width: 25),
                  _buildFontStyleControls(context),
                  const SizedBox(width: 25),
                  _buildAlignmentControls(context),
                  const SizedBox(width: 25),
                  _buildHighlightControls(context),
                  const SizedBox(width: 25),
                  const ShadowControls(),
                  const SizedBox(width: 25),
                  _buildFontFamilyControls(context),
                  const SizedBox(width: 25),
                  _buildColorControls(context),
                  const SizedBox(width: 25),
                  _buildCopyButton(context),
                  const SizedBox(width: 25),
                  _buildClearFormatButton(context),
                  const SizedBox(width: 16), // End padding
                ],
              ),
            ),
          ),

          // Left scroll arrow (web only)
          if (kIsWeb && _showLeftArrow)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorConstants.uiWhite,
                      ColorConstants.uiWhite.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    color: ColorConstants.gray700,
                    onPressed: _scrollLeft,
                    tooltip: 'Scroll left',
                  ),
                ),
              ),
            ),

          // Right scroll arrow (web only)
          if (kIsWeb && _showRightArrow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      ColorConstants.uiWhite,
                      ColorConstants.uiWhite.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    color: ColorConstants.gray700,
                    onPressed: _scrollRight,
                    tooltip: 'Scroll right',
                  ),
                ),
              ),
            ),

          if (!kIsWeb && _showRightArrow)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      ColorConstants.uiWhite.withValues(alpha: 0.8),
                      ColorConstants.uiWhite.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) =>
          previous.selectedTextItemIndex != current.selectedTextItemIndex,
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Copy',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: _buildStyleButton(
                icon: Icons.copy,
                isSelected: false,
                onPressed: isDisabled
                    ? null
                    : () {
                        context
                            .read<CanvasCubit>()
                            .copyText(selectedIndex, context);
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHighlightControls(BuildContext context) {
    const highlightColors = ColorConstants.highlightColors;

    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.isHighlighted != cItem.isHighlighted ||
              pItem.highlightColor != cItem.highlightColor;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;
        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final isHighlighted = textItem?.isHighlighted ?? false;
        final currentHighlightColor =
            textItem?.highlightColor ?? ColorConstants.highlightYellow;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Highlight',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: Row(
                children: [
                  _buildStyleButton(
                    icon: Icons.highlight,
                    isSelected: isHighlighted,
                    onPressed: isDisabled
                        ? null
                        : () {
                            context
                                .read<CanvasCubit>()
                                .toggleTextHighlight(selectedIndex);
                          },
                  ),
                  const SizedBox(width: 8),
                  ...highlightColors.map((color) {
                    final isSelected =
                        isHighlighted && currentHighlightColor == color;
                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => context
                              .read<CanvasCubit>()
                              .changeHighlightColor(selectedIndex, color),
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? ColorConstants.uiBlueAccent
                                : ColorConstants.gray400,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClearFormatButton(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) =>
          previous.selectedTextItemIndex != current.selectedTextItemIndex,
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Reset',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: _buildStyleButton(
                icon: Icons.layers_clear,
                isSelected: false,
                onPressed: isDisabled
                    ? null
                    : () {
                        context
                            .read<CanvasCubit>()
                            .resetFormatting(selectedIndex);
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontStyleControls(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontWeight != cItem.fontWeight ||
              pItem.fontStyle != cItem.fontStyle ||
              pItem.isUnderlined != cItem.isUnderlined;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final isBold = textItem?.fontWeight == FontWeight.bold;
        final isItalic = textItem?.fontStyle == FontStyle.italic;
        final isUnderlined = textItem?.isUnderlined ?? false;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Style',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: Row(
                children: [
                  _buildStyleButton(
                    icon: Icons.format_bold,
                    isSelected: isBold,
                    onPressed: isDisabled
                        ? null
                        : () {
                            final newWeight =
                                isBold ? FontWeight.normal : FontWeight.bold;
                            context
                                .read<CanvasCubit>()
                                .changeFontWeight(selectedIndex, newWeight);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_italic,
                    isSelected: isItalic,
                    onPressed: isDisabled
                        ? null
                        : () {
                            final newStyle =
                                isItalic ? FontStyle.normal : FontStyle.italic;
                            context
                                .read<CanvasCubit>()
                                .changeFontStyle(selectedIndex, newStyle);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_underline,
                    isSelected: isUnderlined,
                    onPressed: isDisabled
                        ? null
                        : () {
                            bool newUnderline = !isUnderlined;
                            context.read<CanvasCubit>().changeTextUnderline(
                                selectedIndex, newUnderline);
                          },
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_clear,
                    isSelected: false,
                    onPressed: isDisabled
                        ? null
                        : () {
                            context.read<CanvasCubit>().changeFontStyle(
                                selectedIndex, FontStyle.normal);
                            context.read<CanvasCubit>().changeFontWeight(
                                selectedIndex, FontWeight.normal);
                            context
                                .read<CanvasCubit>()
                                .changeTextUnderline(selectedIndex, false);
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlignmentControls(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        final prevIndex = previous.selectedTextItemIndex;
        final currIndex = current.selectedTextItemIndex;

        if (prevIndex != currIndex) return true;

        if (currIndex != null &&
            currIndex < previous.textItems.length &&
            currIndex < current.textItems.length) {
          final prevItem = previous.textItems[currIndex];
          final currItem = current.textItems[currIndex];
          return prevItem.textAlign != currItem.textAlign;
        }

        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final currentAlign = textItem?.textAlign ?? TextAlign.left;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Align',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: Row(
                children: [
                  _buildStyleButton(
                    icon: Icons.format_align_left,
                    isSelected: currentAlign == TextAlign.left,
                    onPressed: isDisabled
                        ? null
                        : () => context
                            .read<CanvasCubit>()
                            .changeTextAlignment(selectedIndex, TextAlign.left),
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_align_center,
                    isSelected: currentAlign == TextAlign.center,
                    onPressed: isDisabled
                        ? null
                        : () => context.read<CanvasCubit>().changeTextAlignment(
                            selectedIndex, TextAlign.center),
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_align_right,
                    isSelected: currentAlign == TextAlign.right,
                    onPressed: isDisabled
                        ? null
                        : () => context.read<CanvasCubit>().changeTextAlignment(
                            selectedIndex, TextAlign.right),
                  ),
                  const SizedBox(width: 8),
                  _buildStyleButton(
                    icon: Icons.format_align_justify,
                    isSelected: currentAlign == TextAlign.justify,
                    onPressed: isDisabled
                        ? null
                        : () => context.read<CanvasCubit>().changeTextAlignment(
                            selectedIndex, TextAlign.justify),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontFamilyControls(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null &&
            current.selectedTextItemIndex! < current.textItems.length) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontFamily != cItem.fontFamily;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;

        final currentFont =
            !isDisabled ? state.textItems[selectedIndex].fontFamily : 'Roboto';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Font',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: isDisabled
                  ? null
                  : () =>
                      _showFontPickerModal(context, selectedIndex, currentFont),
              icon: const Icon(Icons.font_download, size: 18),
              label: Text(
                currentFont,
                style: GoogleFonts.getFont(currentFont, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.gray100,
                foregroundColor: ColorConstants.gray800,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: ColorConstants.gray300),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFontPickerModal(
      BuildContext context, int selectedIndex, String currentFont) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return _FontPickerContent(
              currentFont: currentFont,
              selectedIndex: selectedIndex,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  Widget _buildColorControls(BuildContext context) {
    const colors = ColorConstants.textColors;

    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled =
            selectedIndex == null || selectedIndex >= state.textItems.length;
        final textItem = !isDisabled ? state.textItems[selectedIndex] : null;
        final selectedColor = textItem?.color ?? ColorConstants.dialogTextBlack;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Color',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ColorConstants.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.gray300),
              ),
              child: Row(
                children: [
                  ...colors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => context
                              .read<CanvasCubit>()
                              .changeTextColor(selectedIndex, color),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? ColorConstants.uiBlueAccent
                                : (color == ColorConstants.uiWhite
                                    ? ColorConstants.gray400
                                    : Colors.transparent),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: ColorConstants.gray600),
                    tooltip: 'More colors',
                    onPressed: isDisabled
                        ? null
                        : () async {
                            final pickedColor = await showColorPickerDialog(
                              context,
                              selectedColor,
                              title: const Text('Pick a color'),
                              showColorCode: true,
                              showRecentColors: false,
                              backgroundColor: ColorConstants.uiWhite,
                              constraints: const BoxConstraints(
                                minHeight: 400,
                                minWidth: 300,
                              ),
                            );

                            if (!context.mounted) return;

                            context
                                .read<CanvasCubit>()
                                .changeTextColor(selectedIndex, pickedColor);
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeWheel(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (previous, current) {
        if (previous.selectedTextItemIndex != current.selectedTextItemIndex) {
          return true;
        }
        if (current.selectedTextItemIndex != null) {
          final pItem = previous.textItems[current.selectedTextItemIndex!];
          final cItem = current.textItems[current.selectedTextItemIndex!];
          return pItem.fontSize != cItem.fontSize;
        }
        return false;
      },
      builder: (context, state) {
        final selectedIndex = state.selectedTextItemIndex;
        final isDisabled = selectedIndex == null;
        final currentSize =
            !isDisabled ? state.textItems[selectedIndex].fontSize.round() : 16;

        return StatefulBuilder(
          builder: (context, setState) {
            final controller = FixedExtentScrollController(
              initialItem: (currentSize - 8).clamp(0, 70),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final index = (currentSize - 8).clamp(0, 70);
              if (controller.hasClients && controller.selectedItem != index) {
                controller.jumpToItem(index);
              }
            });

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Size',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: ColorConstants.gray100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorConstants.gray300),
                  ),
                  child: Row(
                    children: [
                      _buildSizeButton(
                        icon: Icons.remove,
                        onPressed: isDisabled
                            ? null
                            : () {
                                final newSize = (currentSize - 2).clamp(8, 78);
                                context.read<CanvasCubit>().changeFontSize(
                                    selectedIndex, newSize.toDouble());
                              },
                      ),
                      SizedBox(
                        height: 40,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: controller,
                          itemExtent: 32,
                          diameterRatio: 1.2,
                          perspective: 0.003,
                          physics: isDisabled
                              ? const NeverScrollableScrollPhysics()
                              : const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            if (!isDisabled) {
                              final newSize = 8 + index;
                              context.read<CanvasCubit>().changeFontSize(
                                  selectedIndex, newSize.toDouble());
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
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      _buildSizeButton(
                        icon: Icons.add,
                        onPressed: isDisabled
                            ? null
                            : () {
                                final newSize = (currentSize + 2).clamp(8, 78);
                                context.read<CanvasCubit>().changeFontSize(
                                    selectedIndex, newSize.toDouble());
                              },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSizeButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: ColorConstants.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: ColorConstants.gray700,
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: isSelected
          ? ColorConstants.uiBlueAccent.withValues(alpha: 0.2)
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
                ? ColorConstants.uiBlueAccent
                : ColorConstants.gray700,
          ),
        ),
      ),
    );
  }
}

class _FontPickerContent extends StatefulWidget {
  final String currentFont;
  final int selectedIndex;
  final ScrollController scrollController;

  const _FontPickerContent({
    required this.currentFont,
    required this.selectedIndex,
    required this.scrollController,
  });

  @override
  State<_FontPickerContent> createState() => _FontPickerContentState();
}

class _FontPickerContentState extends State<_FontPickerContent> {
  String searchQuery = '';
  late List<String> filteredFonts;

  @override
  void initState() {
    super.initState();
    filteredFonts = List.from(googleFontNames);
  }

  void _updateSearch(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      filteredFonts = googleFontNames
          .where((font) => font.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text("Select Font",
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: _updateSearch,
            decoration: InputDecoration(
              hintText: 'Search fonts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorConstants.gray300),
              ),
              filled: true,
              fillColor: ColorConstants.gray100,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: filteredFonts.length,
            itemBuilder: (context, index) {
              final font = filteredFonts[index];
              final isSelected = font == widget.currentFont;

              return ListTile(
                title: Text(
                  font,
                  style: GoogleFonts.getFont(font, fontSize: 16),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check,
                        color: ColorConstants.dialogButtonBlue)
                    : null,
                onTap: () {
                  context
                      .read<CanvasCubit>()
                      .changeFontFamily(widget.selectedIndex, font);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
