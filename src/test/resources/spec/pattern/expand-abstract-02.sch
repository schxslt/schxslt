<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <ns prefix="html" uri="http://www.w3.org/1999/xhtml"/>
  <include href="expand-abstract-02-incl.sch"/>
  <pattern is-a="table">
    <param name="table" value="html:table"/>
    <param name="row"   value="html:tr"/>
    <param name="entry" value="html:td"/>
  </pattern>
  <properties/>
</schema>
