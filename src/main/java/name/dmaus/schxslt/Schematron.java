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

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import javax.xml.transform.stream.StreamSource;

import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;

public class Schematron
{
    private Templates validator;
    private DocumentBuilder builder;

    private String phase;
    private DOMSource schema;
    private Compiler compiler;

    private final CompilerFactory compilers = new CompilerFactory();
    private final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

    public Schematron (final File schema)
    {
        this(schema, null);
    }

    public Schematron (final File schema, final String phase)
    {
        this.phase = phase;
        this.schema = loadDocument(schema);
        this.compiler = compilers.newInstance(this.schema);
    }

    public Result validate (final InputStream input)
    {
        return validate(loadDocument(input));
    }

    public Result validate (final File file)
    {
        return validate(loadDocument(file));
    }

    public Result validate (final Source source)
    {
        if (this.validator == null) {
            this.validator = this.compiler.compile(this.schema, this.phase);
        }

        DOMResult target = new DOMResult();
        try {
            this.validator.newTransformer().transform(source, target);
            Document report = (Document)target.getNode();

            return new Result(report);

        } catch (TransformerException e) {
            throw new RuntimeException("Unable to apply validation stylesheet");
        }
    }

    public void setFeature (String name, boolean value) throws SAXNotRecognizedException
    {
        try {
            this.factory.setFeature(name, value);
        } catch (ParserConfigurationException e) {
            throw new SAXNotRecognizedException("Feature '" + name + "' is not supported");
        }
    }

    public void setProperty (String name, Object value)
    {
        this.factory.setAttribute(name, value);
    }

    private DOMSource loadDocument (final InputStream input)
    {
        try {
            return new DOMSource(this.factory.newDocumentBuilder().parse(input));
        } catch (SAXException e) {
            throw new RuntimeException("Unable to parse XML document");
        } catch (IOException e) {
            throw new RuntimeException("Unable to parse XML document");
        } catch (ParserConfigurationException e) {
            throw new RuntimeException(e);
        }
    }

    private DOMSource loadDocument (final File file)
    {
        try {
            DOMSource source = loadDocument(new FileInputStream(file));
            source.setSystemId(file.toURI().toString());
            return source;
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Unable to open file '" + file.getAbsolutePath() + "'");
        }
    }
}
