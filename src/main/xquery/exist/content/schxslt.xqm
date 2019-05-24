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
  let $options := if ($phase) then <parameters><param name="phase" value="{$phase}"/></parameters> else ()
  return
    $document => transform:transform(schxslt:compile($schematron, $options))
};

(:~
 : Compile Schematron to validation stylesheet.
 :
 : @param  $schematron Schematron document
 : @return Validation stylesheet
 :)
declare %private function schxslt:compile ($schematron as node(), $options as element(parameters)?) as document-node(element(xsl:transform)) {
  $schematron => schxslt:include() => schxslt:expand() => transform:transform("xslt/compile-for-svrl.xsl", $options)
};

(:~
 : Process inclusions.
 :
 : @param  $schematron Schematron document
 : @return Schematron document w/ processed inclusions
 :)
declare %private function schxslt:include ($schematron as node()) as document-node(element(sch:schema)) {
  $schematron => transform:transform("xslt/include.xsl")
};

(:~
 : Expand abstract patterns and rules.
 :
 : @param  $schematron Schematron document
 : @return Schematron document w/ instantiated abstract patterns and rules
 :)
declare %private function schxslt:expand ($schematron as node()) as document-node(element(sch:schema)) {
  $schematron => transform:transform("xslt/expand.xsl")
};