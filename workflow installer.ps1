# Instalador automático del entorno Flutter - Requiere admin

Write-Host "=== Inicializando instalación Flutter ===" -ForegroundColor Cyan

try { winget --version | Out-Null; Write-Host "Winget OK" -ForegroundColor Green }
catch { Write-Host "Winget no disponible" -ForegroundColor Yellow }


if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permisos admin..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$startTime = Get-Date
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
$downloadDir = "$env:USERPROFILE\Downloads\FlutterInstallers"
if (!(Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir | Out-Null }

# Funciones auxiliares
function Write-Step {
    param ([string]$Message)
    Write-Host "`n--- $Message ---" -ForegroundColor Magenta
}

function Install-WingetPackage {
    param ([string]$PackageId, [string]$PackageName)
    Write-Host "Instalando $PackageName con Winget..." -ForegroundColor Blue
    try {
        winget install --id $PackageId -e --source winget
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] $PackageName instalado." -ForegroundColor Green
            $script:installResults[$PackageName] = "Instalado"
        }
        elseif ($LASTEXITCODE -eq -1978335189) {
            Write-Host "[EXISTE] $PackageName ya esta instalado." -ForegroundColor Yellow
            $script:installResults[$PackageName] = "Existente"
        }
        else {
            Write-Host "[ERROR] $PackageName (Codigo: $LASTEXITCODE)" -ForegroundColor Red
            $script:installResults[$PackageName] = "Error"
        }
    }
    catch {
        Write-Host "[ERROR CRITICO] $PackageName`: $($_.Exception.Message)" -ForegroundColor Red
        $script:installResults[$PackageName] = "Error critico"
    }
}

function Install-Software {
    param ([string]$Url, [string]$InstallerPath, [string]$SoftwareName)
    Write-Step "Instalando $SoftwareName"

    if (Test-Path $InstallerPath) {
        Write-Host "Instalador existente encontrado." -ForegroundColor Yellow
        $script:installResults[$SoftwareName] = "Existente"
    }
    else {
        Write-Host "Descargando..." -ForegroundColor Blue
        try {
            Invoke-WebRequest -Uri $Url -OutFile $InstallerPath
        }
        catch {
            Write-Host "[ERROR DESCARGA] $($_.Exception.Message)" -ForegroundColor Red
            $script:installResults[$SoftwareName] = "Error descarga"
            return
        }
    }

    Write-Host "Instalando..." -ForegroundColor Blue
    try {
        
        Start-Process -FilePath $InstallerPath -Wait -NoNewWindow
        
        Write-Host "[OK] $SoftwareName instalado." -ForegroundColor Green
        $script:installResults[$SoftwareName] = "Instalado"
    }
    catch {
        Write-Host "[ERROR INSTALACION] $($_.Exception.Message)" -ForegroundColor Red
        $script:installResults[$SoftwareName] = "Error instalación"
    }
}

# Variables
$fixedUrls = @{ NVM = "https://github.com/coreybutler/nvm-windows/releases/latest/download/nvm-setup.exe" }
$nvmPath = "$downloadDir\nvm-installer.exe"

# Paquetes Winget a instalar
$wingetPackages = @(
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code" },
    @{ Id = "Google.AndroidStudio"; Name = "Android Studio" },
    @{ Id = "Microsoft.VisualStudio.2022.Community"; Name = "Visual Studio Community" },
    @{ Id = "EclipseAdoptium.Temurin.17.JDK"; Name = "Adoptium JDK 17" }
)

# Tracking de instalaciones
$installResults = @{}

# Instalación de herramientas
Write-Step "Instalando herramientas necesarias"

# Instalar Chocolatey si no está instalado
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Chocolatey..." -ForegroundColor Blue
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    catch {
        Write-Host "Error instalando Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Instalar FVM con Chocolatey
Write-Host "Instalando FVM..." -ForegroundColor Blue
try {
    choco install fvm -y
    Write-Host "FVM instalado correctamente." -ForegroundColor Green

    # Instalar la versión estable de Flutter
    Write-Host "Instalando Flutter LTS con FVM..." -ForegroundColor Blue
    fvm install stable
    fvm global stable
    Write-Host "Flutter LTS instalado correctamente." -ForegroundColor Green
}
catch {
    Write-Host "Error instalando FVM o Flutter: $($_.Exception.Message)" -ForegroundColor Red
}

# Instalar paquetes Winget en bucle
foreach ($package in $wingetPackages) {
    Install-WingetPackage -PackageId $package.Id -PackageName $package.Name
}

# Instalar NVM para Windows
Install-Software -Url $fixedUrls.NVM -InstallerPath $nvmPath -SoftwareName "NVM for Windows"

# Instalar Node.js LTS con NVM
Write-Host "Instalando Node.js LTS con NVM..." -ForegroundColor Blue
try {
    nvm install lts
    nvm use lts
    Write-Host "[OK] Node.js LTS instalado." -ForegroundColor Green
    $installResults["Node.js LTS"] = "Instalado"
}
catch {
    Write-Host "[ERROR] Node.js LTS: $($_.Exception.Message)" -ForegroundColor Red
    $installResults["Node.js LTS"] = "Error"
}

$endTime = Get-Date
$totalTime = $endTime - $startTime

Write-Host "`n=== Completado ===" -ForegroundColor Green
Write-Host "[TIEMPO] $($totalTime.Minutes)m $($totalTime.Seconds)s" -ForegroundColor Cyan

Write-Host "`n[RESULTADOS]:" -ForegroundColor Cyan
foreach ($tool in $installResults.Keys) {
    $status = $installResults[$tool]
    $prefix = switch ($status) {
        "Instalado" { "[OK]" }
        "Existente" { "[EXISTE]" }
        default { "[ERROR]" }
    }
    $color = if ($status -eq "Instalado") { "Green" } elseif ($status -eq "Existente") { "Yellow" } else { "Red" }
    Write-Host "$prefix $tool" -ForegroundColor $color
}

$cleanup = Read-Host "`n¿Limpiar instaladores? (S/N)"
if ($cleanup -eq "S" -or $cleanup -eq "s") {
    if (Test-Path $downloadDir) { Remove-Item $downloadDir -Recurse -Force; Write-Host "[LIMPIO]" -ForegroundColor Green }
}

pause
