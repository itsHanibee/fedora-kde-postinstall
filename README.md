# Fedora 42 KDE Plasma – PostInstall Script

A simple script to set up your fresh Fedora 42 KDE system with essential tools, codecs, drivers, and misc tweaks. \
Originally created for **personal use**, and intentionally opinionated but contributions and suggestions are always welcome if you'd like to expand upon this.

---

## 🛠️ What It Does

- Enables RPM Fusion (Free & Non-Free)
- Configures Flatpak with the actual Flathub repo (Fedora ships with a very filtered Flatpak repository by default)
- Installs multimedia codecs (H.264, 265 etc.)
- Optional NVIDIA driver setup (Auto checks for an Nvidia GPU)
- Swaps the default Dragon Player for VLC Media Player (Dragon is simple by choice and feels quite foreign, you're free to install it again though)
- Installs any packages necessary for missing archive format support
- Configures Firefox to support the aforementioned codecs
- Installs any font packages to fix missing character sets (Seriously, missing glyphs in 2025 is unacceptable) 
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

The script is made with a few presumptions in mind, just to make things a little bit easier for myself. It's no secret that package management on Linux is difficult so try making your life simpler whenever possible. (This is not law, do as you wish as long as you know what you're doing)

**User is expected to;**
- Prefer **KDE Discover** for installing apps and updates
- Prefer **Flatpak** for third-party software (Discord, OBS Studio etc.)
- Avoid downloading `.rpm` files from random websites (Packages you install this way usually come from unverified sources and don't auto-update like the rest of the system)

---

### Why this exists
> Prepare for a rant

I was asked for help with migrating to Linux from Windows 10. I accepted to help them and guide them for any need that may arise, so I begun checking out distros to get them on that had everything they specified they wanted (mainly KDE if you really want to know, I showed off a bunch of DEs). \
I prioritized finding a distro that had everything I wanted out of the box so I could minimize set-up time but as time passed that turned out to be in vain. And thus begun my journey. 

I'm not comfortable leaving my friends who have newly been introduced to Linux on something like Arch. While distros like CachyOS do wonders with OOTB user-experience and the excellent updates and repo maintanance, the underlying **pac**kage **man**ager doesn't safely allow for managing packages through something like Discover, while it works but it is definitely flakey and Discover even warns you that what you're doing is bad.

This leaves me with options like Linux Mint which— in it's own right quite great but users find themselves growing out of it rather quickly. I decided against it mainly because it doesn't have a KDE iso or a clean way to install KDE, plus it's usage of an LTS base for a desktop centric distro is frankly not advicable in the rapidly accelerating climate of desktop Linux.

Decided against Ubuntu because of it's terrible history with botched bi-yearly upgrades. It has always been horror stories and combine that with the Snap packaging format which *(serves quite well for CLI applications and servers but)* is terrible on desktop because of application developers not giving the same priority for releasing their apps on Snaps as they do with Flatpaks especially true for smaller projects, this made the decision is quite easy to make. (Also does scummy behaviour like installing Firefox as a snap by default and it automatically reverts it back to a snap if you install it as a system package without warning the user. **TERRIBLE!**)

Debian because of the same reason as Mint, consistent package updates is important on desktop linux. An LTS distro is simply unacceptable and do not bother recommending Debian Testing, i'm not comfortable leaving my girlfriend or mom on a distro with **Testing** in its name, its there for a reason.

All that's left is the RPM family of Linux.

Fedora when I initially installed it was woefully underdone for what a basic installation of a distro should be. Missing applications in repos, codecs, character sets, the horror! I understand that this was because of legal and philosophical reasons but for all that's holy, **THIS** is what people were recommending to new users ALL this time?

By this time I was losing hope, I wanted to check out OpenSUSE Tumbleweed but I had little to no experience with helping people troubleshoot things on SUSE and I'm not about to set someone on something I couldn't immediately couldn't diagnose if something were to go wrong.

Then eventually I looked for any forks of Fedora and eventually tried out Nobara, with all it's advertised patches to fix Fedora in it's vanilla form I breathed a sigh of relief. Surely my search was done I thought and.... **WOMP WOMP** \
The package management while graphical was a fragmented joke, The updates and app installs aren't managed by a single application and either of the apps weren't good either. They were both GTK apps whose theming break on the default KDE desktop, the 'Update System' application (with it's icon was weirdly out of place) was slow, unresponsive, needlessly complicated. While it does quite alot of novel things, and I really appreciate GloriousEggroll's work on UMU and Proton-GE. This distro definitely needs some UX work. I'd like to know why they opted for a custom solution instead of going with something proven and generic like GNOME Software or Discover and possibly introducing more users to either and help fix upstream issues, were there really so many quirks with Nobara that required a custom solution?

With that I just gave up and returned to Fedora and just got down to unfucking it, this script is not my best work but as long as it works that's all that matters.

And with that you're all set to use Linux. Don't forget to explore, learn and make friends who can help you when you have questions!  
Good luck on your journey! 🐧
