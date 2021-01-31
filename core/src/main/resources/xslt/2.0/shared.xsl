<xsl:transform version="2.0"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="schxslt:copy-attributes" as="attribute()*">
    <xsl:param name="context" as="element()" required="yes"/>
    <xsl:param name="base-uri-fixup" as="xs:boolean" select="true()"/>

    <xsl:if test="exists(base-uri($context))">
      <xsl:attribute name="xml:base" select="base-uri($context)"/>
    </xsl:if>
    <xsl:sequence select="$context/@* except $context/@xml:base"/>

  </xsl:template>

</xsl:transform>
