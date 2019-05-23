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

import java.net.URL;
import java.net.URI;
import java.net.URISyntaxException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import javax.xml.transform.stream.StreamSource;

public class Resolver implements URIResolver
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

            if (href.isEmpty()) {
                hrefUri = baseUri;
            } else {
                hrefUri = baseUri.resolve(href);
            }

            URL systemId = getClass().getResource(hrefUri.toString());

            if (systemId != null) {
                Source source = new StreamSource(getClass().getResourceAsStream(hrefUri.toString()));
                source.setSystemId(systemId.toString());

                return source;
            }
            return null;

        } catch (URISyntaxException e) {
            throw new TransformerException(e);
        }
    }
}
