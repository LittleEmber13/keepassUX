import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color cardBackground;
  final Color cardShadow;
  final Color secondaryText;
  final Color border;
  final Color inputFill;
  final Color danger;
  final Color infoCardBackground;

  const AppColors({
    required this.cardBackground,
    required this.cardShadow,
    required this.secondaryText,
    required this.border,
    required this.inputFill,
    required this.danger,
    required this.infoCardBackground,
  });

  static const light = AppColors(
    cardBackground: Colors.white,
    cardShadow: Color(0x0D000000),
    secondaryText: Colors.black54,
    border: Color(0xFFD2D2D2),
    inputFill: Color(0xFFF3F5F9),
    danger: Colors.red,
    infoCardBackground: Color(0xFFEEFDFF),
  );

  static const dark = AppColors(
    cardBackground: Color(0xFF1E1E1E),
    cardShadow: Color(0x33000000),
    secondaryText: Colors.white70,
    border: Color(0xFF3A3A3A),
    inputFill: Color(0xFF2A2A2A),
    danger: Color(0xFFCF6679),
    infoCardBackground: Color(0xFF173036),
  );

  @override
  AppColors copyWith({
    Color? cardBackground,
    Color? cardShadow,
    Color? secondaryText,
    Color? border,
    Color? inputFill,
    Color? danger,
    Color? infoCardBackground,
  }) {
    return AppColors(
      cardBackground: cardBackground ?? this.cardBackground,
      cardShadow: cardShadow ?? this.cardShadow,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      inputFill: inputFill ?? this.inputFill,
      danger: danger ?? this.danger,
      infoCardBackground: infoCardBackground ?? this.infoCardBackground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      infoCardBackground: Color.lerp(infoCardBackground, other.infoCardBackground, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

BoxDecoration cardDecoration(BuildContext context) {
  final colors = context.appColors;
  return BoxDecoration(
    color: colors.cardBackground,
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    boxShadow: [
      BoxShadow(
        color: colors.cardShadow,
        blurRadius: 5,
        spreadRadius: 1,
        offset: const Offset(1, 2),
      ),
    ],
  );
}

InputDecorationTheme _inputDecorationTheme(AppColors colors) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.inputFill,
    labelStyle: TextStyle(color: colors.secondaryText),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.border, width: 1),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.border, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.danger, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.danger, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
  );
}

final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  inputDecorationTheme: _inputDecorationTheme(AppColors.light),
  extensions: const [AppColors.light],
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  inputDecorationTheme: _inputDecorationTheme(AppColors.dark),
  extensions: const [AppColors.dark],
);
