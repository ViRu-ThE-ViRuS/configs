;; general
(blink-cursor-mode 0) ;; disable blinking cursor
(global-display-line-numbers-mode)

;; theme
(use-package gruvbox-theme)
(load-theme 'gruvbox-dark-medium)

;; font
(setq-default line-spacing 1)
(set-frame-font "Fira Code Retina 13" nil t)
(mac-auto-operator-composition-mode t)

;; macos keybinds
;;      general
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-S") 'write-file)
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs)
(global-set-key (kbd "s-a") 'mark-whole-buffer)
(global-set-key (kbd "s-w") (kbd "C-x 0"))
(global-set-key (kbd "C-x C") (lambda () (interactive) (find-file "~/.config/emacs/init.el")))

;;      editing
(global-set-key (kbd "s-<backspace>") 'kill-whole-line) ;; kill line
(global-set-key (kbd "M-S-<backspace>") 'kill-word) ;; kill word
(global-set-key (kbd "s-<right>") (kbd "C-e")) ;; end of line
(global-set-key (kbd "S-s-<right>") (kbd "C-S-e")) ;; select to end of line
(global-set-key (kbd "s-<left>") (kbd "M-m")) ;; beginning of line
(global-set-key (kbd "S-s-<left>") (kbd "M-S-m")) ;; select to beginning of line
(global-set-key (kbd "s-<up>") 'beginning-of-buffer) ;; first line
(global-set-key (kbd "s-<down>") 'end-of-buffer) ;; last line
(global-set-key (kbd "s-/") 'comment-line) ;; comment line

;;      split control
(global-set-key (kbd "s-1") (kbd "C-x 1")) ;; cmd-1 to kill others
(global-set-key (kbd "s-2") (kbd "C-x 2")) ;; cmd-2 to split horizontally
(global-set-key (kbd "s-3") (kbd "C-x 3")) ;; cmd-3 to split vertically
(global-set-key (kbd "s-0") (kbd "C-x 0")) ;; cmd-0 close current

;;      buffer navigation
(global-set-key (kbd "s-<") 'previous-buffer)
(global-set-key (kbd "s->") 'next-buffer)

;;      evil mode keymaps
(define-key evil-motion-state-map (kbd "C-h") 'evil-window-left)
(define-key evil-motion-state-map (kbd "C-j") 'evil-window-down)
(define-key evil-motion-state-map (kbd "C-k") 'evil-window-up)
(define-key evil-motion-state-map (kbd "C-l") 'evil-window-right)
(define-key evil-motion-state-map (kbd "C-f") 'lsp-format-buffer)
(define-key evil-normal-state-map (kbd "C-p") 'counsel-find-file)

(evil-define-key 'normal neotree-mode-map (kbd "RET") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "TAB") 'neotree-enter)
(evil-define-key 'normal neotree-mode-map (kbd "SPC") 'neotree-quick-look)
(evil-define-key 'normal neotree-mode-map (kbd "q") 'neotree-hide)
(evil-define-key 'normal neotree-mode-map (kbd "R") 'neotree-refresh)
(evil-define-key 'normal neotree-mode-map (kbd "n") 'neotree-next-line)
(evil-define-key 'normal neotree-mode-map (kbd "p") 'neotree-previous-line)
(evil-define-key 'normal neotree-mode-map (kbd "A") 'neotree-stretch-toggle)
(evil-define-key 'normal neotree-mode-map (kbd "I") 'neotree-hidden-file-toggle)

(with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd ":") 'evil-repeat-find-char)
    (define-key evil-motion-state-map (kbd ";") 'evil-ex))

(setq evil-search-module 'swiper
      evil-vsplit-window-right 't
      evil-vsplit-window-below 't
      evil-ex-hl-update-delay 0.01)

(evil-leader/set-key
  "j" 'neotree-toggle
  "t" 'next-buffer
  "y" 'previous-buffer
  "F" 'swiper
  "s" 'shell-pop
  "q" 'kill-this-buffer

  "r" 'lsp-rename
  "d" 'lsp-find-definition
  "u" 'lsp-find-references)

;;      lsp mode shit
(with-eval-after-load 'lsp-mode
  (setq lsp-modeline-diagnostics-scope :workspace))

;; hello my name is viraat chandra and i love to program
