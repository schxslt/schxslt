<!-- Compile preprocessed Schematron to validation stylesheet -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
  <xsl:output indent="yes"/>

  <xsl:include href="compile-functions.xsl"/>
  <xsl:include href="compile-templates.xsl"/>
  <xsl:include href="compile-report.xsl"/>

  <xsl:param name="phase" as="xs:string">#DEFAULT</xsl:param>

  <xsl:variable name="effective-phase" select="schxslt:effective-phase(sch:schema, $phase)" as="xs:string"/>
  <xsl:variable name="active-patterns" select="schxslt:active-patterns(sch:schema, $effective-phase)" as="element(sch:pattern)+"/>

  <xsl:variable name="validation-template-body" as="element(xsl:template)+">
    <xsl:call-template name="schxslt:validation-template-body">
      <xsl:with-param name="patterns" as="element(sch:pattern)+" select="$active-patterns"/>
      <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:schema/sch:phase[@id eq $effective-phase]/sch:let"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="sch:schema">

    <transform version="2.0">
      <xsl:for-each select="sch:ns">
        <xsl:namespace name="{@prefix}" select="@uri"/>
      </xsl:for-each>
      <xsl:sequence select="@xml:base"/>

      <output indent="yes"/>

      <xsl:sequence select="xsl:key[not(preceding-sibling::sch:pattern)]"/>
      <xsl:sequence select="xsl:function[not(preceding-sibling::sch:pattern)]"/>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="sch:let"/>
      </xsl:call-template>

      <template match="/">
        <xsl:sequence select="sch:phase[@id eq $effective-phase]/@xml:base"/>

        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" select="sch:phase[@id eq $effective-phase]/sch:let"/>
        </xsl:call-template>

        <variable name="report" as="element(schxslt:report)">
          <schxslt:report>
            <xsl:variable name="bindings" as="element(xsl:with-param)*">
              <xsl:call-template name="schxslt:let-with-param">
                <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:phase[@id eq $effective-phase]/sch:let"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="$validation-template-body/@name">
              <call-template name="{.}">
                <xsl:sequence select="$bindings"/>
              </call-template>
            </xsl:for-each>
          </schxslt:report>
        </variable>

        <xsl:call-template name="schxslt:process-report"/>

        <xsl:call-template name="svrl:schematron-output">
          <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
          <xsl:with-param name="phase" as="xs:string" select="$effective-phase"/>
        </xsl:call-template>

      </template>

      <template match="text() | @*" mode="#all" priority="-10"/>
      <template match="*" mode="#all" priority="-10">
        <apply-templates mode="#current" select="@* | node()"/>
      </template>

      <xsl:sequence select="$validation-template-body"/>
      <xsl:sequence select="document('compile-functions.xsl')//xsl:function[@name = 'schxslt:location']"/>

    </transform>

  </xsl:template>

  <xsl:template match="sch:rule">
    <xsl:param name="mode" as="xs:string" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <template match="{@context}" priority="{count(following::sch:rule)}" mode="{$mode}">
      <xsl:sequence select="(@xml:base, ../@xml:base)"/>

      <param name="schxslt:rules" as="element(schxslt:rule)*"/>
      <xsl:call-template name="schxslt:let-param">
        <xsl:with-param name="bindings" as="element(sch:let)*" select="$bindings"/>
      </xsl:call-template>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
      </xsl:call-template>

      <if test="empty($schxslt:rules[@pattern = '{generate-id(..)}'])">
        <if test="empty($schxslt:rules[@pattern = '{generate-id(..)}'][@context = generate-id(current())])">
          <schxslt:rule pattern="{generate-id(..)}@{{base-uri(.)}}">
            <xsl:call-template name="svrl:fired-rule">
              <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="sch:assert | sch:report"/>
          </schxslt:rule>
        </if>
      </if>
      <next-match>
        <with-param name="schxslt:rules" as="element(schxslt:rule)*">
          <sequence select="$schxslt:rules"/>
          <schxslt:rule context="{{generate-id()}}" pattern="{generate-id(..)}"/>
        </with-param>
      </next-match>
    </template>

  </xsl:template>

  <xsl:template match="sch:assert">
    <if test="not({@test})">
      <xsl:sequence select="@xml:base"/>
      <xsl:call-template name="svrl:failed-assert">
        <xsl:with-param name="assert" as="element(sch:assert)" select="."/>
      </xsl:call-template>
    </if>
  </xsl:template>

  <xsl:template match="sch:report">
    <if test="{@test}">
      <xsl:sequence select="@xml:base"/>
      <xsl:call-template name="svrl:successful-report">
        <xsl:with-param name="report" as="element(sch:report)" select="."/>
      </xsl:call-template>
    </if>
  </xsl:template>

  <xsl:template match="sch:name">
    <value-of select="{if (@path) then @path else 'name()'}">
      <xsl:sequence select="@xml:base"/>
    </value-of>
  </xsl:template>

  <xsl:template match="sch:value-of">
    <value-of select="{@select}">
      <xsl:sequence select="@xml:base"/>
    </value-of>
  </xsl:template>

</xsl:transform>
