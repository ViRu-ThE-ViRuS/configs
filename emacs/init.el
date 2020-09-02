;; setup repositories
(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(package-initialize)

;; use-package to install and configure packages
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; always ensure packages are installed
(setq use-package-always-ensure t)

;; pass system shell env to emacs
(use-package exec-path-from-shell
  :ensure t)
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; custom.el
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file 'noerror)

;; private.el : after init.el
(add-hook
 'after-init-hook
 (lambda ()
   (let ((private-file (concat user-emacs-directory "private.el")))
     (when (file-exists-p private-file)
       (load-file private-file)))))

(setq mac-right-command-modifier 'super)
(setq mac-command-modifier 'super)
(setq mac-option-modifier 'meta)
(setq mac-right-option-modifier 'meta)

;; smoother scrolling
(setq scroll-margin 10
   scroll-step 5
   next-line-add-newlines nil
   scroll-conservatively 10000
   scroll-preserve-screen-position 1)
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(5 ((shift) . 5)))
(setq ns-use-mwheel-momentum nil)

;; esc : universal get me out of here
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; no autosaves and autobackups
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq large-file-warning-threshold 1000000000)
(setq-default delete-by-moving-to-trash t)
(global-auto-revert-mode t)

(setq
 inhibit-startup-message t
 inhibit-startup-screen t
 cursor-in-non-selected-windows t

 echo-keystrokes 0.1
 initial-major-mode 'org-mode
 sentence-end-double-space nil
 confirm-kill-emacs 'y-or-n-p
 help-window-select t)

(fset 'yer-of-no-p 'y-or-n-p)
(delete-selection-mode 1) ;; delete selected text when typing
(global-unset-key (kbd "s-p")) ;; dont print

;; clipboard management
(use-package simpleclip
  :config
  (simpleclip-mode 1))

;; macos keybinds
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-S") 'write-file)
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs)
(global-set-key (kbd "s-a") 'mark-whole-buffer)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; linear undo/redo
(use-package undo-fu)
(global-set-key (kbd "s-z") 'undo-fu-only-undo)
(global-set-key (kbd "s-Z") 'undo-fu-only-redo)

;; transparent title bar macos
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . light))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; font
(set-frame-font "Fira Code Retina 14" nil t)
(mac-auto-operator-composition-mode t)
(setq-default line-spacing 1)

;; theme
(use-package gruvbox-theme)
(load-theme 'gruvbox-dark-medium)

;; toolbar and scrollbar
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-visual-line-mode 0) ;; wrap lines
(global-hl-line-mode 1) ;; hl current line
;; (global-display-line-numbers-mode)
(setq-default truncate-lines 1)

;; show pairs
(use-package smartparens
  :diminish
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;; hide minor modes from mode line
(use-package rich-minority
  :config
  (rich-minority-mode 1)
  (setf rm-blacklist ""))

;; file tree
(use-package neotree
  :config
  (setq neo-window-width 32
	neo-create-file-auto-open t
	neo-banner-message nil
	neo-show-updir-line t
	neo-window-fixed-size nil
	neo-mode-line-type 'neotree
	neo-vc-integration nil
	neo-smart-open t
	neo-show-hidden-files t
	neo-mode-line-type 'none
	neo-auto-indent-point t)
  (setq neo-theme (if (display-graphic-p) 'nerd 'arrow))
  (setq neo-hidden-regexp-list '("venv" "\\.pyc$" "~$" "\\.git" "__pycache__" ".DS_Store"))
    (global-set-key (kbd "s-B") 'neotree-toggle)) ; Cmd+Shift+b : neotree

;; full path in title bar
(setq-default frame-title-format "%b")

;; use spaces instead of tabs
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; show keybindings
(use-package which-key
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

;; disable blinking cursor
(blink-cursor-mode 0)

;; Cmd + ijkl for movement
(global-set-key (kbd "s-j") 'left-char)
(global-set-key (kbd "s-i") 'previous-line)
(global-set-key (kbd "s-k") 'next-line)
(global-set-key (kbd "s-l") 'right-char)

(global-set-key (kbd "s-<backspace>") 'kill-whole-line) ;; kill line
(global-set-key (kbd "M-S-<backspace>") 'kill-word) ;; kill word

(global-set-key (kbd "s-<right>") (kbd "C-e")) ;; end of line
(global-set-key (kbd "S-s-<right>") (kbd "C-S-e")) ;; select to end of line
(global-set-key (kbd "s-<left>") (kbd "M-m")) ;; beginning of line
(global-set-key (kbd "S-s-<left>") (kbd "M-S-m")) ;; select to beginning of line
(global-set-key (kbd "s-<up>") 'beginning-of-buffer) ;; first line
(global-set-key (kbd "s-<down>") 'end-of-buffer) ;; last line

(defun my-pop-local-mark-ring ()
  (interactive)
  (set-mark-command t))

(defun unpop-to-mark-command ()
  "Unpop off mark rang. Does nothing if mark ring is empty."
  (interactive)
      (when mark-ring
        (setq mark-ring (cons (copy-marker (mark-marker)) mark-ring))
        (set-marker (mark-marker) (car (last mark-ring)) (current-buffer))
        (when (null (mark t)) (ding))
        (setq mark-ring (nbutlast mark-ring))
        (goto-char (marker-position (car (last mark-ring))))))

(global-set-key (kbd "s-,") 'my-pop-local-mark-ring) ;; cmd+. to go forward
(global-set-key (kbd "s-.") 'unpop-to-mark-command) ;; cmd+, to go backward

;; shift buffers
(global-set-key (kbd "s-<") 'previous-buffer)
(global-set-key (kbd "s->") 'next-buffer)

(defun smart-open-line ()
  "Insert an empty line after the current line. Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun smart-open-line-above ()
  "Insert an empty line above the current line. Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "s-<return>") 'smart-open-line) ;; insert line below
(global-set-key (kbd "s-S-<return>") 'smart-open-line-above) ;; insert ine above

(global-set-key (kbd "M-u") 'upcase-dwim)   ;; uppercase
(global-set-key (kbd "M-l") 'downcase-dwim) ;; lowercase

(global-set-key (kbd "s-/") 'comment-line) ;; comment line

;; visual find and replace text
(use-package visual-regexp
  :config
  (define-key global-map (kbd "M-s-f") 'vr/replace)
  (define-key global-map (kbd "s-r") 'vr/replace)) ;; cmd+r find and replace

;; make default vsplit
(setq split-height-threshold 0)
(setq split-width-threshold nil)

(global-set-key (kbd "s-1") (kbd "C-x 1")) ;; cmd-1 to kill others
(global-set-key (kbd "s-2") (kbd "C-x 2")) ;; cmd-2 to split horizontally
(global-set-key (kbd "s-3") (kbd "C-x 3")) ;; cmd-3 to split vertically
(global-set-key (kbd "s-0") (kbd "C-x 0")) ;; cmd-0 close current
(global-set-key (kbd "s-w") (kbd "C-x 0")) ;; close current

;; move between windows iterm2 style
(use-package windmove
  :config
  (global-set-key (kbd "<C-s-left>")  'windmove-left)  ;; Ctrl+Cmd+left go to left window
  (global-set-key (kbd "s-[")  'windmove-left)         ;; Cmd+[ go to left window

  (global-set-key (kbd "<C-s-right>") 'windmove-right) ;; Ctrl+Cmd+right go to right window
  (global-set-key (kbd "s-]")  'windmove-right)        ;; Cmd+] go to right window

  (global-set-key (kbd "<C-s-up>")    'windmove-up)    ;; Ctrl+Cmd+up go to upper window
  (global-set-key (kbd "s-{")  'windmove-up)           ;; Cmd+Shift+[ go to upper window

  (global-set-key (kbd "<C-s-down>")  'windmove-down)  ;; Ctrl+Cmd+down go to down window
  (global-set-key (kbd "s-}")  'windmove-down))        ;; Cmd+Shift+] got to down window

;; quickly restore window configs
(winner-mode 1)
(global-set-key (kbd "M-s-[") 'winner-undo)
(global-set-key (kbd "M-s-]") 'winner-redo)

;; ivy completion
(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t) ;; bookmarks and recent files in buffer list
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  (setq ivy-re-builders-alist
      '((swiper . ivy--regex-plus)
        (t      . ivy--regex-fuzzy))) ;; enable everywhere except swpier
  (global-set-key (kbd "s-b") 'ivy-switch-buffer) ;; Cmd+b show buffers and recent files
  (global-set-key (kbd "M-s-b") 'ivy-resume)) ;; switch to buffer

;; local finder
(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper)       ;; default Emacs Isearch forward...
  (global-set-key "\C-r" 'swiper)       ;; ... and Isearch backward replaced with Swiper
  (global-set-key (kbd "s-f") 'swiper)) ;; Cmd+f find text

;; better menus
(use-package counsel
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x) ;; alt+x run command
  (global-set-key (kbd "s-P") 'counsel-M-x) ;; cmd+shift+p run command
  (global-set-key (kbd "C-x C-f") 'counsel-find-file) ;; replace built in file-open
  (global-set-key (kbd "s-o") 'counsel-find-file)) ;; cmd+o to open file

(use-package smex)  ;; show recent commands when invoking Alt-x (or Cmd+Shift+p)
(use-package flx)   ;; enable fuzzy matching
(use-package avy)   ;; enable avy for quick navigation

;; add info to ivy
(use-package ivy-rich
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev)) ;; shorten file paths

;; gitgutter
(use-package git-gutter
  :diminish
  :config
  (global-git-gutter-mode 't)
  (set-face-background 'git-gutter:modified "yellow4")   ;; background color
  (set-face-foreground 'git-gutter:added "green4")
  (set-face-foreground 'git-gutter:deleted "red"))

;; shell
(use-package shell-pop
  :config
  (custom-set-variables
   '(shell-pop-shell-type (quote ("ansi-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell)))))
   '(shell-pop-universal-key "s-="))) ;; cmd+= for shell

;; company mode code completion
(use-package company
  :config
  (setq company-idle-delay 0.1)
  (setq company-global-modes '(not org-mode))
  (setq company-minimum-prefix-length 1)
  (add-hook 'after-init-hook 'global-company-mode))

;; org mode configs
(use-package org
  :config
  (setq org-startup-indented t)
  (setq org-src-tab-acts-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-log-into-drawer t)
  (setq org-src-fontify-natively t)
  (setq org-log-done 'time)
  (setq org-support-shift-select t)
  (setq org-startup-folded 'showall))
(setq org-directory "~/Workspace/emacs-org/")
(setq org-agenda-files '("~/Workspace/emacs-org/"))

;; evil mode
(use-package evil
  :config
  (evil-mode 1))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(exec-path-from-shell use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
