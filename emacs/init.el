;; setup repositories
(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
(package-initialize)

;; configure use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
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

;; mac keyboard setup
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

;; general ux setup
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

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; transparent title bar macos
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . light))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; toolbar and scrollbar
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; filename in title bar
(setq-default frame-title-format "%b")

(global-visual-line-mode 0) ;; wrap lines
(global-hl-line-mode 1) ;; hl current line
(setq-default truncate-lines 1)

;; use spaces instead of tabs
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; make default vsplit
(setq split-height-threshold 0)
(setq split-width-threshold nil)

;; evil mode
(use-package evil
  :config
  (evil-mode 1)
  (setq x-select-enable-clipboard nil))

(use-package evil-leader
  :config
  (evil-leader/set-leader "\\"))

;; clipboard management
(use-package simpleclip
  :config
  (simpleclip-mode 1))

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
