module namespace _ = "0005";

import module namespace s = "https://doi.org/10.5281/zenodo.1495494" at "../../schematron.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $_:schema := document {
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:sqf="http://www.schematron-quickfix.com/validator/process" queryBinding="xslt">
    <sch:pattern>
        <sch:title>title</sch:title>
        <sch:p>paragraph</sch:p>
        <sch:rule context="title">
            <sch:report test="true()" role="info">
                always true
            </sch:report>
            <sch:assert test="false()" role="info">
                always false
            </sch:assert>
            <sch:report test="3 &gt; count(following-sibling::p)" role="warn">
                short section has fewer than 3 paragraphs
            </sch:report>
        </sch:rule>
        <sch:rule context="p">
            <sch:assert test="boolean(normalize-space())" role="error">
                p (paragraph) should not be empty
            </sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>
};

declare variable $_:xml1 := document {
<document>
    <title>Schematron for eXist</title>
    <p>This is a test of running ISO Schematron in eXist</p>
    <p/>
</document>
};

declare variable $_:xml2 := document {
<document>
    <title>Schematron for eXist</title>
    <p>This is a test of running ISO Schematron in eXist</p>
</document>
};

declare variable $_:xml3 := document {
<document>
    <p>This is a test of running ISO Schematron in eXist</p>
</document>
};

declare
%test:assertEquals(
    'false',
    'true',
    4,
    'info',
    'info',
    'warn',
    'error',
    '/document/title',
    'short section has fewer than 3 paragraphs',
    '/document/p[2]',
    'p (paragraph) should not be empty'
    )
%test:name('message has info, warn, and error')
function _:example1a() {
  let $sch := s:compile($_:schema)
  let $svrl := s:validate($_:xml1, $sch)
  return (
    s:is-valid($svrl),
    s:has-messages($svrl),
    count(s:messages($svrl)),
    s:message-level(s:messages($svrl)[1]),
    s:message-level(s:messages($svrl)[2]),
    s:message-level(s:messages($svrl)[3]),
    s:message-level(s:messages($svrl)[4]),
    s:message-location(s:messages($svrl)[3]),
    normalize-space(s:message-description(s:messages($svrl)[3])),
    s:message-location(s:messages($svrl)[4]),
    normalize-space(s:message-description(s:messages($svrl)[4]))
  )
};

declare
%test:assertEquals(
    'true',
    'true',
    3,
    'info',
    'info',
    'warn',
    '/document/title',
    'short section has fewer than 3 paragraphs'
    )
%test:name('valid with info and warning')
function _:example1b() {
  let $sch := s:compile($_:schema)
  let $svrl := s:validate($_:xml2, $sch)
  return (
    s:is-valid($svrl),
    s:has-messages($svrl),
    count(s:messages($svrl)),
    s:message-level(s:messages($svrl)[1]),
    s:message-level(s:messages($svrl)[2]),
    s:message-level(s:messages($svrl)[3]),
    s:message-location(s:messages($svrl)[3]),
    normalize-space(s:message-description(s:messages($svrl)[3]))
  )
};

declare
%test:assertEquals('true', 'false')
%test:name('validate schematron without messages')
function _:example1c() {
  let $sch := s:compile($_:schema)
  let $svrl := s:validate($_:xml3, $sch)
  return (
    s:is-valid($svrl),
    s:has-messages($svrl)
  )
};
