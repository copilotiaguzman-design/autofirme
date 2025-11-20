import 'package:flutter/material.dart';
import '../theme/corporate_theme.dart';

enum CorporateButtonStyle { primary, secondary, accent, outline }

class CorporateButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CorporateButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CorporateButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = CorporateButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: CorporateTheme.spacingMD,
            vertical: CorporateTheme.spacingSM,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: CorporateTheme.iconSizeSmall,
                  height: CorporateTheme.iconSizeSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTextColor(),
                    ),
                  ),
                ),
                const SizedBox(width: CorporateTheme.spacingSM),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: CorporateTheme.iconSizeSmall,
                  color: _getTextColor(),
                ),
                const SizedBox(width: CorporateTheme.spacingSM),
              ],
              Text(
                text,
                style: CorporateTheme.buttonText.copyWith(
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (style) {
      case CorporateButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: CorporateTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: CorporateTheme.buttonRadius,
          ),
          elevation: 2,
        );
      case CorporateButtonStyle.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: CorporateTheme.secondaryBlue,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: CorporateTheme.buttonRadius,
          ),
          elevation: 2,
        );
      case CorporateButtonStyle.accent:
        return ElevatedButton.styleFrom(
          backgroundColor: CorporateTheme.accentRed,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: CorporateTheme.buttonRadius,
          ),
          elevation: 2,
        );
      case CorporateButtonStyle.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: CorporateTheme.primaryBlue,
          side: const BorderSide(color: CorporateTheme.primaryBlue),
          shape: const RoundedRectangleBorder(
            borderRadius: CorporateTheme.buttonRadius,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (style) {
      case CorporateButtonStyle.outline:
        return CorporateTheme.primaryBlue;
      default:
        return Colors.white;
    }
  }
}