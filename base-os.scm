(define-module (base-os)
  #:use-module (nongnu packages linux)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages base)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (gnu services networking)
  #:use-module (gnu services sound)
  #:use-module (gnu services base)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (guix gexp)
  #:use-module (gnu system accounts)
  #:use-module (gnu packages shells)
  #:use-module (gnu system shadow)
  #:use-module (guix packages))

(use-package-modules certs curl version-control gnome rsync tmux vim file compression
                     compression terminals python python-web ssh)

(define-public %my-base-packages
  (append
   (list
    nss-certs ;; for https

    ;; networking tools
    curl git network-manager rsync openssh

    ;; some commandline tools
    tmux neovim zsh file unzip fzf

    ;; python
    python python-requests)
   %base-packages))

(define-public %my-base-services
  (append
   (list (service network-manager-service-type)
         (service wpa-supplicant-service-type)
         (service alsa-service-type (alsa-configuration (pulseaudio? #t))))
   %base-services))

(define-public %my-file-systems
  (cons*
   (file-system
    (device (file-system-label "guix"))
    (mount-point "/")
    (type "ext4"))
   (file-system
    (device (file-system-label "boot"))
    (type "vfat")
    (mount-point "/boot/efi")
    (mount-may-fail? #t))
   %base-file-systems))

(define-public %my-base-users
  (append
   (list
    (user-account
     (name "mahmooz")
     (group "users")
     (supplementary-groups '("wheel" "audio"))
     (shell (file-append zsh "/bin/zsh"))
     (home-directory "/home/mahmooz")))
   %base-user-accounts))

(define-public %my-base-os
  (operating-system
   (kernel linux)
   (locale "en_US.utf8")
   (host-name "mahmooz")
   (timezone "Asia/Jerusalem")
   (keyboard-layout (keyboard-layout "us" "altgr-intl"))
   (kernel-loadable-modules (list rtl8812au-aircrack-ng-linux-module))
   (firmware (cons* iwlwifi-firmware
                    %base-firmware))
   (bootloader
    (bootloader-configuration
     (bootloader grub-efi-bootloader)
     (timeout 1)
     (targets (list "/boot/efi"))))

   (users %my-base-users)
   (groups %base-groups)
   (packages %my-base-packages)

   (sudoers-file
    (plain-file
     "sudoers"
     "root ALL=(ALL) ALL
      %wheel ALL=(ALL) NOPASSWD: ALL"))
   (hosts-file
    (plain-file
     "hosts" "10.0.0.50 server"))

   (file-systems %my-file-systems)))

%my-base-os
