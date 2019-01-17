# SchXslt [ʃˈɛksl̩t] – An XSLT-based Schematron processor

SchXslt is copyright (c) 2018,2019 by David Maus &lt;dmaus@dmaus.name&lt;
and released under the terms of the MIT license.

[![DOI](https://zenodo.org/badge/157821911.svg)](https://zenodo.org/badge/latestdoi/157821911)

SchXslt is a conforming Schematron processor implemented entirely in
XSLT. It operates as a three-stage transformation process that
translates a Schematron to an XSLT validation stylesheet. This
stylesheet outputs a validation report in the Schematron Validation
Report Language (SVRL) when applied to an instance document.

With this respect it operates much like the
["skeleton" implementation](https://github.com/schematron/schematron)
by Rick Jelliffe and others. It differes from the "skeleton" in that
it only supports XSLT 2 aus query language binding and requires an
XSLT processor supporting XSLT 2.0 or higher.

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

SchXslt also performs base URI fixup on the included elements.

```
saxon -xsl:src/xslt/include.xsl -o:stage-1.sch </path/to/schematron>
```

### Expand (src/xslt/expand.xsl)

Abstract patterns and rules are instantiated and their respective
definitions removed.

```
saxon -xsl:src/xslt/expand.xsl -o:stage-2.sch stage-1.sch
```

### Compile (src/xslt/compile.xsl)

Finally translates the Schematron to the XSLT stylesheet.

The optional argument 'phase' compiles the Schematron to validate in
the selected phase. If no phase is requested the translation uses the
value of the @defaultPhase attribute, if present. Otherwise it
defaults to phase '#ALL' and validates all patterns.

```
saxon -xsl:src/xslt/compile.xsl -o:stage-3.xsl stage-2.sch [phase=myphase]
```

It is in error to request translation for a phase that is not defined
in the schema. Translation also fails if the schema uses a query
language binding other than 'xslt2', or still contains unprocessed
includes, extends, abstract rules and abstract patterns.

## Using XProc

With an XProc 1.0 processor installed you can create the validation
stylesheet with the step ```compile-schematron.xpl```.

```
calabash -i </path/to/schematron> -o:stage-3.xsl src/xproc/compile-schematron.xpl
```

Lastly, SchXslt comes with another XProc step
```validate-with-schematron.xpl``` that performs schematron validation
using SchXslt's stylesheets. To run it from the command line you have
to pipe the document to validate in the input port ```source```, and
the Schematron in the input port ```schema```. The step sends the
validation report to the ```result``` output port.

```
calabash -i source=</path/to/document> -i schema=</path/to/schema> src/xproc/validate-with-schematron.xpl
```

## Footnotes

[^1]: The definition of the query language binding for XSLT 2 (Schematron
2016, Annex H) defines the data model to be the XQuery 1.0 and XPath 2.0
Data Model (XDM). The XDM defines element nodes to have a base uri
property.

The Schematron 2016 specification does not discuss what happens to this
property if a Schematron element is incorporated into schema via
sch:include or sch:extends.
