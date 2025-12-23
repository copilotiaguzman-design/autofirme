import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/google_drive_service.dart';
import '../core/exports.dart';

/// Widget para mostrar imágenes de un vehículo desde Google Drive u otras fuentes
class VehiculoImagenes extends StatelessWidget {
  final String? imagenesUrl;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool mostrarBotonAbrir;
  final bool compacto;
  
  const VehiculoImagenes({
    super.key,
    required this.imagenesUrl,
    this.height = 200,
    this.width,
    this.borderRadius,
    this.mostrarBotonAbrir = true,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final imagenInfo = GoogleDriveService.parsearUrlImagen(imagenesUrl);
    
    if (!imagenInfo.tieneImagen) {
      return _buildPlaceholder();
    }
    
    switch (imagenInfo.tipo) {
      case TipoImagen.carpetaGoogleDrive:
        return _buildCarpetaGoogleDrive(context, imagenInfo);
      case TipoImagen.archivoGoogleDrive:
        return _buildImagenGoogleDrive(context, imagenInfo);
      case TipoImagen.urlDirecta:
        return _buildImagenDirecta(context, imagenInfo);
      case TipoImagen.urlGenerica:
        return _buildUrlGenerica(context, imagenInfo);
      default:
        return _buildPlaceholder();
    }
  }
  
  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: compacto ? 32 : 48,
            color: Colors.grey.shade400,
          ),
          if (!compacto) ...[
            const SizedBox(height: 8),
            Text(
              'Sin imágenes',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCarpetaGoogleDrive(BuildContext context, ImagenInfo info) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        onTap: () => _abrirEnGoogleDrive(context, info.url),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/google_drive_icon.png',
                width: compacto ? 24 : 40,
                height: compacto ? 24 : 40,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.folder,
                  size: compacto ? 24 : 40,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
            if (!compacto) ...[
              const SizedBox(height: 12),
              Text(
                'Ver Galería de Imágenes',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Colors.blue.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Abrir en Google Drive',
                    style: TextStyle(
                      color: Colors.blue.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagenGoogleDrive(BuildContext context, ImagenInfo info) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            info.urlThumbnail ?? info.urlDirecta ?? info.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImagen(context, info);
            },
          ),
          if (mostrarBotonAbrir)
            Positioned(
              bottom: 8,
              right: 8,
              child: Material(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _abrirEnGoogleDrive(context, info.url),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildImagenDirecta(BuildContext context, ImagenInfo info) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        info.urlDirecta ?? info.url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }
  
  Widget _buildUrlGenerica(BuildContext context, ImagenInfo info) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        onTap: () => _abrirUrl(context, info.url),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: compacto ? 24 : 36,
              color: CorporateTheme.primaryBlue,
            ),
            if (!compacto) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ver imágenes',
                  style: TextStyle(
                    color: CorporateTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Abrir enlace',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorImagen(BuildContext context, ImagenInfo info) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: compacto ? 24 : 36,
            color: Colors.grey.shade400,
          ),
          if (!compacto) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _abrirEnGoogleDrive(context, info.url),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Abrir en navegador', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _abrirEnGoogleDrive(BuildContext context, String url) async {
    await _abrirUrl(context, url);
  }
  
  Future<void> _abrirUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir el enlace'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Widget para mostrar una miniatura de imagen del vehículo
class VehiculoImagenMiniatura extends StatelessWidget {
  final String? imagenesUrl;
  final double size;
  
  const VehiculoImagenMiniatura({
    super.key,
    required this.imagenesUrl,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final imagenInfo = GoogleDriveService.parsearUrlImagen(imagenesUrl);
    
    if (!imagenInfo.tieneImagen) {
      return _buildPlaceholder();
    }
    
    if (imagenInfo.tipo == TipoImagen.archivoGoogleDrive) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imagenInfo.urlThumbnail ?? imagenInfo.url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    
    if (imagenInfo.tipo == TipoImagen.carpetaGoogleDrive) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Icon(
          Icons.photo_library,
          size: size * 0.5,
          color: Colors.blue.shade400,
        ),
      );
    }
    
    if (imagenInfo.tipo == TipoImagen.urlDirecta) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imagenInfo.url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.link,
        size: size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.directions_car,
        size: size * 0.5,
        color: Colors.grey.shade400,
      ),
    );
  }
}
