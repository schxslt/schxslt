<xsl:transform version="2.0" exclude-result-prefixes="#all"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494">

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

  <xsl:template name="schxslt:effective-strategy">
    <xsl:param name="strategy" as="xs:string" required="yes"/>
    <xsl:param name="schematron" as="element(sch:schema)" select="."/>
    <xsl:value-of select="$strategy"/>
  </xsl:template>

  <xsl:template name="schxslt:effective-queryBinding">
    <xsl:param name="queryBinding" as="xs:string" required="yes"/>
    <xsl:param name="schematron" as="element(sch:schema)" select="."/>
    <xsl:value-of select="lower-case($queryBinding)"/>
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
      <param name="{@name}" tunnel="yes"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:let-with-param">
    <xsl:param name="bindings" as="element(sch:let)*"/>
    <xsl:for-each select="distinct-values($bindings/@name)">
      <with-param name="{.}" select="${.}" tunnel="yes"/>
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

  <xsl:template name="schxslt:copy-helper">
    <xsl:sequence select="document('')/xsl:transform/xsl:template[@name = 'schxslt:location']"/>
    <xsl:sequence select="document('')/xsl:transform/xsl:template[@name = 'schxslt:location-step']"/>
    <xsl:sequence select="document('')/xsl:transform/xsl:template[@mode = 'schxslt:unwrap-report']"/>
  </xsl:template>

  <xsl:function name="schxslt:pattern-grouping-key" as="xs:string">
    <xsl:param name="pattern" as="element(sch:pattern)"/>
    <xsl:value-of select="if ($effective-strategy eq 'traditional') then generate-id($pattern) else string-join((generate-id($pattern/sch:let), $pattern/@documents), ' ')"/>
  </xsl:function>

  <xsl:template match="node()" mode="schxslt:unwrap-report">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="svrl:fired-rule" mode="schxslt:unwrap-report" priority="1">
    <xsl:if test="not(preceding-sibling::svrl:fired-rule[@schxslt:context = current()/@schxslt:context][@schxslt:pattern = current()/@schxslt:pattern])">
      <xsl:copy>
        <xsl:sequence select="@* except @schxslt:*"/>
      </xsl:copy>
      <xsl:sequence select="*"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="svrl:*[@schxslt:*]" mode="schxslt:unwrap-report" priority="0">
    <xsl:copy>
      <xsl:sequence select="@* except @schxslt:*"/>
      <xsl:sequence select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Create the body of a rule template -->
  <xsl:template name="schxslt:rule-template-body">
    <xsl:param name="bindings" as="element(sch:let)*" required="yes"/>

    <xsl:sequence select="(@xml:base, ../@xml:base)[1]"/>
    <xsl:if test="$effective-strategy eq 'ex-post'">
      <param name="schxslt:fired-rules" as="element(svrl:fired-rule)*"/>
    </xsl:if>
    <xsl:call-template name="schxslt:let-param">
      <xsl:with-param name="bindings" select="$bindings"/>
    </xsl:call-template>

    <xsl:call-template name="schxslt:let-variable">
      <xsl:with-param name="bindings" select="sch:let"/>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$effective-strategy eq 'ex-post'">
        <if test="empty($schxslt:fired-rules[@schxslt:context = generate-id()][schxslt:pattern = {generate-id(..)}])">
          <svrl:fired-rule schxslt:context="{{generate-id()}}" schxslt:pattern="{generate-id(..)}">
            <xsl:sequence select="(@id, @context, @role, @flag)"/>
            <xsl:apply-templates select="sch:assert | sch:report"/>
          </svrl:fired-rule>
        </if>
      </xsl:when>
      <xsl:otherwise>
        <svrl:fired-rule schxslt:context="{{generate-id()}}" schxslt:pattern="{generate-id(..)}">
          <xsl:sequence select="(@id, @context, @role, @flag)"/>
          <xsl:apply-templates select="sch:assert | sch:report"/>
        </svrl:fired-rule>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="schxslt:location" as="xs:string">
    <xsl:param name="node" as="node()" select="."/>
    <xsl:variable name="steps" as="xs:string*">
      <xsl:for-each select="$node/ancestor-or-self::node()">
        <xsl:call-template name="schxslt:location-step"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat('/', string-join($steps, '/'))"/>
  </xsl:template>

  <xsl:template name="schxslt:location-step" as="xs:string?">
    <xsl:choose>
      <xsl:when test=". instance of element()">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:value-of select="concat(name(.), '[', $position, ']')"/>
      </xsl:when>
      <xsl:when test=". instance of attribute()">
        <xsl:value-of select="concat('@', name(.))"/>
      </xsl:when>
      <xsl:when test=". instance of processing-instruction()">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:value-of select="concat('processing-instruction(&quot;', name(.), '&quot;)[', $position, ']')"/>
      </xsl:when>
      <xsl:when test=". instance of comment()">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:value-of select="concat('comment()[', $position, ']')"/>
      </xsl:when>
      <xsl:when test=". instance of text()">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:value-of select="concat('text()[', $position, ']')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="schxslt:svrl-detailed-report">
    <xsl:call-template name="schxslt:svrl-copy-diagnostics"/>
    <xsl:call-template name="schxslt:svrl-copy-properties"/>
    <xsl:if test="text() | *">
      <svrl:text>
        <xsl:apply-templates select="node()"/>
      </svrl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="schxslt:svrl-copy-properties">
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@properties, ' ')">
      <xsl:variable name="property" select="$schematron/sch:properties/sch:property[@id eq current()]"/>
      <svrl:property-reference property="{.}">
        <xsl:sequence select="($property/@role, $property/@scheme)"/>
        <svrl:text>
          <xsl:apply-templates select="$property/node()"/>
        </svrl:text>
      </svrl:property-reference>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="schxslt:svrl-copy-diagnostics">
    <xsl:param name="schematron" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@diagnostics, ' ')">
      <xsl:variable name="diagnostic" select="$schematron/sch:diagnostics/sch:diagnostic[@id eq current()]"/>
      <svrl:diagnostic-reference diagnostic="{.}">
        <svrl:text>
          <xsl:apply-templates select="$diagnostic/node()"/>
        </svrl:text>
      </svrl:diagnostic-reference>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="sch:name">
    <value-of select="{if (@path) then @path else 'name()'}">
      <xsl:sequence select="@xml:base"/>
    </value-of>
  </xsl:template>

  <xsl:template match="sch:value-of">
    <value-of select="{@select}">
      <xsl:sequence select="@xml:base"/>
    </value-of>
  </xsl:template>

</xsl:transform>
