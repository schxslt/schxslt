<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <pattern abstract="true" id="table">
    <rule context="$table">
      <report test="$row" id="R1"/>
    </rule>
    <rule context="$row">
      <report test="$entry" id="R2"/>
    </rule>
  </pattern>
  <pattern is-a="table">
    <param name="table" value="html:table"/>
    <param name="row"   value="html:tr"/>
    <param name="entry" value="html:td"/>
  </pattern>
  <properties/>
</schema>
