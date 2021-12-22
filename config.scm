(use-modules (gnu) (nongnu packages linux))
(use-modules (gnu) (nongnu packages mozilla))
(use-modules (gnu) (gnu packages base))
(use-modules (guix packages))
(use-modules (guix git-download))
(use-modules (guix build-system gnu))
(use-modules (guix licenses))
(use-modules (guix utils))
(use-modules (gnu system setuid))
(use-service-modules networking desktop xorg sound)
(use-package-modules vim gnome version-control curl wm
                     emacs xorg xdisorg image-viewers terminals
                     gtk rsync cran rust-apps shells bittorrent
                     gnuzilla pulseaudio compton video fonts tmux
                     freedesktop fontutils web-browsers package-management
                     emacs-xyz ssh cmake pkg-config image music photo android
                     glib python-xyz python unicode admin certs linux rust
                     crates-io disk imagemagick file haskell-xyz
                     bootloaders compression node python-web
                     code networking irc libreoffice tex pdf sqlite
                     gcc sdl commencement audio)

(use-modules (packages sxiv))
(use-modules (packages python-arp-scan))

(define %xorg-libinput-config
  "Section \"InputClass\"
  Identifier \"Touchpads\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsTouchpad \"on\"

  Option \"Tapping\" \"on\"
  Option \"TappingDrag\" \"on\"
  Option \"DisableWhileTyping\" \"on\"
  Option \"MiddleEmulation\" \"on\"
  Option \"ScrollMethod\" \"twofinger\"
EndSection
")

(operating-system
 (kernel linux)
 (locale "en_US.utf8")
 (host-name "mahmooz")
 (timezone "Asia/Jerusalem")

 (keyboard-layout (keyboard-layout "us" "altgr-intl"))

 (kernel-loadable-modules (list rtl8812au-aircrack-ng-linux-module))

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (timeout 1)
   (targets (list "/boot/efi"))))

 (firmware (list linux-firmware))

 (users
  (cons*
   (user-account
    (name "mahmooz")
    (group "users")
    (supplementary-groups '("wheel" "audio" "adbusers"))
    (shell (file-append zsh "/bin/zsh"))
    (home-directory "/home/mahmooz"))
   %base-user-accounts))

 (packages
  (append
   (list
    ;; for https
    nss-certs

    ;; fonts
    fontconfig font-fantasque-sans font-dejavu
    font-google-noto ;; for emojis

    ;; media
    mpv feh sxiv

    ;; X drivers
    libinput xf86-video-fbdev xf86-video-nouveau
    xf86-video-ati xf86-video-vesa
    ;; X commandline tools
    setxkbmap xclip xset xrdb scrot zip acpi
    ;; X desktop
    awesome sxhkd xorg-server picom
    rofi clipit kitty libnotify

    ;; networking tools
    curl git transmission irssi
    clyrics yt-dlp network-manager
    rsync openssh irssi nmap tcpdump

    ;; web
    ;;firefox
    qutebrowser

    ;; data
    sqlite

    ;; text editors
    neovim

    ;; shell tools
    zsh tmux adb ranger vifm imagemagick
    file ffmpeg unzip the-silver-searcher fzf

    ;; emacs
    emacs emacs-guix emacs-geiser

    ;; audio/bluetooth
    pulseaudio pulsemixer pipewire
    bluez

    ;; other
    cmake gnu-make dbus playerctl flatpak libreoffice
    zathura zathura-pdf-poppler

    ;; programming languages
    python python-pip python-flask python-requests python-pyaudio
    rust rust-cargo-0.53
    node
    sdl gcc-toolchain
    )
   %base-packages))

 (sudoers-file
  (plain-file
   "sudoers"
   "root ALL=(ALL) ALL
    %wheel ALL=(ALL) NOPASSWD: ALL"))

 (hosts-file
  (plain-file
   "hosts" "10.0.0.50 server"))

 (services
  (append
   (list (service network-manager-service-type)
         (udev-rules-service 'android android-udev-rules
                             #:groups '("adbusers"))
         (service wpa-supplicant-service-type)
         (service slim-service-type
                  (slim-configuration
                   (auto-login? #t)
                   (default-user "mahmooz")
                   (display ":0")
                   (vt "vt2")
                   (xorg-configuration (xorg-configuration (extra-config (list %xorg-libinput-config))))))
         (service xorg-server-service-type)
         (service alsa-service-type (alsa-configuration
                                     (pulseaudio? #t)))
         (bluetooth-service #:auto-enable? #t))
   %base-services))

 (file-systems
  (cons*
   (file-system
    (device (file-system-label "guix"))
    (mount-point "/")
    (type "ext4")
    (mount-may-fail? #t))
   (file-system
    (device (file-system-label "boot"))
    (type "vfat")
    (mount-point "/boot/efi")
    (mount-may-fail? #t))
   %base-file-systems)))
