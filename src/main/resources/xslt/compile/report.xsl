<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>Templates in the svrl: namespace create portions of the validation stylesheet that generate SVRL output.</desc>
  </doc>
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Create SVRL report</p>
    </desc>
    <param name="schema">Schematron</param>
    <param name="phase">Effective phase</param>
    <param name="report-variable-name">Name of the variable holding the intermediary report</param>
  </doc>
  <xsl:template name="svrl:schematron-output">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:param name="phase" as="xs:string" required="yes"/>
    <xsl:param name="report-variable-name" as="xs:string" required="yes"/>

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

      <sequence select="${$report-variable-name}"/>

    </svrl:schematron-output>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Report an active pattern</p>
    </desc>
    <param name="pattern">Active pattern</param>
  </doc>
  <xsl:template name="svrl:active-pattern">
    <xsl:param name="pattern" as="element(sch:pattern)" required="yes"/>
    <svrl:active-pattern documents="{{base-uri(.)}}">
      <xsl:sequence select="($pattern/@id, $pattern/@role)"/>
    </svrl:active-pattern>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Report a fired rule</p>
    </desc>
    <param name="rule">Fired rule</param>
  </doc>
  <xsl:template name="svrl:fired-rule">
    <xsl:param name="rule" as="element(sch:rule)" required="yes"/>
    <svrl:fired-rule>
      <xsl:sequence select="($rule/@id, $rule/@context, $rule/@role, $rule/@flag)"/>
    </svrl:fired-rule>
  </xsl:template>
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Report a failed assert</p>
    </desc>
    <param name="assert">Failed assert</param>
  </doc>
  <xsl:template name="svrl:failed-assert">
    <xsl:param name="assert" as="element(sch:assert)" required="yes"/>
    <svrl:failed-assert location="{{schxslt:location({($assert/@subject, $assert/../@subject, '.')[1]})}}">
      <xsl:sequence select="($assert/@role, $assert/@flag, $assert/@id, $assert/@test)"/>
      <xsl:call-template name="svrl:detailed-report">
        <xsl:with-param name="schema" as="element(sch:schema)" tunnel="yes" select="$assert/../../.."/>
      </xsl:call-template>
    </svrl:failed-assert>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Report successful report</p>
    </desc>
    <param name="report">Successful report</param>
  </doc>
  <xsl:template name="svrl:successful-report">
    <xsl:param name="report" as="element(sch:report)" required="yes"/>
    <svrl:successful-report location="{{schxslt:location({($report/@subject, $report/../@subject, '.')[1]})}}">
      <xsl:sequence select="($report/@role, $report/@flag, $report/@id, $report/@test)"/>
      <xsl:call-template name="svrl:detailed-report">
        <xsl:with-param name="schema" as="element(sch:schema)" tunnel="yes" select="$report/../../.."/>
      </xsl:call-template>
    </svrl:successful-report>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Create detailed report about failed assert or successful report</p>
    </desc>
  </doc>
  <xsl:template name="svrl:detailed-report">
    <xsl:call-template name="svrl:copy-diagnostics"/>
    <xsl:call-template name="svrl:copy-properties"/>
    <xsl:if test="text() | *">
      <svrl:text>
        <xsl:apply-templates select="node()"/>
      </svrl:text>
    </xsl:if>
  </xsl:template>
  
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Copy Schematron properties to SVRL</p>
    </desc>
    <param name="schema">Schematron</param>
  </doc>
  <xsl:template name="svrl:copy-properties">
    <xsl:param name="schema" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@properties, ' ')">
      <xsl:variable name="property" select="$schema/sch:properties/sch:property[@id eq current()]"/>
      <svrl:property-reference property="{.}">
        <xsl:sequence select="($property/@role, $property/@scheme)"/>
        <svrl:text>
          <xsl:apply-templates select="$property/node()"/>
        </svrl:text>
      </svrl:property-reference>
    </xsl:for-each>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Copy Schematron diagnostics to SVRL</p>
    </desc>
    <param name="schema">Schematron</param>
  </doc>
  <xsl:template name="svrl:copy-diagnostics">
    <xsl:param name="schema" as="element(sch:schema)" tunnel="yes"/>

    <xsl:for-each select="tokenize(@diagnostics, ' ')">
      <xsl:variable name="diagnostic" select="$schema/sch:diagnostics/sch:diagnostic[@id eq current()]"/>
      <svrl:diagnostic-reference diagnostic="{.}">
        <svrl:text>
          <xsl:apply-templates select="$diagnostic/node()"/>
        </svrl:text>
      </svrl:diagnostic-reference>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>
