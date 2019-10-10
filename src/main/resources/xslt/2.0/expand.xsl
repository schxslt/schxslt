<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="sch:schema">
    <xsl:apply-templates select="." mode="schxslt:expand"/>
  </xsl:template>

  <!-- Copy the outermost element and preserve it's base URI -->
  <xsl:template match="sch:schema" mode="schxslt:expand">
    <xsl:copy>
      <xsl:if test="exists(base-uri())">
        <xsl:attribute name="xml:base" select="base-uri()"/>
      </xsl:if>
      <xsl:sequence select="@* except @xml:base"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="abstract-rules"    select="sch:pattern/sch:rule[@abstract = 'true']" as="element(sch:rule)*" tunnel="yes"/>
        <xsl:with-param name="abstract-patterns" select="sch:pattern[@abstract = 'true']" as="element(sch:pattern)*" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Copy all other elements -->
  <xsl:template match="node() | @*" mode="schxslt:expand">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove abstract patterns from output -->
  <xsl:template match="sch:pattern[@abstract = 'true']" mode="schxslt:expand"/>

  <!-- Remove abstract rules from output -->
  <xsl:template match="sch:rule[@abstract = 'true']"    mode="schxslt:expand"/>

  <!-- Instantiate an abstract rule -->
  <xsl:template match="sch:extends[@rule]" mode="schxslt:expand">
    <xsl:param name="abstract-rules" as="element(sch:rule)*" tunnel="yes"/>
    <xsl:sequence select="$abstract-rules[@id = current()/@rule]/node()"/>
  </xsl:template>

  <!-- Instantiate an abstract pattern -->
  <xsl:template match="sch:pattern[@is-a]" mode="schxslt:expand">
    <xsl:param name="abstract-patterns" as="element(sch:pattern)*" tunnel="yes"/>
    <xsl:variable name="is-a" as="element(sch:pattern)" select="$abstract-patterns[@id = current()/@is-a]"/>
    <xsl:copy>
      <xsl:sequence select="@* except @is-a"/>
      <xsl:apply-templates select="(if (not(@documents)) then $is-a/@documents else (), $is-a/node())" mode="#current">
        <xsl:with-param name="params" select="sch:param" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- Replace placeholders in abstract pattern instance -->
  <xsl:template match="sch:assert/@test | sch:report/@test | sch:rule/@context | sch:value-of/@select | sch:pattern/@documents | sch:name/@path | sch:let/@value" mode="schxslt:expand">
    <xsl:param name="params" as="element(sch:param)*" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="schxslt:replace-params(., $params)"/>
  </xsl:template>

  <!-- Replace placeholders in property value -->
  <xsl:function name="schxslt:replace-params" as="xs:string?">
    <xsl:param name="src" as="xs:string"/>
    <xsl:param name="params" as="element(sch:param)*"/>
    <xsl:choose>
      <xsl:when test="empty($params)">
        <xsl:value-of select="$src"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="value" select="replace($params[1]/@value, '\$', '\\\$')"/>
        <xsl:variable name="src" select="replace($src, concat('(\W*)\$', $params[1]/@name, '(\W*)'), concat('$1', $value, '$2'))"/>
        <xsl:value-of select="schxslt:replace-params($src, $params[position() > 1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:transform>
