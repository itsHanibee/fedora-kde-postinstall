#!/bin/bash

# This script automates common post-installation tasks for Fedora 42 KDE Plasma

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
RPM_FUSION=absent

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
}

# Check if running on Fedora
check_fedora() {
    if ! grep -q "Fedora" /etc/os-release; then
        error "This script is designed for Fedora systems only."
    fi
    log "Fedora detected - proceeding with installation"
}

# User confirmation function
ask_confirmation() {
    local prompt="$1"
    while true; do
        echo -n "$prompt (y/N): "
        read -r choice
        case $choice in
            [Yy]* ) return 0;;
            [Nn]* | "" ) return 1;;
            * ) warn "Please answer y or n.";;
        esac
    done
}

# Configure DNF for better performance
configure_dnf() {
    if ! ask_confirmation "Configure DNF for better performance (enable 6 parallel downloads)?"; then
        info "Skipping DNF configuration"
        return
    fi

    info "Configuring DNF for better performance..."

    # Check if max_parallel_downloads is already configured
    if grep -q "^max_parallel_downloads" /etc/dnf/dnf.conf; then
        CURRENT_VALUE=$(grep "^max_parallel_downloads" /etc/dnf/dnf.conf | cut -d'=' -f2)
        info "max_parallel_downloads is already set to: $CURRENT_VALUE"
        log "DNF parallel downloads already configured - skipping"
    else
        info "Setting max parallel downloads to 6"
        echo "max_parallel_downloads=6" | sudo tee -a /etc/dnf/dnf.conf
        log "DNF configuration updated"
    fi
}

# Install RPM Fusion repositories
install_rpm_fusion() {
    info "Checking for existing RPM Fusion repositories..."
    info "Some sections coming up depend on having RPM Fusion set up. If you don't have it installed, you won't be bothered with anything that needs it as a prerequisite"

    # Check if RPM Fusion repositories are already present
    if dnf repolist --enabled | grep -E "^rpmfusion-free\s" && dnf repolist --enabled | grep -E "^rpmfusion-nonfree\s"; then
        log "RPM Fusion repositories already installed"
        RPM_FUSION=present

        if ask_confirmation "RPM Fusion is already present. Refresh AppStream metadata?"; then
            info "Refreshing AppStream metadata..."
            sudo dnf makecache
            log "AppStream metadata refreshed"
        else
            info "Skipping metadata refresh"
        fi
        return
    fi

    if ! ask_confirmation "Install RPM Fusion repository? This provides software that Fedora cannot ship due to legal or licensing reasons (Multimedia codecs, proprietary drivers etc.)"; then
        info "Skipping RPM Fusion installation"
        return
    fi

    info "Installing RPM Fusion repositories..."
    sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    RPM_FUSION=present
    log "RPM Fusion repositories installed successfully"

    info "Refreshing AppStream metadata..."
    sudo dnf makecache
    log "AppStream metadata refreshed"
}

# Update system packages
update_system() {
    if ! ask_confirmation "Update all system packages?"; then
        info "Skipping system update"
        return
    fi

    info "Updating system packages..."
    sudo dnf update -y
    log "System update completed"
}

# Configure Flatpak repositories
configure_flatpak() {
    if ! ask_confirmation "Configure Flatpak repositories (replace all existing repos with unfiltered Flathub)?"; then
        info "Skipping Flatpak configuration"
        return
    fi

    info "Configuring Flatpak repositories..."

    # Remove all existing repositories unconditionally
    flatpak remotes 2>/dev/null | awk '{print $1}' | while read -r repo; do
        if [ ! -z "$repo" ] && [ "$repo" != "Name" ]; then
            info "Removing repository: $repo"
            sudo flatpak remote-delete "$repo" 2>/dev/null || true
        fi
    done

    # Add full Flathub repository
    info "Adding full Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    log "Flathub repository configured"
}

# Install/swap packages
install_packages() {
    [ "$RPM_FUSION" != "present" ] && return

    if ! ask_confirmation "Replace Dragon Player with VLC?"; then
        info "Skipping Video player swap"
        return
    fi

    info "Swapping packages..."

    # Replace Dragon Player with VLC
        info "Removing Dragon Player..."
        if dnf list installed dragon 2>/dev/null | grep -q "dragon"; then
            sudo dnf remove -y dragon
            log "Dragon Player removed successfully"
        else
            info "Dragon Player not found or already removed"
        fi

        info "Installing VLC Media Player ..."
        sudo dnf install -y vlc vlc-plugins-base vlc-plugins-extra vlc-plugins-freeworld
        log "VLC Media Player installed successfully"

    # Install essential system packages
    if ask_confirmation "Install misc. packages (These include stuff like QoL packages, fonts, archive formats support, CLI apps, etc.)?"; then
        info "Installing..."

        sudo dnf install -y git unzip p7zip p7zip-plugins unrar fuse flatpak-kcm google-noto-sans-runic-fonts

        log "Packages installed successfully"
    fi
}

