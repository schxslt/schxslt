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

import java.io.File;

public class Application
{
    public static void main (final String[] args)
    {
        Configuration configuration = new Configuration();
        configuration.parse(args);

        Schematron schematron = new Schematron(configuration.getSchematron(), configuration.getPhase());
        Application application = new Application(schematron);

        if (configuration.hasDocument()) {
            File document = configuration.getDocument();
            System.out.print(document.getAbsolutePath());
            if (application.isValid(document)) {
                System.out.println(":valid");
            } else {
                System.out.println(":invalid");
            }
        }
    }

    private Schematron schematron;
    private Result result;

    public Application (Schematron schematron)
    {
        this.schematron = schematron;
    }

    public boolean isValid (File document)
    {
        result = schematron.validate(document);
        return result.isValid();
    }
}
