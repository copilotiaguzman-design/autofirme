import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class CumpleanosScreen extends StatefulWidget {
  final List<Map<String, String>> clientes;
  final VoidCallback? onRefresh;
  
  const CumpleanosScreen({
    super.key, 
    required this.clientes,
    this.onRefresh,
  });

  @override
  State<CumpleanosScreen> createState() => _CumpleanosScreenState();
}

class _CumpleanosScreenState extends State<CumpleanosScreen> {
  List<Map<String, dynamic>> clientesConCumpleanos = [];
  bool isLoading = true;
  String mensajePersonalizado = '';

  // Mensajes predeterminados
  final List<String> mensajesPredeterminados = [
    '🎉 ¡Feliz cumpleaños! Desde AutoFirme te deseamos un día lleno de alegría y bendiciones. ¡Que este nuevo año de vida esté lleno de éxitos! 🎂✨',
    '🎈 ¡Muchas felicidades en tu día especial! El equipo de AutoFirme te envía los mejores deseos en tu cumpleaños. ¡Esperamos verte pronto! 🚗🎁',
    '🎊 ¡Feliz cumpleaños desde AutoFirme! Que este nuevo año de vida te traiga mucha prosperidad y momentos inolvidables. ¡Celebra en grande! 🥳🎂',
    '🎉 ¡Es tu día especial! Desde AutoFirme queremos ser los primeros en felicitarte. Que tengas un cumpleaños extraordinario lleno de sorpresas. 🎈🎁',
  ];

  String mensajeSeleccionado = '';

  @override
  void initState() {
    super.initState();
    mensajeSeleccionado = mensajesPredeterminados[0];
    _cargarClientesConCumpleanos();
  }

  Future<void> _cargarClientesConCumpleanos() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Usar los clientes recibidos como parámetro directamente
      List<Map<String, String>> todosLosClientes = widget.clientes;
      
