;; Mac OS X Stuff
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used
   by the user's shell. This is particularly useful under Mac OSX, where GUI
   apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;; Cask
(require 'cask "~/.cask/cask.el")
(cask-initialize "~/")

;; Make default directory HOME instead of /
(setq command-line-default-directory "~/")

;; Turn off the damn bell
(setq visible-bell t)

(defun my-bell-function ()
  (unless (memq this-command
        '(isearch-abort abort-recursive-edit exit-minibuffer
              keyboard-quit mwheel-scroll down up next-line previous-line
              backward-char forward-char))
    (ding)))
(setq ring-bell-function 'my-bell-function)

;; Turn off the toolbar
(if window-system
    (tool-bar-mode 0))

;; Whitespace
(setq whitespace-style '(face empty tabs trailing))
(global-whitespace-mode t)

;; Set theme
(if window-system
    (load-theme 'wombat t))

;; Add various modes that are needed
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js3-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.avsc$" . json-mode)) ;; Avro schema
(add-to-list 'auto-mode-alist '("\\.html\\.erb$" . web-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

;; Flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Column indicator
(setq fci-rule-use-dashes t)
(setq fci-dash-pattern .5)

(setq fci-rule-width 1)
(setq fci-rule-color "darkred")
(setq fci-rule-column 80)
(add-hook 'find-file-hook 'fci-mode)

;; Add robe for ruby code completion and documentation
(add-hook 'ruby-mode-hook 'robe-mode)

;; Folding
(add-hook 'ruby-mode-hook 'hs-minor-mode)
(add-hook 'js3-mode-hook 'hs-minor-mode)
(eval-after-load "hideshow"
  '(add-to-list 'hs-special-modes-alist
                 `(ruby-mode
                   ,(rx (or "def" "class" "module" "{" "[")) ; Block start
                   ,(rx (or "}" "]" "end"))                  ; Block end
                   ,(rx (or "#" "=begin"))                   ; Comment start
                   ruby-forward-sexp nil)))
(global-set-key (kbd "<f7>")      'hs-toggle-hiding)
(global-set-key (kbd "<M-f7>")    'hs-hide-all)
(global-set-key (kbd "<S-M-f7>")  'hs-show-all)

;; Search through files in git project with fuzzy search
(defun ido-git-files ()
  "Use ido to select a file from the project."
  (flx-ido-mode t)
  (interactive)
  (let (my-project-root project-files tbl)
    ;; TODO: Error handling if it isn't a git repo (maybe find git repos?)
    (setq my-project-root (replace-regexp-in-string "\n$" ""
          (shell-command-to-string "git rev-parse --show-toplevel")))
    ;; get project files
    (setq project-files
          (split-string
           (shell-command-to-string
            (concat "git ls-files --full-name --exclude-standard -co " my-project-root))))
    ;; populate hash table (display repr => path)
    (setq tbl (make-hash-table :test 'equal))
    (let (ido-list)
      (mapc (lambda (path)
              ;; format path for display in ido list
              ;; (replace-regexp-in-string "\\(.*?\\)\\([^/]+?\\)$" "\\2|\\1" path))
              ;; remove trailing | or /
              (setq key (replace-regexp-in-string "\\(|\\|/\\)$" "" path))
              (puthash key (concat my-project-root "/" key) tbl)
              (push key ido-list)
              )
            project-files
            )
      (find-file (gethash (ido-completing-read "project-files: " ido-list) tbl)))))
 (global-set-key (kbd "C-x C-d") 'ido-git-files)

;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
