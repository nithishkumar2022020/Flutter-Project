import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MiniDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MiniDock({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;

    final tabs = const [
      (key: 'minidock_corpus', label: 'CORPUS', icon: Icons.folder_open_outlined),
      (key: 'minidock_query', label: 'QUERY', icon: Icons.bolt_outlined),
      (key: 'minidock_matrix', label: 'MATRIX', icon: Icons.grid_4x4_outlined),
      (key: 'minidock_diag', label: 'DIAG', icon: Icons.insights_outlined),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: AppTheme.brutalistDecoration(
          bgColor: bgColor,
          borderColor: borderColor,
          borderWidth: 2,
          shadowOffset: const Offset(4, 4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final isSelected = currentIndex == index;
            final tab = tabs[index];

            return GestureDetector(
              key: Key(tab.key),
              onTap: () => onTabSelected(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? vermilion : Colors.transparent,
                  border: isSelected ? Border.all(color: borderColor, width: 1.5) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected ? Colors.white : textColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab.label,
                      style: AppTheme.monospace(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
