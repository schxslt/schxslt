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

import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;

import java.io.File;

/**
 * Commandline application configuration.
 */
public final class Configuration
{
    private static final String OPTION_DOCUMENT = "d";
    private static final String OPTION_EXITCODE = "e";
    private static final String OPTION_OUTPUT = "o";
    private static final String OPTION_PHASE = "p";
    private static final String OPTION_REPL = "r";
    private static final String OPTION_SCHEMA = "s";
    private static final String OPTION_VERBOSE = "v";

    private final DefaultParser parser = new DefaultParser();
    private final Options options = new Options();

    private CommandLine arguments;

    public Configuration ()
    {
        options.addOption(OPTION_PHASE, "phase", true, "Validation phase");
        options.addOption(OPTION_DOCUMENT, "document", true, "Path to document");
        options.addOption(OPTION_EXITCODE, "exitcode", true, "Use exit code to indicate invalid document (default is 0)");
        options.addOption(OPTION_REPL, "repl", false, "Run as REPL");
        options.addOption(OPTION_VERBOSE, "verbose", false, "Verbose output");
        options.addOption(OPTION_OUTPUT, "output", true, "Output file (SVRL report)");
        options.addRequiredOption(OPTION_SCHEMA, "schematron", true, "Path to schema");
    }

    public boolean parse (final String[] args)
    {
        try {
            arguments = parser.parse(options, args);
            if (arguments.getArgList().size() > 0) {
                throw new ParseException("Excess arguments on command line");
            }
            if (hasDocument() && isRepl()) {
                throw new ParseException("Cannot run a REPL when a document is provided");
            }
            try {
                getExitCode();
            } catch (NumberFormatException e) {
                throw new ParseException("Provided exit code is not an integer");
            }
        } catch (ParseException e) {
            System.err.println(e.getMessage());
            printHelp();
            return false;
        }
        return true;
    }

    public boolean isRepl ()
    {
        return arguments.hasOption(OPTION_REPL);
    }

    public boolean hasDocument ()
    {
        return arguments.hasOption(OPTION_DOCUMENT);
    }

    public File getDocument ()
    {
        return new File(arguments.getOptionValue(OPTION_DOCUMENT));
    }

    public File getOutputFile ()
    {
        if (arguments.hasOption(OPTION_OUTPUT)) {
            return new File(arguments.getOptionValue(OPTION_OUTPUT));
        }
        return null;
    }

    public boolean hasOutputFile ()
    {
        return arguments.hasOption(OPTION_OUTPUT);
    }

    public String getPhase ()
    {
        if (arguments.hasOption(OPTION_PHASE)) {
            return arguments.getOptionValue(OPTION_PHASE);
        } else {
            return "#ALL";
        }
    }

    public File getSchematron ()
    {
        return new File(arguments.getOptionValue(OPTION_SCHEMA));
    }

    public int getExitCode ()
    {
        if (arguments.hasOption(OPTION_EXITCODE)) {
            return Integer.parseInt(arguments.getOptionValue(OPTION_EXITCODE));
        }
        return 0;
    }

    public Boolean beVerbose ()
    {
        return arguments.hasOption(OPTION_VERBOSE);
    }

    private void printHelp ()
    {
        System.out.println("SchXslt CLI v" + getVersion());
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("name.dmaus.schxslt.cli.Application", options, true);
    }

    private String getVersion ()
    {
        return getClass().getPackage().getImplementationVersion();
    }

}
