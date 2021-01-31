<xsl:transform version="2.0"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
