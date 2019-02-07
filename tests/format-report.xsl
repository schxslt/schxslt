<xsl:transform version="2.0"
               exclude-result-prefixes="#all"
               xmlns:xspec="http://www.jenitennison.com/xslt/xspec"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="xspec:reports">
    <xsl:variable name="total" select="xspec:report"/>
    <xsl:variable name="success" select="xspec:report[every $t in xspec:scenario/xspec:test/@successful satisfies $t = 'true']"/>
    <xsl:variable name="fail" select="xspec:report[some $t in xspec:scenario/xspec:test/@successful satisfies $t = 'false']"/>
    <p>Overall success: <xsl:value-of select="(count($total), count($success), count($fail))" separator=" / "/></p>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:transform>
