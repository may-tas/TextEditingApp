import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FontControls extends StatelessWidget {
  const FontControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFontSizeControls(context),
            const SizedBox(width: 24),
            _buildFontStyleControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControls(BuildContext context) {
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
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSizeButton(
                context: context,
                icon: Icons.remove,
                onPressed: () => _changeFontSize(context, decrease: true),
              ),
              BlocBuilder<CanvasCubit, CanvasState>(
                builder: (context, state) {
                  final fontSize = state.textItems.isNotEmpty
                      ? state.textItems.last.fontSize.round()
                      : 16;
                  return Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$fontSize',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
              _buildSizeButton(
                context: context,
                icon: Icons.add,
                onPressed: () => _changeFontSize(context, decrease: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontStyleControls(BuildContext context) {
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
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: BlocBuilder<CanvasCubit, CanvasState>(
            builder: (context, state) {
              final currentFont = state.textItems.isNotEmpty
                  ? state.textItems.last.fontFamily
                  : 'Arial';
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentFont,
                  items: const [
                    DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                    DropdownMenuItem(value: 'Courier', child: Text('Courier')),
                    DropdownMenuItem(
                        value: 'Times New Roman',
                        child: Text('Times New Roman')),
                    DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                    DropdownMenuItem(
                        value: 'Helvetica', child: Text('Helvetica')),
                  ],
                  onChanged: (value) => _changeFontFamily(context, value),
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
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

  void _changeFontSize(BuildContext context, {required bool decrease}) {
    final selectedIndex =
        context.read<CanvasCubit>().state.textItems.length - 1;
    if (selectedIndex >= 0) {
      final currentSize =
          context.read<CanvasCubit>().state.textItems[selectedIndex].fontSize;
      final newSize = decrease ? currentSize - 2 : currentSize + 2;
      context.read<CanvasCubit>().changeFontSize(
            selectedIndex,
            newSize.clamp(8.0, 64.0),
          );
    }
  }

  void _changeFontFamily(BuildContext context, String? value) {
    if (value != null) {
      final selectedIndex =
          context.read<CanvasCubit>().state.textItems.length - 1;
      if (selectedIndex >= 0) {
        context.read<CanvasCubit>().changeFontStyle(selectedIndex, value);
      }
    }
  }
}
