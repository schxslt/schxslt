<xsl:transform xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template name="schxslt:user-agent">
    <xsl:variable name="product" select="normalize-space(concat(system-property('xsl:product-name'), ' ', system-property('xsl:product-version')))"/>
    <xsl:text>SchXslt </xsl:text>
    <xsl:text xml:id="version">1.4-SNAPSHOT</xsl:text>
    <xsl:if test="$product != ''">
      <xsl:text> / </xsl:text>
      <xsl:value-of select="$product"/>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:value-of select="concat('(', system-property('xsl:vendor'), ')')"/>
  </xsl:template>

</xsl:transform>
