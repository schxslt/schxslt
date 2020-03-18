xquery version "3.1";

(:~
 : eXist module for Schematron validation with SchXslt.
 :
 : @author David Maus
 : @see    https://doi.org/10.5281/zenodo.1495494
 : @see    https://exist-db.org
 :
 :)

module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494";

declare namespace expath = "http://expath.org/ns/pkg";
declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare %private variable $schxslt:base-dir :=
  util:collection-name(collection(repo:get-root())//expath:package[@name = "https://doi.org/10.5281/zenodo.1495494"]);

(:~
 : Validate document against Schematron and return the validation report.
 :
 : @param  $document   Document to be validated
 : @param  $schematron Schematron schema
 : @param  $phase      Validation phase
 : @return Validation report
 :)
declare function schxslt:validate ($document as node(), $schematron as node(), $phase as xs:string?, $parameters as map(*)) as element(svrl:schematron-output) {
  let $compileOptions := if ($phase) then <parameters><param name="phase" value="{$phase}"/></parameters> else ()
  let $validateOptions := if (map:contains($parameters, "validate")) then schxslt:transform-parameters($parameters("validate")) else ()
  let $schematron := if ($schematron instance of document-node()) then $schematron/sch:schema else $schematron
  let $xsltver := schxslt:processor-path(lower-case($schematron/@queryBinding))
  return
    $document => transform:transform(schxslt:compile($schematron, $compileOptions, $xsltver), $validateOptions)
};

(:~
 : Validate document against Schematron and return the validation report.
 :
 : @param  $document   Document to be validated
 : @param  $schematron Schematron schema
 : @param  $phase      Validation phase
 : @return Validation report
 :)
declare function schxslt:validate ($document as node(), $schematron as node(), $phase as xs:string?) as element(svrl:schematron-output) {
  schxslt:validate($document, $schematron, $phase, map{})
};

(:~
 : Validate document against Schematron and return the validation report.
 :
 : @param  $document Document to be validated
 : @param  $schematron Schematron document
 : @return Validation report
 :)
declare function schxslt:validate ($document as node(), $schematron as node()) as element(svrl:schematron-output) {
  schxslt:validate($document, $schematron, ())
};

(:~
 : Return path segment to processor for requested query language.
 :
 : @error  Query language not supported
 :
 : @param  $queryBinding Query language token
 : @return Path segment to processor
 :)
declare %private function schxslt:processor-path ($queryBinding as xs:string) as xs:string {
  switch ($queryBinding)
    case ""
      return "1.0"
    case "xslt"
      return "1.0"
    case "xslt2"
      return "2.0"
    default
      return error(xs:QName("schxslt:UnsupportedQueryBinding"))
};

(:~
 : Compile Schematron to validation stylesheet.
 :
 : @param  $schematron Schematron document
 : @param  $options Schematron compiler parameters
 : @return Validation stylesheet
 :)
declare %private function schxslt:compile ($schematron as node(), $options as element(parameters)?, $xsltver as xs:string) as element(xsl:transform) {
  let $basedir := "xmldb:exist://" || $schxslt:base-dir || "/content/xslt/" || $xsltver || "/"
  let $include := $basedir || "include.xsl"
  let $expand  := $basedir || "expand.xsl"
  let $compile := $basedir || "compile-for-svrl.xsl"
  return
    $schematron => transform:transform($include, ()) => transform:transform($expand, ()) => transform:transform($compile, $options)
};

(:~
 : Convert map of transformation parameters into tree structure.
 :
 : @param  $parameters Transformation parameters as map
 : @return Transformation parameters as tree
 :)
declare %private function schxslt:transform-parameters ($parameters as map(*)) as element(parameters) {
  <parameters>{
    for $key in map:keys($parameters)
    return <param name="{$key}" value="{$parameters($key)}"/>}
  </parameters>
};