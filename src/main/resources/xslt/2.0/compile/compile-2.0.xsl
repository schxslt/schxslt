<!-- Compile preprocessed Schematron to validation stylesheet -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="api-2.0.xsl"/>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Compile preprocessed Schematron to validation stylesheet</p>
    </desc>
    <param name="phase">Validation phase</param>
  </doc>

  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
  <xsl:output indent="yes"/>

  <xsl:include href="functions.xsl"/>
  <xsl:include href="templates.xsl"/>
  <xsl:include href="../../version.xsl"/>

  <xsl:param name="phase" as="xs:string">#DEFAULT</xsl:param>

  <xsl:variable name="effective-phase" select="schxslt:effective-phase(sch:schema, $phase)" as="xs:string"/>
  <xsl:variable name="active-patterns" select="schxslt:active-patterns(sch:schema, $effective-phase)" as="element(sch:pattern)+"/>

  <xsl:variable name="validation-stylesheet-body" as="element(xsl:template)+">
    <xsl:call-template name="schxslt:validation-stylesheet-body">
      <xsl:with-param name="patterns" as="element(sch:pattern)+" select="$active-patterns"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="sch:schema">

    <transform version="{schxslt:xslt-version(.)}">
      <xsl:for-each select="sch:ns">
        <xsl:namespace name="{@prefix}" select="@uri"/>
      </xsl:for-each>
      <xsl:sequence select="@xml:base"/>

      <xsl:call-template name="schxslt:version"/>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-top-hook">
        <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
      </xsl:call-template>

      <output indent="yes"/>

      <xsl:sequence select="xsl:key[not(preceding-sibling::sch:pattern)]"/>
      <xsl:sequence select="xsl:function[not(preceding-sibling::sch:pattern)]"/>

      <!-- See https://github.com/dmj/schxslt/issues/25 -->
      <xsl:variable name="global-bindings" as="element(sch:let)*" select="(sch:let, sch:phase[@id eq $effective-phase]/sch:let, $active-patterns/sch:let)"/>
      <xsl:if test="count($global-bindings) ne count(distinct-values($global-bindings/@name))">
        <xsl:message terminate="yes">
          Compilation aborted because of variable name conflicts:
          <xsl:for-each-group select="$global-bindings" group-by="@name">
            <xsl:value-of select="current-grouping-key()"/> (<xsl:value-of select="current-group()/../local-name()" separator=", "/>)
          </xsl:for-each-group>
        </xsl:message>
      </xsl:if>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="$global-bindings"/>
      </xsl:call-template>

      <template match="/">
        <xsl:sequence select="sch:phase[@id eq $effective-phase]/@xml:base"/>

        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" select="sch:phase[@id eq $effective-phase]/sch:let"/>
        </xsl:call-template>

        <variable name="report" as="element(schxslt:report)">
          <schxslt:report>
            <xsl:for-each select="$validation-stylesheet-body/@name">
              <call-template name="{.}"/>
            </xsl:for-each>
          </schxslt:report>
        </variable>

        <!-- Unwrap the intermediary report -->
        <variable name="schxslt:report" as="node()*">
          <for-each select="$report/schxslt:pattern">
            <sequence select="node()"/>
            <sequence select="$report/schxslt:rule[@pattern = current()/@id]/node()"/>
          </for-each>
        </variable>

        <xsl:call-template name="schxslt-api:report">
          <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
          <xsl:with-param name="phase" as="xs:string" select="$effective-phase"/>
        </xsl:call-template>

      </template>

      <template match="text() | @*" mode="#all" priority="-10"/>
      <template match="*" mode="#all" priority="-10">
        <apply-templates mode="#current" select="@* | node()"/>
      </template>

      <xsl:sequence select="$validation-stylesheet-body"/>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-bottom-hook">
        <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
      </xsl:call-template>

    </transform>

  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return rule template</p>
    </desc>
    <param name="mode">Template mode</param>
  </doc>
  <xsl:template match="sch:rule">
    <xsl:param name="mode" as="xs:string" required="yes"/>

    <template match="{@context}" priority="{count(following::sch:rule)}" mode="{$mode}">
      <xsl:sequence select="(@xml:base, ../@xml:base)"/>

      <!-- Check if a context node was already matched by a rule of the current pattern. -->
      <param name="schxslt:rules" as="element(schxslt:rule)*"/>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
      </xsl:call-template>

      <choose>
        <when test="empty($schxslt:rules[@pattern = '{generate-id(..)}'][@context = generate-id(current())])">
          <schxslt:rule pattern="{generate-id(..)}@{{base-uri(.)}}">
            <xsl:call-template name="schxslt-api:fired-rule">
              <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="sch:assert | sch:report"/>
          </schxslt:rule>
        </when>
        <otherwise>
          <schxslt:rule pattern="{generate-id(..)}@{{base-uri(.)}}">
            <xsl:variable name="message">
              WARNING: Rule <xsl:value-of select="normalize-space(@id)"/> for context "<xsl:value-of select="@context"/>" shadowed by preceeding rule
            </xsl:variable>
            <comment> <xsl:sequence select="normalize-space($message)"/> </comment>
            <message> <xsl:sequence select="normalize-space($message)"/> </message>
          </schxslt:rule>
        </otherwise>
      </choose>

      <next-match>
        <with-param name="schxslt:rules" as="element(schxslt:rule)*">
          <sequence select="$schxslt:rules"/>
          <schxslt:rule context="{{generate-id()}}" pattern="{generate-id(..)}"/>
        </with-param>
      </next-match>
    </template>

  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return body of validation stylesheet</p>
    </desc>
    <param name="patterns">Sequence of active patterns</param>
  </doc>
  <xsl:template name="schxslt:validation-stylesheet-body">
    <xsl:param name="patterns" as="element(sch:pattern)+"/>

    <xsl:for-each-group select="$patterns" group-by="string-join((generate-id(sch:let), base-uri(.), @documents), '&lt;')">
      <xsl:variable name="mode" as="xs:string" select="generate-id()"/>
      <xsl:variable name="baseUri" as="xs:anyURI" select="base-uri(.)"/>

      <template name="{$mode}">
        <xsl:sequence select="@xml:base"/>

        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
        </xsl:call-template>

        <variable name="documents" as="item()+">
          <xsl:choose>
            <xsl:when test="@documents">
              <for-each select="{@documents}">
                <sequence select="document(resolve-uri(., '{$baseUri}'))"/>
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
              <xsl:call-template name="schxslt-api:active-pattern">
                <xsl:with-param name="pattern" as="element(sch:pattern)" select="."/>
              </xsl:call-template>
            </schxslt:pattern>
          </xsl:for-each>

          <apply-templates mode="{$mode}" select="."/>
        </for-each>

      </template>

      <xsl:apply-templates select="current-group()/sch:rule">
        <xsl:with-param name="mode" as="xs:string" select="$mode"/>
      </xsl:apply-templates>

    </xsl:for-each-group>

  </xsl:template>

</xsl:transform>
