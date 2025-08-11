# Fedora 42 KDE Plasma – PostInstall Script

A simple script to set up your fresh Fedora 42 KDE system with essential tools, codecs, drivers, and misc tweaks. \
Originally created for **personal use**, but contributions and suggestions are always welcome if you'd like to expand upon this.

---

## 🛠️ What It Does

- Enables RPM Fusion (Free & Non-Free)
- Configures Flatpak with Flathub (Fedora ships with a very filtered Flatpak repository by default)
- Installs multimedia codecs (H.264, MP3, etc.)
- Optional NVIDIA driver setup (Auto checks for an Nvidia GPU) 
- Swaps the default Dragon Player for VLC Media Player
- Installs useful tools for archive format support
- Configures Firefox media support
- Sets hostname, improves boot time, sets up auto-cleanup for packages
- Steam & Lutris install for gaming.

> **All steps are optional and ask for confirmation before running.**

---

## ⚙️ Usage
- Download the script onto your system
```bash
wget https://raw.githubusercontent.com/itsHanibee/fedora-kde-postinstall/refs/heads/main/fedora-kde-postinstall.sh
```
- Run the script using bash
```bash
bash fedora-postinstall.sh
```

> Yes the script is intended to be run as a **regular user**, not root.

---

## 📦 Software management

The script is made with a few presumptions in mind, just to make things a little bit easier for myself. (This is not law, do as you wish as long as you know what you're doing)

**User is expected to;**
- Prefer **KDE Discover** for installing apps and updates
- Prefer **Flatpak** for third-party software (Discord, OBS Studio etc.)
- Avoid downloading `.rpm` files from random websites (Packages you install this way usually come from unverified sources and don't auto-update like the rest of the system)

---

## 🐧 Welcome to Linux

You're all set to use Linux. Don't forget to explore, learn and make friends who can help you when you have questions!  
Good luck on your journey!
