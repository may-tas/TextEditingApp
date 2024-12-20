import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FontControls extends StatelessWidget {
  const FontControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[400]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Font Size Controls
          Row(
            children: [
              const Text('Font Size:'),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final selectedIndex =
                      context.read<CanvasCubit>().state.textItems.length - 1;
                  if (selectedIndex >= 0) {
                    final currentSize = context
                        .read<CanvasCubit>()
                        .state
                        .textItems[selectedIndex]
                        .fontSize;
                    context.read<CanvasCubit>().changeFontSize(
                        selectedIndex, (currentSize - 2).clamp(8.0, 64.0));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final selectedIndex =
                      context.read<CanvasCubit>().state.textItems.length - 1;
                  if (selectedIndex >= 0) {
                    final currentSize = context
                        .read<CanvasCubit>()
                        .state
                        .textItems[selectedIndex]
                        .fontSize;
                    context.read<CanvasCubit>().changeFontSize(
                        selectedIndex, (currentSize + 2).clamp(8.0, 64.0));
                  }
                },
              ),
            ],
          ),

          // Font Family Dropdown
          Row(
            children: [
              const Text('Font Style:'),
              DropdownButton<String>(
                value: context.read<CanvasCubit>().state.textItems.isNotEmpty
                    ? context
                        .read<CanvasCubit>()
                        .state
                        .textItems
                        .last
                        .fontFamily
                    : 'Arial',
                items: const [
                  DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                  DropdownMenuItem(value: 'Courier', child: Text('Courier')),
                  DropdownMenuItem(
                      value: 'Times New Roman', child: Text('Times New Roman')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    final selectedIndex =
                        context.read<CanvasCubit>().state.textItems.length - 1;
                    if (selectedIndex >= 0) {
                      context
                          .read<CanvasCubit>()
                          .changeFontStyle(selectedIndex, value);
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
