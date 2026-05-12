;;; init.el --- tle130475c's Emacs config  -*- lexical-binding: t; -*-

;;; Commentary:

;; Minimal config: built-ins only, portable across machines.

;;; Code:

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
;; Tree-sitter: prefer *-ts-mode when the grammar is available
;; ===========================================================================
;; Tree-sitter modes give better syntax highlighting, indentation, and modern
;; language features (e.g. Java 15+ text blocks) even without LSP.
;;
;; PHILOSOPHY: this block is fail-safe. The remap is only added when the
;; grammar for that language is actually installed and loadable. Missing
;; grammar → file opens in legacy mode (still highlighted, no warning).
;;
;; TO UPGRADE A FILE TYPE TO TREE-SITTER, install its grammar once per machine:
;;   M-x treesit-install-language-grammar RET python     RET
;;   M-x treesit-install-language-grammar RET c          RET
;;   M-x treesit-install-language-grammar RET cpp        RET
;;   M-x treesit-install-language-grammar RET rust       RET
;;   M-x treesit-install-language-grammar RET java       RET
;;   M-x treesit-install-language-grammar RET javascript RET
;;   M-x treesit-install-language-grammar RET typescript RET
;;   M-x treesit-install-language-grammar RET bash       RET
;; Grammars cached to ~/.emacs.d/tree-sitter/. Requires git + C compiler
;; on the system (Arch base-devel covers this).
;;
;; The pairs below are (grammar-name . (legacy-mode . tree-sitter-mode)).
;; Some grammar names differ from mode names (cpp vs c++, bash vs sh,
;; javascript vs js) — that's intentional, not a typo.
(require 'treesit)
(dolist (pair '((python     . (python-mode     . python-ts-mode))
                (c          . (c-mode          . c-ts-mode))
                (cpp        . (c++-mode        . c++-ts-mode))
                (rust       . (rust-mode       . rust-ts-mode))
                (java       . (java-mode       . java-ts-mode))
                (javascript . (js-mode         . js-ts-mode))
                (typescript . (typescript-mode . typescript-ts-mode))
                (bash       . (sh-mode         . bash-ts-mode))))
  (when (treesit-ready-p (car pair) t)
    (add-to-list 'major-mode-remap-alist (cdr pair))))

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
;; TROUBLESHOOTING:
;;   "[eglot] Server died"        → server isn't installed or not on PATH
;;   See what eglot is doing      → M-x eglot-events-buffer
;;   Restart a server             → M-x eglot-reconnect
;;   Shut down a server           → M-x eglot-shutdown
;;
;; To enable: uncomment the dolist below. Both legacy and *-ts-mode hooks are
;; listed so eglot starts regardless of whether tree-sitter grammars are
;; installed on this machine — LSP and tree-sitter are independent features.
;;
;; If you stop using a language, REMOVE both of its hooks below — otherwise
;; eglot will try to start a server every time you open that file type and
;; fail noisily.

;; (dolist (hook '(python-mode-hook        python-ts-mode-hook
;;                 c-mode-hook             c-ts-mode-hook
;;                 c++-mode-hook           c++-ts-mode-hook
;;                 rust-mode-hook          rust-ts-mode-hook
;;                 java-mode-hook          java-ts-mode-hook
;;                 js-mode-hook            js-ts-mode-hook
;;                 typescript-mode-hook    typescript-ts-mode-hook
;;                 sh-mode-hook            bash-ts-mode-hook))
;;   (add-hook hook #'eglot-ensure))

;; ===========================================================================
;; Flymake (on-the-fly diagnostics) — eglot feeds into it automatically
;; ===========================================================================
(add-hook 'prog-mode-hook #'flymake-mode)
(defvar flymake-mode-map)  ; silence byte-compiler; real def is in flymake.el
(declare-function flymake-goto-next-error "flymake")
(declare-function flymake-goto-prev-error "flymake")
(with-eval-after-load 'flymake
  (keymap-set flymake-mode-map "M-n" #'flymake-goto-next-error)
  (keymap-set flymake-mode-map "M-p" #'flymake-goto-prev-error))

;; ===========================================================================
;; which-key (built-in)
;; ===========================================================================
(which-key-mode 1)

;; ===========================================================================
;; Line numbers in programming modes
;; ===========================================================================
(setopt display-line-numbers-width 3)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; ===========================================================================
;; Whitespace visualization in programming modes
;; ===========================================================================
(setopt whitespace-style '(face tabs trailing tab-mark missing-newline-at-eof))
(add-hook 'prog-mode-hook #'whitespace-mode)

;; ===========================================================================
;; Per-machine: HiDPI font bump on WSL2 (everything-tiny fix)
;; ===========================================================================
;; WSLg + emacs-wayland (PGTK) doesn't pick up Windows display scaling, so
;; on a HiDPI monitor everything renders at native pixel size and looks tiny.
;; Detect WSL by checking any WSL-set env var (different distros / WSL versions
;; populate different ones).
;;
;; Adjust :height if monitor / Windows scaling changes:
;;   140 ≈ Arch GNOME at 133%
;;   120 = smaller / older monitor
;;   160+ = 4K at high Windows scaling
(when (and (eq system-type 'gnu/linux)
           (or (getenv "WSL_DISTRO_NAME")
               (getenv "WSL_INTEROP")
               (getenv "WSLENV")))
  (set-face-attribute 'default nil :height 140))

;;; init.el ends here
