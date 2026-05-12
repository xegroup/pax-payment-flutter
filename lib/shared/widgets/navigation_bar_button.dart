import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/pax_colors.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';

class NavigationBarButton extends StatelessWidget {
  const NavigationBarButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? PaxColors.teal400 : PaxColors.teal500;
    final muted = isDark ? PaxColors.grey600 : PaxColors.grey400;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: PaxSpacing.durationNormal,
          curve: PaxSpacing.curveDefault,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: PaxSpacing.durationNormal,
                curve: PaxSpacing.curveDefault,
                padding: const EdgeInsets.symmetric(
                  horizontal: PaxSpacing.md,
                  vertical: PaxSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? accent.withValues(alpha: 0.15)
                          : PaxColors.teal50)
                      : PaxColors.transparent,
                  borderRadius: PaxSpacing.brPill,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: PaxSpacing.durationFast,
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        key: ValueKey(isSelected),
                        size: 22,
                        color: isSelected ? accent : muted,
                      ),
                    ),
                    if (badge != null && badge! > 0)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(
                            color: PaxColors.error,
                            borderRadius: PaxSpacing.brPill,
                          ),
                          child: Text(
                            badge! > 99 ? '99+' : '$badge',
                            style: PaxTextStyles.captionMedium.copyWith(
                              color: PaxColors.white,
                              fontSize: 8.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: PaxSpacing.xxs),
              AnimatedDefaultTextStyle(
                duration: PaxSpacing.durationNormal,
                style: PaxTextStyles.navLabel.copyWith(
                  color: isSelected ? accent : muted,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
