(define-module (mgnu packages video)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vulkan)
  #:use-module (guix build-system meson)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public libplacebo
  (package
    (name "libplacebo")
    (version "2.72.2")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://code.videolan.org/videolan/libplacebo")
               (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1ijqpx1pagc6qg63ynqrinvckwc8aaw1i0lx48gg5szwk8afib4i"))))
    (build-system meson-build-system)
    (arguments
     `(#:configure-flags
       `(,(string-append "-Dvulkan-registry="
                         (assoc-ref %build-inputs "vulkan-headers")
                         "/share/vulkan/registry/vk.xml"))))
    (native-inputs
     `(("python-mako" ,python-mako)
       ("pkg-config" ,pkg-config)))
    (inputs
     `(("lcms" ,lcms)
       ;; TODO: mesa should be a propagated input
       ("mesa" ,mesa)
       ("shaderc" ,shaderc)
       ("vulkan-headers" ,vulkan-headers)
       ("vulkan-loader" ,vulkan-loader)))
    (propagated-inputs
     `(("libepoxy" ,libepoxy)))
    (synopsis "GPU-accelerated image/video processing library")
    (description "libplacebo is, in a nutshell, the core rendering algorithms
and ideas of mpv rewritten as an independent library. As of today, libplacebo
contains a large assortment of video processing shaders, focusing on both
quality and performance.")
    (license lgpl2.1+)
    (home-page "https://code.videolan.org/videolan/libplacebo")))

(define-public libplacebo-3
  (package
    (inherit libplacebo)
    (version "3.104.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://code.videolan.org/videolan/libplacebo")
               (commit (string-append "v" version))))
        (file-name (git-file-name (package-name libplacebo) version))
        (sha256
         (base32 "0p5mx8ch7cp7b54yrkl4fs8bcvqma1h461gx6ps4kagn4dsx8asb"))))))
