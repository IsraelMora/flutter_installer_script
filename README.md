# Instalador Automático del Entorno Flutter

Un script de PowerShell completamente automatizado que instala todo el entorno de desarrollo Flutter en Windows con una sola ejecución.

## 🚀 Características

- **Instalación completa**: Instala todas las herramientas necesarias para desarrollo Flutter
- **Detección inteligente**: Reconoce paquetes ya instalados y los omite
- **Manejo de errores robusto**: Logging detallado y códigos de error específicos
- **Interfaz coloreada**: Mensajes claros con colores para fácil identificación
- **Limpieza automática**: Opción para eliminar instaladores descargados
- **Temporización**: Muestra el tiempo total de instalación

## 📦 Herramientas Instaladas

### Via Winget
- **Git**: Control de versiones
- **Visual Studio Code**: Editor de código recomendado
- **Android Studio**: IDE oficial para desarrollo Android
- **Visual Studio Community**: IDE alternativo con soporte C++
- **Adoptium JDK 17**: Java Development Kit requerido

### Via Chocolatey
- **FVM (Flutter Version Manager)**: Gestor de versiones Flutter
- **Flutter LTS**: Framework de desarrollo multiplataforma

### Via Instaladores Directos
- **NVM for Windows**: Gestor de versiones Node.js
- **Node.js LTS**: Runtime JavaScript

## 🔧 Requisitos del Sistema

- **Sistema Operativo**: Windows 10/11 (64-bit)
- **Permisos**: Administrador (el script los solicita automáticamente)
- **Conexión a Internet**: Para descargar instaladores
- **Espacio en Disco**: Mínimo 5GB libres

## 📋 Instrucciones de Uso

### 🚀 Opción 1: One-Click desde GitHub (Recomendado)
```powershell
# Copie y pegue esta línea completa en PowerShell con permisos de administrador
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/IsraelMora/flutter_installer_script/main/workflow%20installer.ps1'))
```

### Opción 2: Ejecutar Archivo Descargado
```powershell
# Desde PowerShell con permisos de administrador
.\workflow installer.ps1
```

### Opción 3: Desde Explorador de Archivos
1. Haga clic derecho en `workflow installer.ps1`
2. Seleccione "Ejecutar con PowerShell"
3. Acepte la solicitud de permisos de administrador

### Opción 4: Desde Terminal
```cmd
powershell -ExecutionPolicy Bypass -File "workflow installer.ps1"
```

## 🎯 Proceso de Instalación

1. **Verificación Inicial**: Comprueba disponibilidad de Winget
2. **Solicitud de Permisos**: Eleva automáticamente a administrador si es necesario
3. **Configuración del Entorno**: Establece políticas de ejecución
4. **Instalación de Herramientas**:
   - Chocolatey (si no está instalado)
   - FVM y Flutter LTS
   - Paquetes Winget (Git, VSCode, Android Studio, etc.)
   - NVM y Node.js LTS
5. **Verificación**: Muestra resumen de instalaciones exitosas/fallidas
6. **Limpieza**: Opción para eliminar archivos temporales

## 📊 Salida del Script

### Mensajes de Estado
- `[OK]` - Instalación exitosa (verde)
- `[EXISTE]` - Ya instalado (amarillo)
- `[ERROR]` - Falló la instalación (rojo)

### Ejemplo de Salida
```
=== Inicializando instalación Flutter ===
Winget OK
Solicitando permisos admin...

--- Instalando herramientas necesarias ---
Instalando Git con Winget...
[OK] Git instalado.
Instalando Visual Studio Code con Winget...
[EXISTE] Visual Studio Code ya esta instalado.

=== Completado ===
[TIEMPO] 5m 23s

[RESULTADOS]:
[OK] Git
[EXISTE] Visual Studio Code
[OK] Android Studio
[ERROR] Visual Studio Community

¿Limpiar instaladores? (S/N)
```

## 🛠️ Solución de Problemas

### Error: "Winget no disponible"
- Instale Windows Package Manager desde Microsoft Store
- O actualice Windows a la versión más reciente

### Error: "No se puede ejecutar debido al error: El usuario ha cancelado la operación"
- El script requiere permisos de administrador
- Ejecute PowerShell como administrador manualmente

### Error: "Error de descarga"
- Verifique su conexión a internet
- Algunos instaladores pueden requerir VPN en ciertas regiones

### Paquetes ya instalados aparecen como errores
- El script ahora detecta correctamente paquetes existentes (código -1978335189)
- Si ve errores, actualice Winget: `winget upgrade --all`

## 🔍 Códigos de Error Comunes

| Código | Significado | Acción |
|--------|-------------|---------|
| 0 | Éxito | Ninguna |
| -1978335189 | Ya instalado | Ninguna (normal) |
| Otros | Error específico | Revisar logs |

## 📁 Archivos Generados

- **Directorio temporal**: `%USERPROFILE%\Downloads\FlutterInstallers\`
  - Contiene instaladores descargados
  - Se puede eliminar automáticamente al final

## ⚙️ Personalización

Para modificar qué herramientas instalar, edite la variable `$wingetPackages` en el script:

```powershell
$wingetPackages = @(
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code" },
    # Agregue o remueva paquetes aquí
)
```

## 🤝 Contribución

Para mejoras o reportes de bugs:
1. Verifique que el problema no esté ya documentado
2. Incluya logs completos del error
3. Especifique versión de Windows y PowerShell

## 📄 Licencia

Este script es de código abierto y puede ser modificado libremente para uso personal o comercial.

## ⚠️ Notas Importantes

- **Backup**: Se recomienda hacer backup de configuraciones existentes
- **Antivirus**: Algunos antivirus pueden bloquear las descargas
- **Redes corporativas**: Puede requerir configuración de proxy
- **Tiempo**: La instalación completa puede tomar 10-30 minutos dependiendo de la conexión

---

**¿Problemas?** Revise la sección de solución de problemas arriba. Para soporte adicional, incluya los logs completos de error.
