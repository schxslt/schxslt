<p:declare-step version="1.0" name="validate-with-schematron" type="schxslt:validate-with-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:schxslt="http://dmaus.name/ns/schxslt">

  <p:option name="phase" select="''"/>

  <p:input  port="source" primary="true"/>
  <p:input  port="schema"/>

  <p:output port="result" primary="true">
    <p:pipe step="validate-with-schematron" port="source"/>
  </p:output>
  <p:output port="report">
    <p:pipe step="validate" port="result"/>
  </p:output>

  <p:serialization port="report" indent="true"/>

  <p:group name="compile-schematron">
    <p:output port="result">
      <p:pipe step="compile" port="result"/>
    </p:output>

    <p:xslt>
      <p:input port="source">
        <p:pipe step="validate-with-schematron" port="schema"/>
      </p:input>
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
        <p:document href="../xslt/compile.xsl"/>
      </p:input>
    </p:xslt>
  </p:group>

  <p:xslt name="validate">
    <p:input port="source">
      <p:pipe step="validate-with-schematron" port="source"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe step="compile-schematron" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
