<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>Return path to node</p>
    </desc>
    <param name="node">Node</param>
    <return>Path to node</return>
  </doc>
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
