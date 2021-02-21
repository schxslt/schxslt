<xsl:transform version="3.0"
               xmlns:map="http://www.w3.org/2005/xpath-functions/map"
               xmlns:runtime="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:schxslt-report="https://doi.org/10.5281/zenodo.1495494#report"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:namespace-alias stylesheet-prefix="runtime" result-prefix="xsl"/>

  <xsl:output indent="yes"/>

  <xsl:mode name="schxslt:copy-verbatim" on-no-match="deep-copy"/>

  <xsl:template match="sch:schema">
    <xsl:variable name="modes" as="map(xs:string, map(xs:string, item()*))" select="schxslt:analyze-schema(sch:pattern)"/>

    <runtime:stylesheet version="3.0">

      <runtime:output indent="true"/>

      <runtime:template match="/">
        <schxslt-report:report>
          <xsl:for-each select="map:keys($modes)">
            <xsl:variable name="mode" as="xs:string" select="."/>
            <xsl:variable name="spec" as="map(xs:string, item()*)" select="$modes($mode)"/>

            <xsl:choose>
              <xsl:when test="$spec?documents">
                <runtime:for-each select="{$spec?document}">
                  <runtime:source-document href="." streamable="{if ($spec?streaming) then 'yes' else 'no'}">
                    <xsl:choose>
                      <xsl:when test="$spec?burst">
                        <runtime:apply-templates select="." mode="{$mode}.dispatch"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <runtime:apply-templates select="." mode="{$mode}"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </runtime:source-document>
                </runtime:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$spec?burst">
                    <runtime:apply-templates select="." mode="{$mode}.dispatch"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <runtime:apply-templates select="." mode="{$mode}"/>
                  </xsl:otherwise>
                </xsl:choose>
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
            <runtime:template match="{@context}" priority="{position()}" mode="{$mode}.dispatch">
              <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>
              <runtime:apply-templates select="{$spec?burst}(.)" mode="{$mode}"/>
            </runtime:template>
          </xsl:if>

          <runtime:template match="{@context}" priority="{position()}" mode="{$mode}">
            <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>
            <runtime:param name="schxslt:pattern" as="xs:string*"/>

            <xsl:apply-templates select="sch:let"/>

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

  <xsl:template match="sch:let">
    <xsl:param name="use-param" as="xs:boolean" select="false()"/>
    <xsl:element name="{if ($use-param) then 'param' else 'variable'}">
      <xsl:sequence select="@as, @xml:base, @name"/>
      <xsl:choose>
        <xsl:when test="@value">
          <xsl:attribute name="select" select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()" mode="schxslt:copy-verbatim"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="sch:assert | sch:report">
    <runtime:if test="{if (self::sch:report) then @test else 'not(' || @test || ')'}">
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

</xsl:transform>
