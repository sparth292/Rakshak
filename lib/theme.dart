import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF78143C), // Dark pink
    onPrimary: Colors.white,
    secondary: Color(0xFFDE5972), // Complementary light pink
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
);

const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF78143C), // Dark pink
    onPrimary: Colors.white,
    secondary: Color(0xFFDE5972), // Complementary light pink
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.black,
    onSurface: Colors.white,
);

ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(lightColorScheme.primary),
            foregroundColor: WidgetStateProperty.all<Color>(lightColorScheme.onPrimary),
            elevation: WidgetStateProperty.all<double>(5.0), // Shadow
            padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                ),
            ),
        ),
    ),
);

ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(darkColorScheme.primary),
            foregroundColor: WidgetStateProperty.all<Color>(darkColorScheme.onPrimary),
            elevation: WidgetStateProperty.all<double>(5.0), // Shadow
            padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                ),
            ),
        ),
    ),
);