# Install multimedia codecs and components
install_multimedia_codecs() {
    [ "$RPM_FUSION" != "present" ] && return

    if ! ask_confirmation "Install multimedia codecs for enhanced media playback?"; then
        info "Skipping multimedia codecs installation"
        return
    fi

    info "Installing multimedia codecs for enhanced media playback..."
    info "This includes proprietary codecs not available in the default Fedora repositories"

    info "Installing multimedia group packages..."
    sudo dnf group install -y multimedia

    info "Switching to full FFMPEG (from ffmpeg-free)..."
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing

    info "Installing GStreamer components..."
    info "Required for GNOME Videos and other media applications"
    sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

    log "Multimedia codecs installation completed"
}

# Configure VA-API for hardware video acceleration
configure_vaapi() {
    [ "$RPM_FUSION" != "present" ] && return

    if ! ask_confirmation "Configure VA-API for hardware video acceleration?"; then
        info "Skipping VA-API configuration"
        return
    fi

    info "Configuring VA-API for hardware video acceleration..."

    sudo dnf install -y ffmpeg-libs libva libva-utils

    log "VA-API base packages installed"

    # Detect CPU vendor
    info "Detecting CPU vendor for appropriate driver installation..."
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')


    if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
        info "Intel CPU detected - installing Intel VA-API drivers"
        info ""

        sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing
        sudo dnf install -y libva-intel-driver

        log "Intel VA-API drivers installed"
    fi

        info "Swapping Mesa VA drivers to freeworld package..."
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        log "Mesa VA drivers swapped successfully"

        info "Swapping Mesa VDPAU drivers to freeworld package..."
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
        log "Mesa VDPAU drivers swapped successfully"

        info "Swapping Mesa VA 32-bit drivers to freeworld package..."
        sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
        log "Mesa VA 32-bit drivers swapped successfully"

        info "Swapping Mesa VDPAU 32-bit drivers to freeworld package..."
        sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
        log "Mesa VDPAU 32-bit drivers swapped successfully"

    log "VA-API driver optimization completed"
    info "You can test VA-API functionality with: vainfo"
}

# Configure Firefox codec
configure_firefox() {
    [ "$RPM_FUSION" != "present" ] && return

    if ! ask_confirmation "Configure Firefox with H.264 support, once installed enable OpenH264 in about:addons > Plugins > OpenH264 > 3-Dot Menu > Always Activate"; then
        info "Skipping Firefox configuration"
        return
    fi

    info "Installing codec support for Firefox, it will automatically skip if the packages are present"
    info "This enables H.264 video playback in Firefox"

    sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

    log "Firefox codecs support added"
    info "=========================================="
    log "Enable OpenH264 in about:addons > Plugins > OpenH264 > 3-Dot Menu > Always Activate"
    info "=========================================="
}

# Install NVIDIA proprietary drivers
install_nvidia_drivers() {
    [ "$RPM_FUSION" != "present" ] && return

    info "Detecting NVIDIA GPU..."

    # Check for NVIDIA GPU using lspci
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        NVIDIA_GPU=$(lspci | grep -i nvidia | head -1 | cut -d: -f3 | sed 's/^ *//')
        log "NVIDIA GPU detected: $NVIDIA_GPU"

        if ! ask_confirmation "Install NVIDIA proprietary drivers? This will provide better performance and features compared to the open-source nouveau drivers"; then
            info "Skipping NVIDIA drivers installation"
            return
        fi

        info "Installing NVIDIA proprietary drivers..."
        info "This may take several minutes as the driver needs to be compiled for your kernel"

        info "Installing NVIDIA kernel module..."
        sudo dnf install -y akmod-nvidia

        info "Installing NVIDIA CUDA support..."
        sudo dnf install -y xorg-x11-drv-nvidia-cuda

        info "Enabling NVIDIA DRM kernel mode setting..."
        sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"

        info ""
        log "NVIDIA drivers installation completed"
        warn "A reboot is required for the NVIDIA drivers to take effect"
        info "After reboot, you can verify the installation with:"
        info "  - nvidia-smi (shows GPU status and driver version)"
        info "  - modinfo -F version nvidia (shows loaded kernel module version)"

    else
        info "No NVIDIA GPU detected - skipping NVIDIA drivers installation"
    fi
}

