xquery version "3.1";

(:~
 : BaseX module for Schematron validation with SchXslt.
 :
 : @author David Maus
 : @see    https://doi.org/10.5281/zenodo.1495494
 : @see    https://basex.org
 :
 :)

module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494";

declare namespace svrl = "http://purl.oclc.org/dsdl/svrl";
declare namespace sch = "http://purl.oclc.org/dsdl/schematron";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

(:~
 : Validate document against Schematron and return the validation report.
 :
 : @param  $document Document to be validated
 : @param  $schematron Schematron document
 : @param  $phase Validation phase
 : @return Validation report
 :)
declare function schxslt:validate ($document as node(), $schematron as node(), $phase as xs:string?) as document-node(element(svrl:schematron-output)) {
  if (xslt:version() ne '3.0')
    then error(QName('https://doi.org/10.5281/zenodo.1495494', 'E0001'), "Processor does not support the required XSLT version")
    else
      let $options := if ($phase) then map{"phase": $phase} else map{}
      return
        $document => xslt:transform(schxslt:compile($schematron, $options))
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
      error(xs:QName("schxslt:UnsupportedQueryBinding"))
};

(:~
 : Validate document against Schematron and return the validation report.
 :
 : @param  $document Document to be validated
 : @param  $schematron Schematron document
 : @return Validation report
 :)
declare function schxslt:validate ($document as node(), $schematron as node()) as document-node(element(svrl:schematron-output)) {
  schxslt:validate($document, $schematron, ())
};

(:~
 : Compile Schematron to validation stylesheet.
 :
 : @param  $schematron Schematron document
 : @param  $options Schematron compiler parameters
 : @return Validation stylesheet
 :)
declare %private function schxslt:compile ($schematron as node(), $options as map(*)) as document-node(element(xsl:transform)) {
  $schematron => schxslt:include() => schxslt:expand() => xslt:transform(file:base-dir() || "xslt/2.0/compile-for-svrl.xsl", $options)
};

(:~
 : Process inclusions.
 :
 : @param  $schematron Schematron document
 : @return Schematron document w/ processed inclusions
 :)
declare %private function schxslt:include ($schematron as node()) as document-node(element(sch:schema)) {
  $schematron => xslt:transform(file:base-dir() || "xslt/2.0/include.xsl")
};

(:~
 : Expand abstract patterns and rules.
 :
 : @param  $schematron Schematron document
 : @return Schematron document w/ instantiated abstract patterns and rules
 :)
declare %private function schxslt:expand ($schematron as node()) as document-node(element(sch:schema)) {
  $schematron => xslt:transform(file:base-dir() || "xslt/2.0/expand.xsl")
};