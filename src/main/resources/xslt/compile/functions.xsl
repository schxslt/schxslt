<xsl:transform version="2.0" 
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return the effective phase</p>
      <p> 
        The effective phase is #ALL if the selected phase is #DEFAULT or no phase was selected.  Terminates if the schema does not contain the selected phase.
      </p>
    </desc>
    <param name="schema">Schematron schema</param>
    <param name="phase">Requested phase</param>
    <return>Effective phase</return>
  </doc>
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
      <xsl:message terminate="yes"> The phase '<xsl:value-of select="$phase"/>' is not defined.
      </xsl:message>
    </xsl:if>

    <xsl:value-of select="$phase"/>

  </xsl:function>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return sequence of active patterns</p>
    </desc>
    <param name="schema">Schematron schema</param>
    <param name="phase">Phase</param>
    <return>Sequence of patterns active in selected phase</return>
  </doc>
  <xsl:function name="schxslt:active-patterns" as="element(sch:pattern)+">
    <xsl:param name="schema" as="element(sch:schema)"/>
    <xsl:param name="phase" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="$phase eq '#ALL'">
        <xsl:sequence select="$schema/sch:pattern"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="$schema/sch:pattern[@id = $schema/sch:phase[@id eq $phase]/sch:active/@pattern]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="schxslt:rename-variable" as="xs:string">
    <xsl:param name="expression" as="xs:string"/>
    <xsl:param name="from" as="xs:string"/>
    <xsl:param name="to" as="xs:string"/>

    <xsl:variable name="quote">"</xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($expression, '$')">
        <xsl:variable name="head" select="substring-before($expression, '$')"/>
        <xsl:variable name="tail" select="substring-after($expression, '$')"/>
        <xsl:variable name="in-string-expr-p" as="xs:boolean" select="count(tokenize($head, '[''$quote]')) mod 2 eq 0"/>
        <xsl:variable name="head" select="if ($in-string-expr-p) then $head else replace($head, concat('(\W*)\$', $from, '(\W*)'), concat('$1', $to, '$2'))"/>
        <xsl:sequence select="($head, schxslt:rename-variable($tail, $from, $to))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$expression"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:transform>
