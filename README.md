Ant task for Schematron validation with SchXslt
==

SchXslt Ant is copyright (c) 2019,2020 by David Maus &lt;dmaus@dmaus.name&gt; and released under the
terms of the MIT license.

This project implements a task for [Apache Ant](https://ant.apache.org/) that performs Schematron
validation with SchXslt.

## Installing SchXslt Ant

Download or compile the .jar file and define a new task using ```name.dmaus.schxslt.ant.Task``` as
class name. The .jar contains the Java classes of a Schematron validation task as well as the
SchXslt transformation stylesheets.

You can download the .jar from the [list of releases](https://github.com/schxslt/schxslt-ant/releases)
or build it using the [Maven](https://maven.apache.org) build tool.

To create the .jar file from its sources clone this repository and run the Maven build tool.

```
git clone https://github.com/schxslt/schxslt-ant.git
cd schxslt-ant
mvn clean package
```

This creates the jar file inside the ```target``` directory.

## Using SchXslt Ant

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

## Example

```
<project name="Test" basedir="." default="build">
  <taskdef name="schematron" classname="name.dmaus.schxslt.ant.Task" classpath="/path/to/ant-schxslt-1.3.jar"/>
  <target name="build">
    <schematron schema="schema.sch" file="document.xml" report="report.xml" phase="myPhase"/>
  </target>
</project>
```
