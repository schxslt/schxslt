<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:schxslt="http://dmaus.name/ns/schxslt"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key name="schxslt:abstract-patterns" match="sch:pattern[@abstract = 'true']" use="@id"/>
  <xsl:key name="schxslt:abstract-rules"    match="sch:rule[@abstract = 'true']"    use="@id"/>

  <xsl:template match="sch:schema">
    <xsl:copy>
      <xsl:attribute name="xml:base" select="base-uri()"/>
      <xsl:sequence select="@* except @xml:base"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Expand abstract rules and patters -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:pattern[@abstract = 'true']" />
  <xsl:template match="sch:rule[@abstract = 'true']"    />

  <!-- 5.4.3
       Abstract rules are named lists of assertions without a context expression. An extends element with a rule
       attribute shall reference an abstract rule. The current rule uses all the assertions from the abstract rule it
       extends.
  -->
  <xsl:template match="sch:extends[@rule]" >
    <xsl:sequence select="key('schxslt:abstract-rules', @rule)/node()"/>
  </xsl:template>

  <!-- 5.4.9
       When a pattern element has the attribute abstract with a value true, then the pattern defines an abstract
       pattern. An abstract pattern shall not have a is-a attribute and shall have an id attribute.
  -->
  <xsl:template match="sch:pattern[@is-a]" >
    <xsl:variable name="is-a" select="key('schxslt:abstract-patterns', @is-a)"/>
    <xsl:copy>
      <xsl:sequence select="@* except @is-a"/>
      <xsl:apply-templates select="(if (not(@documents)) then $is-a/@documents else (), $is-a/node())" >
        <xsl:with-param name="schxslt:params" select="sch:param" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sch:assert/@test | sch:report/@test | sch:rule/@context | sch:value-of/@select | sch:pattern/@documents | sch:name/@path" >
    <xsl:param name="schxslt:params" as="element(sch:param)*" tunnel="yes"/>
    <xsl:attribute name="{name()}">
      <xsl:call-template name="schxslt:replace-params">
        <xsl:with-param name="src" select="."/>
        <xsl:with-param name="params" select="$schxslt:params"/>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="schxslt:replace-params" as="xs:string?">
    <xsl:param name="params" as="element(sch:param)*" required="yes"/>
    <xsl:param name="src" as="xs:string" required="yes"/>
    <xsl:choose>
      <xsl:when test="empty($params)">
        <xsl:value-of select="$src"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="schxslt:replace-params">
          <xsl:with-param name="params" select="$params[position() > 1]"/>
          <xsl:with-param name="src" select="replace($src, concat('(\W*)\$', $params[1]/@name, '(\W*)'), concat('$1', $params[1]/@value, '$2'))"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
