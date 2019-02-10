<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <pattern abstract="true" id="foobar" documents="('$filename')">
    <rule context="sch:schema">
      <report test="true()" id="R1"/>
    </rule>
  </pattern>
  <pattern is-a="foobar">
    <param name="filename" value="expand-abstract-04.sch"/>
  </pattern>
  <properties/>
</schema>
