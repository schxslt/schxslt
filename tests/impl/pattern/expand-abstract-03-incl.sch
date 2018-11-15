<pattern xmlns="http://purl.oclc.org/dsdl/schematron" abstract="true" id="foobar">
  <let name="foo" value="'$fooValue'"/>
  <rule context="/">
    <let name="bar" value="'$barValue'"/>
    <report test="$foo eq 'bar'" id="R1"/>
    <report test="$bar eq 'foo'" id="R2"/>
  </rule>
</pattern>
