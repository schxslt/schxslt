<p:declare-step version="1.0" name="validate-with-schematron" type="schxslt:validate-with-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">


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

  <p:import href="compile-schematron.xpl"/>

  <schxslt:compile-schematron name="compile-schematron">
    <p:input port="source">
      <p:pipe step="validate-with-schematron" port="schema"/>
    </p:input>
    <p:with-option name="phase" select="$phase"/>
  </schxslt:compile-schematron>

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
