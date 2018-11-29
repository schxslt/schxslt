<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern id="pattern-1">
    <let name="variable" value="'in-pattern-1'"/>
    <rule context="*">
      <assert test="true()" id="A01"/>
    </rule>
  </pattern>
  <pattern id="pattern-2">
    <let name="variable" value="'in-pattern-2'"/>
    <rule context="*">
      <assert test="true()" id="A02"/>
    </rule>
  </pattern>
</schema>
