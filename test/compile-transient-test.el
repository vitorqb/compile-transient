;;; compile-transient-test.el --- Tests for compile-transient -*- lexical-binding: t -*-
(ert-deftest test-compile-transient--get-compilation-buffer-name-function ()
  
  ;; No args -> default function
  (-let [args nil]
    (should (eq (compile-transient--get-compilation-buffer-name-function args)
                compilation-buffer-name-function)))

  ;; Args but no `--new-buffer-name=` nor `--ensure-new-buffer` -> default function
  (-let [args '("--foo=bar" "--baz")]
    (should (eq (compile-transient--get-compilation-buffer-name-function args)
                compilation-buffer-name-function)))

  ;; With `--ensure-new-buffer` and not `--new-buffer-name` -> Returns fn for unique name
  (-let* ((args '("--ensure-new-buffer"))
          (result (compile-transient--get-compilation-buffer-name-function args)))
    (should (eq result #'compile-transient--unique-buffer-name)))

  ;; With `--new-buffer-name` and `--new-buffer-name` -> call generate-new-buffer-name with name
  (cl-letf (((symbol-function 'generate-new-buffer-name)
             (lambda (x) (concat x "<3>"))))
    (-let* ((args '("--ensure-new-buffer" "--new-buffer-name=*foo*"))
            (result (compile-transient--get-compilation-buffer-name-function args))
            (result-buffer-name (funcall result)))
      (should (string= result-buffer-name "*foo*<3>"))))

  ;; With `--new-buffer-name` and without `--new-buffer-name` -> return name
  (cl-letf (((symbol-function 'generate-new-buffer-name)
             (lambda (x) (concat x "<4>"))))
    (-let* ((args '("--new-buffer-name=*foo*"))
            (result (compile-transient--get-compilation-buffer-name-function args))
            (result-buffer-name (funcall result)))
      (should (string= result-buffer-name "*foo*")))))
;;; compile-transient-test.el ends here
