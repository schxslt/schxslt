SchXslt \[ʃˈɛksl̩t\] – An XSLT-based Schematron processor
==

SchXslt is copyright (c) by David Maus &lt;dmaus@dmaus.name&gt; and released under the terms of the MIT
license.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1495494.svg)](https://doi.org/10.5281/zenodo.1495494)

SchXslt is a Schematron processor implemented entirely in XSLT. It transforms a Schematron schema document into an XSLT
stylesheet that you apply to the document(s) to be validated.

Limitations
--

As of date SchXslt does not properly implement the scoping rules of pattern (see
[#135](https://github.com/schxslt/schxslt/issues/135)) and phase variables (see
[#136](https://github.com/schxslt/schxslt/issues/136)).

Schema, pattern, and phase variables are all implemented as global XSLT variables. As a consequence the name of a
schema, pattern, or phase variable must be unique in the entire schema.

Due to the constrains of XSLT 1.0 and the way rules are implemented it is not possible to use a variable inside a rule
context expression of a Schematron using the XSLT 1.0 query binding (see
[#138](https://github.com/schxslt/schxslt/issues/138)).

When an external construct is incorporated with ```sch:include``` or ```sch:extends``` by its ```@xml:id``` attribute,
the namespace bindings of the include target document are not preserved (#343 #344).

The ```svrl:active-patterns/@documents``` attribute does not contain the URIs of the subordinate documents (#342).

Schematron enhancements
--

SchXslt implements the following Schematron enhancements:

### Typed variables

[Proposal 1](https://github.com/Schematron/schematron-enhancement-proposals/issues/1)

The Schematron specification does not allow for annotating variables with the expected type of its value. Type
annotations are helpful to make the most of XSLT 3.0. Using them is current best practice.

This proposal adds support for an ```@as``` attribute on variable declarations.

### Global abstract rules

[Proposal 3](https://github.com/Schematron/schematron-enhancement-proposals/issues/3)

The Schematron specification limits the the reuse of abstract rules to the current pattern element. The ```@href
attribute``` on ```extends``` was introduced in 2016 to overcome this limitation but requires a schema author to
externalize abstract rules for them to be used.

This proposal extends Schematron with a top-level ```rules``` element to hold abstract rules that are globally
referencable by the ```@rule``` attribute of ```extends```.

### Additional XSLT elements

[Proposal 4](https://github.com/Schematron/schematron-enhancement-proposals/issues/4)

The Schematron specification allows the XSLT elements ```function``` and ```key``` to be used in a Schematron
schema. This makes sense because both are required to set up the query language environment. The ```key``` element
prepares data structures for the ```key()``` function and the ```function``` element allows the use of user defined
functions.

This proposal adds support for the following XSLT elements:

* xsl:accumulator (XSLT 3.0)
* xsl:import (XSLT 1.0, XSLT 2.0, XSLT 3.0)
* xsl:import-schema (XSLT 2.0, XSLT 3.0)
* xsl:include (XSLT 1.0, XSLT 2.0, XSLT 3.0)
* xsl:use-package (XSLT 3.0)

Installing SchXslt
--

Depending on your environment there are several ways to install SchXslt.

* Starting with version 1.5 every release on [this repository's release
  page](https://github.com/schxslt/schxslt/releases) provides a ZIP file with just the XSLT stylesheets. This page also
  provides a ZIP file with the XSLT stylesheets and two [XProc 1.0](https://w3.org/tr/xproc) steps. Just download and
  unzip.

* A Java package is published to [Maven Central](https://mvnrepository.com/artifact/name.dmaus.schxslt/schxslt). Use it
  with Maven or the Java dependency management tool of your choice.

* If you use [BaseX](https://basex.org) or [eXist](https://exist-db.org) you can download installable XQuery modulesq
  from [this repository's release page](https://github.com/schxslt/schxslt/releases) as well.

Building SchXslt
--

SchXslt uses the [Maven](https://maven.apache.org) build tool to create installable packages. To create the packages for
yourself clone this repository, install [Maven](https://maven.apache.org) and run it with the ```package``` phase.

```
dmaus@carbon ~ % git clone --recursive https://github.com/schxslt/schxslt.git
Cloning into 'schxslt'...
remote: Enumerating objects: 450, done.
remote: Counting objects: 100% (450/450), done.
remote: Compressing objects: 100% (298/298), done.
remote: Total 3789 (delta 172), reused 374 (delta 111), pack-reused 3339
Receiving objects: 100% (3789/3789), 470.87 KiB | 1.05 MiB/s, done.
Resolving deltas: 100% (1607/1607), done.

dmaus@carbon ~ % mvn package
```

This runs the unit tests and creates the following files:

* ant/target/ant-schxslt-{VERSION}.jar (Java archive)
* cli/target/schxslt-cli.jar (Java archive)
* core/target/schxslt-{VERSION}.jar (Java archive)
* core/target/schxslt-{VERSION}-xslt-only.zip (ZIP file with stylesheets)
* exist/target/schxslt-exist-{VERSION}.xar (XQuery package for eXist)
* basex/target/schxslt-basex-{VERSION}.xar (XQuery package for BaseX)

Where {VERSION} is replaced with the current SchXslt version.

Using SchXslt
--

### XSLT Stylesheets

The simplest way to use SchXslt is to download the ZIP file with just the stylesheets from the
[releases](https://github.com/schxslt/schxslt/releases) page. To validate documents with your Schematron you first
transform it with the ```pipeline-for-svrl.xsl``` stylesheet. This creates the XSL transformation that creates a
validation report when applied to a document.

### Java applications

To use SchXslt in your Java application define the following Maven dependency:

```xml
<dependency>
  <groupId>name.dmaus.schxslt</groupId>
  <artifactId>schxslt</artifactId>
  <version>{VERSION}</version>
</dependency>
```

Where {VERSION} is replaced with the current SchXslt version.

Also take a look at [SchXslt Java](https://github.com/schxslt/schxslt-java), a set of Java classes for Schematron
validation with SchXslt.

### XQuery

The XQuery module provides a function ```schxslt:validate()``` that validates a document and returns a validation report
expressed in the Schematron Validation Report Language (SVRL). You import the module using its namespace URI.

```
import module namespace schxslt = "https://doi.org/10.5281/zenodo.1495494";

let $document := <ex:example xmlns:ex="https://example.com/ns"/>
let $schema :=
  <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <sch:pattern>
      <sch:rule context="/">
        <sch:assert test="true()">Always true</sch:assert>
      </sch:rule>
    </sch:pattern>
  </sch:schema>

return
  schxslt:validate($document, $schema)

```

### Ant

The Ant module implements a task for [Apache Ant](https://ant.apache.org/) that performs Schematron validation with
SchXslt. Download or compile the Jar file and define a new task using ```name.dmaus.schxslt.ant.Task``` as class name.

```
<project name="Test" basedir="." default="build">
  <taskdef name="schematron" classname="name.dmaus.schxslt.ant.Task" classpath="/path/to/ant-schxslt-{VERSION}.jar"/>
  <target name="build">
    <schematron schema="schema.sch" file="document.xml" report="report.xml" phase="myPhase"/>
  </target>
</project>
```

The task supports the following options:

<table>
    <tbody>
        <tr>
            <th>file</th>
            <td>Path to the file to be validated</td>
            <td>-</td>
        </tr>
        <tr>
            <th>schema</th>
            <td>Path to the file containing the Schematron</td>
            <td>-</td>
        </tr>
        <tr>
            <th>phase</th>
            <td>Validation phase</td>
            <td>#ALL</td>
        </tr>
        <tr>
            <th>report</th>
            <td>Path to the file that the SVRL report should be written to</td>
            <td></td>
        </tr>
    </tbody>
</table>

SchXslt Ant uses [XML Resolver](https://xmlresolver.org) to support XML Catalog resolvers.

### Command line

The CLI module provides a command line program for performing Schematron validation with SchXslt. Download or compile
the Jar file ```schxslt-cli.jar```.

To validate the XML document ```document.xml``` against the schema in ```schema.sch``` with the report written to
```report.xml``` you can run:

```
java -jar schxslt-cli.jar -d document.xml -s schema.sch -o report.xml
```

The command line option ```-h``` lists all available options.

```
SchXslt CLI v1.10
usage: name.dmaus.schxslt.cli.Application [-d <arg>] [-e <arg>] [-o <arg>]
       [-p <arg>] [-r] -s <arg> [-v]
 -d,--document <arg>     Path to document
 -e,--exitcode <arg>     Use exit code to indicate invalid document
                         (default is 0)
 -o,--output <arg>       Output file (SVRL report)
 -p,--phase <arg>        Validation phase
 -r,--repl               Run as REPL
 -s,--schematron <arg>   Path to schema
 -v,--verbose            Verbose output
```

