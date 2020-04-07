<xsl:transform xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template name="schxslt:version">
    <xsl:variable name="product" select="normalize-space(concat(system-property('xsl:product-name'), ' ', system-property('xsl:product-version')))"/>
    <xsl:comment>
      Schematron validation stylesheet created with SchXslt <xsl:text xml:id="version">1.4.5</xsl:text> running
      XSLT processor <xsl:value-of select="$product"/> by <xsl:value-of select="system-property('xsl:vendor')"/>.
    </xsl:comment>
  </xsl:template>

</xsl:transform>