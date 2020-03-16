module namespace _ = "0001";

import module namespace s = "https://doi.org/10.5281/zenodo.1495494";

declare namespace svrl="http://purl.oclc.org/dsdl/svrl";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $_:schema := document {
    <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt">

</sch:schema>
};

declare variable $_:xml := document {
    <document/>
};


declare
%test:assertExists
%test:name('compile empty schema')
function _:compile() {
  let $c := s:compile($_:schema)
  return $c[self::xsl:stylesheet]
};

declare
%test:assertExists
%test:name('validate empty document')
function _:validationResult() {
  let $c := s:compile($_:schema)
  let $r := s:validate($_:xml, $c)
  return $r[self::svrl:schematron-output]
};
