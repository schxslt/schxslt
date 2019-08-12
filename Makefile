VERSION := $(file < VERSION)

.PHONY: test
test: clean
	mvn test
	basex -c "TEST src/test/xquery/basex/"

.PHONY: clean
clean:
	rm -f src/test/resources/spec/*/*.sch.xsl
	mvn clean

.PHONY: update-version
update-version:
	calabash lib/update-version.xpl

basex-module:
	cd src/main/xquery/basex; zip -r ../../../../target/xquery-basex-${VERSION}.xar content expath-pkg.xml

exist-module:
	cd src/main/xquery/exist; zip -r ../../../../target/xquery-exist-${VERSION}.xar content expath-pkg.xml repo.xml

exist-docker:
	docker pull existdb/existdb:release
	docker run -dit -p 8080:8080 -p 8443:8443 --name exist existdb/existdb:release

