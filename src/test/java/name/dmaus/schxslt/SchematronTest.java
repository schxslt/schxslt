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

package name.dmaus.schxslt;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

import java.io.File;

import name.dmaus.schxslt.Schematron;
import name.dmaus.schxslt.Result;

public class SchematronTest
{   
    private File simpleSchema10;
    private File simpleSchema20;

    @BeforeClass
    public static void setup ()
    {
        System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
    }

    @Before
    public void setupSimpleSchema () throws Exception
    {
        simpleSchema10 = new File(getClass().getResource("/simple-schema-10.sch").toURI());
        simpleSchema20 = new File(getClass().getResource("/simple-schema-20.sch").toURI());
    }

    @Test
    public void newSchematronForXSLT10 () throws Exception
    {
        Schematron schematron = new Schematron(simpleSchema10);
        Result result = schematron.validate(simpleSchema10);
    }

    @Test
    public void newSchematronForXSLT20 () throws Exception
    {
        Schematron schematron = new Schematron(simpleSchema20);
        Result result = schematron.validate(simpleSchema10);
    }
}
