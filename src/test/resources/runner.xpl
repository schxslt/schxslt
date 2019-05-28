<p:declare-step version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:run="tag:maus@hab.de,2018:xproc-xspec"
                xmlns:p="http://www.w3.org/ns/xproc">

  <p:output port="result" sequence="true"/>

  <p:import href="../../../lib/xproc-xspec/library.xpl"/>

  <p:group name="test-spec">

    <p:output  port="result" sequence="true" primary="true"/>

    <p:directory-list path="spec"/>
    <p:viewport match="/c:directory/c:directory">
      <p:directory-list include-filter=".*\.xspec$">
        <p:with-option name="path" select="resolve-uri(c:directory/@name, base-uri(c:directory))"/>
      </p:directory-list>
    </p:viewport>

    <p:for-each>
      <p:iteration-source select="//c:file"/>
      <p:load>
        <p:with-option name="href" select="resolve-uri(c:file/@name, base-uri(c:file))"/>
      </p:load>
      <run:xspec-schematron>
        <p:with-option name="XSpecHome" select="resolve-uri('../../../lib/xspec/', static-base-uri())"/>
        <p:with-option name="SchematronXsltInclude" select="resolve-uri('../../main/resources/xslt/2.0/include.xsl', static-base-uri())"/>
        <p:with-option name="SchematronXsltExpand" select="resolve-uri('../../main/resources/xslt/2.0/expand.xsl', static-base-uri())"/>
        <p:with-option name="SchematronXsltCompile" select="resolve-uri('../../main/resources/xslt/2.0/compile-for-svrl.xsl', static-base-uri())"/>
      </run:xspec-schematron>
    </p:for-each>

  </p:group>

  <p:group name="test-impl">

    <p:output  port="result" sequence="true" primary="true"/>

    <p:directory-list path="impl" include-filter=".*\.xspec$"/>
    <p:for-each>
      <p:iteration-source select="//c:file"/>
      <p:load>
        <p:with-option name="href" select="resolve-uri(c:file/@name, base-uri(c:file))"/>
      </p:load>
      <run:xspec-xslt>
        <p:with-option name="XSpecHome" select="resolve-uri('../../../lib/xspec/', static-base-uri())"/>
      </run:xspec-xslt>
    </p:for-each>
    
  </p:group>

  <p:wrap-sequence wrapper="reports" wrapper-prefix="x" wrapper-namespace="http://www.jenitennison.com/xslt/xspec">
    <p:input port="source">
      <p:pipe step="test-spec" port="result"/>
      <p:pipe step="test-impl" port="result"/>
    </p:input>
  </p:wrap-sequence>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="format-report.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
