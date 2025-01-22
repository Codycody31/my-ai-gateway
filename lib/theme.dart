import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282474385),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292273151),
      onPrimaryContainer: Color(4280829815),
      secondary: Color(4283850609),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292535033),
      onSecondaryContainer: Color(4282271577),
      tertiary: Color(4285551989),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294629629),
      onTertiaryContainer: Color(4283907676),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4287823882),
      surface: Color(4294572543),
      onSurface: Color(4279835680),
      onSurfaceVariant: Color(4282664782),
      outline: Color(4285822847),
      outlineVariant: Color(4291086032),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4279442475),
      secondaryFixedDim: Color(4290692828),
      onSecondaryFixedVariant: Color(4282271577),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280816430),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4283907676),
      surfaceDim: Color(4292467168),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293783028),
      surfaceContainerHigh: Color(4293388526),
      surfaceContainerHighest: Color(4293059305),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4279449189),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4283461024),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281218631),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4284771712),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282723914),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4286538884),
      onTertiaryContainer: Color(4294967295),
      error: Color(4285792262),
      onError: Color(4294967295),
      errorContainer: Color(4291767335),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572543),
      onSurface: Color(4279177494),
      onSurfaceVariant: Color(4281546302),
      outline: Color(4283388506),
      outlineVariant: Color(4285164917),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4283461024),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4281816454),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4284771712),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283192679),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4286538884),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4284828779),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4291151565),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293388526),
      surfaceContainerHigh: Color(4292664547),
      surfaceContainerHighest: Color(4291940824),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4278397787),
      surfaceTint: Color(4282474385),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280961402),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280495165),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4282468699),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282000448),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284039262),
      onTertiaryContainer: Color(4294967295),
      error: Color(4284481540),
      onError: Color(4294967295),
      errorContainer: Color(4288151562),
      onErrorContainer: Color(4294967295),
      surface: Color(4294572543),
      onSurface: Color(4278190080),
      onSurfaceVariant: Color(4278190080),
      outline: Color(4280888371),
      outlineVariant: Color(4282796369),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289382399),
      primaryFixed: Color(4280961402),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279120482),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4282468699),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280955716),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284039262),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4282460743),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4290295999),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293980407),
      surfaceContainer: Color(4293059305),
      surfaceContainerHigh: Color(4292072667),
      surfaceContainerHighest: Color(4291151565),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289382399),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278857823),
      primaryContainer: Color(4280829815),
      onPrimaryContainer: Color(4292273151),
      secondary: Color(4290692828),
      onSecondary: Color(4280824129),
      secondaryContainer: Color(4282271577),
      onSecondaryContainer: Color(4292535033),
      tertiary: Color(4292721888),
      onTertiary: Color(4282329156),
      tertiaryContainer: Color(4283907676),
      onTertiaryContainer: Color(4294629629),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309080),
      onSurface: Color(4293059305),
      onSurfaceVariant: Color(4291086032),
      outline: Color(4287533209),
      outlineVariant: Color(4282664782),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4282474385),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197054),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4280829815),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4279442475),
      secondaryFixedDim: Color(4290692828),
      onSecondaryFixedVariant: Color(4282271577),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280816430),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4283907676),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4281809214),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279835680),
      surfaceContainer: Color(4280098852),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4291681791),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278199633),
      primaryContainer: Color(4285829575),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4292140274),
      onSecondary: Color(4280100406),
      secondaryContainer: Color(4287140261),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294169335),
      onTertiary: Color(4281539897),
      tertiaryContainer: Color(4288972713),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294955724),
      onError: Color(4283695107),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      surface: Color(4279309080),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4292533478),
      outline: Color(4289704635),
      outlineVariant: Color(4287533209),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4280895608),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278194475),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4279449189),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4278718753),
      secondaryFixedDim: Color(4290692828),
      onSecondaryFixedVariant: Color(4281218631),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4280092707),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4282723914),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4282598474),
      surfaceContainerLowest: Color(4278585100),
      surfaceContainerLow: Color(4279967266),
      surfaceContainer: Color(4280690733),
      surfaceContainerHigh: Color(4281414200),
      surfaceContainerHighest: Color(4282138179),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4293652735),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4289119228),
      onPrimaryContainer: Color(4278192928),
      secondary: Color(4293652735),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290429912),
      onSecondaryContainer: Color(4278389530),
      tertiary: Color(4294961663),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4292393180),
      onTertiaryContainer: Color(4279632925),
      error: Color(4294962409),
      onError: Color(4278190080),
      errorContainer: Color(4294946468),
      onErrorContainer: Color(4280418305),
      surface: Color(4279309080),
      onSurface: Color(4294967295),
      onSurfaceVariant: Color(4294967295),
      outline: Color(4293849081),
      outlineVariant: Color(4290822860),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4280895608),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4289382399),
      onPrimaryFixedVariant: Color(4278194475),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290692828),
      onSecondaryFixedVariant: Color(4278718753),
      tertiaryFixed: Color(4294629629),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4292721888),
      onTertiaryFixedVariant: Color(4280092707),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4283322454),
      surfaceContainerLowest: Color(4278190080),
      surfaceContainerLow: Color(4280098852),
      surfaceContainer: Color(4281217078),
      surfaceContainerHigh: Color(4281940801),
      surfaceContainerHighest: Color(4282730316),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
