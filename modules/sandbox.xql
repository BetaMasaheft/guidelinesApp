xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace teiE="http://www.tei-c.org/ns/Examples";

import module namespace app="http://betamasaheft.eu/guidelines/templates" at "app.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://betamasaheft.eu/guidelines/config" at "config.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic"    at "resource:org/exist/xquery/lib/kwic.xql";


base-uri(collection($config:data-root)//id('persons'))