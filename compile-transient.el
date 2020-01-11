(require 'transient)
(require 'dash)

(defun compile-transient--unique-buffer-name ()
  (generate-new-buffer-name "*compilation*"))

(defun compile-transient--compile-suf (args)
  (interactive (list (transient-args 'compile-transient)))
  (-let* ((interactive? (--some (string= "--interactive" it) args))
          (ensure-new-buffer? (--some (string= "--ensure-new-buffer" it) args))
          (compilation-buffer-name-function (if ensure-new-buffer?
                                                (-const (compile-transient--unique-buffer-name))
                                              compilation-buffer-name-function))
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

(defun compile-transient--cd-current-project ()
  (interactive)
  (let ((compile-command (s-concat "cd " (projectile-project-root) " && ")))
    (call-interactively #'compile-transient--compile-suf)))

(define-transient-command compile-transient ()
  "A transient for compilation."
  ["Options"
   ("i" "Interactive compilation." ("-i" "--interactive"))
   ("n" "Ensure new buffer." ("-n" "--ensure-new-buffer"))]
  ["Actions (no command)"
   ("k" "Compile" compile-transient--compile-suf)
   ("c" "Clean Compile (no suggestion)" compile-transient--clean-suf)
   ("r" "Recompile" compile-transient--recompile-suf)]
  ["Actions (pre-filled commands)"
   ("b" "Compile from ORG BLOCK." compile-transient--from-org-block-suf)
   ("R" "Compile from REGION" compile-transient--from-region-suf)
   ("K" "Compile from KILL-RING" compile-transient--from-kill-ring)
   ("p" "Compile with cd to project root" compile-transient--cd-current-project)])

(provide 'compile-transient)
