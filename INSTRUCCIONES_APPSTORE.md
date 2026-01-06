# 📋 PASOS OBLIGATORIOS ANTES DE HACER PUSH

## ✅ 1. Crear la App en App Store Connect
Debes ir a: `https://appstoreconnect.apple.com/apps`

### Información que necesitas:
- **Bundle ID:** `com.autofirme.app` (ya configurado)
- **Name:** AutoFirme Sistema
- **Primary Language:** Spanish (Spain) 
- **SKU:** `autofirme-sistema-2026` (ID único específico)

### Datos mínimos requeridos:
- **App Privacy:** Usar política en privacy_policy.html
- **Age Rating:** 4+ (Business use)
- **App Review Information:** Ver APP_STORE_METADATA.md para detalles completos
- **Version Information:** Descripción detallada, screenshots de calidad, etc.
- **Demo Account:** brandon@gmail.com / admin123 (para revisión de Apple)

## ⚠️ IMPORTANTE
**SIN ESTOS PASOS, EL UPLOAD FALLARÁ** porque Apple necesita que la app esté registrada primero en App Store Connect.

## 🚀 Después de crear la app
1. Haz push de los cambios
2. Ve a GitHub Actions 
3. El workflow automáticamente:
   - ✅ Compilará la app
   - ✅ Creará el archive
   - ✅ Exportará el IPA  
   - ✅ Subirá directamente a App Store Connect

**¡Ya no necesitas Mac para nada!** 🎉