(define-module (full-os)
  #:use-module (gnu)
  #:use-module (nongnu packages mozilla)
  #:use-module (gnu packages fonts)
  #:use-module (gnu services virtualization)
  #:use-module (minimal-os))

(use-package-modules tex libreoffice pdf imagemagick virtualization video)

(define-public %my-full-packages
  (append
   (list
    font-google-noto
    texlive firefox libreoffice imagemagick qemu virt-manager ffmpeg)
   %my-minimal-packages))

(define-public %my-full-os
  (operating-system
   (inherit %my-minimal-os)
   (packages %my-full-packages)))

%my-full-os
