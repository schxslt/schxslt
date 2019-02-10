<pattern xmlns="http://purl.oclc.org/dsdl/schematron" abstract="true" id="table">
  <rule context="$table">
    <report test="$row" id="R1"/>
  </rule>
  <rule context="$row">
    <report test="$entry" id="R2"/>
  </rule>
</pattern>
