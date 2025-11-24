# Script para convertir certificado iOS a base64 para GitHub Actions
# Requiere que tengas OpenSSL instalado

# Rutas de archivos
$certFile = "ios_distribution.cer"
$keyFile = "ios_private_key.key"
$p12File = "ios_certificate.p12"
$base64File = "ios_certificate_base64.txt"

# Contraseña para el archivo p12 (usa una contraseña segura)
$p12Password = "AutofirmeSecure2024"

Write-Host "🔐 Convirtiendo certificado iOS para GitHub Actions..." -ForegroundColor Green

# Verificar que los archivos existen
if (-not (Test-Path $certFile)) {
    Write-Error "❌ No se encuentra el archivo: $certFile"
    exit 1
}

if (-not (Test-Path $keyFile)) {
    Write-Error "❌ No se encuentra el archivo: $keyFile"
    exit 1
}

Write-Host "✅ Archivos encontrados:" -ForegroundColor Green
Write-Host "   📜 Certificado: $certFile" -ForegroundColor Cyan
Write-Host "   🔑 Clave privada: $keyFile" -ForegroundColor Cyan

# Instrucciones para usar OpenSSL
Write-Host "`n📋 INSTRUCCIONES:" -ForegroundColor Yellow
Write-Host "1️⃣ Instala OpenSSL desde: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor White
Write-Host "2️⃣ O usa Git Bash que incluye OpenSSL" -ForegroundColor White
Write-Host "3️⃣ Ejecuta este comando:" -ForegroundColor White
Write-Host "`nopenssl pkcs12 -export -out $p12File -inkey $keyFile -in $certFile -password pass:$p12Password`n" -ForegroundColor Magenta

Write-Host "4️⃣ Luego ejecuta este comando para generar base64:" -ForegroundColor White
Write-Host "powershell -Command `"[Convert]::ToBase64String([IO.File]::ReadAllBytes('$p12File')) | Out-File -FilePath '$base64File' -Encoding ascii`"`n" -ForegroundColor Magenta

Write-Host "🔐 Información para GitHub Secrets:" -ForegroundColor Green
Write-Host "   📦 Archivo P12: $p12File" -ForegroundColor Cyan
Write-Host "   🔒 Contraseña P12: $p12Password" -ForegroundColor Cyan
Write-Host "   📝 Base64: $base64File" -ForegroundColor Cyan

Write-Host "`n⚠️  IMPORTANTE: Guarda la contraseña '$p12Password' como secreto IOS_CERTIFICATE_PASSWORD en GitHub" -ForegroundColor Red