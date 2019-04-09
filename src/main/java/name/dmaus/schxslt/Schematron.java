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

    public Schematron (final File schema, final String phase)
    {
        Compiler compiler = new Compiler();
        this.validator = compiler.compile(new DOMSource(this.loadDocument(schema)), phase);
    }

    public Result validate (final InputStream input)
    {
        return validate(new DOMSource(this.loadDocument(input)));
    }

    public Result validate (final File file)
    {
        return validate(new DOMSource(this.loadDocument(file)));
    }

    public Result validate (final DOMSource source)
    {
        DOMResult target = new DOMResult();
        try {
            this.validator.newTransformer().transform(source, target);
            Document report = (Document)target.getNode();

            return new Result(report);

        } catch (TransformerException e) {
            throw new RuntimeException("Unable to apply validation stylesheet");
        }
    }

    private Document loadDocument (final InputStream input)
    {
        try {
            return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(input);
        } catch (SAXException e) {
            throw new RuntimeException("Unable to parse XML document");
        } catch (IOException e) {
            throw new RuntimeException("Unable to parse XML document");
        } catch (ParserConfigurationException e) {
            throw new RuntimeException("Unable to parse XML document");
        }
    }

    private Document loadDocument (final File file)
    {
        try {
            return loadDocument(new FileInputStream(file));
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Unable to open file '" + file.getAbsolutePath() + "'");
        }
    }
}
