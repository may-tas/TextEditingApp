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
    Color.fromARGB(254, 255, 255, 255) // White
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: state.isBackgroundColorTrayVisible ? null : 0,
          child: state.isBackgroundColorTrayVisible
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(163, 187, 223, 243),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Background Color',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<CanvasCubit>().hideBackgroundColorTray();
                            },
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: backgroundColors.map((color) {
                          final isSelected = state.backgroundColor == color;
                          return GestureDetector(
                            onTap: () {
                              context.read<CanvasCubit>().changeBackgroundColor(color);
                              // Optionally hide tray after selection
                              // context.read<CanvasCubit>().hideBackgroundColorTray();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
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
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
