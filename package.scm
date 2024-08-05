(use-modules (guix packages)
             (nongnu packages dotnet)
             ((guix licenses) #:prefix license:)
             (gnu packages llvm)
             (gnu packages version-control)
             (guix build-system cmake)
             (guix build-system copy)
             (guix git-download)
             (guix utils))

(define-public dotnet-runtime-source
               (let ((commit "release/7.0")
                     (revision "1"))
                 (package
                   (name "dotnet-runtime")
                   (version (git-version "7.0" revision commit))
                   (source (origin
                             (method git-fetch)
                             (uri 
                               (git-reference
                                 (url "https://github.com/dotnet/runtime")
                                 (commit commit)))
                             (file-name (git-file-name name version))
                             (sha256
                               (base32 "01ai7wn6bvvf6r6x2fa0mskwyvp598n6v82vdng9z8fwpybnk6pd"))))
                   (build-system copy-build-system)
                   (synopsis "hi")
                   (description "hello")
                   (home-page "https://github.com/dotnet/runtime")
                   (license license:expat))))

(define-public netcoredbg
  (let ((commit "e4512506fd211493864c4187fb52ff1384af8f5e")
        (revision "1"))
    (package
     (name "netcoredbg")
     (version (git-version "3.1.0" revision commit))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/samsung/netcoredbg")
                    (commit commit)))
              (file-name (git-file-name name version))
              (sha256
               (base32 "0y3c9ywwlax1c4dxanchjy58xi4a9fq7ng1zxkwfjfn6sgl1a9zx"))))
     (build-system cmake-build-system)
     (outputs '("out"))
     (arguments
         `(#:phases
           (modify-phases %standard-phases
                          (add-after 'unpack 'redirect-home
                                     (lambda _
                                       (setenv "HOME" "/tmp")))
                          (add-after 'redirect-home 'set-dotnet-invariant-mode
                                     (lambda _
                                       (setenv "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" "1")))
                          (add-after 'build 'link-dbg-shim
                                     (lambda* (#:key inputs outputs #:allow-other-keys)
                                              (display (string-append "Linking object file: " (assoc-ref inputs "dotnet") "/share/dotnet/shared/Microsoft.NETCore.App/6.0.9/libdbgshim.so"))
                                              (mkdir (assoc-ref outputs "out"))
                                              (symlink (string-append (assoc-ref inputs "dotnet") "/share/dotnet/shared/Microsoft.NETCore.App/6.0.9/libdbgshim.so")
                                                       (string-append (assoc-ref outputs "out") "/libdbgshim.so")))))
           #:configure-flags `(,(string-append "-DCORECLR_DIR=" (assoc-ref %build-inputs "dotnet-runtime") "/src/coreclr") 
                                ,(string-append "-DDOTNETDIR=" (assoc-ref %build-inputs "dotnet"))
                                 "-DBUILD_MANAGED=0")
           #:tests? #f))
     (inputs (list clang-toolchain-9 dotnet dotnet-runtime-source))
     (propagated-inputs (list dotnet))
     (synopsis "hello")
     (description "goodbye")
     (home-page "google.com")
     (license license:expat))))

netcoredbg
