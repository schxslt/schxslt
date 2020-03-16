xquery version "3.1";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

test:suite((
    inspect:module-functions(xs:anyURI("0001-compile-validate/0001.xqm")),
    inspect:module-functions(xs:anyURI("0002-basic-pass-fail/0002.xqm")),
    inspect:module-functions(xs:anyURI("0003-no-fired-rules/0003.xqm")),
    inspect:module-functions(xs:anyURI("0004-phases/0004.xqm")),
    inspect:module-functions(xs:anyURI("0005-example-1/0005.xqm"))
))
