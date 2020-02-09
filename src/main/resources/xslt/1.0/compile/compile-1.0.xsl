<xsl:transform version="1.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="api-1.0.xsl"/>

  <xsl:include href="../../version.xsl"/>

  <xsl:output indent="yes"/>
  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>

  <xsl:key name="schxslt:diagnostics" match="sch:diagnostic" use="@id"/>
  <xsl:key name="schxslt:properties" match="sch:property" use="@id"/>

  <xsl:param name="phase">#DEFAULT</xsl:param>

  <xsl:template match="/sch:schema">
    <xsl:apply-templates select="." mode="schxslt:compile"/>
  </xsl:template>

  <xsl:template match="/sch:schema" mode="schxslt:compile">

    <xsl:variable name="effective-phase">
      <xsl:choose>
        <xsl:when test="$phase = '#DEFAULT' or $phase = ''">
          <xsl:choose>
            <xsl:when test="/sch:schema/@defaultPhase">
              <xsl:value-of select="/sch:schema/@defaultPhase"/>
            </xsl:when>
            <xsl:otherwise>#ALL</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$phase"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="@queryBinding and translate(@queryBinding, 'XSLT', 'xslt') != 'xslt'">
      <xsl:message terminate="yes">
        This Schematron processor only supports the 'xslt' query binding
      </xsl:message>
    </xsl:if>

    <xsl:if test="$effective-phase != '#ALL' and not(sch:phase[@id = $effective-phase])">
      <xsl:message terminate="yes">
        The phase '<xsl:value-of select="$effective-phase"/>' is undefined
      </xsl:message>
    </xsl:if>

    <transform version="1.0">
      <xsl:for-each select="sch:ns">
        <xsl:attribute name="{@prefix}:dummy" namespace="{@uri}"/>
      </xsl:for-each>

      <xsl:call-template name="schxslt:version"/>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-top-hook">
        <xsl:with-param name="schema" select="."/>
      </xsl:call-template>

      <!-- Schema, phase and pattern variables are global -->
      <xsl:call-template name="schxslt:let-param">
        <xsl:with-param name="bindings" select="sch:let"/>
      </xsl:call-template>
      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="sch:phase[@id = $effective-phase]/sch:let"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$effective-phase = '#ALL'">
          <xsl:call-template name="schxslt:detect-name-collisions">
            <xsl:with-param name="bindings-1" select="sch:phase[@id = $effective-phase]/sch:let | sch:let"/>
            <xsl:with-param name="bindings-2" select="sch:pattern/sch:let"/>
          </xsl:call-template>
          <xsl:call-template name="schxslt:let-variable">
            <xsl:with-param name="bindings" select="sch:pattern/sch:let"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="schxslt:detect-name-collisions">
            <xsl:with-param name="bindings-1" select="sch:phase[@id = $effective-phase]/sch:let | sch:let"/>
            <xsl:with-param name="bindings-2" select="sch:pattern[@id = current()/sch:phase[@id = $effective-phase]/sch:active/@pattern]/sch:let"/>
          </xsl:call-template>
          <xsl:call-template name="schxslt:let-variable">
            <xsl:with-param name="bindings" select="sch:pattern[@id = current()/sch:phase[@id = $effective-phase]/sch:active/@pattern]/sch:let"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>

      <output indent="yes"/>

      <template match="/">

        <variable name="schxslt:report">
          <xsl:choose>
            <xsl:when test="$effective-phase = '#ALL'">
              <xsl:for-each select="sch:pattern">
                <call-template name="{generate-id()}"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="sch:pattern[@id = current()/sch:phase[@id = $effective-phase]/sch:active/@pattern]">
                <call-template name="{generate-id()}"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </variable>

        <xsl:call-template name="schxslt-api:report">
          <xsl:with-param name="schema" select="."/>
          <xsl:with-param name="phase" select="$effective-phase"/>
        </xsl:call-template>

      </template>

      <xsl:choose>
        <xsl:when test="$effective-phase = '#ALL'">
          <xsl:apply-templates select="sch:pattern" mode="schxslt:compile"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="sch:pattern[@id = current()/sch:phase[@id = $effective-phase]/sch:active/@pattern]" mode="schxslt:compile"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-bottom-hook">
        <xsl:with-param name="schema" select="."/>
      </xsl:call-template>

    </transform>

  </xsl:template>

  <xsl:template match="sch:pattern" mode="schxslt:compile">

    <template name="{generate-id()}">

      <xsl:choose>
        <xsl:when test="@documents">
          <for-each select="{@documents}">
            <xsl:call-template name="schxslt-api:active-pattern">
              <xsl:with-param name="pattern" select="."/>
            </xsl:call-template>
            <apply-templates select="document(normalize-space())" mode="{generate-id()}"/>
          </for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="schxslt-api:active-pattern">
            <xsl:with-param name="pattern" select="."/>
          </xsl:call-template>
          <apply-templates select="/" mode="{generate-id()}"/>
        </xsl:otherwise>
      </xsl:choose>

    </template>

    <xsl:apply-templates select="sch:rule" mode="schxslt:compile"/>

    <template mode="{generate-id()}" match="*" priority="-10">
      <apply-templates mode="{generate-id()}" select="node() | @*"/>
    </template>

    <template mode="{generate-id()}" match="@* | text()" priority="-10"/>

  </xsl:template>

  <xsl:template match="sch:rule" mode="schxslt:compile">

    <template match="{@context}" mode="{generate-id(..)}" priority="{count(following-sibling::sch:rule)}">
      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="sch:let"/>
      </xsl:call-template>

      <xsl:call-template name="schxslt-api:fired-rule">
        <xsl:with-param name="rule" select="."/>
      </xsl:call-template>

      <xsl:apply-templates select="sch:assert | sch:report" mode="schxslt:compile"/>

      <apply-templates mode="{generate-id(..)}" select="node() | @*"/>

    </template>

  </xsl:template>

  <xsl:template match="sch:assert" mode="schxslt:compile">
    <if test="not({@test})">
      <xsl:call-template name="schxslt-api:failed-assert">
        <xsl:with-param name="assert" select="."/>
      </xsl:call-template>
    </if>
  </xsl:template>

  <xsl:template match="sch:report" mode="schxslt:compile">
    <if test="{@test}">
      <xsl:call-template name="schxslt-api:successful-report">
        <xsl:with-param name="report" select="."/>
      </xsl:call-template>
    </if>
  </xsl:template>

  <xsl:template match="sch:name[@path]" mode="schxslt:compile">
    <value-of select="{@path}"/>
  </xsl:template>

  <xsl:template match="sch:name[not(@path)]" mode="schxslt:compile">
    <value-of select="name()"/>
  </xsl:template>

  <xsl:template match="sch:value-of" mode="schxslt:compile">
    <value-of select="{@select}"/>
  </xsl:template>

  <xsl:template match="node() | @*" mode="schxslt:compile">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="schxslt:compile"/>
    </xsl:copy>
  </xsl:template>

  <!-- Named templates -->
  <xsl:template name="schxslt:let-variable">
    <xsl:param name="bindings"/>
    <xsl:if test="$bindings">
      <xsl:for-each select="$bindings">
        <xsl:choose>
          <xsl:when test="@value">
            <variable name="{@name}" select="{@value}"/>
          </xsl:when>
          <xsl:otherwise>
            <variable name="{@name}">
              <xsl:copy-of select="node()"/>
            </variable>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="schxslt:let-param">
    <xsl:param name="bindings"/>
    <xsl:if test="$bindings">
      <xsl:for-each select="$bindings">
        <xsl:choose>
          <xsl:when test="@value">
            <param name="{@name}" select="{@value}"/>
          </xsl:when>
          <xsl:otherwise>
            <param name="{@name}">
              <xsl:copy-of select="node()"/>
            </param>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="schxslt:detect-name-collisions">
    <xsl:param name="bindings-1"/>
    <xsl:param name="bindings-2"/>
    <xsl:for-each select="$bindings-1 | $bindings-2">
      <xsl:if test="count($bindings-1/self::sch:let[@name = current()/@name]) + count($bindings-2/self::sch:let[@name = current()/@name]) != 1">
        <xsl:message terminate="yes">
          Compilation aborted because of variable name conflicts: <xsl:value-of select="@name"/>
        </xsl:message>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

</xsl:transform>
