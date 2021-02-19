(define-module (mgnu packages boost)
  #:use-module (gnu packages boost)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix utils))

;; rescued from gnu/packages/boost.scm commit 0a404bdb5ec415357b14b7780d4eae4b42a4014b
(define-public boost-1.69
  (package
    (inherit boost)
    (name "boost")
    (version "1.69.0")
    (source (origin
              (method url-fetch)
              (uri (let ((version-with-underscores
                          (string-map (lambda (x) (if (eq? x #\.) #\_ x)) version)))
                     (list (string-append "mirror://sourceforge/boost/boost/" version
                                          "/boost_" version-with-underscores ".tar.bz2")
                           (string-append "https://dl.bintray.com/boostorg/release/"
                                          version "/source/boost_"
                                          version-with-underscores ".tar.bz2"))))
              (sha256
               (base32
                "01j4n142dz20lcgqji8d8hspp04p1nv7m8i6dz8w5lchfdhx8clg"))))
    (arguments
     (substitute-keyword-arguments (package-arguments boost)
       ((#:phases phases)
        `(modify-phases ,phases
           (replace 'configure
             (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((icu (assoc-ref inputs "icu4c"))
                   (out (assoc-ref outputs "out")))
               (substitute* '("libs/config/configure"
                              "libs/spirit/classic/phoenix/test/runtest.sh"
                              "tools/build/src/engine/execunix.c"
                              "tools/build/src/engine/Jambase"
                              "tools/build/src/engine/jambase.c")
                 (("/bin/sh") (which "sh")))

               (setenv "SHELL" (which "sh"))
               (setenv "CONFIG_SHELL" (which "sh"))

               (invoke "./bootstrap.sh"
                       (string-append "--prefix=" out)
                       ;; Auto-detection looks for ICU only in traditional
                       ;; install locations.
                       (string-append "--with-icu=" icu)
                       "--with-toolset=gcc"))))))))))
