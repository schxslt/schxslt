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
import org.xml.sax.SAXNotRecognizedException;

import javax.xml.XMLConstants;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerFactory;

import name.dmaus.schxslt.Schematron;
import name.dmaus.schxslt.Compiler;

public class SchemaFactory extends javax.xml.validation.SchemaFactory
{
    private boolean secureProcessing = false;
    private Object accessExternalSchema = null;
    private Object accessExternalDtd = null;

    private String phase = "#ALL";

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

        Compiler compiler = new Compiler();
        Schematron schematron = new Schematron(compiler, schemas[0], this.phase);

        schematron.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, this.secureProcessing);
        if (this.accessExternalDtd != null) {
            schematron.setProperty(XMLConstants.ACCESS_EXTERNAL_DTD, this.accessExternalDtd);
        }
        if (this.accessExternalSchema != null) {
            schematron.setProperty(XMLConstants.ACCESS_EXTERNAL_SCHEMA, this.accessExternalSchema);
        }

        return new Schema(schematron);
    }

    public void setProperty (String name, Object value) throws SAXNotRecognizedException
    {
        if (name.equals(XMLConstants.ACCESS_EXTERNAL_DTD)) {
            this.accessExternalDtd = value;
        } else if (name.equals(XMLConstants.ACCESS_EXTERNAL_SCHEMA)) {
            this.accessExternalSchema = value;
        } else if (name.equals("phase")) {
            this.phase = (String)value;
        } else {
            throw new SAXNotRecognizedException();
        }
    }

    public void setFeature (String name, boolean value) throws SAXNotRecognizedException
    {
        if (name.equals(XMLConstants.FEATURE_SECURE_PROCESSING)) {
            this.secureProcessing = value;
        } else {
            throw new SAXNotRecognizedException();
        }
    }
}
