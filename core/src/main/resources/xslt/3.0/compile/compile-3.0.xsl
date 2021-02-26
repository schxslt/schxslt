<xsl:transform version="3.0"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:runtime="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:schxslt-error="https://doi.org/10.5281/zenodo.1495494#error"
               xmlns:schxslt-report="https://doi.org/10.5281/zenodo.1495494#report"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:namespace-alias stylesheet-prefix="runtime" result-prefix="xsl"/>

  <xsl:output indent="yes"/>

  <xsl:mode name="schxslt:copy-verbatim" on-no-match="deep-copy"/>
  <xsl:mode name="schxslt:message-template" on-no-match="shallow-copy"/>

  <xsl:import href="api-3.0.xsl"/>

  <xsl:param name="phase" as="xs:string" select="''"/>

  <xsl:template match="/sch:schema">
    <xsl:call-template name="schxslt:compile">
      <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
      <xsl:with-param name="options" as="map(xs:string, item()*)" select="map{'phase': $phase}"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="schxslt:compile" as="element(xsl:stylesheet)">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:param name="options" as="map(xs:string, item()*)" select="map{}"/>

    <xsl:variable name="phase" as="xs:string" select="schxslt:effective-phase(string($options?phase), string($schema/@defaultPhase))"/>
    <xsl:variable name="patterns" as="element(sch:pattern)*">
      <xsl:choose>
        <xsl:when test="$phase ne '#ALL'">
          <xsl:sequence select="$schema/sch:pattern[@id = $schema/sch:phase[@id = $phase]/sch:active/@pattern]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$schema/sch:pattern"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="empty($patterns)">
      <xsl:message terminate="yes" expand-text="yes">
        The phase {$phase} did not select any pattern.
      </xsl:message>
    </xsl:if>

    <xsl:variable name="modes" as="map(xs:string, map(xs:string, item()*))" select="schxslt:analyze-schema($patterns)"/>

    <runtime:stylesheet version="3.0">
      <xsl:for-each select="sch:ns">
        <xsl:namespace name="{@prefix}" select="@uri"/>
      </xsl:for-each>
      <xsl:sequence select="$schema/@xml:base"/>

      <runtime:output indent="true"/>

      <xsl:call-template name="schxslt:assert-unique-variables">
        <xsl:with-param name="decls" as="element(sch:let)*" select="$schema/sch:let"/>
      </xsl:call-template>
      <xsl:call-template name="schxslt:let-param">
        <xsl:with-param name="decls" as="element(sch:let)*" select="$schema/sch:let"/>
      </xsl:call-template>

      <xsl:call-template name="schxslt:assert-unique-variables">
        <xsl:with-param name="decls" as="element(sch:let)*" select="$schema/sch:phase[@id = $phase]/sch:let | $patterns/sch:let"/>
      </xsl:call-template>
      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="decls" as="element(sch:let)*" select="$schema/sch:phase[@id = $phase]/sch:let | $patterns/sch:let"/>
      </xsl:call-template>

      <runtime:template match="/">
        <schxslt-report:report>
          <xsl:for-each select="map:keys($modes)">
            <xsl:variable name="mode" as="xs:string" select="."/>
            <xsl:variable name="spec" as="map(xs:string, item()*)" select="$modes($mode)"/>

            <xsl:choose>
              <xsl:when test="$spec?documents">
                <runtime:for-each select="{$spec?documents}">
                  <runtime:source-document href=".">
                    <xsl:attribute name="streamable" select="if ($spec?streaming) then 'yes' else 'no'"/>
                    <xsl:call-template name="schxslt:apply-rule">
                      <xsl:with-param name="mode" as="xs:string" select="$mode"/>
                      <xsl:with-param name="burst" as="xs:string?" select="$spec?burst"/>
                    </xsl:call-template>
                  </runtime:source-document>
                </runtime:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="schxslt:apply-rule">
                  <xsl:with-param name="mode" as="xs:string" select="$mode"/>
                  <xsl:with-param name="burst" as="xs:string?" select="$spec?burst"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </schxslt-report:report>
      </runtime:template>

      <xsl:for-each select="map:keys($modes)">
        <xsl:variable name="mode" as="xs:string" select="."/>
        <xsl:variable name="spec" as="map(xs:string, item()*)" select="$modes($mode)"/>

        <runtime:mode name="{$mode}" on-no-match="shallow-skip" streamable="{if ($spec?streaming) then 'yes' else 'no'}"/>

        <!-- When using burst mode, we need to create a second mode
             that dispatches the burst. -->
        <xsl:if test="$spec?burst">
          <runtime:mode name="{$mode}.dispatch" on-no-match="shallow-skip" streamable="{if ($spec?streaming) then 'yes' else 'no'}"/>
        </xsl:if>

        <xsl:for-each select="$spec?rules">
          <!-- When using burst mode, we have a mode that dispatches the burst. -->
          <xsl:if test="$spec?burst">
            <runtime:template match="{@context}" priority="{count(following-sibling::sch:rule)}" mode="{$mode}.dispatch">
              <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>
              <runtime:apply-templates select="{$spec?burst}(.)" mode="{$mode}"/>
            </runtime:template>
          </xsl:if>

          <runtime:template match="{@context}" priority="{count(following-sibling::sch:rule)}" mode="{$mode}">
            <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>
            <runtime:param name="schxslt:pattern" as="xs:string*"/>

            <xsl:call-template name="schxslt:assert-unique-variables">
              <xsl:with-param name="decls" as="element(sch:let)*" select="sch:let"/>
            </xsl:call-template>
            <xsl:call-template name="schxslt:let-variable">
              <xsl:with-param name="decls" as="element(sch:let)*" select="sch:let"/>
            </xsl:call-template>

            <runtime:choose>
              <runtime:when test="$schxslt:pattern[. = '{generate-id(..)}']">
                <schxslt-report:suppressed-context context="{@context}">
                  <xsl:call-template name="schxslt-api:suppressed-rule">
                    <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
                  </xsl:call-template>
                </schxslt-report:suppressed-context>
              </runtime:when>
              <runtime:otherwise>
                <schxslt-report:context context="{@context}">
                  <xsl:call-template name="schxslt-api:fired-rule">
                    <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
                  </xsl:call-template>
                  <xsl:apply-templates select="sch:assert | sch:report"/>
                </schxslt-report:context>
              </runtime:otherwise>
            </runtime:choose>

          </runtime:template>

        </xsl:for-each>

      </xsl:for-each>
    </runtime:stylesheet>

  </xsl:template>

  <xsl:template match="sch:assert | sch:report">
    <runtime:if test="{if (self::sch:report) then @test else 'not(' || @test || ')'}">
      <xsl:sequence select="@xml:base"/>
      <schxslt-report:failed-constraint>
        <runtime:attribute name="{local-name()}">
          <xsl:value-of select="@test"/>
        </runtime:attribute>
        <xsl:sequence select="@id"/>
        <xsl:choose>
          <xsl:when test="self::sch:assert">
            <xsl:call-template name="schxslt-api:failed-assert">
              <xsl:with-param name="assert" as="element(sch:assert)" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="schxslt-api:successful-report">
              <xsl:with-param name="report" as="element(sch:report)" select="."/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </schxslt-report:failed-constraint>
    </runtime:if>
  </xsl:template>

  <xsl:template match="*" mode="schxslt:copy-verbatim">
    <runtime:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:apply-templates mode="#current"/>
    </runtime:element>
  </xsl:template>

  <xsl:function name="schxslt:effective-phase" as="xs:string">
    <xsl:param name="phase" as="xs:string"/>
    <xsl:param name="default" as="xs:string"/>
    <!--
         If no phase is given, the give phase is '#DEFAULT', or the
         give phase is the empty string we use the default phase or
         '#ALL' if no default phase is defined.
    -->
    <xsl:choose>
      <xsl:when test="$phase = ('', '#DEFAULT')">
        <xsl:value-of select="if ($default) then $default else '#ALL'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$phase"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="schxslt:analyze-schema" as="map(xs:string, map(xs:string, item()*))">
    <xsl:param name="schema" as="element(sch:pattern)+"/>

    <xsl:map>
      <xsl:for-each-group select="$schema/sch:rule" composite="true" group-by="(base-uri(..), ../@documents, xs:boolean(@streaming), @burst)">
        <xsl:variable name="mode" as="xs:string" select="generate-id()"/>
        <xsl:map-entry key="$mode">
          <xsl:map>
            <xsl:map-entry key="'burst'" select="string(@burst)"/>
            <xsl:map-entry key="'streaming'" select="xs:boolean(@streaming)"/>
            <xsl:map-entry key="'documents'" select="../@documents"/>
            <xsl:map-entry key="'rules'" select="current-group()"/>
          </xsl:map>
        </xsl:map-entry>
      </xsl:for-each-group>
    </xsl:map>
  </xsl:function>

  <xsl:template name="schxslt:assert-unique-variables" as="empty-sequence()">
    <xsl:param name="decls" as="element(sch:let)*" required="yes"/>
    <xsl:if test="count($decls) ne count(distinct-values($decls/@name))">
      <xsl:message terminate="yes">
        It is an error for a variable to be multiply defined
        <xsl:for-each-group select="$decls" group-by="@name">
          <xsl:sort select="current-grouping-key()"/>
          <xsl:if test="count(current-group()) gt 1">
            <xsl:value-of select="current-grouping-key()"/>
          </xsl:if>
        </xsl:for-each-group>
      </xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template name="schxslt:let-variable" as="element(xsl:variable)*">
    <xsl:param name="decls" as="element(sch:let)*" required="yes"/>
    <xsl:for-each select="$decls">
      <runtime:variable>
        <xsl:sequence select="@as, @xml:base, @name"/>
        <xsl:call-template name="schxslt:let-value"/>
      </runtime:variable>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-param" as="element(xsl:param)*">
    <xsl:param name="decls" as="element(sch:let)*" required="yes"/>
    <xsl:for-each select="$decls">
      <runtime:param>
        <xsl:sequence select="@as, @xml:base, @name"/>
        <xsl:call-template name="schxslt:let-value"/>
      </runtime:param>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-value" as="item()*">
    <xsl:context-item use="required" as="element(sch:let)"/>
    <xsl:choose>
      <xsl:when test="@value">
        <xsl:attribute name="select" select="@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="schxslt:copy-verbatim"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="schxslt:apply-rule" as="element(xsl:apply-templates)">
    <xsl:param name="mode" as="xs:string" required="yes"/>
    <xsl:param name="burst" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$burst">
        <runtime:apply-templates select="." mode="{$mode}.dispatch"/>
      </xsl:when>
      <xsl:otherwise>
        <runtime:apply-templates select="." mode="{$mode}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sch:name" mode="schxslt:message-template">
    <runtime:value-of select="{if (@path) then @path else 'name()'}">
      <xsl:sequence select="@xml:base"/>
    </runtime:value-of>
  </xsl:template>

  <xsl:template match="sch:value-of" mode="schxslt:message-template">
    <runtime:value-of select="{@select}">
      <xsl:sequence select="@xml:base"/>
    </runtime:value-of>
  </xsl:template>

</xsl:transform>
