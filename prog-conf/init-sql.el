;;; init-sql.el --- configuration for sql

;;; Commentary:
;; 

;;; Code:

;; capitalize keywords in sql-mode
(add-hook 'sql-mode-hook 'sqlup-mode)

;; capitalize keywords in an interactive session (e.g. psql)
(add-hook 'sql-interactive-mode-hook 'sqlup-mode)

;; set a global keyword to use sqlup on a region
(global-set-key (kbd "C-c u") 'sqlup-capitalize-keywords-in-region)

(provide 'init-sql)

;;; init-sql.el ends here
