<xsl:transform version="2.0"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="compile-for-svrl.xsl"/>
  <xsl:import href="include.xsl"/>
  <xsl:import href="expand.xsl"/>

  <xsl:variable name="input-include" as="element(sch:schema)">
    <xsl:call-template name="schxslt:include">
      <xsl:with-param name="schematron" as="element(sch:schema)" select="/sch:schema"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="input-expand" as="element(sch:schema)">
    <xsl:call-template name="schxslt:expand">
      <xsl:with-param name="schematron" as="element(sch:schema)" select="$input-include"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:call-template name="schxslt:compile">
      <xsl:with-param name="schematron" select="$input-expand" as="element(sch:schema)"/>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
