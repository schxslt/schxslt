<p:declare-step version="3.0" name="compile-schematron" type="schxslt:compile-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <p:option name="phase" as="xs:string" select="'#DEFAULT'"/>

  <p:input  port="source"/>
  <p:output port="result"/>

  <p:choose>
    <p:when test="lower-case(/sch:schema/@queryBinding) = ('xslt2', 'xslt3')">
      <p:xslt parameters="map{xs:QName('phase'): $phase}">
        <p:with-input port="stylesheet">
          <p:document href="../../xslt/2.0/pipeline-for-svrl.xsl"/>
        </p:with-input>
      </p:xslt>
    </p:when>
    <p:when test="lower-case(/sch:schema/@queryBinding) = ('', 'xslt')">
      <p:xslt>
        <p:with-input port="stylesheet">
          <p:document href="../../xslt/1.0/include.xsl"/>
        </p:with-input>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet">
          <p:document href="../../xslt/1.0/expand.xsl"/>
        </p:with-input>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet">
          <p:document href="../../xslt/1.0/compile-for-svrl.xsl"/>
        </p:with-input>
      </p:xslt>
    </p:when>
    <p:otherwise>
      <p:error code="schxslt:UnsupportedQueryBinding">
        <p:with-input port="source">
          <p:empty/>
        </p:with-input>
      </p:error>
    </p:otherwise>
  </p:choose>

</p:declare-step>
