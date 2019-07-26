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

import org.w3c.dom.Element;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import java.util.List;
import java.util.ArrayList;

import java.io.File;
import java.io.IOException;

import javax.xml.transform.stream.StreamResult;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;

import javax.xml.transform.dom.DOMSource;

public class Result
{
    private final Document report;
    private final List<String> messages = new ArrayList<String>();

    public Result (final Document report)
    {
        this.report = report;

        this.readMessages(report.getElementsByTagNameNS("http://purl.oclc.org/dsdl/svrl", "failed-assert"));
        this.readMessages(report.getElementsByTagNameNS("http://purl.oclc.org/dsdl/svrl", "successful-report"));
    }

    public List<String> getValidationMessages ()
    {
        return this.messages;
    }

    public Document getValidationReport ()
    {
        return this.report;
    }

    public boolean isValid ()
    {
        return this.messages.isEmpty();
    }

    public void saveAs (final File file)
    {
        try {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            DOMSource source = new DOMSource(this.report, this.report.getDocumentURI());
            StreamResult result = new StreamResult(file);

            transformer.transform(source, result);

        } catch (TransformerException e) {
            throw new RuntimeException("Unable to save validation report to file '" + file + "'");
        }
    }

    private void readMessages (NodeList nodes)
    {
        for (int i = 0; i < nodes.getLength(); i++) {
            Element element = (Element)nodes.item(i);
            String message = element.getLocalName() + " " + element.getAttribute("location") + " " + element.getTextContent();
            this.messages.add(message);
        }
    }
}
