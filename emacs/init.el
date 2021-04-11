;; default is 800kb
(setq gc-cons-threshold (* 50 1000 1000))

;; profile emacs startup
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "*** Emacs loaded in %s with %d garbage collections."
		     (format "%.2f seconds" (float-time (time-subtract after-init-time before-init-time)))
		     gcs-done)))

;; setup repositories
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; configure use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; pass system shell env to emacs
(use-package exec-path-from-shell :ensure t)
(when (memq window-system '(mac ns)) (exec-path-from-shell-initialize))

;; custom.el
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file 'noerror)

;; private.el
(add-hook
 'after-init-hook
 (lambda () (let ((private-file (concat user-emacs-directory "private.el")))
     (when (file-exists-p private-file) (load-file private-file)))))

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
      scroll-preserve-screen-position 1
      mouse-wheel-follow-mouse 't
      mouse-wheel-scroll-amount '(5 ((shift) . 5))
      ns-use-mwheel-momentum nil)

;; esc : universal get me out of here
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; no autosaves and autobackups
(setq auto-save-default nil
      make-backup-files nil
      large-file-warning-threshold 1000000000)
(setq-default delete-by-moving-to-trash t)
(global-auto-revert-mode t)

;; ui/ux setup
(setq inhibit-startup-message t
      inhibit-startup-screen t
      echo-keystrokes 0.1
      initial-major-mode 'org-mode
      sentence-end-double-space nil
      confirm-kill-emacs 'y-or-n-p
      help-window-select t
      set-fringe-mode 10
      require-final-newline t)
(fset 'yer-of-no-p 'y-or-n-p)
(delete-selection-mode 1)           ;; delete selected text when typing
(global-unset-key (kbd "s-p"))      ;; dont print
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq-default frame-title-format "%b")
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-visual-line-mode 0)         ;; wrapping
(global-hl-line-mode 1)             ;; line hl
(setq-default truncate-lines 1)     ;; truncate

;; spaces instead of tabs
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; default splitting
(setq split-height-threshold 0)
(setq split-width-threshold nil)

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

;; neotree
(use-package neotree
  :config
  (setq neo-window-width 32
        neo-create-file-auto-open t
        neo-banner-message nil
        neo-show-updir-line t
        neo-window-fixed-size nil
        neo-vc-integration nil
        neo-mode-line-type 'neotree
        neo-smart-open t
        neo-show-hidden-files t
        neo-mode-line-type 'none
        neo-auto-indent-point t)
  (setq neo-theme (if (display-graphic-p) 'nerd 'arrow))
  (setq neo-hidden-regexp-list '("venv" "\\.pyc$" "~$" "\\.git" "__pycache__" ".DS_Store")))

;; evil leader
(use-package evil-leader
  :config (global-evil-leader-mode))

;; evil mode
(use-package evil
  :config
  (evil-mode 1)
  (setq x-select-enable-clipboard nil)
  (evil-set-leader 'normal (kbd "\\")))

;; ivy: fuzzy option completion
(use-package ivy
  :diminish
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-count-format ""
        ivy-initial-inputs-alist nil
        enable-recursive-minibuffers t
        ivy-re-builders-alist '((swiper . ivy--regex-plus) (t . ivy--regex-fuzzy))))

(use-package ivy-rich
  :after counsel
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev))

;; swiper: local fuzzy finder
(use-package swiper)

;; counsel: better menus
(use-package counsel
  :config
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "s-P") 'counsel-M-x)
  (global-set-key (kbd "s-o") 'counsel-find-file)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file))

;; gitgutter
(use-package git-gutter
  :diminish
  :config
  (global-git-gutter-mode 't)
  (set-face-background 'git-gutter:modified 'nil)
  (set-face-foreground 'git-gutter:added "green4")
  (set-face-foreground 'git-gutter:deleted "red"))

;; terminal
(use-package shell-pop
  :config
  (custom-set-variables
   '(shell-pop-shell-type (quote ("ansi-term" "*ansi-term*"
                                  (lambda nil (ansi-term shell-pop-term-shell)))))))

;; lsp
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-idle-delay 0.5
        lsp-enable-symbol-highlighting t
        lsp-modeline-code-actions-enable nil
        lsp-modeline-diagnostics-enable nil
        lsp-headerline-breadcrumb-enable nil
        lsp-enable-folding nil
        lsp-enable-imenu nil
        lsp-enable-snippet nil
        lsp-prefer-capf t)
  :hook
  ((python-mode
    c-mode
    c++-mode
    c-or-c++-mode) . lsp))

;; company
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map ("<tab>" . company-complete-selection))
        (:map lsp-mode-map ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))
