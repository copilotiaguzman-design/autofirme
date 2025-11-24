# GitHub Secrets Configuration

Para que el workflow de GitHub Actions funcione correctamente y pueda compilar la aplicación iOS, necesitas configurar los siguientes secretos en tu repositorio de GitHub:

## 🔐 Secretos Requeridos

Ve a `Settings` > `Secrets and variables` > `Actions` en tu repositorio de GitHub y agrega:

### Certificados iOS
- **`IOS_CERTIFICATE_BASE64`**: Tu certificado .p12 convertido a base64
- **`IOS_CERTIFICATE_PASSWORD`**: Contraseña del certificado .p12

### Apple Developer
- **`APPLE_TEAM_ID`**: Tu Team ID de Apple Developer (10 caracteres)
- **`APPSTORE_ISSUER_ID`**: Issuer ID de tu API Key de App Store Connect
- **`APPSTORE_KEY_ID`**: Key ID de tu API Key de App Store Connect  
- **`APPSTORE_PRIVATE_KEY`**: Contenido completo de tu archivo .p8 de API Key

### Apple ID (Opcional - para subir a TestFlight)
- **`APPLE_ID_EMAIL`**: Tu Apple ID email
- **`APPLE_ID_PASSWORD`**: App-specific password de tu Apple ID

## 📋 Cómo obtener estos valores:

### 1. Certificado (.p12)
```bash
# Convierte tu certificado .cer a .p12 y luego a base64:
openssl pkcs12 -export -out certificate.p12 -inkey private-key.pem -in certificate.cer
base64 -i certificate.p12 -o certificate-base64.txt
```

### 2. Team ID
- Ve a https://developer.apple.com/account/#/membership/
- Tu Team ID está en la sección "Membership Information"

### 3. App Store Connect API Key
- Ve a https://appstoreconnect.apple.com/access/api
- Crea una nueva API Key con rol "Developer"
- Descarga el archivo .p8
- Copia el contenido completo del archivo .p8 al secret `APPSTORE_PRIVATE_KEY`

### 4. Provisioning Profile
El workflow descargará automáticamente el provisioning profile usando la API de App Store Connect.

## 🚀 Pasos para configurar:

1. Sube tu código a GitHub
2. Configura todos los secretos listados arriba
3. El workflow se ejecutará automáticamente en push a `main` o `develop`
4. Los archivos IPA se generarán como artifacts descargables

## 📱 Resultado esperado:

- ✅ Compilación automática en cada push
- ✅ Generación de archivo .ipa
- ✅ Subida opcional a TestFlight
- ✅ Artifacts descargables por 30 días