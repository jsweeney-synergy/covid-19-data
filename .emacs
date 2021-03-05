;=========================================================================
; EMACS Init File
;=========================================================================
; Author: Scott McKenzie

;; (require 'compile)

;-------------------------------------------------------------------------
; Useful Default Settings
;-------------------------------------------------------------------------


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;(package-initialize)

(setq standard-indent 3)                          ; Set indent to 3 spaces
(setq scroll-step 1)                              ; Scroll line by line
(mouse-wheel-mode t)                              ; Enable mouse wheel scrolling
(setq make-backup-files nil)                      ; disable backup creation
(setq inhibit-startup-message t)                  ; No Startup Message
(global-set-key "\C-z" 'undo)                     ; Ctrl-z = 'undo'
(global-set-key "\C-x\C-b" 'electric-buffer-list) ; Ctrl-x Ctrl-B = buffer list
(tool-bar-mode -1)                                ; turn off icon bar
(global-font-lock-mode t)                         ; turn on font-lock mode
;;(scroll-bar-mode -1)                              ; no scroll bar
;;(menu-bar-mode -99)                               ; no menu bar, either.
(setq next-line-add-newlines nil)                 ; stop at the end of
						  ; the file, not just
						  ; add lines
(show-paren-mode 1)                               ; turn on matching parenthesis highlighting
(setq-default truncate-lines t)                   ; Always truncate lines.
(setq default-fill-column 80)                     ; Fill @ 80 cols

;-------------------------------------------------------------------------
; Text Size and Appearance
;-------------------------------------------------------------------------

;(set-face-attribute 'default nil :height 130)
;(set-face-attribute 'default nil :family "Liberation Mono")
(set-face-attribute 'default nil :family "DejaVu Sans Mono")

;(set-face-attribute 'default nil :height 110)
(set-face-attribute 'default nil :height 115)
(set-face-attribute 'default nil :width 'semi-condensed)

(set-foreground-color "bisque") ; to set text color
(set-background-color "black")  ; to set background
(set-cursor-color "SeaGreen1")  ; Set cursor color
(set-mouse-color "snow")        ; Set mouse color

;-------------------------------------------------------------------------
; Window Cycling and Management
;-------------------------------------------------------------------------

(global-set-key (kbd "\C-x o") 'select-next-window)
(global-set-key (kbd "\C-x i") 'select-previous-window)
(global-set-key (kbd "\C-x p") 'select-next-next-window)

(global-set-key (kbd "\C-x +") 'balance-windows)

(setq split-height-threshold 150) 
(setq split-width-threshold 250)

;-------------------------------------------------------------------------
; Other Bindings
;-------------------------------------------------------------------------

; Toggle truncate lines
(global-set-key (kbd "C-x t") 'toggle-truncate-lines)

; Grep Buffer
(global-set-key (kbd "C-S-s") 'occur)
(global-set-key (kbd "C-S-M-s") 'scott-occur)

; Batten Extend-o
(global-set-key (kbd "C-q") 'extend-char-to-end)

; Windows-esque delete
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

; Set hotkeys to shell mode
(global-set-key [f1] (lambda () (interactive) (shell "*shell*")))
(global-set-key [f2] (lambda () (interactive) (shell "*shell*<2>")))
(global-set-key [f3] (lambda () (interactive) (shell "*shell*<3>")))
(global-set-key [f4] (lambda () (interactive) (shell "*shell*<4>")))

               
; Find file at point
(global-set-key (kbd "C-c f") 'find-file-at-point)

;-------------------------------------------------------------------------
; Custom Functions
;-------------------------------------------------------------------------

(defun select-next-window ()
 "Switch to the next window"
 (interactive)
 (select-window (next-window)))

(defun select-previous-window ()
 "Switch to the previous window"
 (interactive)
 (select-window (previous-window)))

(defun select-next-next-window ()
 "Switch to two windows forward"
 (interactive)
 (select-window (next-window))
 (select-window (next-window)))

(defun extend-char-to-end ()
 "Extend adjacent character to fill 80 columns"
  (interactive)
  (let ( (end-point (point-at-eol)) (match-char nil) )
    (beginning-of-line)
    (re-search-forward "[^ ][ ]*$" end-point t)
    (setq match-char (string-to-char (match-string 0)))
    (replace-match "")
    (insert-char match-char (- 80 (current-column)))))

(defun cs ()
  "Clear screen"
  (interactive)
  (let ((old-max comint-buffer-maximum-size))
    (setq current_line (line-number-at-pos)
          max_lines (line-number-at-pos (point-max)))
    (setq comint-buffer-maximum-size (- max_lines current_line))
    (comint-truncate-buffer)
    (setq comint-buffer-maximum-size old-max)))

; limit shell buffer sizes, and auto-truncate to keep mem usage OK
(setq comint-buffer-maximum-size 50000)
(setq eshell-buffer-maximum-lines 12000)

(add-hook 'comint-output-filter-functions
	  'comint-truncate-buffer)

(defun scott-occur ()
  "Run occur for 'SCOTT'"
  (interactive)
  (occur "SCOTT"))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;-------------------------------------------------------------------------
; Display and Status Bar
;-------------------------------------------------------------------------

(setq display-time-day-and-date t
     display-time-24hr-format nil)
(display-time)


;-------------------------------------------------------------------------
; Stuff from Will
;-------------------------------------------------------------------------

(let ((default-directory "~/.emacs.d/"))
  (normal-top-level-add-subdirs-to-load-path))

(defadvice occur (after rename-buf activate)
  "Rename the occur buffer to be unique."
  (save-excursion
    (when (get-buffer "*Occur*")
      (with-current-buffer "*Occur*"
        (goto-line 0)
        (let ((line (thing-at-point 'line))
              (search)
              (buffer))
          (string-match "for \"\\(.*\\)\" in buffer: \\(.*\\)" line)
          (setq search (match-string 1 line))
          (setq buffer (match-string 2 line))
          (rename-buffer (format "*Occur: %s:\"%s\"*" buffer search)))))))
(ad-activate 'occur)

(setq-default column-number-mode t)

;-------------------------------------------------------------------------
; Grep
;-------------------------------------------------------------------------
;; qgrep setup
(require 'grep)
;(append 'load-path "~/.emacs.d/qgrep")
(autoload 'qgrep "qgrep" "Quick grep" t)
(autoload 'qgrep-no-confirm "qgrep" "Quick grep" t)
(autoload 'qgrep-confirm "qgrep" "Quick grep" t)
(global-set-key (kbd "\C-c g") 'qgrep-no-confirm)
(global-set-key (kbd "\C-c G") 'qgrep-confirm)

;; Stricter filters
(setq qgrep-default-find-orig "find . \\( -wholename '*/.svn' -o -wholename '*/obj' -o -wholename '*/.git' -o -wholename '*/sim' -o -wholename '*/VCOMP' \\) -prune -o -type f \\( '!' -name '*atdesignerSave.ses' -a \\( -name '*' \\) \\) -type f -print0")
(setq qgrep-default-find qgrep-default-find-orig)
(setq qgrep-default-grep "grep -iI -nH -e \"%s\"")

; Swap incremental search keys with regex isearch keys
(global-set-key (kbd "\C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key [(control meta s)] 'isearch-forward)
(global-set-key [(control meta r)] 'isearch-backward)

;-------------------------------------------------------------------------
; Auto-fill
;-------------------------------------------------------------------------

(add-hook 'c-mode-common-hook
	  (lambda ()
	    (auto-fill-mode 1)
	    (set (make-local-variable 'fill-nobreak-predicate)
		 (lambda ()
		   (not (eq (get-text-property (point) 'face)
			    'font-lock-comment-face))))))

;-------------------------------------------------------------------------
; verilog mode
;-------------------------------------------------------------------------

(add-to-list 'load-path "~/.emacs.d/verilog-mode/")
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
(setq verilog-auto-newline nil)
(setq verilog-linter "cn_lint")
(setq verilog-typedef-regexp "_[tT]$")

(setq large-file-warning-threshold 1000000000) ; warn on files larger than 1Gb

;-------------------------------------------------------------------------
; ya-snippets
;-------------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/cl-lib")
(require 'cl-lib)
(add-to-list 'load-path "~/.emacs.d/yasnippet")
(require 'yasnippet)

(setq snippet-directory "~/.emacs.d/snippets")
(yas-global-mode 1)
;(yasnippet-enable)

;-------------------------------------------------------------------------
; yaml
;-------------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/yaml")
(require 'yaml-mode)


;-------------------------------------------------------------------------------
; Toggle-window-split
;-------------------------------------------------------------------------------
(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
	     (next-win-buffer (window-buffer (next-window)))
	     (this-win-edges (window-edges (selected-window)))
	     (next-win-edges (window-edges (next-window)))
	     (this-win-2nd (not (and (<= (car this-win-edges)
					 (car next-win-edges))
				     (<= (cadr this-win-edges)
					 (cadr next-win-edges)))))
	     (splitter
	      (if (= (car this-win-edges)
		     (car (window-edges (next-window))))
		  'split-window-horizontally
		'split-window-vertically)))
	(delete-other-windows)
	(let ((first-win (selected-window)))
	  (funcall splitter)
	  (if this-win-2nd (other-window 1))
	  (set-window-buffer (selected-window) this-win-buffer)
	  (set-window-buffer (next-window) next-win-buffer)
	  (select-window first-win)
	  (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "\C-x 4") 'toggle-window-split)

;-------------------------------------------------------------------------------
; uniq-lines
;-------------------------------------------------------------------------------

(defun uniq-lines (beg end)
  "Unique lines in region.
Called from a program, there are two arguments:
BEG and END (region to sort)."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
        (kill-line 1)
        (yank)
        (let ((next-line (point)))
          (while
              (re-search-forward
               (format "^%s" (regexp-quote (car kill-ring))) nil t)
            (replace-match "" nil nil))
          (goto-char next-line))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ediff mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ediff customization
(setq ediff-split-window-function 'split-window-horizontally)
; -w for ignore whitespace differences
(setq ediff-diff-options "-w")
; upward shift is in pixels
(setq ediff-control-frame-upward-shift 40)
; left/right shift is in characters
(setq ediff-narrow-control-frame-leftward-shift -30)
; Use plain mode so control window stays in original frame
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;-------------------------------------------------------------------------------
; csv-mode
;-------------------------------------------------------------------------------

(add-to-list 'load-path "~/.emacs.d/csv")
(require 'csv-mode)

;; (put 'downcase-region 'disabled nil)
;; (put 'upcase-region 'disabled nil)

;-------------------------------------------------------------------------------
;; Add major mode suffixes
;-------------------------------------------------------------------------------

(add-to-list 'auto-mode-alist '("\.aliases\\'" .       shell-script-mode))
(add-to-list 'auto-mode-alist '("\.cshrc.private\\'" . shell-script-mode))
(add-to-list 'auto-mode-alist '("Makefile\.".          makefile-mode))
(add-to-list 'auto-mode-alist '("\\.[ds]?vh?\\'" .     verilog-mode))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-time-mode t)
 '(package-selected-packages
   (quote
    (yasnippet zenburn-theme warm-night-theme underwater-theme ubuntu-theme twilight-theme tao-theme sublime-themes soothe-theme soft-charcoal-theme hc-zenburn-theme eclipse-theme darkburn-theme dark-mint-theme danneskjold-theme clues-theme cherry-blossom-theme caroline-theme calmer-forest-theme bubbleberry-theme bliss-theme birds-of-paradise-plus-theme badwolf-theme badger-theme ample-zen-theme ample-theme abyss-theme)))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Courier 10 Pitch" :foundry "bitstream" :slant normal :weight normal :height 123 :width normal)))))
