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
    <xsl:apply-templates mode="schxslt:include" select="."/>
  </xsl:template>

  <xsl:template match="node() | @*" mode="schxslt:include">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:include" mode="schxslt:include">
    <xsl:param name="base-uri" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="include" select="document(if ($base-uri) then resolve-uri(@href, $base-uri) else @href)"/>
    <xsl:apply-templates select="$include" mode="schxslt:include">
      <xsl:with-param name="base-uri" as="xs:string?" tunnel="yes" select="base-uri($include)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="sch:extends[@href]" mode="schxslt:include">
    <xsl:param name="base-uri" as="xs:string?" tunnel="yes"/>
    <xsl:variable name="extends" select="document(if ($base-uri) then resolve-uri(@href, $base-uri) else @href)"/>
    <xsl:variable name="element" as="element()" select="if ($extends instance of element()) then $extends else $extends/*"/>
    <xsl:if test="(local-name($element) eq local-name(..)) and (namespace-uri($element) eq 'http://purl.oclc.org/dsdl/schematron')">
      <xsl:apply-templates mode="schxslt:include" select="$element/*">
        <xsl:with-param name="base-uri" as="xs:string?" tunnel="yes" select="base-uri($element)"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- <!-\- Replace with contents of external definition -\-> -->
  <!-- <xsl:template match="sch:extends[@href]" mode="schxslt:include"> -->
  <!--   <xsl:variable name="location" -->
  <!--                 select="if (ancestor::*/@schxslt:base-uri) then resolve-uri(@href, ancestor::*/@schxslt:base-uri[1]) else @href"/> -->
  <!--   <xsl:variable name="extends" select="document($location)"/> -->
  <!--   <xsl:variable name="element" select="if ($extends instance of element()) then $extends else $extends/*"/> -->
  <!--   <xsl:if test="(local-name($element) eq local-name(..)) and (namespace-uri($element) eq 'http://purl.oclc.org/dsdl/schematron')"> -->
  <!--     <xsl:variable name="base-uri" as="xs:string?" select="base-uri($element)"/> -->
  <!--     <xsl:for-each select="$element/*"> -->
  <!--       <xsl:copy> -->
  <!--         <xsl:sequence select="@*"/> -->
  <!--         <xsl:if test="$base-uri"> -->
  <!--           <xsl:attribute name="schxslt:base-uri" select="$base-uri"/> -->
  <!--         </xsl:if> -->
  <!--       </xsl:copy> -->
  <!--     </xsl:for-each> -->
  <!--   </xsl:if> -->
  <!-- </xsl:template> -->

  <!-- <!-\- Replace with external definition -\-> -->
  <!-- <xsl:template match="sch:include" mode="schxslt:include"> -->
  <!--   <xsl:variable name="location" -->
  <!--                 select="if (ancestor::*/@schxslt:base-uri) then resolve-uri(@href, ancestor::*/@schxslt:base-uri[1]) else @href"/> -->
  <!--   <xsl:variable name="include" select="document($location)"/> -->
  <!--   <xsl:variable name="element" select="if ($include instance of element()) then $include else $include/*"/> -->
  <!--   <xsl:variable name="base-uri" as="xs:string?" select="base-uri($element)"/> -->
  <!--   <xsl:for-each select="$element"> -->
  <!--     <xsl:copy> -->
  <!--       <xsl:sequence select="@*"/> -->
  <!--       <xsl:if test="$base-uri"> -->
  <!--         <xsl:attribute name="schxslt:base-uri" select="$base-uri"/> -->
  <!--       </xsl:if> -->
  <!--     </xsl:copy> -->
  <!--   </xsl:for-each> -->
  <!-- </xsl:template> -->

</xsl:transform>
