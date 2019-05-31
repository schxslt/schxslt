<p:declare-step name="update-version" version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:pom="http://maven.apache.org/POM/4.0.0"
                xmlns:p="http://www.w3.org/ns/xproc">

  <p:variable name="version" select="unparsed-text('../VERSION')"/>

  <p:string-replace match="/pom:project/pom:version/text()" name="update-pom">
    <p:with-option name="replace" select="concat('&quot;', $version, '&quot;')"/>
    <p:input port="source">
      <p:document href="../pom.xml"/>
    </p:input>
  </p:string-replace>
  <p:store method="xml" href="../pom.xml">
    <p:input port="source">
      <p:pipe step="update-pom" port="result"/>
    </p:input>
  </p:store>

  <p:string-replace match="/pkg:package/@version" name="update-xquery-basex">
    <p:with-option name="replace" select="concat('&quot;', $version, '&quot;')"/>
    <p:input port="source">
      <p:document href="../src/main/xquery/basex/expath-pkg.xml"/>
    </p:input>
  </p:string-replace>
  <p:store method="xml" href="../src/main/xquery/basex/expath-pkg.xml">
    <p:input port="source">
      <p:pipe step="update-xquery-basex" port="result"/>
    </p:input>
  </p:store>

  <p:string-replace match="/pkg:package/@version" name="update-xquery-exist">
    <p:with-option name="replace" select="concat('&quot;', $version, '&quot;')"/>
    <p:input port="source">
      <p:document href="../src/main/xquery/exist/expath-pkg.xml"/>
    </p:input>
  </p:string-replace>
  <p:store method="xml" href="../src/main/xquery/exist/expath-pkg.xml">
    <p:input port="source">
      <p:pipe step="update-xquery-exist" port="result"/>
    </p:input>
  </p:store>

  <p:string-replace match="id('version')/text()" name="update-xslt">
    <p:with-option name="replace" select="concat('&quot;', $version, '&quot;')"/>
    <p:input port="source">
      <p:document href="../src/main/resources/xslt/version.xsl"/>
    </p:input>
  </p:string-replace>
  <p:store method="xml" href="../src/main/resources/xslt/version.xsl">
    <p:input port="source">
      <p:pipe step="update-xslt" port="result"/>
    </p:input>
  </p:store>

</p:declare-step>
