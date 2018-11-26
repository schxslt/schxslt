<xsl:transform version="2.0" exclude-result-prefixes="#all"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="http://dmaus.name/ns/schxslt">

  <xsl:template name="schxslt:effective-phase" as="xs:string">
    <xsl:param name="phase" as="xs:string" required="yes"/>
    <xsl:param name="schematron" as="element(sch:schema)" select="."/>
    <xsl:choose>
      <xsl:when test="$phase = ('#DEFAULT', '')">
        <xsl:value-of select="($schematron/@defaultPhase, '#ALL')[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$phase"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="schxslt:let-variable">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="$bindings">
      <variable name="{@name}" select="{@value}">
        <xsl:sequence select="@xml:base"/>
      </variable>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-param">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="$bindings">
      <param name="{@name}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-with-param">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="distinct-values($bindings/@name)">
      <with-param name="{.}" select="${.}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:active-patterns">
    <xsl:param name="phase" as="xs:string" required="yes"/>
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$phase eq '#ALL'">
        <xsl:sequence select="$schematron/sch:pattern"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$schematron/sch:pattern[@id = $schematron/sch:phase[@id eq $phase]/sch:active/@pattern]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
