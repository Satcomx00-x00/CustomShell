# CustomShell PowerShell Install Script
# Installs Kubernetes tools and dependencies

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

# Install kubectl
function Install-Kubectl {
    if (Test-Command "kubectl") {
        Write-Info "kubectl is already installed"
        return $true
    }

    Write-Info "Installing kubectl..."

    $platform = Get-Platform
    $arch = Get-Architecture

    if ($platform -eq "windows") {
        $kubectlUrl = "https://dl.k8s.io/release/$(curl.exe -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/$arch/kubectl.exe"
        $kubectlPath = "$env:TEMP\kubectl.exe"
    } else {
        $kubectlUrl = "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$platform/$arch/kubectl"
        $kubectlPath = "/tmp/kubectl"
    }

    if (-not (Download-File $kubectlUrl $kubectlPath)) {
        return $false
    }

    # Install kubectl
    if ($platform -eq "windows") {
        $installPath = "$env:ProgramFiles\kubectl\kubectl.exe"
        if (-not (Test-Path "$env:ProgramFiles\kubectl")) {
            New-Item -ItemType Directory -Path "$env:ProgramFiles\kubectl" -Force | Out-Null
        }
        Move-Item $kubectlPath $installPath -Force
        # Add to PATH if not already there
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*kubectl*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$env:ProgramFiles\kubectl", "Machine")
        }
    } else {
        chmod +x $kubectlPath
        sudo mv $kubectlPath /usr/local/bin/kubectl
    }

    Write-Success "kubectl installed successfully"
    return $true
}

# Install talosctl
function Install-Talosctl {
    if (Test-Command "talosctl") {
        Write-Info "talosctl is already installed"
        return $true
    }

    Write-Info "Installing talosctl..."

    $platform = Get-Platform
    $arch = Get-Architecture

    if ($platform -eq "windows") {
        # Use PowerShell to download and run the install script
        try {
            $installScript = Invoke-WebRequest -Uri "https://talos.dev/install.ps1" -UseBasicParsing
            Invoke-Expression $installScript.Content
        } catch {
            Write-Error "Failed to install talosctl via install script"
            return $false
        }
    } else {
        # Use bash install script
        try {
            curl -sL https://talos.dev/install | sh
        } catch {
            Write-Error "Failed to install talosctl via install script"
            return $false
        }
    }

    Write-Success "talosctl installed successfully"
    return $true
}

# Install Helm
function Install-Helm {
    if (Test-Command "helm") {
        Write-Info "helm is already installed"
        return $true
    }

    Write-Info "Installing Helm..."

    $platform = Get-Platform
    $arch = Get-Architecture

    if ($platform -eq "windows") {
        $helmUrl = "https://get.helm.sh/helm-v3.12.0-windows-$arch.zip"
        $helmZip = "$env:TEMP\helm.zip"
        $helmExtractPath = "$env:TEMP\helm"
    } else {
        $helmUrl = "https://get.helm.sh/helm-v3.12.0-$platform-$arch.tar.gz"
        $helmTar = "/tmp/helm.tar.gz"
        $helmExtractPath = "/tmp/helm"
    }

    if ($platform -eq "windows") {
        if (-not (Download-File $helmUrl $helmZip)) { return $false }
        Expand-Archive $helmZip $helmExtractPath -Force
        $helmExe = "$helmExtractPath\windows-$arch\helm.exe"
        $installPath = "$env:ProgramFiles\Helm\helm.exe"
        if (-not (Test-Path "$env:ProgramFiles\Helm")) {
            New-Item -ItemType Directory -Path "$env:ProgramFiles\Helm" -Force | Out-Null
        }
        Move-Item $helmExe $installPath -Force
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*Helm*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$env:ProgramFiles\Helm", "Machine")
        }
        Remove-Item $helmZip, $helmExtractPath -Recurse -Force
    } else {
        if (-not (Download-File $helmUrl $helmTar)) { return $false }
        tar -zxvf $helmTar -C /tmp
        sudo mv /tmp/$platform-$arch/helm /usr/local/bin/helm
        sudo chmod +x /usr/local/bin/helm
        rm -rf /tmp/$platform-$arch $helmTar
    }

    Write-Success "Helm installed successfully"
    return $true
}

# Install k9s
function Install-K9s {
    if (Test-Command "k9s") {
        Write-Info "k9s is already installed"
        return $true
    }

    Write-Info "Installing k9s..."

    $platform = Get-Platform
    $arch = Get-Architecture

    # Get latest release
    try {
        $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/derailed/k9s/releases/latest"
        $version = $releaseInfo.tag_name
    } catch {
        Write-Warning "Could not get latest version, using fallback"
        $version = "v0.27.3"
    }

    if ($platform -eq "windows") {
        $k9sUrl = "https://github.com/derailed/k9s/releases/download/$version/k9s_Windows_$arch.tar.gz"
        $k9sTar = "$env:TEMP\k9s.tar.gz"
        $k9sExtractPath = "$env:TEMP\k9s"
    } else {
        $k9sUrl = "https://github.com/derailed/k9s/releases/download/$version/k9s_${platform}_$arch.tar.gz"
        $k9sTar = "/tmp/k9s.tar.gz"
        $k9sExtractPath = "/tmp/k9s"
    }

    if (-not (Download-File $k9sUrl $k9sTar)) { return $false }

    if ($platform -eq "windows") {
        # Windows tar command might not be available, use Expand-Archive if it's a zip
        # For now, assume tar is available or use 7zip if available
        Write-Warning "k9s installation on Windows requires manual extraction. Please extract $k9sTar and add k9s.exe to PATH"
        return $false
    } else {
        tar -zxvf $k9sTar -C $k9sExtractPath
        sudo mv $k9sExtractPath/k9s /usr/local/bin/k9s
        sudo chmod +x /usr/local/bin/k9s
        rm -rf $k9sExtractPath $k9sTar
    }

    Write-Success "k9s installed successfully"
    return $true
}

# Main installation function
function Install-Dependencies {
    Write-Info "Starting Kubernetes tools installation..."
    Write-Info "Platform: $(Get-Platform), Architecture: $(Get-Architecture)"

    if (-not $SkipConfirmation) {
        $confirm = Read-Host "This will install Kubernetes tools. Continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Info "Installation cancelled"
            return
        }
    }

    $tools = @(
        @{Name = "kubectl"; Installer = ${function:Install-Kubectl}},
        @{Name = "talosctl"; Installer = ${function:Install-Talosctl}},
        @{Name = "helm"; Installer = ${function:Install-Helm}},
        @{Name = "k9s"; Installer = ${function:Install-K9s}}
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
    Write-Info "  - Restart your shell or reload PATH to use the new tools"
    Write-Info "  - For kubectl: Run 'kubectl version --client' to verify"
    Write-Info "  - For talosctl: Run 'talosctl version' to verify"
    Write-Info "  - For helm: Run 'helm version' to verify"
    Write-Info "  - For k9s: Run 'k9s --version' to verify"
}

# Run the installation
Install-Dependencies