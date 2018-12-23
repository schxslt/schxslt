<p:declare-step version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:run="tag:maus@hab.de,2018:xproc-xspec"
                xmlns:p="http://www.w3.org/ns/xproc">

  <p:output port="result" sequence="true"/>

  <p:option name="filter" select="'.*\.xspec$'"/>
  <p:option name="strategy" select="'traditional'"/>

  <p:import href="vendor/xproc-xspec/library.xpl"/>

  <p:directory-list path="tests/impl"/>
  <p:viewport match="/c:directory/c:directory">
    <p:directory-list>
      <p:with-option name="include-filter" select="$filter"/>
      <p:with-option name="path" select="resolve-uri(c:directory/@name, base-uri(c:directory))"/>
    </p:directory-list>
  </p:viewport>

  <p:for-each>
    <p:iteration-source select="//c:file"/>
    <p:load>
      <p:with-option name="href" select="resolve-uri(c:file/@name, base-uri(c:file))"/>
    </p:load>
    <run:xspec-schematron>
      <p:with-param name="strategy" select="$strategy"/>
      <p:with-option name="XSpecHome" select="resolve-uri('vendor/xspec/', static-base-uri())"/>
      <p:with-option name="SchematronXsltInclude" select="resolve-uri('src/xslt/include.xsl', static-base-uri())"/>
      <p:with-option name="SchematronXsltExpand" select="resolve-uri('src/xslt/expand.xsl', static-base-uri())"/>
      <p:with-option name="SchematronXsltCompile" select="resolve-uri('src/xslt/compile.xsl', static-base-uri())"/>
    </run:xspec-schematron>
  </p:for-each>

</p:declare-step>
