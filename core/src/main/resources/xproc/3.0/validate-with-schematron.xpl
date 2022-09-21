<p:declare-step version="3.0" name="validate-with-schematron" type="schxslt:validate-with-schematron"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <p:import href="compile-schematron.xpl"/>

  <p:option name="phase" as="xs:string" select="'#DEFAULT'"/>

  <p:input  port="source"/>
  <p:input  port="schema"/>

  <p:output port="result" pipe="source@validate-with-schematron" primary="true"/>
  <p:output port="report" pipe="result@validate"/>

  <schxslt:compile-schematron name="compile-schematron" phase="{$phase}">
    <p:with-input pipe="schema@validate-with-schematron"/>
  </schxslt:compile-schematron>

  <p:xslt name="validate">
    <p:with-input port="source" pipe="source@validate-with-schematron"/>
    <p:with-input port="stylesheet" pipe="result@compile-schematron"/>
  </p:xslt>

</p:declare-step>
