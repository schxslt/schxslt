module namespace _ = "0004";

import module namespace s = "https://doi.org/10.5281/zenodo.1495494";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare variable $_:schema := document {
    <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt">
    <sch:phase id="phase1">
        <sch:active pattern="pattern1"/>
    </sch:phase>
    <sch:phase id="phase2">
        <sch:active pattern="pattern2"/>
    </sch:phase>
    <sch:pattern id="pattern1">
        <sch:rule context="/">
            <sch:assert test="true()">
                Pass Valid
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="pattern2">
        <sch:rule context="/">
            <sch:assert test="false()">
                Fail Invalid
            </sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
};

declare variable $_:xml := document {
    <document/>
};

declare
%test:assertTrue
%test:name('phase parameter pass')
function _:phase1() {
  let $p := <parameters><param name="phase" value="phase1"/></parameters>
  let $s := s:compile($_:schema, $p)
  let $r := s:validate($_:xml, $s)
  return s:is-valid($r)
};

declare
%test:assertFalse
%test:name('phase parameter fail')
function _:phase2() {
  let $p := <parameters><param name="phase" value="phase2"/></parameters>
  let $s := s:compile($_:schema, $p)
  let $r := s:validate($_:xml, $s)
  return s:is-valid($r)
};

declare
%test:assertTrue
%test:name('string parameter pass')
function _:phase1string() {
  let $s := s:compile($_:schema, 'phase1')
  let $r := s:validate($_:xml, $s)
  return s:is-valid($r)
};

declare
%test:assertFalse
%test:name('string parameter fail')
function _:phase2string() {
  let $s := s:compile($_:schema, 'phase2')
  let $r := s:validate($_:xml, $s)
  return s:is-valid($r)
};
