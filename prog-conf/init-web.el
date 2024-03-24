;;; init-web.el --- configurations for web programming

;;; Commentary:
;; 

;;; Code:

;; use emmet-mode with sgml-mode and css-mode
(add-hook 'sgml-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook  'emmet-mode)

;; use lsp with sgml-mode, css-mode and js-mode
(add-hook 'sgml-mode-hook #'lsp)
(add-hook 'css-mode-hook #'lsp)
(add-hook 'js-mode-hook #'lsp)

;; configure web-mode
(add-hook 'web-mode-hook #'emmet-mode)
(add-hook 'web-mode-hook #'lsp)
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))

(provide 'init-web)

;;; init-web.el ends here
