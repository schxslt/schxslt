<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key name="schxslt:abstract-patterns" match="sch:pattern[@abstract = 'true']" use="@id"/>
  <xsl:key name="schxslt:abstract-rules"    match="sch:rule[@abstract = 'true']"    use="@id"/>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Keep base URI of outermost element</p>
    </desc>
  </doc>
  <xsl:template match="sch:schema">
    <xsl:copy>
      <xsl:attribute name="xml:base" select="base-uri()"/>
      <xsl:sequence select="@* except @xml:base"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Copy all other elements</p>
    </desc>
  </doc>
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Remove abstract patterns</p>
    </desc>
  </doc>
  <xsl:template match="sch:pattern[@abstract = 'true']" />

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Remove abstract rules</p>
    </desc>
  </doc>
  <xsl:template match="sch:rule[@abstract = 'true']"    />

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Instantiate abstract rule</p>
      <p>
        The current rule uses all the assertions from the abstract rule it
        extends.
      </p>
    </desc>
  </doc>
  <xsl:template match="sch:extends[@rule]" >
    <xsl:sequence select="key('schxslt:abstract-rules', @rule)/node()"/>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Instantiate abstract pattern</p>
    </desc>
  </doc>
  <xsl:template match="sch:pattern[@is-a]" >
    <xsl:variable name="is-a" select="key('schxslt:abstract-patterns', @is-a)"/>
    <xsl:copy>
      <xsl:sequence select="@* except @is-a"/>
      <xsl:apply-templates select="(if (not(@documents)) then $is-a/@documents else (), $is-a/node())" >
        <xsl:with-param name="schxslt:params" select="sch:param" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Replace placeholders in abstract pattern instances</p>
    </desc>
    <param name="schxslt:params">Placeholders</param>
  </doc>
  <xsl:template match="sch:assert/@test | sch:report/@test | sch:rule/@context | sch:value-of/@select | sch:pattern/@documents | sch:name/@path | sch:let/@value">
    <xsl:param name="schxslt:params" as="element(sch:param)*" tunnel="yes"/>
    <xsl:attribute name="{name()}">
      <xsl:call-template name="schxslt:replace-params">
        <xsl:with-param name="src" select="."/>
        <xsl:with-param name="params" select="$schxslt:params"/>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Replace placeholders in property value</p>
    </desc>
    <param name="params">Sequence of placeholders</param>
    <param name="src">Property value</param>
    <return>Property value with all placeholders replaced</return>
  </doc>
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
