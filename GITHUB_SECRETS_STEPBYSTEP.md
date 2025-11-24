# 🔐 CONFIGURACIÓN DE SECRETOS EN GITHUB - PASO A PASO

## ✅ ARCHIVOS PREPARADOS:
- 📦 `ios_certificate.p12` - Certificado en formato P12
- 📝 `ios_certificate_base64.txt` - Certificado en base64 para GitHub
- 🔒 Contraseña: `AutofirmeSecure2024`

## 🚀 PASOS PARA CONFIGURAR EN GITHUB:

### 1️⃣ Ir a la configuración de secretos
1. Ve a tu repositorio: https://github.com/copilotiaguzman-design/autofirme
2. Haz clic en **"Settings"** (Configuración)
3. En el menú izquierdo, busca **"Secrets and variables"**
4. Haz clic en **"Actions"**

### 2️⃣ Agregar el certificado base64
1. Haz clic en **"New repository secret"**
2. **Name:** `IOS_CERTIFICATE_BASE64`
3. **Secret:** Copia y pega TODO el contenido del archivo `ios_certificate_base64.txt`
   - Abre el archivo `ios_certificate_base64.txt`
   - Selecciona TODO (Ctrl+A)
   - Copia (Ctrl+C)
   - Pega en el campo Secret
4. Haz clic en **"Add secret"**

### 3️⃣ Agregar la contraseña del certificado
1. Haz clic en **"New repository secret"** otra vez
2. **Name:** `IOS_CERTIFICATE_PASSWORD`
3. **Secret:** `AutofirmeSecure2024`
4. Haz clic en **"Add secret"**

### 4️⃣ Agregar tu Team ID de Apple Developer
1. Ve a https://developer.apple.com/account/#/membership/
2. Busca tu **Team ID** (10 caracteres alfanuméricos)
3. En GitHub, haz clic en **"New repository secret"**
4. **Name:** `APPLE_TEAM_ID`
5. **Secret:** Tu Team ID (ej: `1234567890`)
6. Haz clic en **"Add secret"**

### 5️⃣ Secretos para App Store Connect API (OPCIONAL - para subir automáticamente)

Si quieres que GitHub suba automáticamente a TestFlight:

1. **APPSTORE_ISSUER_ID**
   - Ve a https://appstoreconnect.apple.com/access/api
   - Copia el "Issuer ID"
   
2. **APPSTORE_KEY_ID**  
   - Crea una nueva API Key en App Store Connect
   - Copia el "Key ID"
   
3. **APPSTORE_PRIVATE_KEY**
   - Descarga el archivo .p8
   - Abre con Notepad
   - Copia TODO el contenido (incluye -----BEGIN PRIVATE KEY----- y -----END PRIVATE KEY-----)

## ✅ VERIFICACIÓN FINAL

Al final deberías tener estos secretos configurados:

| Nombre | Estado | Descripción |
|--------|---------|-------------|
| `IOS_CERTIFICATE_BASE64` | ✅ REQUERIDO | Certificado en base64 |
| `IOS_CERTIFICATE_PASSWORD` | ✅ REQUERIDO | Contraseña: AutofirmeSecure2024 |
| `APPLE_TEAM_ID` | ✅ REQUERIDO | Tu Team ID de Apple Developer |
| `APPSTORE_ISSUER_ID` | 🔶 OPCIONAL | Para subidas automáticas a TestFlight |
| `APPSTORE_KEY_ID` | 🔶 OPCIONAL | Para subidas automáticas a TestFlight |
| `APPSTORE_PRIVATE_KEY` | 🔶 OPCIONAL | Para subidas automáticas a TestFlight |

## 🎯 RESULTADO ESPERADO

Una vez configurados los secretos REQUERIDOS:
- ✅ GitHub Actions compilará tu app automáticamente en cada push a `main`
- ✅ Se generará un archivo .ipa descargable
- ✅ Los tests se ejecutarán automáticamente
- ✅ Solo se ejecutará cuando tengas certificados válidos

## ❓ ¿NECESITAS AYUDA?

1. **¿No encuentras tu Team ID?** - Búscalo en https://developer.apple.com/account/#/membership/
2. **¿El base64 es muy largo?** - Es normal, puede tener miles de caracteres
3. **¿Errores en el workflow?** - Revisa que todos los secretos REQUERIDOS estén configurados

---
**🚀 ¡Una vez configurado, haz un push y verás tu app compilándose automáticamente!**