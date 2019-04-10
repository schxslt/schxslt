<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Create part of the validation stylesheet that creates the report -->
  <xsl:template name="schxslt-api:report">
    <xsl:param name="schema" as="element(sch:schema)" required="yes"/>
    <xsl:param name="phase" as="xs:string" required="yes"/>
  </xsl:template>

  <!-- Create part of the validation stylesheet that reports an active pattern -->
  <xsl:template name="schxslt-api:active-pattern">
    <xsl:param name="pattern" as="element(sch:pattern)" required="yes"/>
  </xsl:template>

  <!-- Create part of the validation stylesheet that reports a fired rule -->
  <xsl:template name="schxslt-api:fired-rule">
    <xsl:param name="rule" as="element(sch:rule)" required="yes"/>
  </xsl:template>

  <!-- Create part of the validation stylesheet that reports a failed assert -->
  <xsl:template name="schxslt-api:failed-assert">
    <xsl:param name="assert" as="element(sch:assert)" required="yes"/>
  </xsl:template>

  <!-- Create part of the validation stylesheet that reports a successful report -->
  <xsl:template name="schxslt-api:successful-report">
    <xsl:param name="report" as="element(sch:report)" required="yes"/>
  </xsl:template>

</xsl:transform>
