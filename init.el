;;; init.el — tle130475c's Emacs config  -*- lexical-binding: t; -*-

;; ===========================================================================
;; House-keeping: keep junk files out of project directories
;; ===========================================================================
(let ((backup-dir   (expand-file-name "backups/"    user-emacs-directory))
      (autosave-dir (expand-file-name "auto-saves/" user-emacs-directory))
      (lock-dir     (expand-file-name "lock-files/" user-emacs-directory)))
  (dolist (dir (list backup-dir autosave-dir lock-dir))
    (unless (file-directory-p dir)
      (make-directory dir t)))

  (setopt backup-directory-alist        `((".*" . ,backup-dir))
          backup-by-copying             t
          version-control               t
          delete-old-versions           t
          kept-new-versions             5
          kept-old-versions             2
          auto-save-file-name-transforms `((".*" ,autosave-dir t))
          auto-save-list-file-prefix    (expand-file-name ".saves-" autosave-dir)
          lock-file-name-transforms     `((".*" ,lock-dir t))))

;; Customize output goes to its own file
(setopt custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Built-in package state files
(setopt savehist-file         (expand-file-name "savehist"  user-emacs-directory)
        recentf-save-file     (expand-file-name "recentf"   user-emacs-directory)
        bookmark-default-file (expand-file-name "bookmarks" user-emacs-directory)
        project-list-file     (expand-file-name "projects"  user-emacs-directory))

;; Native-compilation cache (enabled by default in 30; just relocate it)
(startup-redirect-eln-cache
 (expand-file-name "eln-cache/" user-emacs-directory))

;; ===========================================================================
;; Minibuffer completion: fido-vertical-mode
;; ===========================================================================
(fido-vertical-mode 1)
(setopt completion-styles       '(basic substring initials flex)
        completion-auto-help    'always
        completions-max-height  20
        completions-format      'one-column
        completion-auto-select  'second-tab)

;; ===========================================================================
;; In-buffer completion preview (Emacs 30)
;; ===========================================================================
(global-completion-preview-mode 1)
(setopt tab-always-indent 'complete)

;; ===========================================================================
;; LSP via eglot
;; ===========================================================================
;; Eglot is the LSP client (built-in since Emacs 29). It does NOT include the
;; language servers themselves — those are external programs eglot launches.
;; You must install them on the system before the corresponding hook is useful.
;;
;; SETUP CHECKLIST FOR ARCH (verified 2026-05):
;;
;;   Python:    sudo pacman -S pyright                      [extra]
;;   C / C++:   sudo pacman -S clang                        [extra]  (provides clangd)
;;   Rust:      sudo pacman -S rust-analyzer                [extra]
;;   JS / TS:   sudo pacman -S typescript-language-server   [extra]
;;   Bash:      sudo pacman -S bash-language-server         [extra]
;;   Java:      yay -S jdtls                                [AUR]    (not in official repos)
;;              └─ requires JDK 21+; install with: sudo pacman -S jdk-openjdk
;;
;; VERIFY each server is found on PATH:
;;   $ which pyright-langserver clangd rust-analyzer \
;;          typescript-language-server bash-language-server jdtls
;;
;; TREE-SITTER GRAMMARS (the *-ts-mode hooks below need these):
;;   In Emacs, run once per language:
;;     M-x treesit-install-language-grammar RET python     RET
;;     M-x treesit-install-language-grammar RET c          RET
;;     M-x treesit-install-language-grammar RET cpp        RET
;;     M-x treesit-install-language-grammar RET rust       RET
;;     M-x treesit-install-language-grammar RET javascript RET
;;     M-x treesit-install-language-grammar RET typescript RET
;;     M-x treesit-install-language-grammar RET bash       RET
;;   Grammars are cached in ~/.emacs.d/tree-sitter/.
;;
;; TROUBLESHOOTING:
;;   "[eglot] Server died"        → server isn't installed or not on PATH
;;   "cannot find tree-sitter ..." → run the treesit-install-language-grammar above
;;   See what eglot is doing       → M-x eglot-events-buffer
;;   Restart a server              → M-x eglot-reconnect
;;   Shut down a server            → M-x eglot-shutdown
;;
;; If you stop using a language, REMOVE its hook below — otherwise eglot will
;; try to start a server every time you open that file type and fail noisily.
;; (dolist (hook '(python-ts-mode-hook
;;                 c-ts-mode-hook
;;                 c++-ts-mode-hook
;;                 rust-ts-mode-hook
;;                 java-mode-hook
;;                 js-ts-mode-hook
;;                 typescript-ts-mode-hook
;;                 bash-ts-mode-hook))
;;   (add-hook hook #'eglot-ensure))

;; ===========================================================================
;; Flymake (on-the-fly diagnostics) — eglot feeds into it automatically
;; ===========================================================================
(add-hook 'prog-mode-hook #'flymake-mode)
(with-eval-after-load 'flymake
  (keymap-set flymake-mode-map "M-n" #'flymake-goto-next-error)
  (keymap-set flymake-mode-map "M-p" #'flymake-goto-prev-error))

;; ===========================================================================
;; which-key (built-in)
;; ===========================================================================
(which-key-mode 1)

;;; init.el ends here
