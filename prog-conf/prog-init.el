;;; prog-init.el --- programming configurations init file

;;; Commentary:
;; 

;;; Code:

;; use linum-mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; display fill column indicator
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

;; use rainbow-delimiters-mode
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; use smartparens-mode
(add-hook 'prog-mode-hook #'smartparens-mode)

;; use company mode
(add-hook 'prog-mode-hook 'company-mode)

;; use yasnippet
(add-hook 'prog-mode-hook #'yas-minor-mode)

;; configure company-mode
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)

;; configure lsp-mode's performance
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; lsp-mode increase the file watch warning threshold
(setq lsp-file-watch-threshold 2000)

;; lsp which-key integration
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

;; load configurations for corresponding language
(require 'init-c)
(require 'init-cpp)
(require 'init-csharp)
(require 'init-java)
(require 'init-python)
(require 'init-elisp)
(require 'init-sh)
(require 'init-sql)
(require 'init-web)

(provide 'prog-init)

;;; prog-init.el ends here
