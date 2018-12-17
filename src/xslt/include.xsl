<!-- Perform inclusions as per 5.4.3 and 5.4.3 -->
<xsl:transform version="2.0" exclude-result-prefixes="#all"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

  <xsl:template match="sch:schema">
    <xsl:call-template name="schxslt:include">
      <xsl:with-param name="schematron" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="schxslt:include">
    <xsl:param name="schematron" as="element(sch:schema)" required="yes"/>
    <xsl:variable name="result" as="element(sch:schema)">
      <xsl:apply-templates select="$schematron" mode="schxslt:include"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$result//sch:include or $result//sch:extends[@href]">
        <xsl:call-template name="schxslt:include">
          <xsl:with-param name="schematron" select="$result" as="element(sch:schema)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sch:schema" mode="schxslt:include">
    <xsl:copy>
      <xsl:attribute name="xml:base" select="base-uri()"/>
      <xsl:sequence select="@* except @xml:base"/>
      <xsl:apply-templates mode="schxslt:include"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node() | @*" mode="schxslt:include">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- 5.4.3
       An extends attribute with an href attribute shall reference external declarations. The href attribute is an IRI
       reference to an external well-formed XML document or to an element in external well-formed XML document that is
       Schematron element of the same type as the parent element of the extends element. The contents of that referenced
       element shall be inserted in place of the extends element.
  -->
  <xsl:template match="sch:extends[@href]" mode="schxslt:include">
    <xsl:variable name="extends" select="doc(resolve-uri(@href, base-uri(.)))"/>
    <xsl:variable name="element" select="if ($extends instance of element()) then $extends else $extends/*"/>
    <xsl:if test="(local-name($element) eq local-name(..)) and (namespace-uri($element) eq 'http://purl.oclc.org/dsdl/schematron')">
      <xsl:for-each select="$element/*">
        <xsl:copy>
          <xsl:sequence select="@* except @xml:base"/>
          <xsl:attribute name="xml:base" select="base-uri(.)"/>
          <xsl:sequence select="node()"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- 5.4.4
       The required href attribute shall be an IRI reference to a well-formed XML document or to an element in a
       well-formed XML document
  -->
  <xsl:template match="sch:include" mode="schxslt:include">
    <xsl:variable name="include" select="doc(resolve-uri(@href, base-uri(.)))"/>
    <xsl:variable name="element" select="if ($include instance of element()) then $include else $include/*"/>
    <xsl:for-each select="$element">
      <xsl:copy>
        <xsl:sequence select="@* except @xml:base"/>
        <xsl:attribute name="xml:base" select="base-uri(.)"/>
        <xsl:sequence select="node()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:transform>
