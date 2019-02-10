<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" defaultPhase="default">
  <phase id="default">
    <let name="localname" value="'document'"/>
    <active pattern="P01"/>
  </phase>
  <pattern id="P01">
    <rule context="*[local-name() eq $localname]">
      <assert test="false()" id="A01"/>
    </rule>
  </pattern>
</schema>
