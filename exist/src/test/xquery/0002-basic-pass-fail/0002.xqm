module namespace _ = "0002";

import module namespace s = "https://doi.org/10.5281/zenodo.1495494";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $_:schema := document {
    <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt">
    <sch:pattern>
        <sch:rule context="title">
            <sch:assert test="following-sibling::p">
                title should be followed by a p (paragraph) element
            </sch:assert>
        </sch:rule>
        <sch:rule context="p">
            <sch:assert test="boolean(normalize-space())">
                p (paragraph) should not be empty
            </sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
};

declare variable $_:valid := document {
<document>
    <title>Schematron for eXist</title>
    <p>This is a test of running ISO Schematron in eXist</p>
</document>
};

declare variable $_:invalid := document {
<document>
    <title>Schematron for eXist</title>
    <p>This is a test of running ISO Schematron in eXist</p>
    <p/>
</document>
};

declare
%test:assertTrue
%test:name('simple pass')
function _:valid() {
  let $r := s:validate($_:valid, s:compile($_:schema))
  return s:is-valid($r)
};

declare
%test:assertFalse
%test:name('simple fail')
function _:invalid() {
  let $r := s:validate($_:invalid, s:compile($_:schema))
  return s:is-valid($r)
};

declare
%test:assertEmpty
%test:name('valid message')
function _:valid-messages() {
  let $r := s:messages(s:validate($_:valid, s:compile($_:schema)))
  return $r
};

declare
%test:assertEquals(1)
%test:name('invalid message')
function _:invalid-messages() {
  let $r := s:messages(s:validate($_:invalid, s:compile($_:schema)))
  return count($r)
};
