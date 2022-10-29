#!/bin/bash
cask emacs --batch -l ./test/test-helper.el -l ./test/compile-transient-test.el -f ert-run-tests-batch
