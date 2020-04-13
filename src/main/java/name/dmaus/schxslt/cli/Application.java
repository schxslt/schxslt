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

package name.dmaus.schxslt.cli;

import name.dmaus.schxslt.Result;
import name.dmaus.schxslt.Schematron;
import name.dmaus.schxslt.SchematronException;

import java.io.File;
import java.io.Console;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.xml.transform.dom.DOMSource;

import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Transformer;

import org.w3c.dom.Document;

public class Application
{
    public static void main (final String[] args) throws SchematronException
    {
        Configuration configuration = new Configuration();
        configuration.parse(args);

        StreamSource schema = new StreamSource(configuration.getSchematron());

        Schematron schematron = new Schematron(schema, configuration.getPhase());
        Application application = new Application(schematron, configuration.beVerbose(), configuration.getOutputFile());

        if (configuration.hasDocument()) {
            application.execute(configuration.getDocument());
        } else if (configuration.isRepl()) {
            application.execute(System.console());
        } else {
            application.execute(System.in);
        }
    }

    private File output;
    private Boolean verbose;
    private Schematron schematron;

    public Application (Schematron schematron)
    {
        this(schematron, false);
    }

    public Application (Schematron schematron, Boolean verbose)
    {
        this.verbose = verbose;
        this.schematron = schematron;
    }

    public Application (Schematron schematron, Boolean verbose, File output)
    {
        this.output = output;
        this.verbose = verbose;
        this.schematron = schematron;
    }

    public void execute (final File input) throws SchematronException
    {
        StreamSource in = new StreamSource(input);
        in.setSystemId(input);

        Result result = schematron.validate(in);
        printResult(result, input.getAbsolutePath());
        if (output != null) {
            save(result.getValidationReport());
        }
    }

    public void execute (final InputStream input) throws SchematronException
    {
        Result result = schematron.validate(new StreamSource(input));
        printResult(result, "<stdin>");
        if (output != null) {
            save(result.getValidationReport());
        }
    }

    public void execute (final Console console) throws SchematronException
    {
        if (console == null) {
            return;
        }

        while (true) {
            InputStream input = readConsole(console);
            Result result = schematron.validate(new StreamSource(input));
            printResult(result, "<stdin>");
        }
    }

    private void save (Document document)
    {
        try {
            Transformer serializer = TransformerFactory.newInstance().newTransformer();
            serializer.transform(new DOMSource(document), new StreamResult(output));
        } catch (TransformerException e) {
            throw new RuntimeException(e);
        }
    }

    private InputStream readConsole (final Console console)
    {
        StringBuffer buf = new StringBuffer();
        String line;

        do {
            line = console.readLine();
            if (line != null) {
                buf.append(line);
            }
        } while (line != null);

        return new ByteArrayInputStream(buf.toString().getBytes());
    }

    private void printResult (final Result result, final String filename)
    {
        System.out.format("[%s] %s%n", result.isValid() ? "valid" : "invalid", filename);
        if (verbose) {
            for (String message : result.getValidationMessages()) {
                System.out.format("[%s] %s %s%n", result.isValid() ? "valid" : "invalid", filename, message);
            }
        }
    }
}
