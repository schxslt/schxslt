<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
  <pattern documents="'subordinate-01.sch'">
    <rule context="/*">
      <assert test="self::sch:schema" id="A1"/>
      <assert test="self::document" id="A2"/>
    </rule>
  </pattern>
  <pattern documents="('subordinate-01.sch', 'subordinate-01.xspec')">
    <rule context="/*">
      <assert test="true()"/>
    </rule>
  </pattern>
</schema>
