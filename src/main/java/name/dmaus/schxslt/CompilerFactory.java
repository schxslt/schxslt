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

import javax.xml.transform.dom.DOMSource;

import org.w3c.dom.Node;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class CompilerFactory
{
    public Compiler newInstance (final DOMSource schema)
    {
        Document document = (Document)schema.getNode();
        Element outermost = document.getDocumentElement();
        if (outermost == null) {
            throw new RuntimeException("Invalid Schematron document");
        }
        String queryBinding = outermost.getAttribute("queryBinding");
        if (queryBinding == "") {
            queryBinding = "xslt";
        }

        Compiler compiler = new Compiler();
        if (queryBinding.toLowerCase().equals("xslt")) {
            compiler.setIncludeStylesheetPath("/xslt/1.0/include.xsl");
            compiler.setExpandStylesheetPath("/xslt/1.0/expand.xsl");
            compiler.setCompileStylesheetPath("/xslt/1.0/compile-for-svrl.xsl");
        }
        return compiler;
    }
}
