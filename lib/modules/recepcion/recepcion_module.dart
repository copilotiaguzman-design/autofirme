import 'package:flutter/material.dart';
import 'dart:async';
import 'formulario_screen.dart';
import 'lista_clientes_screen.dart';
import 'cumpleanos_screen.dart';
import '../../services/google_sheets_service.dart';
import '../../core/exports.dart';

class RecepcionModule extends StatefulWidget {
  const RecepcionModule({Key? key}) : super(key: key);

  @override
  _RecepcionModuleState createState() => _RecepcionModuleState();
}

class _RecepcionModuleState extends State<RecepcionModule> {
  int _selectedIndex = 0;
  List<Map<String, String>> clientesLocales = [];
  bool isLoading = false;
  bool datosLoaded = false; // Para saber si ya cargamos los datos

  @override
  void initState() {
    super.initState();
    // Iniciar carga de datos SIN esperar (fire and forget)
    unawaited(_cargarClientesEnBackground());
  }

  // Cargar datos en background sin bloquear la UI
  Future<void> _cargarClientesEnBackground() async {
    if (datosLoaded) return; // Si ya cargamos, no hacemos nada
    
    // NO bloquear la UI con setState aquí
    // La UI se muestra inmediatamente vacía
    
    try {
      // Cargar datos sin mostrar loading inicialmente
      final clientes = await GoogleSheetsService.obtenerClientes();
      
      if (!mounted) return;
      setState(() {
        clientesLocales = clientes;
        isLoading = false;
        datosLoaded = true; // Marcamos que ya tenemos datos
      });
      
      print('✅ RecepcionModule: Datos cargados: ${clientes.length} clientes');
      print('📋 Lista actual: ${clientesLocales.map((c) => c['nombre']).join(', ')}');
    } catch (e) {
      print('❌ Error al cargar clientes: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      
      // Mostrar snackbar con error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Solo recargar cuando el usuario lo solicite explícitamente
  Future<void> _refrescarDatos() async {
    setState(() {
      isLoading = true;
      datosLoaded = false; // Resetear para forzar carga
    });

    await _cargarClientesEnBackground();
  }

  void _onClienteAgregado(Map<String, String> cliente) {
    // Agregar el cliente a la lista local y refrescar datos
    setState(() {
      clientesLocales.add(cliente);
    });
    _refrescarDatos(); // Refrescar datos cuando se agrega un cliente
  }

  int _contarCumpleanosProximos() {
    int count = 0;
    final DateTime hoy = DateTime.now();
    for (var cliente in clientesLocales) {
      if (cliente['cumple'] != null && cliente['cumple']!.isNotEmpty) {
        try {
          DateTime fechaCumpleanos = DateTime.parse(cliente['cumple']!);
          DateTime cumpleanosEsteAno = DateTime(hoy.year, fechaCumpleanos.month, fechaCumpleanos.day);
          
          if (cumpleanosEsteAno.isBefore(DateTime(hoy.year, hoy.month, hoy.day))) {
            cumpleanosEsteAno = DateTime(hoy.year + 1, fechaCumpleanos.month, fechaCumpleanos.day);
          }
          
          int diasFaltantes = cumpleanosEsteAno.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
          if (diasFaltantes <= 7) count++;
        } catch (e) {
          // Ignorar errores de parsing
        }
      }
    }
    return count;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Los datos ya están cargados, no necesitamos recargar
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      FormularioScreen(onClienteAgregado: _onClienteAgregado),
      ListaClientesScreen(
        clientesLocales: clientesLocales,
        onRefresh: _refrescarDatos,
      ),
      CumpleanosScreen(
        clientes: clientesLocales,
        onRefresh: _refrescarDatos,
      ),
    ];

    return Scaffold(
      backgroundColor: CorporateTheme.backgroundLight,
      appBar: CorporateAppBar(
        title: 'Recepción de Clientes',
        showLoadingIndicator: isLoading,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: CorporateTheme.primaryBlue,
        unselectedItemColor: CorporateTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          _buildNavItem(
            icon: Icons.person_add,
            label: 'Registro',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.people,
            label: 'Clientes',
            index: 1,
            badge: clientesLocales.length > 0 ? '${clientesLocales.length}' : null,
          ),
          _buildNavItem(
            icon: Icons.cake,
            label: 'Cumpleaños',
            index: 2,
            badge: _contarCumpleanosProximos() > 0 
                ? '${_contarCumpleanosProximos()}' 
                : null,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    String? badge,
  }) {
    final isSelected = _selectedIndex == index;
    
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(CorporateTheme.spacingSM),
        decoration: BoxDecoration(
          color: isSelected 
              ? CorporateTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(CorporateTheme.spacingSM),
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? CorporateTheme.primaryBlue
                  : CorporateTheme.textSecondary,
              size: CorporateTheme.iconSizeMedium,
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: CorporateTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: label,
    );
  }
}