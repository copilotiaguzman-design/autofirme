import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class WebSafeIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const WebSafeIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 24;
    final iconColor = color ?? Theme.of(context).iconTheme.color ?? Colors.grey;

    // En web, primero intentar el ícono normal, con fallback a texto
    if (kIsWeb) {
      return Container(
        width: iconSize,
        height: iconSize,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
          semanticLabel: semanticLabel,
        ),
      );
    }

    return Icon(
      icon,
      size: iconSize,
      color: iconColor,
      semanticLabel: semanticLabel,
    );
  }
}