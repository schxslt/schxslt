<!-- Compile Schematron to XSLT 2.0 stylesheet -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
  <xsl:output indent="yes"/>

  <xsl:include href="compile-lib.xsl"/>

  <xsl:param name="phase" as="xs:string">#DEFAULT</xsl:param>
  <xsl:variable name="effective-phase" as="xs:string" select="schxslt:effective-phase(sch:schema, $phase)"/>

  <xsl:param name="strategy" as="xs:string">ex-post</xsl:param>

  <xsl:param name="queryBinding" as="xs:string" select="(sch:schema/@queryBinding, 'xslt1')[1]"/>
  <xsl:variable name="effective-queryBinding" as="xs:string" select="schxslt:effective-queryBinding($queryBinding)"/>

  <xsl:template match="sch:schema">
    <xsl:call-template name="schxslt:compile">
      <xsl:with-param name="schematron" select="." tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="schxslt:compile">
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>

    <xsl:call-template name="schxslt:assert-prerequisites"/>

    <xsl:variable name="active-patterns" as="element(sch:pattern)+" select="schxslt:active-patterns($schematron, $effective-phase)"/>

    <xsl:variable name="template-body" as="element()*">
      <xsl:call-template name="schxslt:handle-patterns">
        <xsl:with-param name="patterns" as="element(sch:pattern)*" select="$active-patterns"/>
        <xsl:with-param name="bindings" as="element(sch:let)*" select="$schematron/sch:phase[@id eq $effective-phase]/sch:let"/>
      </xsl:call-template>
    </xsl:variable>

    <transform version="{if ($effective-queryBinding eq 'xslt2') then '2.0' else '3.0'}">
      <xsl:for-each select="$schematron/sch:ns">
        <xsl:namespace name="{@prefix}" select="@uri"/>
      </xsl:for-each>
      <xsl:sequence select="@xml:base"/>

      <output indent="yes"/>

      <xsl:sequence select="xsl:key[not($schematron/preceding-sibling::sch:pattern)]"/>
      <xsl:sequence select="xsl:function[not($schematron/preceding-sibling::sch:pattern)]"/>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="$schematron/sch:let"/>
      </xsl:call-template>

      <template match="/">
        <xsl:sequence select="$schematron/sch:phase[@id eq $effective-phase]/@xml:base"/>

        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" select="$schematron/sch:phase[@id eq $effective-phase]/sch:let"/>
        </xsl:call-template>

        <variable name="report" as="element()*">
          <svrl:schematron-output>
            <xsl:for-each select="$template-body/@name">
              <schxslt:active-pattern-group ident="{.}">
                <call-template name="{.}">
                  <xsl:call-template name="schxslt:let-with-param">
                    <xsl:with-param name="bindings" as="element(sch:let)*" select="$schematron/sch:phase[@id eq $effective-phase]/sch:let"/>
                  </xsl:call-template>
                </call-template>
              </schxslt:active-pattern-group>
            </xsl:for-each>
          </svrl:schematron-output>
        </variable>

        <svrl:schematron-output>
          <xsl:sequence select="$schematron/@schemaVersion"/>
          <xsl:if test="$effective-phase ne '#ALL'">
            <xsl:attribute name="phase" select="$effective-phase"/>
          </xsl:if>
          <xsl:if test="$schematron/sch:title">
            <xsl:attribute name="title" select="$schematron/sch:title"/>
          </xsl:if>
          <xsl:for-each select="$schematron/sch:ns">
            <svrl:ns-prefix-in-attribute-values>
              <xsl:sequence select="(@prefix, @uri)"/>
            </svrl:ns-prefix-in-attribute-values>
          </xsl:for-each>

          <xsl:for-each-group select="$active-patterns" group-by="schxslt:pattern-grouping-key(.)">
            <xsl:variable name="ident" select="generate-id()"/>
            <xsl:for-each select="current-group()">
              <xsl:variable name="pattern" as="element(sch:pattern)" select="."/>
              <for-each select="$report/schxslt:active-pattern-group[@ident = '{$ident}']/schxslt:active-document">
                <svrl:active-pattern document="{{@href}}">
                  <xsl:sequence select="$pattern/@id | $pattern/@role"/>
                  <xsl:if test="$pattern/sch:title"><xsl:attribute name="name" select="$pattern/sch:title"/></xsl:if>
                </svrl:active-pattern>
                <for-each select="svrl:fired-rule[@schxslt:pattern = '{generate-id($pattern)}']">
                  <copy>
                    <sequence select="@* except @schxslt:*"/>
                  </copy>
                  <sequence select="*"/>
                </for-each>
              </for-each>
            </xsl:for-each>
          </xsl:for-each-group>
        </svrl:schematron-output>
      </template>

      <xsl:sequence select="$template-body"/>

      <xsl:call-template name="schxslt:copy-helper"/>

      <!-- Modify default rules -->
      <template match="text() | @*" mode="#all" priority="-10"/>
      <template match="*" mode="#all" priority="-10">
        <apply-templates mode="#current" select="@* | node()"/>
      </template>

    </transform>

  </xsl:template>

  <xsl:template name="schxslt:handle-patterns">
    <xsl:param name="patterns" as="element(sch:pattern)*" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <xsl:for-each-group select="$patterns" group-by="schxslt:pattern-grouping-key(.)">
      <xsl:variable name="ident" select="generate-id()"/>

      <xsl:call-template name="schxslt:pattern-template">
        <xsl:with-param name="ident" select="$ident"/>
        <xsl:with-param name="bindings" select="$bindings"/>
      </xsl:call-template>

      <xsl:apply-templates select="current-group()/sch:rule">
        <xsl:with-param name="ident" select="$ident"/>
        <xsl:with-param name="bindings" as="element(sch:let)*" select="($bindings, sch:let)"/>
      </xsl:apply-templates>

    </xsl:for-each-group>

  </xsl:template>

  <xsl:template name="schxslt:pattern-template">
    <xsl:param name="ident" as="xs:string" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <template name="{$ident}">
      <xsl:sequence select="@xml:base"/>

      <xsl:call-template name="schxslt:let-param">
        <xsl:with-param name="bindings" select="$bindings"/>
      </xsl:call-template>
      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
      </xsl:call-template>

      <variable name="instances" as="item()*">
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

      <for-each select="$instances">
        <schxslt:active-document href="{{base-uri(.)}}">

          <apply-templates mode="{$ident}" select=".">
            <xsl:call-template name="schxslt:let-with-param">
              <xsl:with-param name="bindings" as="element(sch:let)*" select="($bindings, sch:let)"/>
            </xsl:call-template>
          </apply-templates>

        </schxslt:active-document>

      </for-each>

    </template>
  </xsl:template>

  <xsl:template match="sch:rule">
    <xsl:param name="ident" as="xs:string" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <template match="{@context}" mode="{$ident}" priority="{count(following::sch:rule)}">

      <xsl:call-template name="schxslt:rule-template-body">
        <xsl:with-param name="bindings" select="$bindings"/>
      </xsl:call-template>

      <xsl:choose>
        <xsl:when test="$strategy eq 'traditional'">
          <apply-templates select="node() | @*" mode="#current"/>
        </xsl:when>
        <xsl:when test="$strategy eq 'ex-post'">
          <next-match>
            <with-param name="schxslt:fired-rules" as="element(svrl:fired-rule)*">
              <sequence select="$schxslt:fired-rules"/>
              <svrl:fired-rule schxslt:context="{{generate-id()}}" schxslt:pattern="{generate-id(..)}"/>
            </with-param>
          </next-match>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>

    </template>

  </xsl:template>

  <xsl:template match="sch:assert">
    <if test="not({@test})">
      <xsl:sequence select="@xml:base"/>

      <variable name="location">
        <call-template name="schxslt:location">
          <with-param name="node" select="{(@subject, ../@subject, '.')[1]}"/>
        </call-template>
      </variable>
      <svrl:failed-assert location="{{$location}}">
        <xsl:sequence select="(@role, @flag, @id, @test)"/>
        <xsl:call-template name="schxslt:svrl-detailed-report"/>
      </svrl:failed-assert>
    </if>
  </xsl:template>

  <xsl:template match="sch:report">
    <if test="{@test}">
      <xsl:sequence select="@xml:base"/>

      <variable name="location">
        <call-template name="schxslt:location">
          <with-param name="node" select="{(@subject, ../@subject, '.')[1]}"/>
        </call-template>
      </variable>
      <svrl:successful-report location="{{$location}}">
        <xsl:sequence select="(@role, @flag, @id, @test)"/>
        <xsl:call-template name="schxslt:svrl-detailed-report"/>
      </svrl:successful-report>
    </if>
  </xsl:template>

  <xsl:template name="schxslt:assert-prerequisites">
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>

    <!-- Supported query bindings -->
    <xsl:if test="not($effective-queryBinding = ('xslt2', 'xslt3'))">
      <xsl:message terminate="yes">
        The query binding language '<xsl:value-of select="$effective-queryBinding"/>' is not supported.
      </xsl:message>
    </xsl:if>

    <!-- Effective phase -->
    <xsl:if test="($effective-phase ne '#ALL') and empty($schematron/sch:phase[@id = $effective-phase])">
      <xsl:message terminate="yes">
        The phase '<xsl:value-of select="$phase"/>' is not defined.
      </xsl:message>
    </xsl:if>

    <!-- Effective strategy -->
    <xsl:choose>
      <xsl:when test="$strategy eq 'traditional'"/>
      <xsl:when test="$strategy eq 'ex-post'"/>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          The strategy '<xsl:value-of select="$strategy"/>' is not defined.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Abstract patterns -->
    <xsl:if test="$schematron/sch:pattern[@abstract]">
      <xsl:message terminate="yes">
        The Schematron contains abstract patterns.
      </xsl:message>
    </xsl:if>

    <!-- Abstract rules. -->
    <xsl:if test="$schematron/sch:pattern/sch:rule[@abstract]">
      <xsl:message terminate="yes">
        The Schematron contains abstract rules.
      </xsl:message>
    </xsl:if>

    <!-- Includes -->
    <xsl:if test="$schematron//sch:include">
      <xsl:message terminate="yes">
        The Schematron contains unprocessed includes.
      </xsl:message>
    </xsl:if>

    <!-- Extends -->
    <xsl:if test="$schematron//sch:extends">
      <xsl:message terminate="yes">
        The Schematron contains unprocessed extends.
      </xsl:message>
    </xsl:if>

  </xsl:template>

</xsl:transform>
