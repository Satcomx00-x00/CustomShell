# CustomShell PowerShell Install Script
# Installs Starship shell

param(
    [switch]$Force,
    [switch]$SkipConfirmation
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Cyan"
$White = "White"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $White
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "[INFO] $Message" $Blue
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" $Green
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[WARNING] $Message" $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "[ERROR] $Message" $Red
}

# Detect platform
function Get-Platform {
    if ($PSVersionTable.Platform -eq "Win32NT" -or $env:OS -eq "Windows_NT") {
        return "windows"
    } elseif ($PSVersionTable.Platform -eq "Unix") {
        if ($env:OSTYPE -eq "linux-gnu" -or (Test-Path "/etc/os-release")) {
            return "linux"
        } elseif ((Test-Path "/usr/bin/sw_vers") -or $env:OSTYPE -eq "darwin") {
            return "macos"
        }
    }
    return "unknown"
}

# Get architecture
function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq "AMD64") {
        return "amd64"
    } elseif ($arch -eq "x86") {
        return "386"
    } elseif ($arch -eq "ARM64") {
        return "arm64"
    }
    # For Unix systems
    try {
        $uname = uname -m 2>$null
        if ($uname) {
            switch ($uname) {
                "x86_64" { return "amd64" }
                "i386" { return "386" }
                "i686" { return "386" }
                "aarch64" { return "arm64" }
                "armv7l" { return "arm" }
            }
        }
    } catch {}
    return "amd64" # default
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Download file
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    Write-Info "Downloading $Url to $OutputPath"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        return $true
    } catch {
        Write-Error "Failed to download $Url"
        return $false
    }
}

# Install Starship
function Install-Starship {
    if (Test-Command "starship") {
        Write-Info "Starship is already installed"
        return $true
    }

    Write-Info "Installing Starship..."

    try {
        # Use the official Starship installer
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/starship/starship/master/install/install.ps1')
        Write-Success "Starship installed successfully"
        return $true
    } catch {
        Write-Error "Failed to install Starship: $_"
        return $false
    }
}




# Main installation function
function Install-Dependencies {
    Write-Info "Starting Starship installation..."
    Write-Info "Platform: $(Get-Platform), Architecture: $(Get-Architecture)"

    if (-not $SkipConfirmation) {
        $confirm = Read-Host "This will install Starship shell. Continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Info "Installation cancelled"
            return
        }
    }

    $tools = @(
        @{Name = "starship"; Installer = ${function:Install-Starship}}
    )

    $installed = 0
    $total = $tools.Count

    foreach ($tool in $tools) {
        try {
            if (& $tool.Installer) {
                $installed++
            }
        } catch {
            Write-Error "Failed to install $($tool.Name): $_"
        }
    }

    Write-Success "Installation complete: $installed/$total tools installed"

    Write-Info "Post-installation notes:"
    Write-Info "  - Restart your shell or reload PATH to use Starship"
    Write-Info "  - To enable Starship, add 'Invoke-Expression (&starship init powershell)' to your PowerShell profile"
    Write-Info "  - For verification: Run 'starship --version'"
}

# Run the installation
Install-Dependencies