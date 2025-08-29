import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';

class BackgroundOptionsSheet extends StatelessWidget {
  const BackgroundOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Background Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BackgroundOptionTile(
                  icon: Icons.photo_library,
                  title: 'Upload Image',
                  subtitle: 'From gallery',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CanvasCubit>().uploadBackgroundImage();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BackgroundOptionTile(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CanvasCubit>().takePhotoForBackground();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BackgroundOptionTile(
                  icon: Icons.color_lens,
                  title: 'Solid Color',
                  subtitle: 'Pick a color',
                  onTap: () {
                    Navigator.pop(context);
                    context.read<CanvasCubit>().toggleTray();
                  },
                ),
              ),
              const SizedBox(width: 12),
              BlocBuilder<CanvasCubit, CanvasState>(
                builder: (context, state) {
                  return Expanded(
                    child: _BackgroundOptionTile(
                      icon: Icons.clear,
                      title: 'Remove Image',
                      subtitle: 'Clear background',
                      enabled: state.backgroundImagePath != null,
                      onTap: state.backgroundImagePath != null
                          ? () {
                              Navigator.pop(context);
                              context.read<CanvasCubit>().removeBackgroundImage();
                            }
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BackgroundOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _BackgroundOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.grey[50] : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled ? Colors.black87 : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: enabled ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled ? Colors.grey[600] : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}