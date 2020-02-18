.PHONY: test tests

tests:
	test

test:
	cask exec ert-runner $(ERT_RUNNER_ARGS)
