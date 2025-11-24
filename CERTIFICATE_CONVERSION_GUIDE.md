# 🔐 GUÍA COMPLETA: Convertir Certificado iOS para GitHub Actions

## 📁 Archivos que tienes:
- ✅ ios_distribution.cer (certificado de Apple)
- ✅ ios_private_key.key (clave privada)
- ✅ ios_cert.csr (Certificate Signing Request original)

## 🛠️ OPCIÓN 1: Usar OpenSSL (Recomendado)

### Paso 1: Instalar OpenSSL
**Descarga e instala desde:** https://slproweb.com/products/Win32OpenSSL.html
- Elige la versión "Win64 OpenSSL v3.x.x Light"
- Instala en la ruta predeterminada

### Paso 2: Abrir Command Prompt como Administrador
1. Presiona `Win + X`
2. Selecciona "Windows PowerShell (Administrador)" o "Command Prompt (Admin)"
3. Navega a tu proyecto: `cd "D:\Proyectos\autofirme_sistema"`

### Paso 3: Ejecutar comandos OpenSSL

```bash
# 1. Convertir .cer + .key a .p12
"C:\Program Files\OpenSSL-Win64\bin\openssl.exe" pkcs12 -export -out ios_certificate.p12 -inkey ios_private_key.key -in ios_distribution.cer -password pass:AutofirmeSecure2024

# 2. Convertir .p12 a base64
powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('ios_certificate.p12')) | Out-File -FilePath 'ios_certificate_base64.txt' -Encoding ascii"
```

## 🛠️ OPCIÓN 2: Usar herramientas online (Si OpenSSL falla)

### Sitios confiables para conversión:
1. **SSL Converter**: https://www.sslshopper.com/ssl-converter.html
2. **DigiCert**: https://www.digicert.com/ssl-converter/

**Pasos:**
1. Ve a uno de estos sitios
2. Sube tu archivo .cer
3. Pega el contenido de tu archivo .key
4. Descarga el archivo .p12 generado
5. Convierte a base64 con PowerShell:
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes('downloaded_certificate.p12')) | Out-File -FilePath 'ios_certificate_base64.txt' -Encoding ascii
   ```

## 📋 INFORMACIÓN PARA GITHUB SECRETS

Una vez que tengas el archivo base64, necesitarás estos secretos en GitHub:

### En tu repositorio GitHub:
`Settings` > `Secrets and variables` > `Actions` > `New repository secret`

| Nombre del Secreto | Valor |
|-------------------|--------|
| `IOS_CERTIFICATE_BASE64` | Contenido completo del archivo `ios_certificate_base64.txt` |
| `IOS_CERTIFICATE_PASSWORD` | `AutofirmeSecure2024` |
| `APPLE_TEAM_ID` | Tu Team ID de Apple Developer (10 caracteres) |

## 🎯 PRÓXIMOS PASOS

1. ✅ Convierte el certificado (usando una de las opciones arriba)
2. ✅ Obtén tu Apple Team ID de https://developer.apple.com/account/#/membership/
3. ✅ Configura los secretos en GitHub
4. ✅ ¡El workflow automático comenzará a funcionar!

## ❓ ¿Necesitas ayuda?

- Si OpenSSL no funciona, usa la Opción 2 (herramientas online)
- Si tienes problemas con los secretos, avísame
- Si necesitas encontrar tu Team ID, te ayudo

---
**🔒 Nota de Seguridad:** Nunca subas archivos .p12, .key o certificados directamente al repositorio. Solo como secretos encriptados en GitHub.