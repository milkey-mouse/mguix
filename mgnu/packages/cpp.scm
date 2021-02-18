(define-module (mgnu packages cpp)
  #:use-module (gnu packages check)
  #:use-module (guix build-system cmake)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix modules)
  #:use-module (guix packages)
  #:use-module (guix utils))

;; TODO: add :doc output (with dependency on doxygen)
(define-public cli11
  (package
    (name "cli11")
    (version "1.9.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/CLIUtils/CLI11")
              (commit (string-append "v" version))))
              ;; TODO: for googletest submodule, (recursive? #t) may be necessary in git-reference
        (file-name (git-file-name name version))
        (sha256
         (base32 "0hbch0vk8irgmiaxnfqlqys65v1770rxxdfn3d23m2vqyjh0j9l6"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags `("-DCLI11_SINGLE_FILE=OFF" "-DCLI11_EXAMPLES=OFF")
       #:imported-modules (,@%cmake-build-system-modules ,@(source-module-closure `((guix utils))))
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'no-vendor-gtest
           (lambda _
             (use-modules (guix utils))
             (substitute* "tests/CMakeLists.txt"
               ;; We provide our own googletest, so this is not really a problem.
               (("message\\(FATAL_ERROR \"You have requested tests be built, but googletest is not downloaded." msg)
                 (string-replace-substring msg "FATAL_ERROR" "TRACE")))
             (substitute* "cmake/AddGoogletest.cmake"
               (("^add_subdirectory\\(.*googletest.*$") "find_package(GTest REQUIRED)")
               (("^set_target_properties\\(gtest gtest_main gmock gmock_main") "")
               (("^    PROPERTIES FOLDER \"Extern\"\\)") ""))
             #t)))))
    (inputs `(("googletest" ,googletest)))
    (synopsis "Command line parser for C++11")
    (description
     "CLI11 is a command line parser for C++11 and beyond that provides a rich
feature set with a simple and intuitive interface.")
    (license bsd-3)
    (home-page "https://cliutils.github.io/CLI11/book/")))
