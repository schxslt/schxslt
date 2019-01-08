<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <let name="foo" value="'bar'"/>
    <rule context="element[@attr = $foo]">
      <assert test="false()" id="A-01"/>
    </rule>
  </pattern>
  <properties/>
</schema>
