<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <phase id="default">
    <active pattern="P02"/>
  </phase>
  <pattern id="P01">
    <rule context="/">
      <assert test="false()" id="A01"/>
    </rule>
  </pattern>
  <pattern id="P02">
    <rule context="/">
      <assert test="false()" id="A02"/>
    </rule>
  </pattern>
  <properties/>
</schema>
