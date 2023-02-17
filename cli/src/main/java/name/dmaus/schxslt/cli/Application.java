/*
 * Copyright 2019-2022 by David Maus <dmaus@dmaus.name>
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
import java.nio.charset.Charset;

import javax.xml.transform.dom.DOMSource;

import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Transformer;

import org.w3c.dom.Document;

/**
 * Commandline application.
 */
public final class Application
{
    private static final String STDIN = "<stdin>";
    private static final int EX_USAGE = 64;

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

    public static void main (final String[] args) throws SchematronException
    {
        Configuration configuration = new Configuration();
        if (configuration.parse(args)) {
            StreamSource schema = new StreamSource(configuration.getSchematron());

            Schematron schematron = new Schematron(schema, configuration.getPhase());
            Application application = new Application(schematron, configuration.beVerbose());

            Result result = null;
            if (configuration.hasDocument()) {
                result = application.execute(configuration.getDocument());
            } else if (configuration.isRepl()) {
                application.execute(System.console());
            } else {
                result = application.execute(System.in);
            }
            if (result != null) {
                if (configuration.hasOutputFile()) {
                    save(result.getValidationReport(), configuration.getOutputFile());
                }
                if (result.isValid()) {
                    System.exit(0);
                }
                System.exit(configuration.getExitCode());
            }
        } else {
            System.exit(EX_USAGE);
        }
    }

    public Result execute (final File input) throws SchematronException
    {
        StreamSource instream = new StreamSource(input);
        instream.setSystemId(input);

        Result result = schematron.validate(instream);
        printResult(result, input.getAbsolutePath());
        return result;
    }

    public Result execute (final InputStream input) throws SchematronException
    {
        Result result = schematron.validate(new StreamSource(input));
        printResult(result, STDIN);
        return result;
    }

    public void execute (final Console console) throws SchematronException
    {
        if (console != null) {
            while (true) {
                InputStream input = readConsole(console);
                Result result = schematron.validate(new StreamSource(input));
                printResult(result, STDIN);
            }
        }
    }

    private static void save (Document document, File output)
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
        StringBuilder buf = new StringBuilder();
        String line;

        do {
            line = console.readLine();
            if (line != null) {
                buf.append(line);
            }
        } while (line != null);

        return new ByteArrayInputStream(buf.toString().getBytes(Charset.defaultCharset()));
    }

    private void printResult (final Result result, final String filename)
    {
        String status;
        if (result.isValid()) {
            status = "valid";
        } else {
            status = "invalid";
        }
        System.out.format("[%s] %s%n", status, filename);
        if (verbose) {
            for (String message : result.getValidationMessages()) {
                System.out.format("[%s] %s %s%n", status, filename, message);
            }
        }
    }
}
