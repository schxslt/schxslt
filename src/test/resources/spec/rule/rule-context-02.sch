<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <let name="localname" value="'document'"/>
    <rule context="*[local-name() eq $localname]">
      <assert test="false()" id="A01"/>
    </rule>
  </pattern>
</schema>
