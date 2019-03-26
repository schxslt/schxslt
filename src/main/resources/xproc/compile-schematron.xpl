<p:declare-step version="1.0" name="compile-schematron" type="schxslt:compile-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

  <p:option name="phase" select="''"/>

  <p:input  port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:serialization port="result" indent="true"/>

  <p:choose>
    <p:when test="/sch:schema/@queryBinding ne 'xslt2'">
      <p:error code="schxslt:UnsupportedQueryBinding">
        <p:input port="source">
          <p:empty/>
        </p:input>
      </p:error>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xslt/include.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xslt/expand.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt name="compile">
    <p:with-param name="phase" select="$phase"/>
    <p:input port="stylesheet">
      <p:document href="../xslt/compile-for-svrl.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>
