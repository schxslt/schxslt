<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:error="https://doi.org/10.5281/zenodo.1495494#error"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="compile/compile-2.0.xsl"/>

  <xsl:template name="schxslt-api:report">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:param name="phase" as="xs:string" required="yes"/>

    <svrl:schematron-output>
      <xsl:sequence select="$schema/@schemaVersion"/>
      <xsl:if test="$phase ne '#ALL'">
        <xsl:attribute name="phase" select="$phase"/>
      </xsl:if>
      <xsl:if test="$schema/sch:title">
        <xsl:attribute name="title" select="$schema/sch:title"/>
      </xsl:if>
      <xsl:for-each select="$schema/sch:p">
        <svrl:text>
          <xsl:sequence select="(@id, @class, @icon)"/>
          <xsl:apply-templates select="node()"/>
        </svrl:text>
      </xsl:for-each>

      <xsl:for-each select="$schema/sch:ns">
        <svrl:ns-prefix-in-attribute-values>
          <xsl:sequence select="(@prefix, @uri)"/>
        </svrl:ns-prefix-in-attribute-values>
      </xsl:for-each>

      <sequence select="$schxslt:report"/>

    </svrl:schematron-output>
  </xsl:template>

  <xsl:template name="schxslt-api:active-pattern">
    <xsl:param name="pattern" as="element(sch:pattern)" required="yes"/>
    <svrl:active-pattern>
      <xsl:sequence select="($pattern/@id, $pattern/@role)"/>
      <xsl:if test="exists(base-uri(.))">
        <attribute name="documents" select="base-uri(.)"/>
      </xsl:if>
    </svrl:active-pattern>
  </xsl:template>

  <xsl:template name="schxslt-api:fired-rule">
    <xsl:param name="rule" as="element(sch:rule)" required="yes"/>
    <svrl:fired-rule>
      <xsl:sequence select="($rule/@id, $rule/@role, $rule/@flag)"/>
      <attribute name="context">
        <xsl:value-of select="$rule/@context"/>
      </attribute>
    </svrl:fired-rule>
  </xsl:template>

  <xsl:template name="schxslt-api:suppressed-rule">
    <xsl:param name="rule" as="element(sch:rule)" required="yes"/>
    <xsl:variable name="message">
      WARNING: Rule <xsl:value-of select="normalize-space(@id)"/> for context "<xsl:value-of select="@context"/>" shadowed by preceeding rule
    </xsl:variable>
    <comment> <xsl:sequence select="normalize-space($message)"/> </comment>
    <message> <xsl:sequence select="normalize-space($message)"/> </message>
    <svrl:suppressed-rule>
      <xsl:sequence select="($rule/@id, $rule/@role, $rule/@flag)"/>
      <attribute name="context">
        <xsl:value-of select="$rule/@context"/>
      </attribute>
    </svrl:suppressed-rule>
  </xsl:template>

  <xsl:template name="schxslt-api:failed-assert">
    <xsl:param name="assert" as="element(sch:assert)" required="yes"/>
    <svrl:failed-assert location="{{schxslt:location({($assert/@subject, $assert/../@subject, '.')[1]})}}">
      <xsl:sequence select="($assert/@role, $assert/@flag, $assert/@id)"/>
      <attribute name="test">
        <xsl:value-of select="$assert/@test"/>
      </attribute>
      <xsl:call-template name="schxslt:handle-detailed-report">
        <xsl:with-param name="schema" as="element(sch:schema)" tunnel="yes" select="$assert/../../.."/>
      </xsl:call-template>
    </svrl:failed-assert>
  </xsl:template>

  <xsl:template name="schxslt-api:successful-report">
    <xsl:param name="report" as="element(sch:report)" required="yes"/>
    <svrl:successful-report location="{{schxslt:location({($report/@subject, $report/../@subject, '.')[1]})}}">
      <xsl:sequence select="($report/@role, $report/@flag, $report/@id)"/>
      <attribute name="test">
        <xsl:value-of select="$report/@test"/>
      </attribute>
      <xsl:call-template name="schxslt:handle-detailed-report">
        <xsl:with-param name="schema" as="element(sch:schema)" tunnel="yes" select="$report/../../.."/>
      </xsl:call-template>
    </svrl:successful-report>
  </xsl:template>

  <xsl:template name="schxslt-api:validation-stylesheet-body-bottom-hook">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:variable name="location-function" select="($schema/sch:schema/xsl:function, document('compile-for-svrl.xsl')//xsl:function)[schxslt:is-location-function(.)][1]"/>
    <xsl:if test="empty($location-function)">
      <xsl:variable name="message">
        Can't find required function Q{https://doi.org/10.5281/zenodo.1495494}location.
      </xsl:variable>
      <xsl:message terminate="yes" select="error(xs:QName('error:E0004'), normalize-space($message))"/>
    </xsl:if>
    <xsl:sequence select="$location-function"/>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Create detailed report about failed assert or successful report</p>
    </desc>
  </doc>
  <xsl:template name="schxslt:handle-detailed-report">
    <xsl:call-template name="schxslt:copy-diagnostics"/>
    <xsl:call-template name="schxslt:copy-properties"/>
    <xsl:if test="text() | *">
      <svrl:text>
        <xsl:apply-templates select="node()"/>
      </svrl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="schxslt:handle-property">
    <xsl:param name="property" as="element(sch:property)"/>
    <svrl:property-reference property="{.}">
      <xsl:sequence select="($property/@role, $property/@scheme)"/>
      <svrl:text>
        <xsl:apply-templates select="$property/node()"/>
      </svrl:text>
    </svrl:property-reference>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Copy Schematron properties to SVRL</p>
    </desc>
    <param name="schema">Schematron</param>
  </doc>
  <xsl:template name="schxslt:copy-properties">
    <xsl:param name="schema" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@properties, ' ')">
      <xsl:call-template name="schxslt:handle-property">
        <xsl:with-param name="property" select="$schema/sch:properties/sch:property[@id eq current()]"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Copy Schematron diagnostics to SVRL</p>
    </desc>
    <param name="schema">Schematron</param>
  </doc>
  <xsl:template name="schxslt:copy-diagnostics">
    <xsl:param name="schema" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@diagnostics, ' ')">
      <xsl:variable name="diagnostic" select="$schema/sch:diagnostics/sch:diagnostic[@id eq current()]"/>
      <svrl:diagnostic-reference diagnostic="{.}">
        <svrl:text>
          <xsl:sequence select="$diagnostic/@*"/>
          <xsl:apply-templates select="$diagnostic/node()"/>
        </svrl:text>
      </svrl:diagnostic-reference>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="schxslt:location" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:variable name="segments" as="xs:string*">
      <xsl:for-each select="($node/ancestor-or-self::node())">
        <xsl:variable name="position">
          <xsl:number level="single"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test=". instance of element()">
            <xsl:value-of select="concat('Q{', namespace-uri(.), '}', local-name(.), '[', $position, ']')"/>
          </xsl:when>
          <xsl:when test=". instance of attribute()">
            <xsl:value-of select="concat('@Q{', namespace-uri(.), '}', local-name(.))"/>
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

  <xsl:function name="schxslt:is-location-function" as="xs:boolean">
    <xsl:param name="function" as="element(xsl:function)"/>

    <xsl:variable name="nsUri" select="namespace-uri-for-prefix(substring-before($function/@name, ':'), $function)"/>
    <xsl:variable name="localname" select="substring-after($function/@name, ':')"/>

    <xsl:sequence select="boolean($nsUri eq 'https://doi.org/10.5281/zenodo.1495494' and $localname eq 'location')"/>
  </xsl:function>

</xsl:transform>
