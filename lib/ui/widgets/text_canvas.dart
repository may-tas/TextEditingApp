import 'package:celebrare_assignment/cubit/canvas_cubit.dart';
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextCanvas extends StatelessWidget {
  const TextCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        return Stack(
          children: state.textItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Positioned(
              left: item.x,
              top: item.y,
              child: GestureDetector(
                onPanUpdate: (details) {
                  context.read<CanvasCubit>().moveText(
                        index,
                        item.x + details.delta.dx,
                        item.y + details.delta.dy,
                      );
                },
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontSize: item.fontSize,
                    fontFamily: item.fontFamily,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
