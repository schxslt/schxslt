# Revisions to [SchXslt](README-REV.md)

This version of [SchXslt](https://github.com/schxslt/schxslt) has several enhancements in mind:

- Simplify process such that only compile-for-svrl.xsl needs to be invoked (i.e., let include.xsl and expand.xsl work behind the scenes, and eliminate the need for XProc compile-schematron.xpl). 
- Support Schematron files that have `<xsl:include href="myxsltlibrary.xsl"/>` statements.
- Anticipate that the resultant SchXslt file might be needed not merely as a master stylesheet, but as a component of other stylesheets.
- Anticipate that the resultant SchXslt file might wind up being part of the very stylesheet libraries the original Schematron file included.

To support these enhancements, the following changes were made (only to the branch for XSLT 2.0):

- Specific alias names were assigned to the default template mode in several files: include.xsl, expand.xsl, compile/templates.xsl.
- compile-for-svrl.xsl was changed:
  - Added parameters to allow skipping include and expand processes, if already done.
  - Bound the optimal form of the input to global variable $input-expanded.
- compile/compile-2.0.xsl was changed: 
   - Converted each `<xsl:include href="myxsltlibrary.xsl"/>` to `<xsl:import href="myxsltlibrary.xsl"/>`. This step is required because unexpected template rules in any included XSLT could wreak havoc with the SchXslt's processes.
   - Supplied **static** parameter $schxslt-is-master to true(). See below.
   - Changed default template patterns so that the stylesheet's own are defined as shallow skips, but all other template modes are allowed to be determined by the imported XSLT stylesheets.
   - Provided the default template mode name an alias, so that any stylesheets that include the schxslt file can invoke its particular process. This is needed because the XSLT library might have imported numerous schxslt files that need to be differentiated. 

The resultant output SchXslt files will still work as before, when treated as master XSLT files. But they can also now be a component of a larger library.

Suppose you have an new SchXslt whose filename is myschematron.sch.xsl and the default template mode is also named schxslt:myschematron.xsl. And suppose want to import that new SchXslt from another XSLT file. In that XSLT file, do something like this:

    <xsl:param name="schxslt-is-master" as="xs:boolean" select="false()" static="yes"/>
    
    <xsl:import href="../../schemas/myschematron.sch.xsl" use-when="not($schxslt-is-master)"/>
    <xsl:template match="document-node() | node() | @*" mode="schxslt:myschematron.sch d8e7">
        <xsl:apply-imports/>
    </xsl:template>

Ensure that @mode lists every mode name mentioned by an imported SchXslt file. Now at this point, you should be able within any given XSLT process to fetch the reports of your choice by applying the specific template mode. For example: 

    <xsl:variable name="some-document-validation-reports" as="document-node()*">
        <xsl:apply-templates select="$some-documents" mode="schxslt:gpo.sch"/>
    </xsl:variable>

This method works because, although stylesheets are not allowed to mutually import one another, the static parameter + @use-when excludes one <xsl:import/> or the other before the stylesheets are compiled.

*Oct. 3, 2019*

*Joel Kalvesmaki*