import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SafeIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const SafeIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    // Para web, usar configuración específica
    if (kIsWeb) {
      return Icon(
        icon,
        size: size ?? 24,
        color: color ?? Theme.of(context).iconTheme.color,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        // Forzar el renderizado correcto en web
        key: ValueKey('web-icon-${icon.codePoint}'),
      );
    }
    
    return Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

// Clase de utilidad para obtener iconos seguros
class SafeIcons {
  static const IconData car = Icons.directions_car;
  static const IconData dashboard = Icons.dashboard;
  static const IconData people = Icons.people;
  static const IconData inventory = Icons.inventory_2;
  static const IconData analytics = Icons.analytics;
  static const IconData settings = Icons.settings;
  static const IconData arrowForward = Icons.arrow_forward;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData checkCircle = Icons.check_circle_outline;
  static const IconData personAdd = Icons.person_add;
  static const IconData list = Icons.list;
  static const IconData cake = Icons.cake;
}