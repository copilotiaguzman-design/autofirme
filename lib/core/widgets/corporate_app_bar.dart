import 'package:flutter/material.dart';
import '../theme/corporate_theme.dart';

class CorporateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showLoadingIndicator;

  const CorporateAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.showLoadingIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CorporateTheme.headerGradient,
        boxShadow: CorporateTheme.headerShadow,
      ),
      child: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showLoadingIndicator) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: showBackButton
            ? leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: onBackPressed ?? () => _handleBackPress(context),
                )
            : leading,
        actions: actions?.map((action) {
          // Envolver los actions en un contenedor con padding consistente
          if (action is IconButton) {
            return action;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: action,
          );
        }).toList(),
      ),
    );
  }

  void _handleBackPress(BuildContext context) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error en navegación: $e');
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}