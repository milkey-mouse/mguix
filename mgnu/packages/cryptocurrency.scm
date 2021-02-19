(define-module (mgnu packages cryptocurrency)
  #:use-module (gnu packages benchmark)
  #:use-module (gnu packages check)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages opencl)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages tls)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system python)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (mgnu packages boost)
  #:use-module (mgnu packages cpp)
  #:use-module (srfi srfi-1))

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
    (license license:asl2.0)
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

(define-public ethminer
  (package
    (name "ethminer")
    (version "0.19.0")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
              (url "https://github.com/ethereum-mining/ethminer")
              (commit (string-append "v" version))
              (recursive? #t)))
        (file-name (git-file-name name version))
        (sha256
         (base32 "1kyff3vx2r4hjpqah9qk99z6dwz7nsnbnhhl6a76mdhjmgp1q646"))))
    (build-system cmake-build-system)
    (arguments
     `(#:configure-flags
       `("-DHUNTER_ENABLED=OFF" "-DETHASHCUDA=OFF")
       #:phases
        (modify-phases %standard-phases
         (add-before 'configure 'no-static-link
           (lambda _
             (substitute* "CMakeLists.txt"
              (("set\\(CMAKE_EXE_LINKER_FLAGS \"\\$\\{CMAKE_EXE_LINKER_FLAGS\\} \\-static\\-libstdc\\+\\+\"\\)" s)
               (string-append "#" s)))
             (substitute* "libpoolprotocols/CMakeLists.txt"
              (("jsoncpp_lib_static") "jsoncpp"))
             #t)))
       ;; no tests aside from one that'd need OpenCL
       #:tests? #f))
    (inputs
     `(;; when built with boost >1.70:
       ;; error: ‘class boost::asio::io_context::strand’ has no member named ‘get_io_service’
       ("boost" ,boost-1.69)
       ("cli11" ,cli11)
       ("ethash" ,ethash)
       ("jsoncpp" ,jsoncpp)
       ("ocl-icd" ,ocl-icd)
       ("opencl-headers" ,opencl-headers)
       ("openssl" ,openssl)))
    (synopsis "Ethereum miner with OpenCL, CUDA and stratum support")
    (description
     "Ethminer is an Ethash GPU mining worker: with ethminer you can mine every
coin which relies on an Ethash Proof of Work thus including Ethereum, Ethereum
Classic, Metaverse, Musicoin, Ellaism, Pirl, Expanse and others.")
    (license license:gpl3+)
    (home-page "https://github.com/ethereum-mining/ethminer")))
