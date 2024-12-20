import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';

class FontControls extends StatelessWidget {
  const FontControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              // Increase font size of the last text item
              final cubit = context.read<CanvasCubit>();
              final lastIndex = cubit.state.textItems.length - 1;
              if (lastIndex >= 0) {
                cubit.changeFont(lastIndex,
                    cubit.state.textItems[lastIndex].fontSize + 2, "Arial");
              }
            },
            child: const Text('Increase Font'),
          ),
          ElevatedButton(
            onPressed: () {
              // Change font style to bold of the last text item
              final cubit = context.read<CanvasCubit>();
              final lastIndex = cubit.state.textItems.length - 1;
              if (lastIndex >= 0) {
                cubit.changeFont(lastIndex,
                    cubit.state.textItems[lastIndex].fontSize, "RobotoMono");
              }
            },
            child: const Text('Change Font'),
          ),
        ],
      ),
    );
  }
}
