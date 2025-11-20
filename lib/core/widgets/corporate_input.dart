import 'package:flutter/material.dart';
import '../theme/corporate_theme.dart';

class CorporateInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int maxLines;
  final bool enabled;
  final String? initialValue;
  final void Function(String)? onChanged;

  const CorporateInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.enabled = true,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CorporateTheme.bodyMedium.copyWith(
            color: CorporateTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: CorporateTheme.spacingSM),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          initialValue: initialValue,
          onChanged: onChanged,
          style: CorporateTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CorporateTheme.bodyMedium,
            filled: true,
            fillColor: enabled ? Colors.white : CorporateTheme.backgroundLight,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: CorporateTheme.textSecondary,
                    size: CorporateTheme.iconSizeSmall,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixIconTap,
                    child: Icon(
                      suffixIcon,
                      color: CorporateTheme.textSecondary,
                      size: CorporateTheme.iconSizeSmall,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: CorporateTheme.inputRadius,
              borderSide: const BorderSide(color: CorporateTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: CorporateTheme.inputRadius,
              borderSide: const BorderSide(color: CorporateTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: CorporateTheme.inputRadius,
              borderSide: const BorderSide(
                color: CorporateTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: CorporateTheme.inputRadius,
              borderSide: const BorderSide(
                color: CorporateTheme.accentRed,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: CorporateTheme.inputRadius,
              borderSide: const BorderSide(
                color: CorporateTheme.accentRed,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: CorporateTheme.spacingMD,
              vertical: CorporateTheme.spacingSM,
            ),
          ),
        ),
      ],
    );
  }
}