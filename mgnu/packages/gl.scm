(define-module (mgnu packages gl)
  #:use-module (gnu packages)
  #:use-module (gnu packages gl)
  #:use-module (guix build-system meson)
  #:use-module (guix download)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix transformations)
  #:use-module (guix utils))

(define-public mesa-20.3.4
  (package
    (inherit mesa)
    (version "20.3.4")
    (source
      (origin
        (method url-fetch)
        (uri (list (string-append "https://mesa.freedesktop.org/archive/"
                                  "mesa-" version ".tar.xz")
                   (string-append "ftp://ftp.freedesktop.org/pub/mesa/"
                                  "mesa-" version ".tar.xz")
                   (string-append "ftp://ftp.freedesktop.org/pub/mesa/"
                                  version "/mesa-" version ".tar.xz")))
        (sha256
         (base32
          "1120kf280hg4h0a2505vxf6rdw8r2ydl3cg4iwkmpx0zxj3sj8fw"))
        (patches
         (parameterize
          ((%patch-path
            (map (lambda (directory)
                   (string-append directory "/mgnu/packages/patches"))
                 %load-path)))
         (search-patches "mesa-skip-tests.patch")))))
    (arguments (substitute-keyword-arguments (package-arguments mesa)
     ((#:imported-modules m %meson-build-system-modules)
       `(,@m ,@(source-module-closure `((guix utils)))))
     ((#:configure-flags flags)
       `(map (lambda (f)
               (use-modules (guix utils))
               (if (string-prefix? "-Dplatforms=" f)
                   (string-append "-Dplatforms=" (string-join
                     (lset-difference string=?
                       (string-split (cadr (string-split f #\=)) #\,)
                       `("drm" "surfaceless")) ","))
                   f)) ,flags))))))

(define-public mesa-opencl-20.3.4
  (package
    (inherit ((package-input-rewriting `((,mesa . ,mesa-20.3.4))) mesa-opencl))
    (version "20.3.4")))

(define-public mesa-opencl-icd-20.3.4
  (package
    (inherit ((package-input-rewriting `((,mesa . ,mesa-20.3.4))) mesa-opencl-icd))
    (version "20.3.4")))
