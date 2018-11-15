<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="/*">
      <assert test="false()" id="A01">
        <value-of  select="@attr"/>
      </assert>
    </rule>
  </pattern>
  <properties/>
</schema>
