#!/bin/bash

# Package Installation Script for Custom Starship Zsh Shell
# This script handles the installation of system dependencies across multiple Linux distributions
# Supports: Debian/Ubuntu (apt), RHEL/CentOS/Fedora (dnf/yum), Arch (pacman),
#           openSUSE (zypper), Alpine (apk), Gentoo (emerge)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if sudo is needed
get_sudo() {
    if [[ $EUID -eq 0 ]]; then
        echo ""
    else
        echo "sudo"
    fi
}

# Detect package manager and distribution
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v apk &> /dev/null; then
        echo "apk"
    elif command -v emerge &> /dev/null; then
        echo "emerge"
    else
        echo "unknown"
    fi
}

# Update package list
update_package_list() {
    local pm=$1
    local sudo_cmd=$(get_sudo)
    log_info "Updating package list..."
    case $pm in
        apt)
            $sudo_cmd apt-get update
            ;;
        yum)
            $sudo_cmd yum check-update || true
            ;;
        dnf)
            $sudo_cmd dnf check-update || true
            ;;
        pacman)
            $sudo_cmd pacman -Sy
            ;;
        zypper)
            $sudo_cmd zypper refresh
            ;;
        apk)
            $sudo_cmd apk update
            ;;
        emerge)
            $sudo_cmd emerge --sync
            ;;
        *)
            log_error "Unsupported package manager: $pm"
            exit 1
            ;;
    esac
}

# Install packages
install_packages() {
    local pm=$1
    shift
    local packages=("$@")
    local sudo_cmd=$(get_sudo)

    log_info "Installing packages: ${packages[*]}"
    case $pm in
        apt)
            $sudo_cmd apt-get install -y "${packages[@]}"
            ;;
        yum)
            $sudo_cmd yum install -y "${packages[@]}"
            ;;
        dnf)
            $sudo_cmd dnf install -y "${packages[@]}"
            ;;
        pacman)
            $sudo_cmd pacman -S --noconfirm "${packages[@]}"
            ;;
        zypper)
            $sudo_cmd zypper install -y "${packages[@]}"
            ;;
        apk)
            $sudo_cmd apk add "${packages[@]}"
            ;;
        emerge)
            $sudo_cmd emerge "${packages[@]}"
            ;;
        *)
            log_error "Unsupported package manager: $pm"
            exit 1
            ;;
    esac
}

# Get package names for different distributions
get_packages() {
    local pm=$1
    local packages=()

    # Common packages with distro-specific names
    case $pm in
        apt)
            packages=(curl wget git zsh build-essential fzf)
            ;;
        yum)
            packages=(curl wget git zsh gcc gcc-c++ make fzf)
            ;;
        dnf)
            packages=(curl wget git zsh gcc gcc-c++ make fzf)
            ;;
        pacman)
            packages=(curl wget git zsh base-devel fzf)
            ;;
        zypper)
            packages=(curl wget git zsh gcc gcc-c++ make fzf)
            ;;
        apk)
            packages=(curl wget git zsh build-base fzf)
            ;;
        emerge)
            packages=(net-misc/curl net-misc/wget dev-vcs/git app-shells/zsh sys-devel/gcc app-misc/fzf)
            ;;
        *)
            log_error "Unsupported package manager: $pm"
            exit 1
            ;;
    esac

    echo "${packages[@]}"
}

# Main installation function
main() {
    local pm=$(detect_package_manager)

    if [[ "$pm" == "unknown" ]]; then
        log_error "No supported package manager found. Please install dependencies manually."
        log_info "Supported package managers: apt, dnf, yum, pacman, zypper, apk, emerge"
        exit 1
    fi

    log_info "Detected package manager: $pm"

    update_package_list "$pm"

    # Get appropriate packages for the detected package manager
    local core_packages
    IFS=' ' read -r -a core_packages <<< "$(get_packages "$pm")"

    install_packages "$pm" "${core_packages[@]}"

    log_success "Package installation completed successfully."
}

# Run main function
main "$@"