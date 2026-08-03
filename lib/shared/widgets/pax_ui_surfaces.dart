import 'package:flutter/material.dart';

import '../theme/pax_colors.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';
import 'paxpayment_button.dart';

class PaxCard extends StatelessWidget {
  const PaxCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.elevation = PaxCardElevation.flat,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final PaxCardElevation elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? PaxColors.grey900 : PaxColors.white;
    final defaultBorder = isDark ? PaxColors.grey800 : PaxColors.grey150;

    final shadows = switch (elevation) {
      PaxCardElevation.flat => <BoxShadow>[],
      PaxCardElevation.raised =>
        isDark ? <BoxShadow>[] : PaxSpacing.shadowSm,
      PaxCardElevation.overlay =>
        isDark ? <BoxShadow>[] : PaxSpacing.shadowMd,
    };

    final container = Container(
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: PaxSpacing.brLg,
        border: Border.all(color: borderColor ?? defaultBorder),
        boxShadow: shadows,
      ),
      child: Padding(
        padding: padding ?? PaxSpacing.cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: PaxColors.transparent,
        borderRadius: PaxSpacing.brLg,
        child: InkWell(
          borderRadius: PaxSpacing.brLg,
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}

enum PaxCardElevation { flat, raised, overlay }

class PaxSectionHeader extends StatelessWidget {
  const PaxSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: PaxTextStyles.h4.copyWith(color: cs.onSurface),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: PaxSpacing.xxs),
                Text(
                  subtitle!,
                  style: PaxTextStyles.caption
                      .copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        ...[?action],
      ],
    );
  }
}

class PaxEmptyState extends StatelessWidget {
  const PaxEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent =
        iconColor ?? (isDark ? PaxColors.blueDark : PaxColors.blueLight);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.xl,
        vertical: PaxSpacing.xxxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? accent.withValues(alpha: 0.12)
                  : accent.withValues(alpha: 0.08),
              borderRadius: PaxSpacing.brXl,
            ),
            child: Icon(icon, size: 32, color: accent),
          ),
          const SizedBox(height: PaxSpacing.md),
          Text(
            title,
            style: PaxTextStyles.h4.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          if (body != null) ...[
            const SizedBox(height: PaxSpacing.sm),
            Text(
              body!,
              style: PaxTextStyles.body
                  .copyWith(color: cs.onSurfaceVariant, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
          if (action case final a?) ...[
            const SizedBox(height: PaxSpacing.xl),
            a,
          ],
        ],
      ),
    );
  }
}

class PaxErrorState extends StatelessWidget {
  const PaxErrorState({
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return PaxEmptyState(
      icon: Icons.wifi_off_rounded,
      iconColor: PaxColors.error,
      title: 'Something went wrong',
      body: message ?? 'An unexpected error occurred.\nPlease try again.',
      action: onRetry != null
          ? PaxButton.tonal(
              label: retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            )
          : null,
    );
  }
}

class PaxSkeletonLoader extends StatefulWidget {
  const PaxSkeletonLoader({super.key, required this.child});
  final Widget child;

  @override
  State<PaxSkeletonLoader> createState() => _PaxSkeletonLoaderState();
}

class _PaxSkeletonLoaderState extends State<PaxSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.5, 0),
              end: const Alignment(1.5, 0),
              colors: [
                Colors.grey.withValues(alpha: 0.06),
                Colors.grey.withValues(alpha: 0.14),
                Colors.grey.withValues(alpha: 0.06),
              ],
              stops: [
                0,
                _anim.value,
                1,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class PaxSkeleton extends StatelessWidget {
  const PaxSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
  });

  final double? width;
  final double height;
  final double? radius;

  factory PaxSkeleton.line({double? width, double height = 14}) =>
      PaxSkeleton(width: width, height: height, radius: 999);

  factory PaxSkeleton.rect({double? width, double height = 80}) =>
      PaxSkeleton(
        width: width,
        height: height,
        radius: PaxSpacing.radiusMd,
      );

  factory PaxSkeleton.circle({double size = 40}) =>
      PaxSkeleton(width: size, height: size, radius: 999);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? PaxColors.grey800 : PaxColors.grey150,
        borderRadius: BorderRadius.circular(
          radius ?? PaxSpacing.radiusSm,
        ),
      ),
    );
  }
}

class PaxInfoRow extends StatelessWidget {
  const PaxInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: PaxSpacing.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PaxSpacing.sm + 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: PaxTextStyles.label.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: PaxSpacing.md),
                Flexible(
                  child: Text(
                    value,
                    style: valueStyle ??
                        PaxTextStyles.bodyMedium.copyWith(
                          color: cs.onSurface,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: PaxSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
      ],
    );
  }
}
