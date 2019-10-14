<!-- Compile preprocessed Schematron to validation stylesheet -->
<xsl:transform version="2.0"
               xmlns="http://www.w3.org/1999/XSL/TransformAlias"
               xmlns:dc="http://purl.org/dc/elements/1.1/"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:error="https://doi.org/10.5281/zenodo.1495494#error"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="api-2.0.xsl"/>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Compile preprocessed Schematron to validation stylesheet</p>
    </desc>
    <param name="phase">Validation phase</param>
  </doc>

  <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>
  <xsl:output indent="yes"/>

  <xsl:include href="functions.xsl"/>
  <xsl:include href="templates.xsl"/>
  <xsl:include href="../../version.xsl"/>

  <xsl:param name="phase" as="xs:string">#DEFAULT</xsl:param>

  <!-- There are cases where a Schematron file includes an XSLT library, and the output schxslt is intended to be incorporated into that library as a low-level imported stylesheet. In such cases, the following parameter should be false, otherwise true. -->
  <xsl:param name="schxslt-is-master-of-included-xslt" as="xs:boolean" select="true()"/>
  
  <!-- To avoid a validation error in thes stylesheet from oXygen, be sure that the including ../compile-for-svrl.xsl is registered as a master file -->
  <xsl:variable name="effective-phase" select="schxslt:effective-phase($input-expanded/sch:schema, $phase)" as="xs:string"/>
  <xsl:variable name="active-patterns" select="schxslt:active-patterns($input-expanded/sch:schema, $effective-phase)" as="element(sch:pattern)+"/>

  <!-- The following regex is a simplification of rules at https://www.w3.org/TR/REC-xml/#CharClasses -->
  <xsl:variable name="ncname-regex" as="xs:string">[\p{Ll}\p{Lu}\p{Lo}\p{Lt}\p{Nl}_:][\p{L}\p{M}\p{Nl}\p{Nd}_:\.-]*</xsl:variable>
  <xsl:variable name="main-template-mode-name" as="xs:string"
    select="if (exists(base-uri(/))) then replace(base-uri(/), concat('.+?(', $ncname-regex, ')$'), '$1') else 'default'"
  />

  <xsl:variable name="metadata" as="element(rdf:Description)">
    <rdf:Description>
      <xsl:if test="sch:schema/sch:title">
        <dc:title>
          <xsl:sequence select="sch:schema/sch:title/@xml:lang"/>
          <xsl:value-of select="sch:schema/sch:title"/>
        </dc:title>
      </xsl:if>
      <xsl:for-each select="sch:schema/sch:p">
        <dc:description>
          <xsl:sequence select="@xml:lang"/>
          <xsl:value-of select="."/>
        </dc:description>
      </xsl:for-each>
      <dc:creator><xsl:call-template name="schxslt:user-agent"/></dc:creator>
      <dc:date><xsl:value-of select="current-dateTime()"/></dc:date>
    </rdf:Description>
  </xsl:variable>

  <xsl:variable name="validation-stylesheet-body" as="element(xsl:template)+">
    <xsl:call-template name="schxslt:validation-stylesheet-body">
      <xsl:with-param name="patterns" as="element(sch:pattern)+" select="$active-patterns"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="target-schxslt-template-modes" as="xs:string+"
    select="('#default', concat('schxslt:', $main-template-mode-name), $validation-stylesheet-body/@name)"/>

  <xsl:template match="sch:schema" mode="#default compile-sch-xslt">
    <!-- This is the main/initial template for any input Schematron file. -->
    <transform version="{schxslt:xslt-version(.)}">
      <xsl:for-each select="sch:ns">
        <xsl:namespace name="{@prefix}" select="@uri"/>
      </xsl:for-each>
      <xsl:sequence select="@xml:base"/>

      <xsl:sequence select="xsl:param"/>
      <xsl:if test="exists(xsl:include)">
        <param name="schxslt-is-master" as="xs:boolean" select="{$schxslt-is-master-of-included-xslt}()" static="yes"/>
      </xsl:if>
      <xsl:sequence select="xsl:import"/>
      <xsl:apply-templates select="xsl:include" mode="include-xslt"/>

      <xsl:sequence select="$metadata"/>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-top-hook">
        <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
      </xsl:call-template>

      <output indent="yes"/>

      <xsl:sequence select="xsl:key"/>
      <xsl:sequence select="xsl:variable"/>
      <xsl:sequence select="xsl:function"/>
      <xsl:sequence select="xsl:template"/>

      <!-- See https://github.com/dmj/schxslt/issues/25 -->
      <xsl:variable name="global-bindings" as="element(sch:let)*" select="(sch:let, sch:phase[@id eq $effective-phase]/sch:let, $active-patterns/sch:let)"/>
      <xsl:if test="count($global-bindings) ne count(distinct-values($global-bindings/@name))">
        <xsl:variable name="message">
          Compilation aborted because of variable name conflicts:
          <xsl:for-each-group select="$global-bindings" group-by="@name">
            <xsl:value-of select="current-grouping-key()"/> (<xsl:value-of select="current-group()/../local-name()" separator=", "/>)
          </xsl:for-each-group>
        </xsl:variable>
        <xsl:message terminate="yes" select="error(xs:QName('error:E0003'), normalize-space($message))"/>
      </xsl:if>

      <xsl:call-template name="schxslt:let-param">
        <xsl:with-param name="bindings" select="sch:let"/>
      </xsl:call-template>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" select="(sch:phase[@id eq $effective-phase]/sch:let, $active-patterns/sch:let)"/>
      </xsl:call-template>

      <template match="/" mode="#default schxslt:{$main-template-mode-name}">
        <xsl:sequence select="sch:phase[@id eq $effective-phase]/@xml:base"/>

        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" select="sch:phase[@id eq $effective-phase]/sch:let"/>
        </xsl:call-template>

        <variable name="report" as="element(schxslt:report)">
          <schxslt:report>
            <xsl:for-each select="$validation-stylesheet-body/@name">
              <call-template name="{.}">
                <with-param name="default-document" as="document-node()" select="."/>
              </call-template>
            </xsl:for-each>
          </schxslt:report>
        </variable>

        <!-- Unwrap the intermediary report -->
        <variable name="schxslt:report" as="node()*">
          <for-each select="$report/schxslt:pattern">
            <sequence select="node()"/>
            <sequence select="$report/schxslt:rule[@pattern = current()/@id]/node()"/>
          </for-each>
        </variable>

        <xsl:call-template name="schxslt-api:report">
          <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
          <xsl:with-param name="phase" as="xs:string" select="$effective-phase"/>
        </xsl:call-template>

      </template>

      <xsl:comment>By default, the modes employed in this schxslt file are shallow skips...</xsl:comment>
      <template match="text() | @*" mode="{string-join($target-schxslt-template-modes, ' ')}"/>
      <template match="* | processing-instruction() | comment()" mode="{string-join($target-schxslt-template-modes, ' ')}">
        <apply-templates mode="#current" select="@* | node()"/>
      </template>
      <xsl:comment>...but all other template modes should defer to rules specified by any imported stylesheets.</xsl:comment>
      <template match="document-node() | node() | @*" mode="#all" priority="-1">
        <apply-imports/>
      </template>

      <xsl:sequence select="$validation-stylesheet-body"/>

      <xsl:call-template name="schxslt-api:validation-stylesheet-body-bottom-hook">
        <xsl:with-param name="schema" as="element(sch:schema)" select="."/>
      </xsl:call-template>
      
    </transform>

  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return rule template</p>
    </desc>
    <param name="mode">Template mode</param>
  </doc>
  <xsl:template match="sch:rule" mode="#default compile-sch-xslt">
    <xsl:param name="mode" as="xs:string" required="yes"/>

    <template match="{@context}" priority="{count(following::sch:rule) + 1}" mode="{$mode}">
      <xsl:sequence select="(@xml:base, ../@xml:base)"/>

      <!-- Check if a context node was already matched by a rule of the current pattern. -->
      <param name="schxslt:rules" as="element(schxslt:rule)*"/>

      <xsl:call-template name="schxslt:let-variable">
        <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
      </xsl:call-template>

      <choose>
        <when test="empty($schxslt:rules[@pattern = '{generate-id(..)}'][@context = generate-id(current())])">
          <schxslt:rule pattern="{generate-id(..)}@{{base-uri(.)}}">
            <xsl:call-template name="schxslt-api:fired-rule">
              <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="sch:assert | sch:report" mode="#current"/>
          </schxslt:rule>
        </when>
        <otherwise>
          <schxslt:rule pattern="{generate-id(..)}@{{base-uri(.)}}">
            <xsl:call-template name="schxslt-api:suppressed-rule">
              <xsl:with-param name="rule" as="element(sch:rule)" select="."/>
            </xsl:call-template>
          </schxslt:rule>
        </otherwise>
      </choose>

      <next-match>
        <with-param name="schxslt:rules" as="element(schxslt:rule)*">
          <sequence select="$schxslt:rules"/>
          <schxslt:rule context="{{generate-id()}}" pattern="{generate-id(..)}"/>
        </with-param>
      </next-match>
    </template>

  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return body of validation stylesheet</p>
    </desc>
    <param name="patterns">Sequence of active patterns</param>
  </doc>
  <xsl:template name="schxslt:validation-stylesheet-body">
    <xsl:param name="patterns" as="element(sch:pattern)+"/>

    <xsl:for-each-group select="$patterns" group-by="string-join((generate-id(sch:let), base-uri(.), @documents), '&lt;')">
      <xsl:variable name="mode" as="xs:string" select="generate-id()"/>
      <xsl:variable name="baseUri" as="xs:anyURI" select="base-uri(.)"/>

      <template name="{$mode}">
        <xsl:sequence select="@xml:base"/>

        <param name="default-document" as="document-node()"/>
        <xsl:call-template name="schxslt:let-variable">
          <xsl:with-param name="bindings" as="element(sch:let)*" select="sch:let"/>
        </xsl:call-template>

        <variable name="documents" as="item()+">
          <xsl:choose>
            <xsl:when test="@documents">
              <for-each select="{@documents}">
                <sequence select="document(resolve-uri(., '{$baseUri}'))"/>
              </for-each>
            </xsl:when>
            <xsl:otherwise>
              <sequence select="$default-document"/>
            </xsl:otherwise>
          </xsl:choose>
        </variable>

        <for-each select="$documents">
          <variable name="this-base-uri" select="(*/@xml:base, base-uri(.))[1]"/>
          <xsl:for-each select="current-group()">
            <schxslt:pattern id="{generate-id()}@{{$this-base-uri}}">
              <xsl:call-template name="schxslt-api:active-pattern">
                <xsl:with-param name="pattern" as="element(sch:pattern)" select="."/>
              </xsl:call-template>
            </schxslt:pattern>
          </xsl:for-each>

          <apply-templates mode="{$mode}" select="."/>
        </for-each>

      </template>

      <xsl:apply-templates select="current-group()/sch:rule">
        <xsl:with-param name="mode" as="xs:string" select="$mode"/>
      </xsl:apply-templates>

    </xsl:for-each-group>

  </xsl:template>
  
  <!-- An <xsl:include> that was in the original schematron file should be downgraded in 
    the output XSLT file to an <xsl:import> so that its content does not accidentally override 
    the new controlling SCHXSLT file.
  -->
  <xsl:template match="xsl:include" mode="include-xslt">
    <!--<xsl:if test="$output-xsl-is-slave-of-included-xslt = false()">
        <import>
          <xsl:copy-of select="@*"/>
        </import>
    </xsl:if>-->
    <import use-when="$schxslt-is-master">
      <xsl:copy-of select="@*"/>
    </import>
  </xsl:template>

</xsl:transform>
