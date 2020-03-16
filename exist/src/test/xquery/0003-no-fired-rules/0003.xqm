module namespace _ = "0003";

import module namespace s = "https://doi.org/10.5281/zenodo.1495494";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $_:schema := document {
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt">
    <sch:pattern>
        <sch:rule context="p">
            <sch:assert test="true()"/>
        </sch:rule>
    </sch:pattern>
</sch:schema>
};

declare variable $_:xml := document {
<root>
    <!--  -->
</root>
};

(:~ Expect validation to fail if the Schematron doesn't match anything in the document. :)
declare
%test:assertFalse
%test:name('No rules fail for 0 matches')
function _:test() {
  let $c := s:compile($_:schema)
  let $r := s:validate($_:xml, $c)
  return s:is-valid($r)
};
