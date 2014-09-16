(global-set-key [(S-f1)] 'ansi-term)
(global-set-key [\C-tab] 'dabbrev-expand)
(global-set-key "\C-ca" 'org-agenda)

(global-set-key [f1] 'split-window-horizontally)
(global-set-key [f2] 'split-window-vertically)
(global-set-key [f3] 'kill-region)
(global-set-key [f4] 'kill-ring-save)
(global-set-key [f5] 'yank)

(global-set-key [insert]    'overwrite-mode) ; [Ins]
(global-set-key [f6] 'bury-buffer)
(global-set-key [f7] 'other-window)
(global-set-key [f12] 'igrep-find)
(global-set-key [(S-f12)] 'next-tag)

(setq minibuffer-max-depth nil)
(setq frame-title-format "emacs - %f")

(setq find-file-compare-truenames t
      dired-refresh-automatically t
      ;; scroll by one line when moving beyond top or bottom of screen
      scroll-step 1
      scroll-conservatively 1
      ;; emacs doesn't preserve file/group ownership by default - fix this
      backup-by-copying-when-mismatch t)
;; display line & column numbers
(column-number-mode t)
(line-number-mode t)
(show-paren-mode t)
(transient-mark-mode t)
(delete-selection-mode t)
(setq-default
 ;; get rid of the annoying startup messages
 inhibit-startup-message t
 initial-scratch-message nil
 ;; don't use TAB characters, except for makefiles
 indent-tabs-mode nil)
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))
;; so I can type "y" or "n" instead of "yes" and "no"
(fset 'yes-or-no-p 'y-or-n-p)

;; indentations in namespace
(c-set-offset 'innamespace 0)
(c-set-offset 'inextern-lang 0)
(c-set-offset 'extern-lang-open 0)
(c-set-offset 'extern-lang-close 0)

(defun my-c-mode-common-hook ()
  (c-add-style "cau"
               '((c-basic-offset . 4)
                 (c-offsets-alist . ((case-label . 4)
                                     (knr-argdecl-intro . 5)
                                     (substatement-open . 0))))
               t)
  (turn-on-font-lock)
  (c-set-offset 'case-label '+)
  (setq c-tab-always-indent nil)
  (setq compile-command "gmake -k")
  (define-key c-mode-base-map [(return)] 'newline-and-indent)
    (define-key c-mode-base-map [(meta q)] 'c-indent-line-or-region))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'fortran-mode-hook 'turn-on-font-lock)

;; these are set globally so they work from the compilation buffer too
(global-set-key [(f9)] 'next-error)
(global-set-key [(shift f9)] 'previous-error)
(global-set-key [(f10)] 'compile)
(global-set-key [(shift f10)] 'make-clean)

(cond
 ((= 24 emacs-major-version)
  ;; evaluate version 24 code
  (set-default-font "-unknown-Inconsolata-normal-normal-normal-*-18-*-*-*-m-0-iso10646-1"))
 ;; (set-default-font "-bitstream-Bitstream Vera Sans Mono-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1"))
 ((= 23 emacs-major-version)
  ;; evaluate version 23 code
  (set-default-font "-adobe-courier-bold-r-normal--14-140-75-75-m-90-iso8859-1")))
;; (set-default-font "-bitstream-Bitstream Vera Sans Mono-bold-normal-normal-*-14-*-*-*-m-0-iso10646-1")
;; $ fc-list :spacing=mono
;; $ fc-list :space=cell

(menu-bar-mode -1)
(tool-bar-mode -1)
(iswitchb-mode t)
(which-function-mode 1)

;; ========================================
(require 'package)
(require 'cl)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; ========================================
;; automatically refresh/install required packages
(defvar required-packages
  '(
    auto-complete
    browse-kill-ring
    color-theme
    goto-last-change
    sr-speedbar
    yasnippet
  ) "a list of packages to ensure are installed at launch.")

; method to check if all packages are installed
(defun packages-installed-p ()
  (loop for p in required-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

; if not all packages are installed, check one by one and install the missing ones.
(unless (packages-installed-p)
  ; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))

;; ========================================
(require 'sr-speedbar)
(global-set-key [(S-f11)] 'sr-speedbar-toggle)

(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)
(setq-default ac-sources '(ac-source-words-in-all-buffer))
(setq ac-dwim t)
(setq ac-ignore-case nil)
(setq ac-delay 0)
(setq ac-auto-show-menu t)

;; (require 'golden-ratio)
;; (golden-ratio-enable)

(require 'goto-last-change)
(global-set-key [f11] 'goto-last-change)

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

(require 'yasnippet)
(setq yas-snippet-dirs '("~/.emacs.d/yasnippet/snippets"))
;; use f8 to trigger
(define-key yas-minor-mode-map (kbd "<tab>") nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)
(define-key yas-minor-mode-map (kbd "<f8>") 'yas-expand)
(yas-global-mode 1)

(require 'color-theme)

(setq ac-auto-start 2)
  (eval-after-load "color-theme"
    '(progn
       (color-theme-initialize)
       (if (display-graphic-p)
           (color-theme-gnome2)
         (color-theme-vim-colors))))

(add-hook 'mouse-leave-buffer-hook
      (lambda ()
        (when (and (>= (recursion-depth) 1) (active-minibuffer-window))
          (abort-recursive-edit))))

(setq display-time-day-and-date t
   display-time-24hr-format t)
(display-time)

