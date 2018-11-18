# SchXslt [ʃˈɛksl̩t] – An XSLT-based Schematron processor

SchXslt is copyright (c) 2018 by David Maus <dmaus@dmaus.name> and
released under the terms of the MIT license.

SchXslt is a conformant Schematron processor implemented entirely in
XSLT. It translates a Schematron schema into a XSL transformation that
outputs a SVRL report when applied to an instance document.

With this respect it operates much like the Rick Jelliffe's "skeleton"
XSLT implementation. It differs from the "skeleton" in the following
parts:

  * It only supports XSLT2 as query language binding and requires a
    XSLT processor supporting XSLT 2.0 or higher.

  * It aims at a strict implementation of ISO Schematron 2016 and
    comes with a suite of XSpec-based tests.

Other than that it should in general be possible to use SchXslt as a
drop-in replacement of the "skeleton" implementation. 

The following table lists the skeleton stylesheets and their SchXslt
counterparts.

<table>
  <thead>
    <tr>
      <th>Skeleton stylesheet</th>
      <th>SchXslt stylesheet</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>iso_dsdl_include.xsl</td>
      <td>include.xsl</td>
    </tr>
    <tr>
      <td>iso_abstract_expand.xsl</td>
      <td>expand.xsl</td>
    </tr>
    <tr>
      <td>iso_svrl_for_xslt2.xsl</td>
      <td>compile.xsl</td>
    </tr>
  </tbody>
</table>

## Usage

Validating an instance document with SchXslt takes two steps.

First, the Schematron schema must be translated into an XSLT
stylesheet. The stylesheet can then be applied to an instance
document. It returns a SVRL report with the validation results.

## Translating Schematron to XSLT

Internally the translation of the schema to the XSLT stylesheet is
implemented in three subsequent transformations or compilation stages.

### Include (src/xslt/include.xsl)

Incorporates all external definitions referenced by sch:include and
sch:extends. The inclusion is recursive, but no check for circular
inclusions (e.g. A includes B which includes A) is performed.

SchXslt also performs base URI fixup on the included elements[^1].

### Expand (src/xslt/expand.xsl)

Abstract patterns and rules are instantiated and their respective
definitions removed.

### Compile (src/xslt/compile.xsl)

Finally translates the Schematron to the XSLT stylesheet.

The optional argument 'phase' compiles the Schematron to validate in
the selected phase. If no phase is requested the translation uses the
value of the @defaultPhase attribute, if present. Otherwise it
defaults to phase '#ALL' and validates all patterns.

It is in error to request translation for a phase that is not defined
in the schema. Translation also fails if the schema uses a query
language binding other than 'xslt2', or still contains unprocessed
includes, extends, abstract rules and abstract patterns.

## Footnotes

[^1]: The definition of the query language binding for XSLT 2 (Schematron
2016, Annex H) defines the data model to be the XQuery 1.0 and XPath 2.0
Data Model (XDM). The XDM defines element nodes to have a base uri
property.

The Schematron 2016 specification does not discuss what happens to this
property if a Schematron element is incorporated into schema via
sch:include or sch:extends.
