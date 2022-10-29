;;; compile-transient.el --- A transient for compile command -*- lexical-binding: t -*-

;; Copyright (C) 2010-2020 Vitor Quintanilha Barbosa

;; Author: Vitor <vitorqb@gmail.com>
;; Version: 0.0.1
;; Maintainer: Vitor <vitorqb@gmail.com>
;; Created: 2020-02-18
;; Keywords: elisp, compile
;; Homepage: https://github.com/vitorqb/mylisputils/blob/development/compile-transient.el

;; This file is not part of GNU Emacs.
     
;; Do whatever you want. No warranties.

(require 'transient)
(require 'dash)

;; Helpers
(defun compile-transient--unique-buffer-name (&rest _)
  (generate-new-buffer-name "*compilation*"))

(defun compile-transient--get-compilation-buffer-name-function (args)
  "Given value-formated infix arguments, returns a function used f"
  (-let* ((ensure-new-buffer? (--some (string= "--ensure-new-buffer" it) args))
          (new-buffer-name-arg (--some (and (s-prefix? "--new-buffer-name=" it) it) args))
          (new-buffer-name-val (-some--> new-buffer-name-arg
                                 (s-split-up-to "=" it 1)
                                 (car (cdr it)))))
    (cond
     ((and (not ensure-new-buffer?) (not new-buffer-name-val))
      compilation-buffer-name-function)

     ((and ensure-new-buffer? (not new-buffer-name-val))
      #'compile-transient--unique-buffer-name)

     ((and ensure-new-buffer? new-buffer-name-val)
      (-const (generate-new-buffer-name new-buffer-name-val)))

     ((and (not ensure-new-buffer?) new-buffer-name-val)
      (-const new-buffer-name-val)))))

;; Infixes
(if (fboundp 'transient-define-infix)
    (transient-define-infix compile-transient--set-buf-name-inf
      "An infix command that set's the global variable `compile-transient-buffer-name` to
   set the name of the compilation buffer."
      :class transient-option
      :argument "--new-buffer-name=")
  (define-infix-command compile-transient--set-buf-name-inf
    "An infix command that set's the global variable `compile-transient-buffer-name` to
   set the name of the compilation buffer."
    :class transient-option
    :argument "--new-buffer-name="))

;; Sufixes
(defun compile-transient--compile-suf (args)
  (interactive (list (transient-args 'compile-transient)))
  (-let* ((interactive? (--some (string= "--interactive" it) args))
          (ensure-new-buffer? (--some (string= "--ensure-new-buffer" it) args))
          (compilation-buffer-name-function
           (compile-transient--get-compilation-buffer-name-function args))
          (prefix-arg (if interactive? '(4) '())))
    (execute-extended-command prefix-arg "compile")))

(defun compile-transient--recompile-suf (args &optional compile-command)
  (interactive (list (transient-args 'compile-transient)))
  (-let* ((interactive? (--some (string= "--interactive" it) args))
          (prefix-arg (if interactive? '(4) '())))
    (execute-extended-command prefix-arg "recompile")))

(defun compile-transient--from-org-block-suf ()
  (interactive)
  (-let* (((_ (&plist :value command)) (org-element-at-point)))
    (setq compile-command (s-trim command))
    (call-interactively #'compile-transient--compile-suf)))

(defun compile-transient--from-region-suf (beg end)
  (interactive "r")
  (setq compile-command (buffer-substring-no-properties beg end))
  (call-interactively #'compile-transient--compile-suf))

(defun compile-transient--clean-suf ()
  (interactive)
  (setq compile-command "")
  (call-interactively #'compile-transient--compile-suf))

(defun compile-transient--from-kill-ring ()
  (interactive)
  (setq compile-command (-> (current-kill 0) substring-no-properties))
  (call-interactively #'compile-transient--compile-suf))

(defun compile-transient--cd-current-project ()
  (interactive)
  (setq compile-command (s-concat "cd " (projectile-project-root) " && "))
  (call-interactively #'compile-transient--compile-suf))

(if (fboundp 'define-transient-command)
    (define-transient-command compile-transient ()
      "A transient for compilation."
      ["Options"
       ("i" "Interactive compilation." ("-i" "--interactive"))
       ("n" "Ensure new buffer." ("-n" "--ensure-new-buffer"))
       ("N" "Set buffer name" compile-transient--set-buf-name-inf)]
      ["Actions (no command)"
       ("k" "Compile" compile-transient--compile-suf)
       ("c" "Clean Compile (no suggestion)" compile-transient--clean-suf)
       ("r" "Recompile" compile-transient--recompile-suf)]
      ["Actions (pre-filled commands)"
       ("b" "Compile from ORG BLOCK." compile-transient--from-org-block-suf)
       ("R" "Compile from REGION" compile-transient--from-region-suf)
       ("K" "Compile from KILL-RING" compile-transient--from-kill-ring)
       ("p" "Compile with cd to project root" compile-transient--cd-current-project)])
  (transient-define-prefix compile-transient ()
    "A transient for compilation."
    ["Options"
     ("i" "Interactive compilation." ("-i" "--interactive"))
     ("n" "Ensure new buffer." ("-n" "--ensure-new-buffer"))
     ("N" "Set buffer name" compile-transient--set-buf-name-inf)]
    ["Actions (no command)"
     ("k" "Compile" compile-transient--compile-suf)
     ("c" "Clean Compile (no suggestion)" compile-transient--clean-suf)
     ("r" "Recompile" compile-transient--recompile-suf)]
    ["Actions (pre-filled commands)"
     ("b" "Compile from ORG BLOCK." compile-transient--from-org-block-suf)
     ("R" "Compile from REGION" compile-transient--from-region-suf)
     ("K" "Compile from KILL-RING" compile-transient--from-kill-ring)
     ("p" "Compile with cd to project root" compile-transient--cd-current-project)]))

(provide 'compile-transient)
;;; compile-transient.el ends here
