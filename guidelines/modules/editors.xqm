xquery version "3.1";

module namespace editors = "http://betamasaheft.eu/guidelines/editors";

declare namespace test = "http://exist-db.org/xquery/xqsuite";
declare namespace t = "http://www.tei-c.org/ns/1.0";

import module namespace console = "http://exist-db.org/xquery/console";

declare variable $editors:editors := doc("/db/apps/lists/editors.xml")//t:list;

(:~
 : gets the name of the editor given the initials
 :)
declare %test:arg("key", "PL") %test:assertEquals("Pietro Maria Liuzzo") function editors:editorKey(
	$key as xs:string
) as xs:string {
	let $match := $editors:editors/t:item[@xml:id = $key]
	return if ($match) then
		string($match)
	else
		string($editors:editors/t:item[@xml:id = "AB"])
};

(:~
 : given the user name, returns the initials
 :)
declare function editors:editorNames($key as xs:string) as xs:string {
	let $match := $editors:editors/t:item[@n = $key]
	return if ($match) then
		string($match/@xml:id)
	else
		"AB"
};
