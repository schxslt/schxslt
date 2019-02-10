<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <pattern>
    <rule context="processing-instruction('foobar')">
      <assert test="false()" id="assert-processing-instruction"/>
    </rule>
  </pattern>
  <pattern>
    <rule context="comment()">
      <assert test="false()" id="assert-comment"/>
    </rule>
  </pattern>
  <pattern>
    <rule context="@foobar">
      <assert test="false()" id="assert-attribute"/>
    </rule>
  </pattern>
  <pattern>
    <rule context="text()">
      <assert test="false()" id="assert-text"/>
    </rule>
  </pattern>
</schema>
