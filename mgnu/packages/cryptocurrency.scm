(define-module (mgnu packages cryptocurrency)
  #:use-module (gnu packages benchmark)
  #:use-module (gnu packages check)
  #:use-module (gnu packages libffi)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages))

(define-public ethash
  (package
    (name "ethash")
    (version "0.6.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/chfast/ethash")
              (commit (string-append "v" version))))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1w2r8bszdn4w9gr5rm9c38k8dqyjkbj9kkykjvdn0kkhwvs2yz9p"))))
    (build-system cmake-build-system)
    (arguments
     '(#:configure-flags
       `("-DHUNTER_ENABLED=OFF" "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
       #:phases
       (modify-phases %standard-phases
         (replace 'check
           (lambda _
             ;(invoke "test/ethash-bench")
             (invoke "test/ethash-test"))))))
    (inputs
     `(("googletest" ,googletest)
       ("benchmark" ,benchmark)))
    (synopsis
     "C/C++ implementation of Ethash – the Ethereum Proof of Work algorithm")
    (description
     "This package provides an optimized implementation of Ethash, the
proof-of-work algorithm used in Ethereum and several other cryptocurrencies.
Note: This is not the reference implementation of Ethash, which has an unclear
licensing status and appears abandoned since 2017.")
    (license asl2.0)
    (home-page "https://github.com/chfast/ethash")))

(define-public python-ethash
  (package
    (inherit ethash)
    (name "python-ethash")
    (build-system python-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-before 'build 'skip-ethash-build
           (lambda _
             (setenv "ETHASH_PYTHON_SKIP_BUILD" "1")
             #t)))))
    (inputs `(("ethash" ,ethash)))
    (propagated-inputs `(("python-cffi" ,python-cffi)))
    (synopsis
     "Python bindings to Ethash, the Ethereum Proof of Work algorithm")))
