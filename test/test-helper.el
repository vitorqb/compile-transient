;;; test-helper.el --- Helpers for compile-transient-test.el
(require 'compile-transient)
(require 'dash)
(require 'dash-functional)

(when (> emacs-major-version 26)
  (defalias 'ert--print-backtrace 'backtrace-to-string))
;;; test-helper.el ends here
