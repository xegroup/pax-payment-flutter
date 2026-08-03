import 'package:flutter/material.dart';

import '../responsive/responsive.dart';
import '../theme/pax_colors.dart';
import '../theme/pax_text_styles.dart';

/// Branded mark for Pax Payment (replaces legacy third-party “Y” logo).
class PaxPaymentLogoMark extends StatelessWidget {
  const PaxPaymentLogoMark({super.key, this.size});

  /// Defaults to 32 on phone, 36 on tablet.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final double side = size ?? r.value(mobile: 32.0, tablet: 36.0);
    final fontSize = side * 0.28;
    final radius = side * 0.22;

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: PaxColors.blueLight,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: PaxColors.blueLight.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'PAX',
        style: PaxTextStyles.caption.copyWith(
          color: PaxColors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          letterSpacing: 0.6,
          height: 1,
        ),
      ),
    );
  }
}

/// 2×2 menu grid used in the POS app bar.
class PaxPosMenuGridIcon extends StatelessWidget {
  const PaxPosMenuGridIcon({super.key, this.color, this.dotSize});

  final Color? color;
  final double? dotSize;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final double s = dotSize ?? r.value(mobile: 4.5, tablet: 5.0);
    const g = 3.0;
    final dotColor = color ?? PaxColors.blueLight;

    Widget dot() => Container(
          width: s,
          height: s,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        );

    return SizedBox(
      width: s * 2 + g,
      height: s * 2 + g,
      child: Wrap(
        spacing: g,
        runSpacing: g,
        children: [dot(), dot(), dot(), dot()],
      ),
    );
  }
}

/// Responsive top bar: go back · PAX logo + “POS” · optional actions & menu.
class PaxPosAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaxPosAppBar({
    super.key,
    this.onGoBack,
    this.onMenu,
    this.leadingLabel = 'Go back',
    this.title = 'POS',
    this.trailing = const [],
    this.compactWidth = 380,
  });

  final VoidCallback? onGoBack;
  final VoidCallback? onMenu;
  final String leadingLabel;
  final String title;
  final List<Widget> trailing;
  final double compactWidth;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final compact = r.width < compactWidth;
    final showBackLabel = !compact && onGoBack != null;
    final showMenuLabel = !compact && onMenu != null;
    final hPad = r.value(mobile: 8.0, tablet: 16.0);

    return Material(
      color: PaxColors.white,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                SizedBox(
                  width: compact ? 44 : 108,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: onGoBack != null
                        ? _BackControl(
                            onPressed: onGoBack!,
                            label: leadingLabel,
                            showLabel: showBackLabel,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PaxPaymentLogoMark(),
                          SizedBox(width: r.value(mobile: 8.0, tablet: 10.0)),
                          Text(
                            title,
                            style: PaxTextStyles.bodySemiBold.copyWith(
                              color: PaxColors.grey800,
                              fontSize: r.value(mobile: 16.0, tablet: 17.0),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: compact ? 88 : 132,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ...trailing,
                        if (onMenu != null)
                          _MenuControl(
                            onPressed: onMenu!,
                            showLabel: showMenuLabel,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackControl extends StatelessWidget {
  const _BackControl({
    required this.onPressed,
    required this.label,
    required this.showLabel,
  });

  final VoidCallback onPressed;
  final String label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: PaxColors.grey500,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const Icon(Icons.close_rounded, size: 20),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: PaxTextStyles.bodyMedium.copyWith(
                  color: PaxColors.grey500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuControl extends StatelessWidget {
  const _MenuControl({
    required this.onPressed,
    required this.showLabel,
  });

  final VoidCallback onPressed;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: PaxColors.grey800,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Text(
              'Menu',
              style: PaxTextStyles.bodySemiBold.copyWith(
                color: PaxColors.grey800,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const PaxPosMenuGridIcon(),
        ],
      ),
    );
  }
}

/// Checkout amount screen back control (shared styling with [PaxPosAppBar]).
class PaxPosBackButton extends StatelessWidget {
  const PaxPosBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;
    return _BackControl(
      onPressed: onPressed,
      label: 'Go back',
      showLabel: !compact,
    );
  }
}
