import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ordering_theme_colors.dart';
import 'pax_colors.dart';
import 'pax_spacing.dart';
import 'pax_text_styles.dart';
import 'pax_theme_text.dart';

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: PaxColors.blueDark,
    onPrimary: PaxColors.grey950,
    primaryContainer: PaxColors.teal600,
    onPrimaryContainer: PaxColors.teal100,
    secondary: PaxColors.grey300,
    onSecondary: PaxColors.grey900,
    secondaryContainer: PaxColors.grey700,
    onSecondaryContainer: PaxColors.grey100,
    tertiary: PaxColors.info,
    onTertiary: PaxColors.white,
    tertiaryContainer: PaxColors.infoDark,
    onTertiaryContainer: PaxColors.infoLight,
    error: PaxColors.error,
    onError: PaxColors.white,
    errorContainer: PaxColors.errorDark,
    onErrorContainer: PaxColors.errorLight,
    surface: PaxColors.grey900,
    onSurface: PaxColors.grey50,
    surfaceContainerLowest: PaxColors.grey950,
    surfaceContainerLow: PaxColors.grey900,
    surfaceContainer: PaxColors.grey850,
    surfaceContainerHigh: PaxColors.grey800,
    surfaceContainerHighest: PaxColors.grey700,
    onSurfaceVariant: PaxColors.grey400,
    outline: PaxColors.grey700,
    outlineVariant: PaxColors.grey800,
    shadow: PaxColors.black,
    scrim: PaxColors.black,
    inverseSurface: PaxColors.grey100,
    onInverseSurface: PaxColors.grey900,
    inversePrimary: PaxColors.teal600,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PaxColors.grey950,
    extensions: [OrderingThemeColors.dark()],
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: PaxColors.grey900,
      foregroundColor: PaxColors.grey50,
      surfaceTintColor: PaxColors.transparent,
      shadowColor: PaxColors.grey950,
      centerTitle: false,
      titleTextStyle: PaxTextStyles.h3.copyWith(color: PaxColors.grey50),
      iconTheme: const IconThemeData(color: PaxColors.grey300, size: 22),
      actionsIconTheme: const IconThemeData(color: PaxColors.grey300, size: 22),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: PaxColors.transparent,
        systemNavigationBarColor: PaxColors.grey900,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: PaxColors.grey900,
      surfaceTintColor: PaxColors.transparent,
      indicatorColor: PaxColors.teal600.withValues(alpha: 0.3),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brMd,
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PaxTextStyles.navLabel.copyWith(color: PaxColors.blueDark);
        }
        return PaxTextStyles.navLabel.copyWith(color: PaxColors.grey500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: PaxColors.blueDark, size: 22);
        }
        return const IconThemeData(color: PaxColors.grey600, size: 22);
      }),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: PaxColors.grey900,
      surfaceTintColor: PaxColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brLg,
        side: const BorderSide(color: PaxColors.grey800, width: 1),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PaxColors.grey850,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.md,
        vertical: PaxSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.grey700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.grey700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.blueDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: PaxSpacing.brMd,
        borderSide: const BorderSide(color: PaxColors.error, width: 1.5),
      ),
      labelStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey400),
      hintStyle: PaxTextStyles.body.copyWith(color: PaxColors.grey600),
      errorStyle: PaxTextStyles.caption.copyWith(color: PaxColors.error),
      prefixIconColor: PaxColors.grey600,
      suffixIconColor: PaxColors.grey600,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PaxColors.blueDark,
        foregroundColor: PaxColors.grey950,
        disabledBackgroundColor: PaxColors.grey800,
        disabledForegroundColor: PaxColors.grey600,
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
        foregroundColor: PaxColors.grey100,
        disabledForegroundColor: PaxColors.grey600,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
        side: const BorderSide(color: PaxColors.grey700),
        textStyle: PaxTextStyles.buttonLg,
        padding: const EdgeInsets.symmetric(horizontal: PaxSpacing.lg),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PaxColors.blueDark,
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
        backgroundColor: PaxColors.grey800,
        foregroundColor: PaxColors.grey100,
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
      tileColor: PaxColors.grey900,
      selectedTileColor: PaxColors.teal600.withValues(alpha: 0.2),
      iconColor: PaxColors.grey400,
      titleTextStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.grey50),
      subtitleTextStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey500),
      minLeadingWidth: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PaxColors.grey800,
      selectedColor: PaxColors.teal600.withValues(alpha: 0.3),
      labelStyle: PaxTextStyles.label.copyWith(color: PaxColors.grey300),
      secondaryLabelStyle: PaxTextStyles.label.copyWith(color: PaxColors.blueDark),
      side: const BorderSide(color: PaxColors.grey700),
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brPill),
      padding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.sm,
        vertical: PaxSpacing.xxs,
      ),
      elevation: 0,
      pressElevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: PaxColors.grey800,
      thickness: 1,
      space: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PaxColors.grey850,
      surfaceTintColor: PaxColors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brXl),
      titleTextStyle: PaxTextStyles.h3.copyWith(color: PaxColors.grey50),
      contentTextStyle: PaxTextStyles.body.copyWith(color: PaxColors.grey400),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: PaxColors.grey850,
      surfaceTintColor: PaxColors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PaxSpacing.radiusXxl),
        ),
      ),
      modalBackgroundColor: PaxColors.grey850,
      showDragHandle: true,
      dragHandleColor: PaxColors.grey700,
      dragHandleSize: const Size(40, 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.grey950;
        return PaxColors.grey600;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.blueDark;
        return PaxColors.grey700;
      }),
      trackOutlineColor: WidgetStateProperty.all(PaxColors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PaxColors.blueDark;
        return PaxColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(PaxColors.grey950),
      side: const BorderSide(color: PaxColors.grey600, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brXs),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PaxColors.grey100,
      contentTextStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.grey900),
      actionTextColor: PaxColors.blueLight,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brMd),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PaxColors.blueDark,
      linearTrackColor: PaxColors.grey800,
      circularTrackColor: PaxColors.grey800,
      linearMinHeight: 4,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: PaxColors.blueDark,
      unselectedLabelColor: PaxColors.grey500,
      labelStyle: PaxTextStyles.buttonMd,
      unselectedLabelStyle: PaxTextStyles.bodyMedium,
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(color: PaxColors.blueDark, width: 2),
        borderRadius: PaxSpacing.brPill,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: PaxColors.grey800,
      overlayColor: WidgetStateProperty.all(
        PaxColors.blueDark.withValues(alpha: 0.08),
      ),
    ),
    textTheme: buildPaxTextTheme(isLight: false),
    popupMenuTheme: PopupMenuThemeData(
      color: PaxColors.grey850,
      surfaceTintColor: PaxColors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: PaxSpacing.brMd,
        side: const BorderSide(color: PaxColors.grey700),
      ),
      textStyle: PaxTextStyles.bodyMedium.copyWith(color: PaxColors.grey100),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: PaxColors.grey100,
        borderRadius: PaxSpacing.brSm,
      ),
      textStyle: PaxTextStyles.caption.copyWith(color: PaxColors.grey900),
      padding: const EdgeInsets.symmetric(
        horizontal: PaxSpacing.sm,
        vertical: PaxSpacing.xs,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: PaxColors.blueDark,
      foregroundColor: PaxColors.grey950,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 2,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: PaxSpacing.brLg),
    ),
  );
}

class AppDarkTheme {
  static ThemeData get theme => buildDarkTheme();
}
