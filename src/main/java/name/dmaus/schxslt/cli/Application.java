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
import name.dmaus.schxslt.Compiler;
import name.dmaus.schxslt.Schematron;

import java.io.File;
import java.io.Console;
import java.io.ByteArrayInputStream;
import java.io.InputStream;

public class Application
{
    public static void main (final String[] args)
    {
        Configuration configuration = new Configuration();
        configuration.parse(args);

        Schematron schematron = new Schematron(new Compiler(), configuration.getSchematron(), configuration.getPhase());
        Application application = new Application(schematron);

        if (configuration.hasDocument()) {
            application.execute(configuration.getDocument());
        } else if (configuration.isRepl()) {
            application.execute(System.console());
        } else {
            application.execute(System.in);
        }
    }

    private Schematron schematron;

    public Application (Schematron schematron)
    {
        this.schematron = schematron;
    }

    public void execute (final File input)
    {
        Result result = schematron.validate(input);
        printResult(result, input.getAbsolutePath());
    }

    public void execute (final InputStream input)
    {
        Result result = schematron.validate(input);
        printResult(result, "<stdin>");
    }

    public void execute (final Console console)
    {
        if (console == null) {
            return;
        }

        while (true) {
            InputStream input = readConsole(console);
            Result result = schematron.validate(input);
            printResult(result, "<stdin>");
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
    }
}
