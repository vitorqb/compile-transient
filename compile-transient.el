(require 'transient)
(require 'dash)

(defun compile-transient--compile-suf (args)
  (interactive (list (transient-args 'compile-transient)))
  (-let* ((interactive? (--some (string= "--interactive" it) args))
          (prefix-arg (if interactive? '(4) '())))
    (execute-extended-command prefix-arg "compile")))

(defun compile-transient--recompile-suf (args &optional compile-command)
  (interactive (list (transient-args 'compile-transient)))
  (-let* ((interactive? (--some (string= "--interactive" it) args))
          (prefix-arg (if interactive? '(4) '())))
    (execute-extended-command prefix-arg "recompile")))

(defun compile-transient--from-org-block-suf ()
  (interactive)
  (-let* (((_ (&plist :value command)) (org-element-at-point))
          (compile-command (s-trim command)))
    (call-interactively #'compile-transient--compile-suf)))

(defun compile-transient--from-region-suf (beg end)
  (interactive "r")
  (let ((compile-command (buffer-substring-no-properties beg end)))
    (call-interactively #'compile-transient--compile-suf)))

(defun compile-transient--clean-suf ()
  (interactive)
  (let ((compile-command ""))
    (call-interactively #'compile-transient--compile-suf)))

(defun compile-transient--from-kill-ring ()
  (interactive)
  (let ((compile-command (-> (current-kill 0) substring-no-properties)))
    (call-interactively #'compile-transient--compile-suf)))

(define-transient-command compile-transient ()
  "A transient for compilation."
  ["Options"
   ("i" "Interactive compilation." ("-i" "--interactive"))]
  ["Actions (no command)"
   ("c" "Compile" compile-transient--compile-suf)
   ("C" "Clean Compile (no suggestion)" compile-transient--clean-suf)
   ("r" "Recompile" compile-transient--recompile-suf)]
  ["Actions (pre-filled commands)"
   ("b" "Compile from ORG BLOCK." compile-transient--from-org-block-suf)
   ("R" "Compile from REGION" compile-transient--from-region-suf)
   ("k" "Compile from KILL-RING" compile-transient--from-kill-ring)])

(provide 'compile-transient)
