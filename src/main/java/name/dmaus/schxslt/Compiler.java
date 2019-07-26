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

import javax.xml.transform.Templates;

import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import javax.xml.transform.stream.StreamSource;

import java.io.File;

import org.w3c.dom.Document;

import java.util.Map;

class Compiler
{
    private final TransformerFactory factory = TransformerFactory.newInstance();
    private final URIResolver resolver = new Resolver();

    private String includeStylesheetPath = "/xslt/2.0/include.xsl";
    private String expandStylesheetPath = "/xslt/2.0/expand.xsl";
    private String compileStylesheetPath = "/xslt/2.0/compile-for-svrl.xsl";

    private Map<String, Object> parameters = null;

    public Compiler ()
    {
        factory.setURIResolver(resolver);
    }

    public void setParameters (final Map<String, Object> parameters)
    {
        this.parameters = parameters;
    }

    public Templates compile (final Source schema)
    {
        return this.compile(schema, "#ALL");
    }

    public Templates compile (final Source schema, final String phase)
    {
        try {

            Transformer stepInclude = createSchematronTransformer(includeStylesheetPath);
            Transformer stepExpand = createSchematronTransformer(expandStylesheetPath);
            Transformer stepCompile = createSchematronTransformer(compileStylesheetPath);

            DOMResult dstInclude = new DOMResult();
            stepInclude.transform(schema, dstInclude);

            DOMSource srcExpand = new DOMSource(dstInclude.getNode(), dstInclude.getSystemId());
            DOMResult dstExpand = new DOMResult();
            stepExpand.transform(srcExpand, dstExpand);

            DOMSource srcCompile = new DOMSource(dstExpand.getNode(), dstExpand.getSystemId());
            DOMResult dstCompile = new DOMResult();

            if (parameters != null) {
                for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                    stepCompile.setParameter(entry.getKey(), entry.getValue());
                }
            }

            if (phase != null) {
                stepCompile.setParameter("phase", phase);
            }

            stepCompile.transform(srcCompile, dstCompile);
            return factory.newTemplates(new DOMSource(dstCompile.getNode(), dstCompile.getSystemId()));

        }  catch (TransformerException e) {
            throw new RuntimeException("Unable to compile validation stylesheet");
        }
    }

    public void setIncludeStylesheetPath (final String includeStylesheetPath)
    {
        this.includeStylesheetPath = includeStylesheetPath;
    }

    public void setExpandStylesheetPath (final String expandStylesheetPath)
    {
        this.expandStylesheetPath = expandStylesheetPath;
    }

    public void setCompileStylesheetPath (final String compileStylesheetPath)
    {
        this.compileStylesheetPath = compileStylesheetPath;
    }

    private Transformer createSchematronTransformer (final String filename) throws TransformerException
    {
        Source source = this.resolver.resolve(filename, null);
        return this.factory.newTransformer(source);
    }
}
