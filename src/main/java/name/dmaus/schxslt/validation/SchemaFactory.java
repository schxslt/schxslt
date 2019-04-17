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

package name.dmaus.schxslt.validation;

import org.w3c.dom.ls.LSResourceResolver;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerFactory;

import name.dmaus.schxslt.Schematron;

public class SchemaFactory extends javax.xml.validation.SchemaFactory
{
    private ErrorHandler errors;
    private LSResourceResolver resources;

    public ErrorHandler getErrorHandler ()
    {
        return this.errors;
    }

    public void setErrorHandler (ErrorHandler errorHandler)
    {
        this.errors = errors;
    }

    public LSResourceResolver getResourceResolver ()
    {
        return this.resources;
    }

    public void setResourceResolver (LSResourceResolver resourceResolver)
    {
        this.resources = resourceResolver;
    }

    public boolean isSchemaLanguageSupported (String schemaLanguage)
    {
        return "http://purl.oclc.org/dsdl/schematron".equals(schemaLanguage);
    }

    public Schema newSchema ()
    {
        throw new UnsupportedOperationException();
    }

    public Schema newSchema (Source[] schemas) throws SAXException
    {
        if (schemas.length != 1) {
            throw new UnsupportedOperationException();
        }

        Schematron schematron = new Schematron(schemas[0], "#ALL");
        return new Schema(schematron);
    }
}
