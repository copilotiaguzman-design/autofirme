import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../responsive_utils.dart';

class CorporateModuleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CorporateModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<CorporateModuleCard> createState() => _CorporateModuleCardState();
}

class _CorporateModuleCardState extends State<CorporateModuleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isWeb = ResponsiveUtils.isWeb();
    
    // Ajustar tamaños según la plataforma
    final iconSize = isMobile ? 48.0 : 56.0;
    final iconContainerSize = isMobile ? 56.0 : 64.0;
    final titleFontSize = isMobile ? 16.0 : 18.0;
    final subtitleFontSize = isMobile ? 12.0 : 14.0;
    final cardPadding = isMobile ? 16.0 : 20.0;

    return MouseRegion(
      onEnter: isWeb ? (_) => _onHover(true) : null,
      onExit: isWeb ? (_) => _onHover(false) : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isWeb ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                    blurRadius: _isHovered ? 25 : 20,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
                border: Border.all(
                  color: _isHovered 
                      ? widget.color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor: widget.color.withOpacity(0.1),
                  highlightColor: widget.color.withOpacity(0.05),
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícono con animación - más compacto para móvil
                        Flexible(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: _isHovered 
                                  ? widget.color.withOpacity(0.15)
                                  : widget.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: iconSize,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        
                        // Título - ajustable según plataforma
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: _isHovered
                                  ? widget.color
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: isMobile ? 6 : 8),
                        
                        // Subtítulo - más compacto para móvil
                        Flexible(
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        
                        // Botón de acción - más compacto para móvil
                        Flexible(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16, 
                              vertical: isMobile ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isHovered
                                  ? widget.color.withOpacity(0.1)
                                  : widget.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isHovered
                                    ? widget.color.withOpacity(0.3)
                                    : widget.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Acceder',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 13,
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 200),
                                  turns: _isHovered ? 0.125 : 0,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: widget.color,
                                    size: isMobile ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHover(bool isHovered) {
    if (mounted) {
      setState(() {
        _isHovered = isHovered;
      });
      
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
}