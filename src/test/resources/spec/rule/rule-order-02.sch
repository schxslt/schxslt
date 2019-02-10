<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <pattern>
    <rule context="html:table">
      <report test="true()" id="R1"/>
    </rule>
    <rule context="html:tr">
      <report test="true()" id="R2"/>
    </rule>
  </pattern>
  <properties/>
</schema>
