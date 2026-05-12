import 'package:flutter/material.dart';

import '../resources/paxpayment_strings.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';
import 'paxpayment_button.dart';

class PaxDialog extends StatelessWidget {
  const PaxDialog({
    super.key,
    required this.title,
    this.body,
    this.bodyWidget,
    this.icon,
    this.isDestructive = false,
    required this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  }) : assert(
          body != null || bodyWidget != null,
          'Provide either body or bodyWidget',
        );

  final String title;
  final String? body;
  final Widget? bodyWidget;
  final IconData? icon;
  final bool isDestructive;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? body,
    Widget? bodyWidget,
    IconData? icon,
    bool isDestructive = false,
    required String confirmLabel,
    String? cancelLabel,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isLoading = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (_) => PaxDialog(
        title: title,
        body: body,
        bodyWidget: bodyWidget,
        icon: icon,
        isDestructive: isDestructive,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isLoading: isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final iconColor = isDestructive ? cs.error : cs.primary;
    final iconBg = isDestructive
        ? (isDark ? cs.error.withValues(alpha: 0.15) : cs.errorContainer)
        : (isDark
            ? cs.primary.withValues(alpha: 0.12)
            : cs.primaryContainer);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.lg,
        vertical: PaxSpacing.xxl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(PaxSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: PaxSpacing.brMd,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: PaxSpacing.md),
            ],
            Text(
              title,
              style: PaxTextStyles.h3.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: PaxSpacing.sm),
            if (bodyWidget != null)
              bodyWidget!
            else
              Text(
                body!,
                style: PaxTextStyles.body.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            const SizedBox(height: PaxSpacing.xl),
            if (cancelLabel != null)
              Row(
                children: [
                  Expanded(
                    child: PaxButton.secondary(
                      label: cancelLabel!,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      size: PaxButtonSize.md,
                    ),
                  ),
                  const SizedBox(width: PaxSpacing.sm),
                  Expanded(
                    child: isDestructive
                        ? PaxButton.destructive(
                            label: confirmLabel,
                            onPressed: onConfirm,
                            isLoading: isLoading,
                            size: PaxButtonSize.md,
                          )
                        : PaxButton.primary(
                            label: confirmLabel,
                            onPressed: onConfirm,
                            isLoading: isLoading,
                            size: PaxButtonSize.md,
                          ),
                  ),
                ],
              )
            else
              isDestructive
                  ? PaxButton.destructive(
                      label: confirmLabel,
                      onPressed: onConfirm,
                      isLoading: isLoading,
                    )
                  : PaxButton.primary(
                      label: confirmLabel,
                      onPressed: onConfirm,
                      isLoading: isLoading,
                    ),
          ],
        ),
      ),
    );
  }
}

/// Legacy dialog API — uses [PaxDialog] styling when refactored.
class CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? cancelText;
  final String? okText;
  final VoidCallback? onCancel;
  final VoidCallback? onOk;
  final double? widthPercentage;

  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    this.cancelText,
    this.okText,
    this.onCancel,
    this.onOk,
    this.widthPercentage,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String? cancelText,
    String? okText,
    VoidCallback? onCancel,
    VoidCallback? onOk,
    double? widthPercentage,
    bool barrierDismissible = true,
  }) {
    return PaxDialog.show<bool>(
      context,
      title: title,
      body: description,
      confirmLabel: okText ?? XeposStrings.ok,
      cancelLabel: cancelText ?? XeposStrings.cancel,
      barrierDismissible: barrierDismissible,
      onConfirm: () {
        final cb = onOk;
        if (cb != null) {
          cb();
        } else {
          Navigator.of(context).pop(true);
        }
      },
      onCancel: onCancel ?? () => Navigator.of(context).pop(false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaxDialog(
      title: title,
      body: description,
      confirmLabel: okText ?? XeposStrings.ok,
      cancelLabel: cancelText,
      onConfirm: () {
        final cb = onOk;
        if (cb != null) {
          cb();
        } else {
          Navigator.of(context).pop(true);
        }
      },
      onCancel: onCancel ?? () => Navigator.of(context).pop(false),
    );
  }
}