# Gaming Packages
gaming_packages() {
    [ "$RPM_FUSION" != "present" ] && return

    if ! ask_confirmation "Install game launchers? (Steam and Lutris)"; then
        info "Skipping Game launchers"
        return
    fi

    sudo dnf install -y steam lutris

    log "Game launchers installed"
}

# Optimize system boot time
optimize_boot() {
    if ! ask_confirmation "Disable NetworkManager-wait-online? (This is not recommended to do, ultimately all it does is shave off a small amount of time when booting. Say N if doubtful)"; then
        info "Skipping boot optimization"
        return
    fi

    info "Disabling NetworkManager-wait-online.service to speed up boot process"
    info "This service can cause delays during boot while waiting for network connectivity"
    info ""
    info "This change can be reverted in the future by running the following:"
    info "sudo systemctl enable --now NetworkManager-wait-online.service"

    sudo systemctl disable NetworkManager-wait-online.service

    log "Boot optimization completed - NetworkManager-wait-online.service disabled"
}

# Configure system hostname
configure_hostname() {
    if ! ask_confirmation "Configure system hostname?"; then
        info "Skipping hostname configuration"
        return
    fi

    info "Configuring system hostname..."

    CURRENT_HOSTNAME=$(hostname)
    info "Current hostname: $CURRENT_HOSTNAME"

    echo -n "Enter new hostname (press Enter to keep existing): "
    read -r NEW_HOSTNAME

    if [ ! -z "$NEW_HOSTNAME" ]; then
        info "Setting hostname to: $NEW_HOSTNAME"
        sudo hostnamectl set-hostname "$NEW_HOSTNAME"
        log "Hostname successfully changed to: $NEW_HOSTNAME"
        info "The new hostname will be fully active after reboot"
    else
        log "Keeping existing hostname: $CURRENT_HOSTNAME"
    fi
}

# System Package cleanup
package_cleanup() {
    if ! ask_confirmation "Run package cleanup (clear package cache, remove orphaned packages)?"; then
        info "Skipping package cleanup"
        return
    fi

    info "Running package cleanup..."

    info "Cleaning DNF package cache..."
    sudo dnf clean all

    info "Removing orphaned packages..."
    sudo dnf autoremove -y

    info "Refreshing DNF repo metadata ..."
    sudo dnf update --refresh

    info "Cleaning Flatpak unused runtimes..."
    flatpak uninstall --unused -y 2>/dev/null || true
    log "Package cleanup completed"
}

# Setup automatic cleanup timer
setup_cleanup_timer() {
    if ! ask_confirmation "Setup automatic DNF cleanup timer (runs weekly)?"; then
        info "Skipping cleanup timer setup"
        return
    fi

    info "Setting up automatic DNF cleanup timer..."

    # Create service file
    sudo tee /etc/systemd/system/dnf-cleanup.service > /dev/null <<EOF
[Unit]
Description=DNF Package Cache Cleanup

[Service]
Type=oneshot
ExecStart=/usr/bin/dnf clean packages -y
EOF

    # Create timer file
    sudo tee /etc/systemd/system/dnf-cleanup.timer > /dev/null <<EOF
[Unit]
Description=Run DNF cleanup weekly
Requires=dnf-cleanup.service

[Timer]
OnCalendar=weekly
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable and start timer
    sudo systemctl daemon-reload
    sudo systemctl enable --now dnf-cleanup.timer

    log "DNF cleanup timer installed and enabled (runs weekly)"
    info "You can check status with: systemctl status dnf-cleanup.timer"
}

# Main execution
main() {
    info "Starting Fedora Post-Install Script"
    info "======================================"

    # System validation
    check_root
    check_fedora

    # Basic system configuration
    configure_dnf
    install_rpm_fusion
    update_system

    # Package repositories and applications
    configure_flatpak
    install_packages

    # Multimedia support (RPM Fusion dependent)
    install_multimedia_codecs
    configure_vaapi
    configure_firefox

    # NVIDIA GPU Drivers
    install_nvidia_drivers

    # Gaming
    gaming_packages

    # System optimization
    optimize_boot
    configure_hostname
    setup_cleanup_timer

    # Final package cleanup
    package_cleanup

    log "Post-installation setup completed successfully!"

    # Reboot prompt
    if ask_confirmation "Reboot now to ensure all changes take effect?"; then
        info "Rebooting system in:"
        for i in {5..1}; do
            echo -n "$i... "
            sleep 1
        done
        echo ""
        log "Rebooting now!"
        sudo reboot
    else
        info "System is ready. You may want to reboot later to ensure all changes take effect."
    fi
}

# Run main function
main "$@"
