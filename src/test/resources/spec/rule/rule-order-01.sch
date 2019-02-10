<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="/">
      <assert test="true()" id="A01"/>
    </rule>
    <rule context="/*">
      <assert test="true()" id="A02"/>
    </rule>
    <rule context="/*">
      <assert test="false()" id="A03"/>
    </rule>
    <rule context="/*">
      <assert test="true()" id="A04"/>
    </rule>
  </pattern>
</schema>
