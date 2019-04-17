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

package name.dmaus.schxslt.validation.test;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

import org.w3c.dom.Document;

import org.xml.sax.SAXException;

import javax.xml.validation.*;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.dom.DOMSource;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import java.io.File;
import java.io.InputStream;
import java.io.IOException;

public class ValidationTest
{
    private Schema simpleSchema;
    private Source simpleSchemaSource;
    private SchemaFactory schemaFactory;

    @BeforeClass
    public static void setup ()
    {
        System.setProperty("javax.xml.validation.SchemaFactory:http://purl.oclc.org/dsdl/schematron", "name.dmaus.schxslt.validation.SchemaFactory");
        System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");
    }

    @Before
    public void setupSimpleSchema () throws Exception
    {
        schemaFactory = SchemaFactory.newInstance("http://purl.oclc.org/dsdl/schematron");
        simpleSchemaSource = new StreamSource(getClass().getResourceAsStream("/simple-schema.sch"));
        simpleSchema = schemaFactory.newSchema(simpleSchemaSource);
    }

    @Test(expected=UnsupportedOperationException.class)
    public void validationHandlerIsNotSupported () throws Exception
    {
        DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
        docFactory.setSchema(simpleSchema);
        docFactory.setValidating(false);

        InputStream document = getClass().getResourceAsStream("/simple-schema.sch");
        docFactory.newDocumentBuilder().parse(document);
    }

    @Test(expected=SAXException.class)
    public void validationFailure () throws Exception
    {
        DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();

        InputStream documentStream = getClass().getResourceAsStream("/simple-schema.sch");
        Document document = docFactory.newDocumentBuilder().parse(documentStream);

        Validator validator = simpleSchema.newValidator();
        validator.validate(new DOMSource(document));
    }

    @Test
    public void validationWithPhase () throws Exception
    {
        schemaFactory.setProperty("phase", "default");
        Schema schema = schemaFactory.newSchema(simpleSchemaSource);

        DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();

        InputStream documentStream = getClass().getResourceAsStream("/simple-schema.sch");
        Document document = docFactory.newDocumentBuilder().parse(documentStream);

        Validator validator = schema.newValidator();
        validator.validate(new DOMSource(document));
    }
}
