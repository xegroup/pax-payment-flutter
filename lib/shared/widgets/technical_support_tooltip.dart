import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/storage_service.dart';
import '../resources/paxpayment_strings.dart';
import '../theme/paxpayment_spacing.dart';
import '../theme/paxpayment_text_styles.dart';
import '../theme/theme_service.dart';

(String, String) _resolveSupportContact() {
  final phone = GetIt.instance<StorageService>().getPhoneNumber() ?? '';
  if (phone.startsWith('+1')) {
    return ('USA Support', XeposStrings.supportPhoneUSA);
  }
  return ('UK Support', XeposStrings.supportPhoneUK);
}

class TechnicalSupportTooltip extends StatelessWidget {
  final GlobalKey anchorKey;
  final VoidCallback onDismiss;

  const TechnicalSupportTooltip({
    super.key,
    required this.anchorKey,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final (regionLabel, supportPhone) = _resolveSupportContact();
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final endMargin = screenWidth * 0.03;
    final tooltipWidth = (screenWidth * 0.52).clamp(320.0, 520.0);

    final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    var xOffset = buttonPosition.dx - (tooltipWidth / 2) + (buttonSize.width / 2);
    final yOffset = buttonPosition.dy + buttonSize.height + XeposSpacing.sp10;

    if (xOffset + tooltipWidth > screenWidth - endMargin) {
      xOffset = screenWidth - tooltipWidth - endMargin;
    }
    if (xOffset < endMargin) xOffset = endMargin;

    const blue = ThemeService.xeposPrimaryBlue;
    const dividerColor = Color(0xFFE8EEF2);

    return Positioned(
      left: xOffset,
      top: yOffset,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(XeposSpacing.radiusLg),
        shadowColor: Colors.black26,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: tooltipWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(XeposSpacing.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: XeposSpacing.sp16,
                    vertical: XeposSpacing.sp10,
                  ),
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(XeposSpacing.radiusLg),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.headset_mic_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: XeposSpacing.sp8),
                      Text(
                        'Technical Support',
                        style: XeposTextStyles.pinEmployeeName.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: XeposSpacing.sp8,
                          vertical: XeposSpacing.sp2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          regionLabel,
                          style: XeposTextStyles.captionMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(XeposSpacing.sp14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SupportCard(
                          icon: Icons.phone_rounded,
                          title: 'Call Us',
                          body: 'Our support team is available to help you.',
                          highlight: supportPhone,
                        ),
                      ),
                      const SizedBox(width: XeposSpacing.sp10),
                      Container(
                        width: 1,
                        height: 90,
                        color: dividerColor,
                        margin: const EdgeInsets.only(top: XeposSpacing.sp4),
                      ),
                      const SizedBox(width: XeposSpacing.sp10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(XeposSpacing.sp5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(XeposSpacing.sp6),
                                  ),
                                  child: const Icon(
                                    Icons.chat_rounded,
                                    color: Color(0xFF25D366),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: XeposSpacing.sp6),
                                Text(
                                  'WhatsApp',
                                  style: XeposTextStyles.pinEmployeeName.copyWith(
                                    color: const Color(0xFF25D366),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: XeposSpacing.sp6),
                            Text(
                              supportPhone,
                              style: XeposTextStyles.pinEmployeeName.copyWith(
                                color: blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: XeposSpacing.sp6),
                            Text(
                              'Scan QR to chat',
                              style: XeposTextStyles.captionMedium.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: XeposSpacing.sp6),
                            Center(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(XeposSpacing.sp4),
                                child: Image.asset(
                                  'assets/images/qr_paxpayment.png',
                                  width: XeposSpacing.sp80,
                                  height: XeposSpacing.sp80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String highlight;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    const blue = ThemeService.xeposPrimaryBlue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(XeposSpacing.sp5),
              decoration: BoxDecoration(
                color: blue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(XeposSpacing.sp6),
              ),
              child: Icon(icon, color: blue, size: 14),
            ),
            const SizedBox(width: XeposSpacing.sp6),
            Text(
              title,
              style: XeposTextStyles.pinEmployeeName.copyWith(
                color: blue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: XeposSpacing.sp6),
        Text(
          body,
          style: XeposTextStyles.captionMedium.copyWith(
            color: Colors.grey.shade600,
            fontSize: 10,
            height: 1.4,
          ),
        ),
        const SizedBox(height: XeposSpacing.sp6),
        Text(
          highlight,
          style: XeposTextStyles.pinEmployeeName.copyWith(
            color: blue,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
