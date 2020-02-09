# SchXslt [ʃˈɛksl̩t] – An XSLT-based Schematron processor

SchXslt is copyright (c) 2018,2019 by David Maus &lt;dmaus@dmaus.name&gt;
and released under the terms of the MIT license.

[![DOI](https://zenodo.org/badge/157821911.svg)](https://zenodo.org/badge/latestdoi/157821911)

SchXslt is a conforming Schematron processor implemented entirely in
XSLT. It operates as a three-stage transformation process that
translates a Schematron to an XSLT validation stylesheet. This
stylesheet outputs a validation report in the Schematron Validation
Report Language (SVRL) when applied to an instance document.

With this respect it operates much like the
["skeleton" implementation](https://github.com/schematron/schematron)
by Rick Jelliffe and others.

## Compiling Schematron to validation stylesheet

### Step 1: Incorporate external definitions

All external definitions referenced by sch:include and sch:extends 
are recursively copied into the source Schematron. The base URI of external 
definitions is preserved such that relative URI references still resolve 
to the right documents.

This step can be skipped if the Schematron does not reference external 
definitions.

The responsible stylesheet is [include.xsl](src/main/resources/xslt/2.0/include.xsl).

```
saxon -xsl:src/main/resources/xslt/2.0/include.xsl -o:stage-1.sch </path/to/schematron>
```

### Step 2: Expand abstract patterns and rules

Abstract patterns and rules are instantiated.

This step can be skipped if the Schematron does not define abstract 
patterns or rules.

The responsible stylesheet is [expand.xsl](src/main/resources/xslt/2.0/expand.xsl).

```
saxon -xsl:src/main/resources/xslt/2.0/expand.xsl -o:stage-2.sch stage-1.sch
```

### Step 3: Compile validation stylesheet

Compiles an XSLT 2.0 validation stylesheet that creates an SVRL report 
document.

The responsible stylesheet is [compile-for-svrl.xsl](src/main/resources/xslt/2.0/compile-for-svrl.xsl).

This stylesheet takes an optional argument 'phase' to validate in the selected 
phase. If no phase is requested the value of the @defaultPhase attribute is 
used if present. Otherwise, it defaults to phase '#ALL' and validates 
all patterns.

```
saxon -xsl:src/main/resources/xslt/2.0/compile-for-svrl.xsl -o:stage-3.xsl stage-2.sch [phase=myphase]
```

## Using XProc

With an XProc 1.0 processor installed you can create the validation
stylesheet with the step ```compile-schematron.xpl```.

```
calabash -i </path/to/schematron> -o:stage-3.xsl src/main/resources/xproc/compile-schematron.xpl
```

Lastly, SchXslt comes with another XProc step
```validate-with-schematron.xpl``` that performs schematron validation
using SchXslt's stylesheets. To run it from the command line you have
to pipe the document to validate in the input port ```source```, and
the Schematron in the input port ```schema```. The step sends the
validation report to the ```result``` output port.

```
calabash -i source=</path/to/document> -i schema=</path/to/schema> src/main/resources/xproc/validate-with-schematron.xpl
```

## The callback API

SchXslt lets you customize the parts of the validation stylesheet that
report on active patterns, fired rule, failed assertions, and
successful reports. The compiler calls named templates in the
```https://doi.org/10.5281/zenodo.1495494#api``` namespace that are
expected to create the part of the validation stylesheet that handles
respective reporting.

You can find the API documentation in the [docs/api](docs/api/index.html)
directory.
