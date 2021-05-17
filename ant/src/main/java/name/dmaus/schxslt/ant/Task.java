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
import name.dmaus.schxslt.SchematronException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;

import java.io.File;

import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Transformer;

import javax.xml.transform.dom.DOMSource;

import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;

public class Task extends org.apache.tools.ant.Task
{
    private File file;
    private File schema;
    private File report;

    private String phase = "#ALL";

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
        if (file == null) {
            throw new BuildException("You must provide the file to be validated in the 'file' attribute");
        }
        if (schema == null) {
            throw new BuildException("You must provide the file containing the schema in the 'schema' attribute");
        }
        if (!file.exists() || !file.canRead()) {
            throw new BuildException("Unable to read " + file);
        }
        if (!schema.exists() || !schema.canRead()) {
            throw new BuildException("Unable to read " + schema);
        }

        try {
            log("Generating validation stylesheet for Schematron '" + schema + "'");
            validator = new Schematron(new StreamSource(schema), phase);
        } catch (SchematronException e) {
            throw new BuildException("Unable to compile validation stylesheet", e);
        }

        log("Validating '" + file + "'");
        validate();

        log("The file '" + file + "' is valid");
    }

    private void validate ()
    {
        try {
            StreamSource source = new StreamSource(file);
            source.setSystemId(file);

            Result result = validator.validate(source);
            for (String message: result.getValidationMessages()) {
                log(message, Project.MSG_WARN);
            }

            if (report != null) {
                save(result.getValidationReport());
            }

            if (result.isValid() == false) {
                String message = "The file '" + file + "' is invalid";
                log(message, Project.MSG_ERR);
                throw new BuildException(message);
            }
        } catch (SchematronException e) {
            throw new RuntimeException(e);
        }

    }

    private void save (final Document document)
    {
        try {
            Transformer serializer = TransformerFactory.newInstance().newTransformer();
            serializer.transform(new DOMSource(document), new StreamResult(report));
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

}
