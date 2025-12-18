import 'package:flutter/material.dart';

class CorporateTheme {
  // Colores corporativos - Más suaves y modernos
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color accentRed = Color(0xFFDC2626);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color surfaceColor = Color(0xFFF1F5F9);

  // Gradientes corporativos - Más sutiles
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras corporativas - Más sutiles
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> headerShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Estilos de texto corporativos
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Bordes redondeados - Más consistentes
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(10));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(10));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(20));

  // Espaciado consistente
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Iconos corporativos con tamaños consistentes
  static const double iconSizeSmall = 18;
  static const double iconSizeMedium = 22;
  static const double iconSizeLarge = 28;
  static const double iconSizeXLarge = 40;

  // Decoración de Card moderna sin bordes
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: cardRadius,
    boxShadow: cardShadow,
  );

  // Decoración de Card con borde sutil
  static BoxDecoration get cardDecorationSubtle => BoxDecoration(
    color: cardBackground,
    borderRadius: cardRadius,
    border: Border.all(color: dividerColor.withOpacity(0.5), width: 1),
  );

  // Decoración para secciones
  static BoxDecoration get sectionDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: cardRadius,
  );

  // Método para crear el tema completo de la aplicación
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: cardBackground,
        background: backgroundLight,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      dividerColor: dividerColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        shadowColor: Colors.black.withOpacity(0.05),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: dividerColor.withOpacity(0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: buttonText,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: accentRed, width: 1),
        ),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryBlue.withOpacity(0.15),
        labelStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const RoundedRectangleBorder(borderRadius: chipRadius),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor.withOpacity(0.5),
        thickness: 1,
        space: 0,
      ),
    );
  }
}