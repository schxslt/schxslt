<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" defaultPhase="phase">
  <let name="level0" value="'0'"/>
  <phase id="phase">
    <let name="level1" value="'1'"/>
    <active pattern="pattern"/>
  </phase>
  <pattern id="pattern">
    <rule context="/*">
      <let name="level3" value="'3'"/>
      <assert test="$level0 eq '0'" id="level0"/>
      <assert test="$level1 eq '1'" id="level1"/>
      <assert test="$level3 eq '3'" id="level3"/>
    </rule>
    <rule context="element">
      <assert test="$level0 eq '0'" id="level0a"/>
      <assert test="$level1 eq '1'" id="level1a"/>
    </rule>      
  </pattern>
</schema>
