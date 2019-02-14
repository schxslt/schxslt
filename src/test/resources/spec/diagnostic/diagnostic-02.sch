<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="*">
      <assert test="false()" diagnostics="d1"/>
    </rule>
  </pattern>
  <diagnostics>
    <diagnostic id="d1" xml:lang="en">
      Context: <value-of select="name()"/>
    </diagnostic>
  </diagnostics>
</schema>
