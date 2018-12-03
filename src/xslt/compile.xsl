<!-- Compile Schematron to XSLT 2.0 stylesheet -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="http://dmaus.name/ns/schxslt">

  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
  <xsl:output indent="yes"/>

  <xsl:include href="compile-lib.xsl"/>

  <xsl:param name="phase" as="xs:string">#DEFAULT</xsl:param>
  <xsl:variable name="effective-phase" as="xs:string">
    <xsl:call-template name="schxslt:effective-phase">
      <xsl:with-param name="phase" select="$phase"/>
      <xsl:with-param name="schematron" as="element(sch:schema)" select="sch:schema"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:param name="strategy" as="xs:string">traditional</xsl:param>
  <xsl:variable name="effective-strategy" as="xs:string">
    <xsl:call-template name="schxslt:effective-strategy">
      <xsl:with-param name="strategy" select="$strategy"/>
      <xsl:with-param name="schematron" as="element(sch:schema)" select="sch:schema"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="sch:schema">
    <xsl:call-template name="schxslt:compile">
      <xsl:with-param name="schematron" select="." tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="schxslt:compile">
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>

    <xsl:call-template name="schxslt:assert-prerequisites"/>

    <xsl:variable name="active-patterns" as="element(sch:pattern)*">
      <xsl:call-template name="schxslt:active-patterns">
        <xsl:with-param name="phase" as="xs:string" select="$effective-phase"/>
      </xsl:call-template>
    </xsl:variable>

    <transform version="2.0">
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
          <xsl:call-template name="schxslt:dispatch-patterns">
            <xsl:with-param name="patterns" as="element(sch:pattern)*" select="$active-patterns"/>
            <xsl:with-param name="bindings" as="element(sch:let)*" select="$schematron/sch:phase[@id eq $effective-phase]/sch:let"/>
          </xsl:call-template>
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

          <apply-templates select="$report" mode="schxslt:unwrap-report"/>

        </svrl:schematron-output>
      </template>

      <xsl:call-template name="schxslt:handle-patterns">
        <xsl:with-param name="patterns" as="element(sch:pattern)*" select="$active-patterns"/>
        <xsl:with-param name="bindings" as="element(sch:let)*" select="$schematron/sch:phase[@id eq $effective-phase]/sch:let"/>
      </xsl:call-template>

      <xsl:call-template name="schxslt:copy-helper"/>

      <!-- Modify default rules -->
      <template match="text() | @*" mode="#all" priority="-10"/>
      <template match="*" mode="#all" priority="-10">
        <apply-templates mode="#current" select="@* | node()"/>
      </template>

    </transform>

  </xsl:template>

  <xsl:template name="schxslt:dispatch-patterns">
    <xsl:param name="patterns" as="element(sch:pattern)*" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <xsl:choose>
      <xsl:when test="$effective-strategy eq 'traditional'">

        <xsl:for-each select="$patterns">
          <call-template name="{generate-id(.)}">
            <xsl:call-template name="schxslt:let-with-param">
              <xsl:with-param name="bindings" select="$bindings"/>
            </xsl:call-template>
          </call-template>
        </xsl:for-each>

      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="schxslt:handle-patterns">
    <xsl:param name="patterns" as="element(sch:pattern)*" required="yes"/>
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <xsl:choose>
      <xsl:when test="$effective-strategy eq 'traditional'">

        <xsl:for-each select="$patterns">
          <template name="{generate-id(.)}">
            <xsl:sequence select="@xml:base"/>

            <xsl:call-template name="schxslt:let-param">
              <xsl:with-param name="bindings" select="$bindings"/>
            </xsl:call-template>
            <xsl:call-template name="schxslt:let-variable">
              <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
            </xsl:call-template>

            <svrl:active-pattern>
              <xsl:sequence select="@id | @documents | @role"/>
              <xsl:if test="sch:title"><xsl:attribute name="name" select="sch:title"/></xsl:if>
            </svrl:active-pattern>

            <variable name="instances">
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

            <apply-templates mode="{generate-id(.)}" select="$instances">
              <xsl:call-template name="schxslt:let-with-param">
                <xsl:with-param name="bindings" as="element(sch:let)*" select="($bindings, sch:let)"/>
              </xsl:call-template>
            </apply-templates>

          </template>

          <xsl:apply-templates select="sch:rule">
            <xsl:with-param name="bindings" as="element(sch:let)*" select="($bindings, sch:let)"/>
          </xsl:apply-templates>

        </xsl:for-each>

      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="sch:rule">
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <xsl:choose>
      <xsl:when test="$effective-strategy eq 'traditional'">

        <template match="{@context}" mode="{generate-id(..)}" priority="{count(following-sibling::*)}">
          <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>

          <xsl:call-template name="schxslt:let-param">
            <xsl:with-param name="bindings" select="$bindings"/>
          </xsl:call-template>

          <xsl:call-template name="schxslt:let-variable">
            <xsl:with-param name="bindings" select="sch:let"/>
          </xsl:call-template>

          <svrl:fired-rule>
            <xsl:sequence select="(@id, @context, @role, @flag)"/>
            <xsl:apply-templates select="sch:assert | sch:report"/>
          </svrl:fired-rule>

          <apply-templates select="node() | @*" mode="#current"/>

        </template>

      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>

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
    <xsl:if test="lower-case($schematron/@queryBinding) ne 'xslt2'">
      <xsl:message terminate="yes">
        The query binding language '<xsl:value-of select="($schematron/@queryBinding, 'xslt')[1]"/>' is not supported.
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
      <xsl:when test="$effective-strategy eq 'traditional'"/>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          The strategy '<xsl:value-of select="$effective-strategy"/>' is not defined.
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
