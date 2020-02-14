xquery version "3.1";

(:~
 : XUnit for the BaseX module.
 :
 : @author David Maus
 : @see    https://doi.org/10.5281/zenodo.1495494
 : @see    https://basex.org
 :
 :)

module namespace test = 'http://basex.org/modules/xqunit-tests';

import module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494" at "../../../main/xquery/basex/content/schxslt.xqm";

declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare %unit:test("expected", "schxslt:UnsupportedQueryBinding") function test:fail-on-unsupported-query-binding () {
  let $schema := <sch:schema queryBinding="unknown"/>
  return
    schxslt:validate($schema, $schema)
};

declare %unit:test function test:validate-with-param () {
  let $schema := <sch:schema><sch:let name="variable"/><sch:pattern><sch:rule context="sch:schema"><sch:report test="$variable = 1"/></sch:rule></sch:pattern></sch:schema>
  let $report := schxslt:validate($schema, $schema, (), map{"validate": map{"variable": 1}})
  return
    unit:assert($report//svrl:successful-report)
};

declare %unit:test function test:validate-with-xslt () {
  let $schema := <sch:schema><sch:pattern><sch:rule context="sch:schema"><sch:assert test="true()"/></sch:rule></sch:pattern></sch:schema>
  let $report := schxslt:validate($schema, $schema)
  return
    unit:assert($report//svrl:fired-rule)
};

declare %unit:test function test:validate-with-xslt2 () {
  let $schema := <sch:schema queryBinding="xslt2"><sch:pattern><sch:rule context="sch:schema"><sch:assert test="true()"/></sch:rule></sch:pattern></sch:schema>
  let $report := schxslt:validate($schema, $schema)
  return
    unit:assert($report//svrl:fired-rule)
};
