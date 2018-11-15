ifeq ($(OS),Windows_NT)
	XSPEC=xspec.cmd
else
	XSPEC=xspec
endif

.PHONY: test
test:
	${XSPEC} tests/xslt/expand.xspec
	${XSPEC} tests/xslt/include.xspec
	bats schematron.bats
