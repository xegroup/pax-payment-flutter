import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ordering_theme_colors.dart';
import 'pax_colors.dart';
import 'pax_spacing.dart';
import 'pax_text_styles.dart';
import 'pax_theme_text.dart';

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.light(
    primary: PaxColors.blueLight,
    onPrimary: PaxColors.white,
    primaryContainer: PaxColors.teal50,
    onPrimaryContainer: PaxColors.teal600,
    secondary: PaxColors.grey700,
    onSecondary: PaxColors.white,
    secondaryContainer: PaxColors.grey100,
    onSecondaryContainer: PaxColors.grey800,
    tertiary: PaxColors.info,
    onTertiary: PaxColors.white,
    tertiaryContainer: PaxColors.infoLight,
    onTertiaryContainer: PaxColors.infoDark,
    error: PaxColors.error,
    onError: PaxColors.white,
    errorContainer: PaxColors.errorLight,
    onErrorContainer: PaxColors.errorDark,
    surface: PaxColors.white,
    onSurface: PaxColors.grey900,
    surfaceContainerLowest: PaxColors.grey50,
    surfaceContainerLow: PaxColors.grey100,
    surfaceContainer: PaxColors.grey150,
    surfaceContainerHigh: PaxColors.grey200,
    surfaceContainerHighest: PaxColors.grey300,
    onSurfaceVariant: PaxColors.grey600,
    outline: PaxColors.grey200,
    outlineVariant: PaxColors.grey150,
    shadow: PaxColors.black,
    scrim: PaxColors.black,
    inverseSurface: PaxColors.grey900,
    onInverseSurface: PaxColors.grey50,
    inversePrimary: PaxColors.blueDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PaxColors.grey50,
    extensions: [OrderingThemeColors.light()],
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: PaxColors.white,
      foregroundColor: PaxColors.grey900,
      surfaceTintColor: PaxColors.transparent,
      shadowColor: PaxColors.grey200,
      centerTitle: false,
      titleTextStyle: PaxTextStyles.h3.copyWith(color: PaxColors.grey900),
      iconTheme: const IconThemeData(color: PaxColors.grey700, size: 22),
      actionsIconTheme: const IconThemeData(color: PaxColors.grey700, size: 22),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: PaxColors.transparent,
        systemNavigationBarColor: PaxColors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: PaxColors.white,
      surfaceTintColor: PaxColors.transparent,
      shadowColor: PaxColors.grey200,
      indicatorColor: PaxColors.teal50,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brMd,
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PaxTextStyles.navLabel.copyWith(color: PaxColors.blueLight);
        }
        return PaxTextStyles.navLabel.copyWith(color: PaxColors.grey500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PaxColors.blueLight, size: 22);
        }
        return const IconThemeData(color: PaxColors.grey400, size: 22);
      }),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: PaxColors.white,
      surfaceTintColor: PaxColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brLg,
        side: const BorderSide(color: PaxColors.grey150, width: 1),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PaxColors.grey50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.md,
        vertical: PaxSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.blueLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.error, width: 1.5),
      ),
      labelStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey600),
      hintStyle: PaxTextStyles.body.copyWith(color: PaxColors.grey400),
      errorStyle: PaxTextStyles.caption.copyWith(color: PaxColors.error),
      prefixIconColor: PaxColors.grey400,
      suffixIconColor: PaxColors.grey400,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PaxColors.blueLight,
        foregroundColor: PaxColors.white,
        disabledBackgroundColor: PaxColors.grey200,
        disabledForegroundColor: PaxColors.grey400,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
        textStyle: PaxTextStyles.buttonLg,
        elevation: 0,
        shadowColor: PaxColors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: PaxSpacing.lg),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PaxColors.grey800,
        disabledForegroundColor: PaxColors.grey400,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
        side: const BorderSide(color: PaxColors.grey200),
        textStyle: PaxTextStyles.buttonLg,
        padding: const EdgeInsets.symmetric(horizontal: PaxSpacing.lg),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PaxColors.blueLight,
        textStyle: PaxTextStyles.buttonMd,
        shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brSm),
        padding: const EdgeInsets.symmetric(
          horizontal: PaxSpacing.md,
          vertical: PaxSpacing.sm,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PaxColors.grey100,
        foregroundColor: PaxColors.grey800,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
        textStyle: PaxTextStyles.buttonLg,
        elevation: 0,
        shadowColor: PaxColors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: PaxSpacing.lg),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.md,
        vertical: PaxSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
      iconColor: PaxColors.grey500,
      titleTextStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.grey900),
      subtitleTextStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey500),
      minLeadingWidth: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PaxColors.grey100,
      selectedColor: PaxColors.teal50,
      labelStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey700),
      secondaryLabelStyle: PaxTextStyles.label.copyWith(color: PaxColors.teal600),
      side: const BorderSide(color: PaxColors.grey200),
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brPill),
      padding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.sm,
        vertical: PaxSpacing.xxs,
      ),
      elevation: 0,
      pressElevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: PaxColors.grey150,
      thickness: 1,
      space: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PaxColors.white,
      surfaceTintColor: PaxColors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brXl),
      titleTextStyle: PaxTextStyles.h3.copyWith(color: PaxColors.grey900),
      contentTextStyle: PaxTextStyles.body.copyWith(color: PaxColors.grey600),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: PaxColors.white,
      surfaceTintColor: PaxColors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PaxSpacing.radiusXxl),
        ),
      ),
      modalBackgroundColor: PaxColors.white,
      showDragHandle: true,
      dragHandleColor: PaxColors.grey300,
      dragHandleSize: const Size(40, 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.white;
        return PaxColors.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.blueLight;
        return PaxColors.grey200;
      }),
      trackOutlineColor: WidgetStateProperty.all(PaxColors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.blueLight;
        return PaxColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(PaxColors.white),
      side: const BorderSide(color: PaxColors.grey300, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brXs),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PaxColors.grey900,
      contentTextStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.white),
      actionTextColor: PaxColors.blueDark,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PaxColors.blueLight,
      linearTrackColor: PaxColors.teal50,
      circularTrackColor: PaxColors.teal50,
      linearMinHeight: 4,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: PaxColors.blueLight,
      unselectedLabelColor: PaxColors.grey500,
      labelStyle: PaxTextStyles.buttonMd,
      unselectedLabelStyle: PaxTextStyles.bodyMedium,
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(color: PaxColors.blueLight, width: 2),
        borderRadius: PaxSpacing.brPill,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: PaxColors.grey150,
      overlayColor: WidgetStateProperty.all(PaxColors.teal50),
    ),
    textTheme: buildPaxTextTheme(isLight: true),
    popupMenuTheme: PopupMenuThemeData(
      color: PaxColors.white,
      surfaceTintColor: PaxColors.transparent,
      elevation: 4,
      shadowColor: PaxColors.grey300,
      shape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brMd,
        side: const BorderSide(color: PaxColors.grey150),
      ),
      textStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.grey800),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: PaxColors.grey900,
        borderRadius: PaxSpacing.brSm,
      ),
      textStyle: PaxTextStyles.caption.copyWith(color: PaxColors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.sm,
        vertical: PaxSpacing.xs,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: PaxColors.blueLight,
      foregroundColor: PaxColors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 2,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brLg),
    ),
  );
}

/// Backward-compatible accessor.
class AppLightTheme {
  static ThemeData get theme => buildLightTheme();
}
