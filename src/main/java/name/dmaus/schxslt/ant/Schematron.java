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

package name.dmaus.schxslt.ant;

import java.io.IOException;
import java.io.File;

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

import java.net.URL;
import java.net.URI;
import java.net.URISyntaxException;

public class Schematron
{
    private final TransformerFactory factory = TransformerFactory.newInstance();
    private final URIResolver resolver = new Resolver();

    private Templates validator;

    public Schematron (final File schema, final String phase)
    {

        factory.setURIResolver(this.resolver);
        try {

            Transformer stepInclude = createSchematronTransformer("/xslt/include.xsl");
            Transformer stepExpand = createSchematronTransformer("/xslt/expand.xsl");
            Transformer stepCompile = createSchematronTransformer("/xslt/compile-for-svrl.xsl");

            DOMSource srcInclude = new DOMSource(this.loadDocument(schema));
            DOMResult dstInclude = new DOMResult();
            stepInclude.transform(srcInclude, dstInclude);

            DOMSource srcExpand = new DOMSource(dstInclude.getNode());
            DOMResult dstExpand = new DOMResult();
            stepExpand.transform(srcExpand, dstExpand);

            DOMSource srcCompile = new DOMSource(dstExpand.getNode());
            DOMResult dstCompile = new DOMResult();

            stepCompile.setParameter("phase", phase);
            stepCompile.transform(srcCompile, dstCompile);

            this.validator = factory.newTemplates(new DOMSource(dstCompile.getNode()));

        } catch (TransformerException e) {
            throw new RuntimeException("Unable to compile validation stylesheet");
        }
    }

    public boolean validate (final File file)
    {
        DOMResult target = new DOMResult();
        DOMSource source = new DOMSource(this.loadDocument(file));
        try {
            this.validator.newTransformer().transform(source, target);
            Document report = (Document)target.getNode();
            NodeList asserts = report.getElementsByTagNameNS("http://purl.oclc.org/dsdl/svrl", "failed-assert");
            NodeList reports = report.getElementsByTagNameNS("http://purl.oclc.org/dsdl/svrl", "successful-report");

            if (asserts.getLength() == 0 && reports.getLength() == 0) {
                return true;
            } else {
                return false;
            }
        } catch (TransformerException e) {
            throw new RuntimeException("Unable to apply validation stylesheet");
        }
    }

    private Document loadDocument (final File file)
    {
        try {
            return DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(file);
        } catch (SAXException e) {
            throw new RuntimeException("Unable to load document '" + file + "'");
        } catch (IOException e) {
            throw new RuntimeException("Unable to load document '" + file + "'");
        } catch (ParserConfigurationException e) {
            throw new RuntimeException("Unable to load document '" + file + "'");
        }
    }

    private Transformer createSchematronTransformer (final String filename) throws TransformerException
    {
        Source source = this.resolver.resolve(filename, null);
        return factory.newTransformer(source);
    }

    private class Resolver implements URIResolver
    {
        public Source resolve (String href, String base) throws TransformerException
        {
            URI baseUri;
            URI hrefUri;
            try {

                if (base == null || base.isEmpty()) {
                    baseUri = new URI("");
                } else {
                    baseUri = new URI(base.substring(1 + base.indexOf("!")));
                }

                hrefUri = baseUri.resolve(href);

                String systemId = getClass().getResource(hrefUri.toString()).toString();
                Source source = new StreamSource(getClass().getResourceAsStream(hrefUri.toString()));
                source.setSystemId(systemId);

                return source;

            } catch (URISyntaxException e) {
                throw new TransformerException(e);
            }
        }
    }
}
