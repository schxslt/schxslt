<!-- Compiler templates -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Named templates -->
  <xsl:template name="schxslt:let-variable">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="$bindings">
      <variable name="{@name}" select="{@value}">
        <xsl:sequence select="@xml:base"/>
      </variable>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-param">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="$bindings">
      <param name="{@name}" tunnel="yes"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-with-param">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="distinct-values($bindings/@name)">
      <with-param name="{.}" select="${.}" tunnel="yes"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:validation-stylesheet-body">
    <xsl:param name="patterns" as="element(sch:pattern)+"/>
    <xsl:param name="bindings" as="element(sch:let)*"/>

    <xsl:for-each-group select="$patterns" group-by="string-join((generate-id(sch:let), base-uri(.), @documents), '&lt;')">
      <xsl:variable name="mode" as="xs:string" select="generate-id()"/>

      <template name="{$mode}">
        <xsl:sequence select="@xml:base"/>

        <xsl:call-template name="schxslt:let-param">
          <xsl:with-param name="bindings" select="$bindings"/>
        </xsl:call-template>
        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
        </xsl:call-template>

        <variable name="documents" as="item()+">
          <xsl:choose>
            <xsl:when test="@documents">
              <for-each select="{@documents}">
                <sequence select="document(.)"/>
              </for-each>
            </xsl:when>
            <xsl:otherwise>
              <sequence select="/"/>
            </xsl:otherwise>
          </xsl:choose>
        </variable>

        <for-each select="$documents">
          <xsl:for-each select="current-group()">
            <schxslt:pattern id="{generate-id()}@{{base-uri(.)}}">
              <xsl:call-template name="svrl:active-pattern">
                <xsl:with-param name="pattern" as="element(sch:pattern)" select="."/>
              </xsl:call-template>
            </schxslt:pattern>
          </xsl:for-each>

          <apply-templates mode="{$mode}" select=".">
            <xsl:call-template name="schxslt:let-with-param">
              <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
            </xsl:call-template>
          </apply-templates>
        </for-each>

      </template>

      <xsl:apply-templates select="current-group()/sch:rule">
        <xsl:with-param name="mode" as="xs:string" select="$mode"/>
        <xsl:with-param name="bindings" as="element(sch:let)*" select="($bindings, current-group()/sch:let)"/>
      </xsl:apply-templates>

    </xsl:for-each-group>

  </xsl:template>

  <xsl:template name="schxslt:process-report">
    <xsl:param name="report-variable-name" as="xs:string" required="yes"/>
    <variable name="{$report-variable-name}" as="element()+">
      <for-each select="${$report-variable-name}/schxslt:pattern">
        <sequence select="*"/>
        <sequence select="${$report-variable-name}/schxslt:rule[@pattern = current()/@id]/*"/>
      </for-each>
    </variable>
  </xsl:template>

</xsl:transform>
