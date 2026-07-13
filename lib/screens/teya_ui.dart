import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/theme/pax_colors.dart';
import '../shared/theme/pax_text_styles.dart';
import '../shared/widgets/pax_pos_app_bar.dart';

/// Handheld payment-flow tokens — aligned with [PaxColors].
abstract final class TeyaColors {
  static const white = PaxColors.white;
  static const accent = PaxColors.teal500;
  static const onAccent = PaxColors.white;
  static const textDark = PaxColors.grey800;
  static const textGrey = PaxColors.grey500;
  static const borderGrey = PaxColors.grey200;
  static const successGreen = PaxColors.successDark;
  static const errorRed = PaxColors.error;
}

abstract final class TeyaUi {
  static final money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final ukDateTime = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');

  static String formatAmount(double amount) => money.format(amount);

  static const buttonRadius = BorderRadius.all(Radius.circular(12));
}

/// Payment-flow top bar — PAX logo, “POS” title, responsive layout.
class TeyaTopBar extends StatelessWidget implements PreferredSizeWidget {
  const TeyaTopBar({
    super.key,
    this.onGoBack,
    this.onMenu,
    this.title = 'POS',
    this.leadingLabel = 'Go back',
  });

  final VoidCallback? onGoBack;
  final VoidCallback? onMenu;
  final String title;
  final String leadingLabel;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return PaxPosAppBar(
      onGoBack: onGoBack,
      onMenu: onMenu,
      title: title,
      leadingLabel: leadingLabel,
    );
  }
}

class TeyaPrimaryButton extends StatelessWidget {
  const TeyaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? TeyaColors.accent : TeyaColors.borderGrey;
    final fg = enabled ? TeyaColors.onAccent : TeyaColors.textGrey;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: bg,
        borderRadius: TeyaUi.buttonRadius,
        child: InkWell(
          borderRadius: TeyaUi.buttonRadius,
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              label,
              style: PaxTextStyles.buttonMd.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TeyaSecondaryButton extends StatelessWidget {
  const TeyaSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: TeyaColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: TeyaUi.buttonRadius,
          side: const BorderSide(color: TeyaColors.borderGrey),
        ),
        child: InkWell(
          borderRadius: TeyaUi.buttonRadius,
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: PaxTextStyles.buttonMd.copyWith(
                color: TeyaColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TeyaScreenScaffold extends StatelessWidget {
  const TeyaScreenScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeyaColors.white,
      appBar: appBar,
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class TeyaDivider extends StatelessWidget {
  const TeyaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: TeyaColors.borderGrey, height: 1),
    );
  }
}

class TeyaContactlessIcon extends StatelessWidget {
  const TeyaContactlessIcon({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.contactless_rounded,
      size: size,
      color: TeyaColors.accent,
    );
  }
}

/// Animated check or X in a circle for success / declined screens.
class TeyaAnimatedResultIcon extends StatefulWidget {
  const TeyaAnimatedResultIcon({
    super.key,
    required this.success,
    this.size = 88,
  });

  final bool success;
  final double size;

  @override
  State<TeyaAnimatedResultIcon> createState() => _TeyaAnimatedResultIconState();
}

class _TeyaAnimatedResultIconState extends State<TeyaAnimatedResultIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success ? TeyaColors.successGreen : TeyaColors.errorRed;
    final icon = widget.success ? Icons.check_rounded : Icons.close_rounded;
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 3),
        ),
        child: Icon(icon, size: widget.size * 0.5, color: color),
      ),
    );
  }
}
