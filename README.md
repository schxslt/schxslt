Ant task for Schematron validation with SchXslt
==

SchXslt Ant is copyright (c) 2019 by David Maus &lt;dmaus@dmaus.name&gt; and released under the
terms of the MIT license.

This project implements a task for [Apache Ant](https://ant.apache.org/) that performs Schematron
validation with SchXslt.

## Using SchXslt Ant

Download or compile the .jar file and define a new task using ```name.dmaus.schxslt.ant.Task``` as
class name. The .jar contains the Java classes of a Schematron validation task as well as the
SchXslt transformation stylesheets.

The task relies on a XSLT 2.0 processor to be registered as transformer factory implementation and
uses [Saxon](https://saxonica.com) if no other transformer is registered.

It supports the following options:

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

```
<project name="Test" basedir="." default="build">
  <taskdef name="schematron" classname="name.dmaus.schxslt.ant.Task" classpath="/path/to/schxslt-ant.jar"/>
  <target name="build">
    <schematron schema="test.sch" file="test.sch" report="report.xml"/>
  </target>
</project>
```
