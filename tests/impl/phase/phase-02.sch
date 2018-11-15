<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" defaultPhase="default">
  <phase id="default">
    <active pattern="P01"/>
  </phase>
  <pattern id="P01">
    <rule context="/">
      <assert test="false()" id="A01"/>
    </rule>
  </pattern>
  <pattern>
    <rule context="/">
      <assert test="false()" id="A02"/>
    </rule>
  </pattern>
  <properties/>
</schema>
