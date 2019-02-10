ifeq ($(OS),Windows_NT)
	XSPEC=xspec.cmd
	CALABASH=calabash.cmd
else
	XSPEC=xspec
	CALABASH=calabash
endif

.PHONY: test
test:
	${CALABASH} src/test/resources/runner.xpl
