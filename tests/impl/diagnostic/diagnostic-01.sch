<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="*">
      <assert test="false()" diagnostics="d1 d2"/>
    </rule>
  </pattern>
  <diagnostics>
    <diagnostic id="d1">
      Context: <value-of select="name()"/>
    </diagnostic>
    <diagnostic id="d2">
      Context: <value-of select="name()"/>
    </diagnostic>
  </diagnostics>
</schema>
