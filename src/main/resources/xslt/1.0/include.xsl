<xsl:transform version="1.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="schxslt.include.perform-include">true</xsl:param>

  <xsl:template match="sch:schema">
    <xsl:choose>
      <xsl:when test="translate($schxslt.include.perform-include, 'TRUE', 'true') = 'true' or $schxslt.include.perform-include = '1'">
        <xsl:apply-templates select="." mode="schxslt:include"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node() | @*" mode="schxslt:include">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="schxslt:include"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:extends[@href]" mode="schxslt:include">
    <xsl:choose>
      <xsl:when test="contains(@href, '#')">
        <xsl:if test="local-name(..) = local-name(document(substring-before(@href, '#'), @href)//*[@xml:id = substring-after(current()/@href, '#')])">
          <xsl:if test="namespace-uri(document(substring-before(@href, '#'), @href)//*[@xml:id = substring-after(current()/@href, '#')]) = 'http://purl.oclc.org/dsdl/schematron'">
            <xsl:apply-templates select="document(substring-before(@href, '#'), @href)//*[@xml:id = substring-after(current()/@href, '#')]/*" mode="schxslt:include"/>
          </xsl:if>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="local-name(..) = local-name(document(@href)/*) and namespace-uri(document(@href)/*) = 'http://purl.oclc.org/dsdl/schematron'">
          <xsl:apply-templates select="document(@href)/*/*" mode="schxslt:include"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sch:include" mode="schxslt:include">
    <xsl:choose>
      <xsl:when test="contains(@href, '#')">
        <xsl:apply-templates select="document(substring-before(@href, '#'), @href)//*[@xml:id = substring-after(current()/@href, '#')]" mode="schxslt:include"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="document(@href)" mode="schxslt:include"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
