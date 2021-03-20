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

  <xsl:output indent="yes"/>

  <xsl:mode name="schxslt:copy-verbatim" on-no-match="deep-copy"/>
  <xsl:mode name="schxslt:message-template" on-no-match="shallow-copy"/>

  <xsl:include href="core.xsl"/>

  <xsl:param name="phase" as="xs:string" select="''"/>

  <xsl:template match="/sch:schema">
    <xsl:variable name="phase" as="xs:string" select="schxslt:effective-phase(string($phase), string(@defaultPhase))"/>
    <xsl:variable name="patterns" as="element(sch:pattern)*">
      <xsl:choose>
        <xsl:when test="$phase ne '#ALL'">
          <xsl:sequence select="sch:pattern[@id = current()/sch:phase[@id = $phase]/sch:active/@pattern]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="sch:pattern"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="empty($patterns)">
      <xsl:message terminate="yes" expand-text="yes">
        The phase {$phase} did not select any pattern.
      </xsl:message>
    </xsl:if>

    <xsl:variable name="environment" as="map(xs:string, item()*)">
      <xsl:map>
        <xsl:map-entry key="'base-uri'"   select="@xml:base"/>
        <xsl:map-entry key="'namespaces'" select="sch:ns"/>
        <xsl:map-entry key="'parameters'" select="sch:let"/>
        <xsl:map-entry key="'variables'"  select="sch:phase[@id = $phase]/sch:let | $patterns/sch:let"/>
        <xsl:map-entry key="'patterns'"   select="$patterns"/>
        <xsl:map-entry key="'foreign'"    select="xsl:import-schema | xsl:include | xsl:import | xsl:key | xsl:function | xsl:accumulator | xsl:use-package"/>
      </xsl:map>
    </xsl:variable>

    <xsl:call-template name="schxslt:compile">
      <xsl:with-param name="environment" as="map(xs:string, item()*)" select="$environment"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="schxslt:effective-phase" as="xs:string">
    <xsl:param name="phase" as="xs:string"/>
    <xsl:param name="default" as="xs:string"/>
    <!--
         If no phase is given, the given phase is '#DEFAULT', or the
         given phase is the empty string we use the default phase or
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

</xsl:transform>
