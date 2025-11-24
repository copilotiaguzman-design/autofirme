# 🏢 Autofirme Sistema

Una aplicación Flutter para el sistema de gestión empresarial de Autofirme.

**Bundle ID**: `com.autofirme.app`

## 📱 Características

- ✅ Sistema de autenticación
- ✅ Gestión de usuarios
- ✅ Control de inventario  
- ✅ Gestión de ventas
- ✅ Control de gastos
- ✅ Gestión de placas
- ✅ Módulo de recepción
- ✅ Tema corporativo personalizado
- ✅ Diseño responsivo

## 🚀 Desarrollo

### Requisitos previos
- Flutter 3.24.0+
- Dart 3.5.0+
- Xcode 15+ (para iOS)
- Android Studio (para Android)

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/autofirme_sistema.git
cd autofirme_sistema

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Comandos útiles

```bash
# Ejecutar tests
flutter test

# Generar build para Android
flutter build apk --release

# Generar build para iOS  
flutter build ios --release

# Analizar código
flutter analyze

# Formatear código
dart format .
```

## 🏗️ CI/CD con GitHub Actions

Este proyecto está configurado para compilación automática usando GitHub Actions:

- **iOS**: Compilación en macOS con certificados Apple
- **Android**: Compilación multiplataforma
- **Tests**: Ejecución automática de pruebas
- **Artifacts**: Generación de IPA/APK descargables

### Configuración requerida

Ver [GITHUB_SECRETS.md](./GITHUB_SECRETS.md) para instrucciones detalladas sobre:
- Configuración de certificados iOS
- Secretos de GitHub Actions  
- Configuración de App Store Connect API

## 📁 Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── config/                     # Configuración de la app
├── core/                       # Funcionalidades core
│   ├── theme/                  # Temas y estilos
│   └── widgets/                # Widgets reutilizables
├── modules/                    # Módulos de funcionalidad
│   ├── gastos/                 # Gestión de gastos
│   ├── inventario/             # Control de inventario
│   ├── placas/                 # Gestión de placas
│   ├── recepcion/              # Módulo de recepción
│   ├── usuarios/               # Gestión de usuarios
│   └── ventas/                 # Gestión de ventas
├── screens/                    # Pantallas principales
├── services/                   # Servicios y APIs
└── widgets/                    # Widgets específicos
```

## 🔧 Configuración

### Variables de entorno
Crear archivo `.env` en la raíz del proyecto:

```env
API_BASE_URL=https://api.autofirme.com
GOOGLE_SHEETS_API_KEY=tu_api_key_aqui
```

### Configuración de Firebase (opcional)
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## 🚀 Despliegue

### iOS (App Store)
1. Configurar certificados en GitHub Secrets
2. Push a rama `main` triggers automático build
3. IPA se genera como artifact
4. Subida automática a TestFlight (opcional)

### Android (Play Store)  
1. Configurar keystore de firma
2. Build automático en GitHub Actions
3. APK/AAB disponible como artifact

## 📚 Recursos

- [Documentación Flutter](https://docs.flutter.dev/)
- [Guías de estilo](https://dart.dev/guides/language/effective-dart/style)
- [Estado de la aplicación](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

## 🤝 Contribución

1. Fork del repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto es privado y propietario de Autofirme.

---

**Desarrollado con ❤️ para Autofirme**