      List<Map<String, dynamic>> clientesConFechas = [];
      DateTime ahora = DateTime.now();
      DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day); // Solo año, mes, día (sin horas)

      print('📊 Procesando ${todosLosClientes.length} clientes para cumpleaños...');
      print('📅 Fecha actual: ${hoy.day}/${hoy.month}/${hoy.year}');

      for (var cliente in todosLosClientes) {
        String fechaCumple = cliente['cumple']?.trim() ?? '';
        print('🔍 Procesando cliente: ${cliente['nombre']} - Cumple: "$fechaCumple"');
        
        if (fechaCumple.isNotEmpty) {
          try {
            DateTime? proximoCumple = _parsearFechaCumpleanos(fechaCumple, hoy);
            
            if (proximoCumple != null) {
              // Calcular días faltantes (ambas fechas ya están sin horas)
              int diasFaltantes = proximoCumple.difference(hoy).inDays;
              
              print('📅 ${cliente['nombre']}: Próximo cumpleaños: ${proximoCumple.day}/${proximoCumple.month}/${proximoCumple.year}');
              print('📅 Hoy es: ${hoy.day}/${hoy.month}/${hoy.year}');
              print('⏰ ${cliente['nombre']}: $diasFaltantes días faltantes');
              
              // Solo incluir cumpleaños en los próximos 60 días
              if (diasFaltantes >= 0 && diasFaltantes <= 60) {
                // Formatear la fecha para mostrar correctamente
                String fechaFormateada = '${proximoCumple.day.toString().padLeft(2, '0')}/${proximoCumple.month.toString().padLeft(2, '0')}/${proximoCumple.year}';
                
                Map<String, dynamic> clienteConDias = Map<String, dynamic>.from(cliente);
                clienteConDias['diasFaltantes'] = diasFaltantes;
                clienteConDias['proximoCumple'] = proximoCumple;
                clienteConDias['cumpleFormateado'] = fechaFormateada; // Nueva fecha formateada
                clientesConFechas.add(clienteConDias);
                print('✅ Cliente agregado: ${cliente['nombre']} - $diasFaltantes días - Fecha: $fechaFormateada');
              } else {
                print('⚠️ Cliente ${cliente['nombre']} no incluido: $diasFaltantes días (fuera del rango de 60 días)');
              }
            } else {
              print('❌ No se pudo parsear la fecha para ${cliente['nombre']}');
            }
          } catch (e) {
            print('❌ Error procesando fecha de ${cliente['nombre']}: $e');
          }
        } else {
          print('⚠️ Cliente ${cliente['nombre']} no tiene fecha de cumpleaños');
        }
      }

      // Ordenar por días faltantes
      clientesConFechas.sort((a, b) => (a['diasFaltantes'] as int).compareTo(b['diasFaltantes'] as int));

      print('🎂 Total de cumpleaños próximos: ${clientesConFechas.length}');

      setState(() {
        clientesConCumpleanos = clientesConFechas;
        isLoading = false;
      });
    } catch (e) {
      print('💥 Error cargando cumpleaños: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime? _parsearFechaCumpleanos(String fecha, DateTime hoy) {
    try {
      // Primero, intentar parsear como formato ISO 8601 (desde Google Sheets)
      if (fecha.contains('T') && (fecha.contains('Z') || fecha.contains('+'))) {
        try {
          DateTime fechaISO = DateTime.parse(fecha);
          print('📅 Fecha ISO parseada: ${fechaISO.day}/${fechaISO.month}/${fechaISO.year}');
          
          // Calcular próximo cumpleaños usando solo día y mes (sin horas para evitar problemas)
          DateTime proximoCumple = DateTime(hoy.year, fechaISO.month, fechaISO.day);
          
          // Si ya pasó este año, calcular para el siguiente
          if (proximoCumple.isBefore(hoy)) {
            proximoCumple = DateTime(hoy.year + 1, fechaISO.month, fechaISO.day);
          }
          
          print('📅 Próximo cumpleaños calculado: ${proximoCumple.day}/${proximoCumple.month}/${proximoCumple.year}');
          return proximoCumple;
        } catch (e) {
          print('❌ Error parsing ISO date: $e');
        }
      }
      
      // Intentar diferentes formatos de fecha tradicionales
      List<String> formatosPosibles = [
        // DD/MM/YYYY
        r'(\d{1,2})\/(\d{1,2})\/(\d{4})',
        // DD-MM-YYYY  
        r'(\d{1,2})-(\d{1,2})-(\d{4})',
        // YYYY-MM-DD (formato ISO sin tiempo)
        r'(\d{4})-(\d{1,2})-(\d{1,2})',
        // DD de MM de YYYY (ej: "10 febrero 2007")
        r'(\d{1,2})\s+(\w+)\s+(\d{4})',
        // DD MM YYYY
        r'(\d{1,2})\s+(\d{1,2})\s+(\d{4})',
      ];

      for (String patron in formatosPosibles) {
        RegExp regex = RegExp(patron, caseSensitive: false);
        Match? match = regex.firstMatch(fecha);
        
        if (match != null) {
          int dia, mes;
          
          if (patron.contains('\\w+')) {
            // Formato con nombre del mes
            dia = int.parse(match.group(1)!);
            String nombreMes = match.group(2)!.toLowerCase();
            mes = _convertirNombreMes(nombreMes);
          } else if (patron.startsWith(r'(\d{4})')) {
            // Formato YYYY-MM-DD
            int anio = int.parse(match.group(1)!);
            mes = int.parse(match.group(2)!);
            dia = int.parse(match.group(3)!);
            print('📅 Fecha YYYY-MM-DD parseada: $dia/$mes/$anio');
          } else {
            // Formato DD/MM/YYYY o DD-MM-YYYY
            dia = int.parse(match.group(1)!);
            mes = int.parse(match.group(2)!);
          }
          
          // Calcular próximo cumpleaños
          DateTime proximoCumple = DateTime(hoy.year, mes, dia);
          
          // Si ya pasó este año, calcular para el siguiente
          if (proximoCumple.isBefore(hoy)) {
            proximoCumple = DateTime(hoy.year + 1, mes, dia);
          }
          
          return proximoCumple;
        }
      }
      
      print('❌ No se pudo parsear la fecha: "$fecha"');
    } catch (e) {
      print('❌ Error parsing fecha "$fecha": $e');
    }
    
    return null;
  }

  int _convertirNombreMes(String nombreMes) {
    Map<String, int> meses = {
      'enero': 1, 'january': 1,
      'febrero': 2, 'february': 2,
      'marzo': 3, 'march': 3,
      'abril': 4, 'april': 4,
      'mayo': 5, 'may': 5,
      'junio': 6, 'june': 6,
      'julio': 7, 'july': 7,
      'agosto': 8, 'august': 8,
      'septiembre': 9, 'september': 9,
      'octubre': 10, 'october': 10,
      'noviembre': 11, 'november': 11,
      'diciembre': 12, 'december': 12,
    };
    
    return meses[nombreMes.toLowerCase()] ?? 1;
  }

  Future<void> _enviarWhatsApp(Map<String, dynamic> cliente, String mensaje) async {
    try {
      String telefono = cliente['telefono']?.toString().replaceAll(RegExp(r'[^\d]'), '') ?? '';
      
      if (telefono.isEmpty) {
        _mostrarError('Este cliente no tiene número de teléfono');
        return;
      }

      // Asegurar formato internacional mexicano
      if (telefono.length == 10) {
        telefono = '52$telefono';
      }

      String mensajeEncoded = Uri.encodeComponent(mensaje);
      String url = 'https://wa.me/$telefono?text=$mensajeEncoded';

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _mostrarExito('WhatsApp abierto para ${cliente['nombre']}');
      } else {
        _mostrarError('No se pudo abrir WhatsApp');
      }
    } catch (e) {
      _mostrarError('Error enviando WhatsApp: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMensajeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC43532).withOpacity(0.1), // Nuevo rojo AutoFirme
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, color: Color(0xFFC43532)), // Nuevo rojo AutoFirme
              const SizedBox(width: 8),
              Text(
                'Seleccionar mensaje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Mensajes predeterminados
          Text(
            'Mensajes predeterminados:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          ...mensajesPredeterminados.asMap().entries.map((entry) {
            String mensaje = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                value: mensaje,
                groupValue: mensajeSeleccionado,
                onChanged: (value) {
                  setState(() {
                    mensajeSeleccionado = value!;
                    mensajePersonalizado = '';
                  });
                },
                title: Text(
                  mensaje,
                  style: TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                dense: true,
                activeColor: Color(0xFFC43532), // Nuevo rojo AutoFirme
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Mensaje personalizado
          Text(
            'O escribe tu mensaje personalizado:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje personalizado aquí...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            onChanged: (value) {
              setState(() {
                mensajePersonalizado = value;
                if (value.isNotEmpty) {
                  mensajeSeleccionado = '';
                }
              });
            },
          ),
        ],
      ),
    );
  }

  String get mensajeActual {
    return mensajePersonalizado.isNotEmpty ? mensajePersonalizado : mensajeSeleccionado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Próximos Cumpleaños', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarClientesConCumpleanos,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFE5D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Selector de mensaje
                _buildMensajeSelector(),
                
                // Lista de cumpleaños
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFC43532), // Nuevo rojo AutoFirme
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Cargando cumpleaños...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : clientesConCumpleanos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cake_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay cumpleaños próximos',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'En los próximos 60 días',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: clientesConCumpleanos.length,
                              itemBuilder: (context, index) {
                                final cliente = clientesConCumpleanos[index];
                                final diasFaltantes = cliente['diasFaltantes'] as int;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFC43532).withOpacity(0.1), // Nuevo rojo AutoFirme con transparencia
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: diasFaltantes == 0
                                        ? Border.all(color: Colors.green, width: 2)
                                        : diasFaltantes <= 7
                                            ? Border.all(color: Colors.orange, width: 1)
                                            : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar con días
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: diasFaltantes == 0
                                                ? Colors.green
                                                : diasFaltantes <= 7
                                                    ? Colors.orange
                                                    : Color(0xFFC43532), // Nuevo rojo AutoFirme
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                diasFaltantes == 0 ? 'HOY' : '$diasFaltantes',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: diasFaltantes == 0 ? 12 : 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (diasFaltantes != 0)
                                                Text(
                                                  diasFaltantes == 1 ? 'día' : 'días',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Información del cliente
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cliente['nombre'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.cake, 
                                                    size: 16, 
                                                    color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    cliente['cumpleFormateado'] ?? cliente['cumple'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (cliente['telefono']?.isNotEmpty == true)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.phone, 
                                                        size: 16, 
                                                        color: Colors.grey.shade600),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        cliente['telefono'] ?? '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Botón WhatsApp
                                        if (cliente['telefono']?.isNotEmpty == true)
                                          ElevatedButton.icon(
                                            onPressed: () => _enviarWhatsApp(cliente, mensajeActual),
                                            icon: const Icon(Icons.message, size: 18),
                                            label: const Text('WhatsApp'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF25D366), // Verde WhatsApp
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}