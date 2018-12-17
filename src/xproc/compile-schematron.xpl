<p:declare-step version="1.0" name="compile-schematron" type="schxslt:compile-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

  <p:option name="phase" select="''"/>
  <p:option name="strategy" select="'traditional'"/>

  <p:input  port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:serialization port="result" indent="true"/>

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
    <p:with-param name="strategy" select="$strategy"/>
    <p:input port="stylesheet">
      <p:document href="../xslt/compile.xsl"/>
    </p:input>
  </p:xslt>

</p:declare-step>
