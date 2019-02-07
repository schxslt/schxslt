<xsl:transform version="2.0"
               exclude-result-prefixes="#all"
               xmlns:xspec="http://www.jenitennison.com/xslt/xspec"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="xspec:reports">
    <xsl:variable name="total" select="xspec:report"/>
    <xsl:variable name="success" select="xspec:report[every $t in xspec:scenario/xspec:test/@successful satisfies $t = 'true']"/>
    <xsl:variable name="fail" select="xspec:report[some $t in xspec:scenario/xspec:test/@successful satisfies $t = 'false']"/>
    <html>
      <head>
        <title>SchXslt test suite</title>
        <style type="text/css">
          .success { color: green; font-weight: bold; }
          .failure { color: red; font-weight: bold; }
        </style>
      </head>
      <body>
        <h1>
          SchXslt test suite
          <br/>
          <small>
            <xsl:value-of select="count($total)"/>
            <xsl:text> / </xsl:text>
            <span class="success"><xsl:value-of select="count($success)"/></span>
            <xsl:text> / </xsl:text>
            <span class="failure"><xsl:value-of select="count($fail)"/></span>
          </small>
        </h1>
        <h2>Test files</h2>
        <table>
          <tbody>
            <xsl:for-each select="$total">
              <tr>
                <th><xsl:value-of select="position()"/></th>
                <td><xsl:value-of select="@xspec"/></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="every $t in xspec:scenario/xspec:test/@successful satisfies $t = 'true'">
                      <span class="success">SUCCESS</span>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="failure">FAIL</span>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:transform>
