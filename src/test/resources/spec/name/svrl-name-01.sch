<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="/*">
      <assert test="false()" id="A01">
        <name/>
      </assert>
    </rule>
  </pattern>
  <pattern>
    <rule context="/*">
      <assert test="false()" id="A02">
        <name path="@attr"/>
      </assert>
    </rule>
  </pattern>
  <properties/>
</schema>
