<!-- Compiler functions -->
<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:function name="schxslt:effective-phase" as="xs:string">
    <xsl:param name="schema" as="element(sch:schema)"/>
    <xsl:param name="phase" as="xs:string"/>

    <xsl:variable name="phase">
      <xsl:choose>
        <xsl:when test="$phase = ('#DEFAULT', '')">
          <xsl:value-of select="($schema/@defaultPhase, '#ALL')[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$phase"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$phase ne '#ALL' and not($schema/sch:phase[@id = $phase])">
      <xsl:message terminate="yes">
        The phase '<xsl:value-of select="$phase"/>' is not defined.
      </xsl:message>
    </xsl:if>

    <xsl:value-of select="$phase"/>

  </xsl:function>

  <xsl:function name="schxslt:active-patterns" as="element(sch:pattern)+">
    <xsl:param name="schema" as="element(sch:schema)"/>
    <xsl:param name="phase" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="$phase eq '#ALL'">
        <xsl:sequence select="$schema/sch:pattern"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$schema/sch:pattern[@id = $schema/sch:phase[@id eq $phase]/sch:active/@pattern]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="schxslt:location" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:variable name="segments" as="xs:string*">
      <xsl:for-each select="($node/ancestor-or-self::node())">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test=". instance of element()">
            <xsl:value-of select="concat(name(.), '[', $position, ']')"/>
          </xsl:when>
          <xsl:when test=". instance of attribute()">
            <xsl:value-of select="concat('@', name(.))"/>
          </xsl:when>
          <xsl:when test=". instance of processing-instruction()">
            <xsl:value-of select="concat('processing-instruction(&quot;', name(.), '&quot;)[', $position, ']')"/>
          </xsl:when>
          <xsl:when test=". instance of comment()">
            <xsl:value-of select="concat('comment()[', $position, ']')"/>
          </xsl:when>
          <xsl:when test=". instance of text()">
            <xsl:value-of select="concat('text()[', $position, ']')"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:value-of select="concat('/', string-join($segments, '/'))"/>
  </xsl:function>

</xsl:transform>
