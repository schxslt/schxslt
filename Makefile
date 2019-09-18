VERSION := $(file < VERSION)

.PHONY: update-version
update-version:
	cp VERSION src/main/resources
	calabash lib/update-version.xpl
