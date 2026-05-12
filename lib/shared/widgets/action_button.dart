import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/pax_colors.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
    this.badge,
    this.isDestructive = false,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? accentColor;
  final int? badge;
  final bool isDestructive;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final accent = widget.isDestructive
        ? PaxColors.error
        : (widget.accentColor ?? PaxColors.teal500);

    final iconBg = widget.isDestructive
        ? (isDark
            ? PaxColors.error.withValues(alpha: 0.15)
            : PaxColors.errorLight)
        : (isDark
            ? accent.withValues(alpha: 0.15)
            : accent.withValues(alpha: 0.1));

    final cardColor = isDark ? PaxColors.grey900 : PaxColors.white;
    final borderColor = isDark ? PaxColors.grey800 : PaxColors.grey150;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          _ctrl.forward();
        },
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: PaxSpacing.brLg,
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : PaxSpacing.shadowSm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(PaxSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: PaxSpacing.brMd,
                      ),
                      child: Icon(widget.icon, size: 20, color: accent),
                    ),
                    if (widget.badge != null && widget.badge! > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: PaxColors.error,
                            borderRadius: PaxSpacing.brPill,
                          ),
                          child: Text(
                            widget.badge! > 99 ? '99+' : '${widget.badge}',
                            style: PaxTextStyles.captionMedium
                                .copyWith(color: PaxColors.white, fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: PaxSpacing.sm),
                Text(
                  widget.label,
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: PaxSpacing.xxs),
                  Text(
                    widget.subtitle!,
                    style: PaxTextStyles.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
