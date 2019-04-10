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

import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;

import java.io.File;

public class Configuration
{
    final private DefaultParser parser = new DefaultParser();
    final private Options options = new Options();

    private CommandLine arguments;

    public Configuration ()
    {
        options.addOption("p", "phase", true, "Validation phase");
        options.addOption("d", "document", true, "Path to document");
        options.addRequiredOption("s", "schematron", true, "Path to schema");
    }

    public void parse (final String[] args)
    {
        try {
            arguments = parser.parse(options, args);
            if (arguments.getArgList().size() > 0) {
                throw new ParseException("Excess arguments on command line");
            }
        } catch (ParseException e) {
            System.err.println(e.getMessage());
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("name.dmaus.schxslt.cli.Main", options, true);
            System.exit(1);
        }
    }

    public boolean hasDocument ()
    {
        return arguments.hasOption("d");
    }

    public File getDocument ()
    {
        return new File(arguments.getOptionValue("d"));
    }

    public String getPhase ()
    {
        if (arguments.hasOption("p")) {
            return arguments.getOptionValue("p");
        } else {
            return "#ALL";
        }
    }

    public File getSchematron ()
    {
        return new File(arguments.getOptionValue("s"));
    }

}
