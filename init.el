;;; init.el --- init file

;;; Commentary:
;; 

;;; Code:

;; set initial window's size and position
(when window-system
  (set-frame-position (selected-frame) 560 0)
  (set-frame-size (selected-frame) 85 50))

;; set backup edited files directory
(setq backup-directory-alist `(("" . ,(concat user-emacs-directory "backup-edited-files"))))

;; add custom configurations to load-path
(add-to-list 'load-path (concat user-emacs-directory "prog-conf"))

;; load customizations
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

;; automatic install missing packages
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(package-install-selected-packages)

;; use which-key
(which-key-mode)

;; configure helm
(helm-mode)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

;; use C-x C-u to convert entire region to uppercase
(put 'upcase-region 'disabled nil)

;; use C-x C-l to convert entire region to lowercase
(put 'downcase-region 'disabled nil)

;; change lsp key prefix
(setq lsp-keymap-prefix "C-c l")

;; load programming configurations
(require 'prog-init)

(provide 'init)

;;; init.el ends here
