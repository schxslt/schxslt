ifeq ($(OS),Windows_NT)
	XSPEC=xspec.cmd
	CALABASH=calabash.cmd
else
	XSPEC=xspec
	CALABASH=calabash
endif

.PHONY: clean
clean:
	rm tests/impl/*/*.sch.xsl

.PHONY: test
test:
	${CALABASH} schematron.xpl
