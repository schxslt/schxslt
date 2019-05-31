/*
 * Copyright 2019 by David Maus <dmaus@dmaus.name>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package name.dmaus.schxslt.ant;

import name.dmaus.schxslt.Result;
import name.dmaus.schxslt.Schematron;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;

import java.io.File;

public class Task extends org.apache.tools.ant.Task
{
    private File file;
    private File schema;
    private File report;

    private String phase = "#ALL";

    private final String transformerFactoryImpl = "net.sf.saxon.TransformerFactoryImpl";

    private Schematron validator;

    public void setPhase (String phase)
    {
        this.phase = phase;
    }

    public void setSchema (File schema)
    {
        this.schema = schema;
    }

    public void setFile (File file)
    {
        this.file = file;
    }

    public void setReport (File report)
    {
        this.report = report;
    }

    public void execute () throws BuildException
    {
        if (this.file == null) {
            throw new BuildException("You must provide the file to be validated in the 'file' attribute");
        }
        if (this.schema == null) {
            throw new BuildException("You must provide the file containing the schema in the 'schema' attribute");
        }
        if (!this.file.exists() || !this.file.canRead()) {
            throw new BuildException("Unable to read " + this.file);
        }
        if (!this.schema.exists() || !this.schema.canRead()) {
            throw new BuildException("Unable to read " + this.schema);
        }
        if (System.getProperty("javax.xml.transform.TransformerFactory") == null) {
            System.setProperty("javax.xml.transform.TransformerFactory", this.transformerFactoryImpl);
        }

        this.log("Generating validation stylesheet for Schematron '" + this.schema + "'");
        this.validator = new Schematron(this.schema, this.phase);

        this.log("Validating '" + this.file + "'");
        this.validate(this.file);

        log("The file '" + this.file + "' is valid");
    }

    private void validate (final File file)
    {
        Result report = this.validator.validate(file);
        for (String message: report.getValidationMessages()) {
            log(message, Project.MSG_WARN);
        }

        if (this.report != null) {
            report.saveAs(this.report);
        }

        if (report.isValid() == false) {
            String message = "The file '" + this.file + "' is invalid";
            log(message, Project.MSG_ERR);
            throw new BuildException(message);
        }
    }

}
