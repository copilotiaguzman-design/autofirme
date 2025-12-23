import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/google_drive_service.dart';

/// Widget para mostrar imágenes de un vehículo desde diferentes fuentes
/// (URLs directas, Google Drive, etc.)
class VehiculoImagenes extends StatefulWidget {
  final List<String> imagenesUrl;
  final double height;
  final BoxFit fit;
  final bool showControls;
  final bool allowFullscreen;
  
  const VehiculoImagenes({
    super.key,
    required this.imagenesUrl,
    this.height = 250,
    this.fit = BoxFit.cover,
    this.showControls = true,
    this.allowFullscreen = true,
  });

  @override
  State<VehiculoImagenes> createState() => _VehiculoImagenesState();
}

class _VehiculoImagenesState extends State<VehiculoImagenes> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Lista de imágenes cargadas (URLs directas para mostrar)
  List<_ImagenCargada> _imagenesCargadas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  @override
  void didUpdateWidget(VehiculoImagenes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagenesUrl != widget.imagenesUrl) {
      _cargarImagenes();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Carga las imágenes, expandiendo carpetas de Google Drive
  Future<void> _cargarImagenes() async {
    if (!mounted) return;
    
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final List<_ImagenCargada> imagenes = [];
      
      for (final url in widget.imagenesUrl) {
        if (url.isEmpty) continue;
        
        final tipoUrl = GoogleDriveService.detectarTipoUrl(url);
        
        switch (tipoUrl) {
          case TipoUrlGoogleDrive.archivoImagen:
            // Es un archivo de imagen de Google Drive
            final fileId = GoogleDriveService.extraerFileId(url);
            if (fileId != null) {
              // Usar URL de thumbnail para mostrar directamente
              final directUrl = 'https://drive.google.com/thumbnail?id=$fileId&sz=w800';
              imagenes.add(_ImagenCargada(
                urlOriginal: url,
                urlDirecta: directUrl,
                tipo: _TipoImagen.googleDriveArchivo,
              ));
            } else {
              imagenes.add(_ImagenCargada(
                urlOriginal: url,
                urlDirecta: null,
                tipo: _TipoImagen.error,
                error: 'No se pudo extraer ID del archivo',
              ));
            }
            break;
            
          case TipoUrlGoogleDrive.carpeta:
            // Es una carpeta de Google Drive - intentar listar contenido
            final contenido = await GoogleDriveService.obtenerContenidoCarpeta(url);
            
            if (contenido.isEmpty) {
              // Si no hay contenido, mostrar botón para abrir en Drive
              imagenes.add(_ImagenCargada(
                urlOriginal: url,
                urlDirecta: null,
                tipo: _TipoImagen.carpetaDrive,
              ));
            } else {
              // Agregar cada imagen de la carpeta
              for (final imagen in contenido) {
                imagenes.add(_ImagenCargada(
                  urlOriginal: url,
                  urlDirecta: imagen['thumbnailLink'] ?? imagen['webContentLink'],
                  tipo: _TipoImagen.googleDriveArchivo,
                  nombre: imagen['name'],
                ));
              }
            }
            break;
            
          case TipoUrlGoogleDrive.noEsGoogleDrive:
          default:
            // URL normal (directa)
            imagenes.add(_ImagenCargada(
              urlOriginal: url,
              urlDirecta: url,
              tipo: _TipoImagen.urlDirecta,
            ));
            break;
        }
      }
      
      if (mounted) {
        setState(() {
          _imagenesCargadas = imagenes;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _cargarImagenes,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_imagenesCargadas.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Sin imágenes'),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Galería de imágenes
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _imagenesCargadas.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imagen = _imagenesCargadas[index];
                  return _buildImagen(imagen);
                },
              ),
              
              // Indicadores de página
              if (_imagenesCargadas.length > 1 && widget.showControls)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _imagenesCargadas.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Flechas de navegación
              if (_imagenesCargadas.length > 1 && widget.showControls) ...[
                if (_currentPage > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage < _imagenesCargadas.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                  ),
              ],
              
              // Contador de imágenes
              if (_imagenesCargadas.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${_imagenesCargadas.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagen(_ImagenCargada imagen) {
    switch (imagen.tipo) {
      case _TipoImagen.carpetaDrive:
        return _buildCarpetaDrive(imagen);
      case _TipoImagen.error:
        return _buildError(imagen);
      default:
        return _buildImagenDirecta(imagen);
    }
  }

  Widget _buildImagenDirecta(_ImagenCargada imagen) {
    if (imagen.urlDirecta == null) {
      return _buildError(imagen);
    }

    return GestureDetector(
      onTap: widget.allowFullscreen ? () => _abrirFullscreen(imagen) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imagen.urlDirecta!,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Error al cargar imagen'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _abrirEnNavegador(imagen.urlOriginal),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Abrir en navegador'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Nombre de la imagen si existe
          if (imagen.nombre != null)
            Positioned(
              bottom: 24,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  imagen.nombre!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarpetaDrive(_ImagenCargada imagen) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Carpeta de Google Drive',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se puede acceder al contenido sin API Key',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _abrirEnNavegador(imagen.urlOriginal),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir en Google Drive'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(_ImagenCargada imagen) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(imagen.error ?? 'Error desconocido'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _abrirEnNavegador(imagen.urlOriginal),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir enlace'),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirFullscreen(_ImagenCargada imagen) {
    if (imagen.urlDirecta == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageView(
          imagenes: _imagenesCargadas.where((i) => i.urlDirecta != null).toList(),
          initialIndex: _imagenesCargadas.indexOf(imagen),
        ),
      ),
    );
  }

  Future<void> _abrirEnNavegador(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Vista de imagen en pantalla completa
class _FullscreenImageView extends StatefulWidget {
  final List<_ImagenCargada> imagenes;
  final int initialIndex;

  const _FullscreenImageView({
    required this.imagenes,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageView> createState() => _FullscreenImageViewState();
}

class _FullscreenImageViewState extends State<_FullscreenImageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.imagenes.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () {
              final imagen = widget.imagenes[_currentIndex];
              _abrirEnNavegador(imagen.urlOriginal);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagenes.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imagen = widget.imagenes[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imagen.urlDirecta!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Error al cargar imagen',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _abrirEnNavegador(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Clase interna para representar una imagen cargada
class _ImagenCargada {
  final String urlOriginal;
  final String? urlDirecta;
  final _TipoImagen tipo;
  final String? nombre;
  final String? error;

  _ImagenCargada({
    required this.urlOriginal,
    required this.urlDirecta,
    required this.tipo,
    this.nombre,
    this.error,
  });
}

enum _TipoImagen {
  urlDirecta,
  googleDriveArchivo,
  carpetaDrive,
  error,
}

/// Widget para mostrar una miniatura de imagen del vehículo
class VehiculoImagenMiniatura extends StatelessWidget {
  final List<String> imagenesUrl;
  final double size;
  final double borderRadius;

  const VehiculoImagenMiniatura({
    super.key,
    required this.imagenesUrl,
    this.size = 60,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (imagenesUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final primeraUrl = imagenesUrl.first;
    final tipoUrl = GoogleDriveService.detectarTipoUrl(primeraUrl);

    // Determinar URL de imagen a mostrar
    String? urlImagen;
    
    switch (tipoUrl) {
      case TipoUrlGoogleDrive.archivoImagen:
        final fileId = GoogleDriveService.extraerFileId(primeraUrl);
        if (fileId != null) {
          urlImagen = 'https://drive.google.com/thumbnail?id=$fileId&sz=w${size.toInt() * 2}';
        }
        break;
      case TipoUrlGoogleDrive.carpeta:
        // Para carpetas, mostrar ícono de carpeta
        return _buildFolderIcon();
      case TipoUrlGoogleDrive.noEsGoogleDrive:
      default:
        urlImagen = primeraUrl;
        break;
    }

    if (urlImagen == null) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          urlImagen,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: Icon(
          Icons.directions_car,
          size: size * 0.5,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildFolderIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: Colors.amber[50],
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.folder,
                size: size * 0.6,
                color: Colors.amber,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(
                Icons.image,
                size: size * 0.25,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
