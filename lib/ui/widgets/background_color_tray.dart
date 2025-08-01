import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';

class BackgroundColorTray extends StatelessWidget {
  const BackgroundColorTray({super.key});

  static const List<Color> backgroundColors = [
    Color(0xFF1A1A1A), // Dark Gray (default)
    Color(0xFF2E1065), // Deep Purple
    Color(0xFF1E3A8A), // Deep Blue
    Color(0xFF166534), // Deep Green
    Color(0xFF7C2D12), // Deep Brown/Orange
    Color.fromARGB(255, 255, 255, 255) // White
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color.fromARGB(163, 187, 223, 243),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Background Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: backgroundColors.map((color) {
                  final isSelected = state.backgroundColor == color;
                  return GestureDetector(
                    onTap: () {
                      context.read<CanvasCubit>().changeBackgroundColor(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color:
                                  Colors.black.withAlpha((0.3 * 255).toInt()),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Color.fromARGB(255, 255, 248, 248),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
