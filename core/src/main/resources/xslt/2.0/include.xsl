<xsl:transform version="2.0" exclude-result-prefixes="#all"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

  <!-- Entry for recursive inclusion -->
  <xsl:template match="sch:schema">
    <xsl:call-template name="schxslt:include">
      <xsl:with-param name="schematron" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- Recursive inclusion -->
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

  <!-- Copy outermost element and keep it's base URI -->
  <xsl:template match="sch:schema" mode="schxslt:include">
    <xsl:copy>
      <xsl:call-template name="schxslt:copy-attributes">
        <xsl:with-param name="context" as="element()" select="."/>
      </xsl:call-template>
      <xsl:apply-templates mode="schxslt:include"/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all other elements -->
  <xsl:template match="node() | @*" mode="schxslt:include">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- Replace with contents of external definition -->
  <xsl:template match="sch:extends[@href]" mode="schxslt:include">
    <xsl:variable name="extends" select="doc(if (exists(schxslt:base-uri(.))) then resolve-uri(@href, schxslt:base-uri(.)) else resolve-uri(@href))"/>
    <xsl:variable name="element" select="if ($extends instance of element()) then $extends else $extends/*"/>
    <xsl:if test="(local-name($element) eq local-name(..)) and (namespace-uri($element) eq 'http://purl.oclc.org/dsdl/schematron')">
      <xsl:for-each select="$element/*">
        <xsl:copy>
          <xsl:call-template name="schxslt:copy-attributes">
            <xsl:with-param name="context" as="element()" select="."/>
          </xsl:call-template>
          <xsl:sequence select="node()"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- Replace with external definition -->
  <xsl:template match="sch:include" mode="schxslt:include">
    <xsl:variable name="include" select="doc(if (exists(schxslt:base-uri(.))) then resolve-uri(@href, schxslt:base-uri(.)) else resolve-uri(@href))"/>
    <xsl:variable name="element" select="if ($include instance of element()) then $include else $include/*"/>
    <xsl:for-each select="$element">
      <xsl:copy>
        <xsl:call-template name="schxslt:copy-attributes">
          <xsl:with-param name="context" as="element()" select="."/>
        </xsl:call-template>
        <xsl:sequence select="node()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="schxslt:base-uri" as="xs:string?">
    <xsl:param name="node" as="node()"/>
    <xsl:variable name="uri" as="xs:anyURI?" select="base-uri($node)"/>
    <xsl:sequence select="if (matches($uri, '^[a-zA-Z.+-]+:/')) then string($uri) else ()"/>
  </xsl:function>

  <xsl:template name="schxslt:copy-attributes" as="attribute()*">
    <xsl:param name="context" as="element()" required="yes"/>
    <xsl:param name="base-uri-fixup" as="xs:boolean" select="true()"/>

    <xsl:variable name="xmlbase" as="attribute(xml:base)?">
      <xsl:choose>
        <xsl:when test="$base-uri-fixup and base-uri($context)">
          <xsl:attribute name="xml:base" select="base-uri($context)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$context/@xml:base"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="($context/@* except $context/@xml:base, $xmlbase)"/>

  </xsl:template>

</xsl:transform>
