xquery version "3.1";

module namespace app="http://betamasaheft.eu/guidelines/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rng="http://relaxng.org/ns/structure/1.0";
declare namespace teiE="http://www.tei-c.org/ns/Examples";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://betamasaheft.eu/guidelines/config" at "config.xqm";
import module namespace editors="http://betamasaheft.eu/guidelines/editors" at "editors.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic"    at "resource:org/exist/xquery/lib/kwic.xql";

(:~
 : This is the logic for the guidelines browser and searching app
 :)
 
 declare variable $app:rng := doc(concat($config:app-root, '/schema/tei-betamesaheft.rng'));

declare function app:modelorelem($ec){
if(starts-with($ec, 'tei_model')) 
      then (for $contModel in $app:rng//rng:define[@name=$ec]//rng:ref/@name 
                return app:modelorelem($contModel))
      else substring-after($ec, 'tei_')
      };
(:storing separately this input in this function makes sure that when the page is reloaded with the results the value entered remains in the input element:)
declare function app:queryinput ($node as node(), $model as map(*), $q as xs:string*){<input name="q" type="search" class="form-control diacritics" placeholder="Search string" value="{$q}"/>};


declare %templates:wrap
    %templates:default("mode", "none")
function app:query($node as node()*, $model as map(*), $q as xs:string?){
if(empty($q) or $q = '') then () else
let $data-collection := '/db/apps/guidelines/data'
let $coll := collection($data-collection)
let $options :=
    <options>
        <default-operator>or</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>yes</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>
let $qp :=  '$coll//tei:body[ft:query(*, $q, $options)]'
let $hits := for $hit in util:eval($qp)  return $hit
return
  map {"hits" : $hits}
 
};

(: copy all parameters, needed for search :)
declare function app:copy-params($node as node(), $model as map(*)) {
    element { node-name($node) } {
        $node/@* except $node/@href,
        attribute href {
            let $link := $node/@href
            let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'user') then ()
                    else  if ($param = 'password') then ()
                    else
                  
                        $param || "=" || $value,
                    "&amp;"
                )
            return
                $link || "?" || $params
        },
        $node/node()
    }
};

(:~
 : FROM SHAKESPEAR
    Create a span with the number of items in the current search result.
:)
declare 
    %templates:wrap function app:hit-count($node as node()*, $model as map(*)) {
    let $q := request:get-parameter('q',())
    return
    if(empty($q)) then () else 
    <h3>You found "{$q}" in <span xmlns="http://www.w3.org/1999/xhtml" id="hit-count">{ count($model("hits")) }</span> entries!</h3>
    
};


declare
    %templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 20)
    %templates:default("min-hits", 0)
    %templates:default("max-pages", 20)
function app:paginate($node as node(), $model as map(*), $start as xs:int, $per-page as xs:int, $min-hits as xs:int,
    $max-pages as xs:int) {
        
    if ($min-hits < 0 or count($model("hits")) >= $min-hits) then
        let $count := xs:integer(ceiling(count($model("hits"))) div $per-page) + 1
        let $middle := ($max-pages + 1) idiv 2
        let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'collection') then ()
                    else if ($param = 'start') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
        return (
            if ($start = 1) then (
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ) else (
                <li>
                    <a href="?{$params}&amp;start=1"><i class="glyphicon glyphicon-fast-backward"/></a>
                </li>,
                <li>
                    <a href="?{$params}&amp;start={max( ($start - $per-page, 1 ) ) }"><i class="glyphicon glyphicon-backward"/></a>
                </li>
            ),
            let $startPage := xs:integer(ceiling($start div $per-page))
            let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
            let $upperBound := min(($lowerBound + $max-pages - 1, $count))
            let $lowerBound := max(($upperBound - $max-pages + 1, 1))
            for $i in $lowerBound to $upperBound
            return
                if ($i = ceiling($start div $per-page)) then
                    <li class="active"><a href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1) )}">{$i}</a></li>
                else
                    <li><a href="?{$params}&amp;start={max( (($i - 1) * $per-page + 1, 1)) }">{$i}</a></li>,
            if ($start + $per-page < count($model("hits"))) then (
                <li>
                    <a href="?{$params}&amp;start={$start + $per-page}"><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a href="?{$params}&amp;start={max( (($count - 1) * $per-page + 1, 1))}"><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            ) else (
                <li class="disabled">
                    <a><i class="glyphicon glyphicon-forward"/></a>
                </li>,
                <li>
                    <a><i class="glyphicon glyphicon-fast-forward"/></a>
                </li>
            )
        ) else
            ()
};

    declare    
%templates:wrap
    %templates:default('start', 1)
    %templates:default("per-page", 10) 
    function app:fullRes (
    $node as node(), 
    $model as map(*), $start as xs:integer, $per-page as xs:integer) {
         let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'id') then ()
                    else if ($param = 'collection') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
    for $term at $p in subsequence($model("hits"), $start, $per-page)
    let $expanded := kwic:expand($term)
        let $id := root($term)//tei:body/@xml:id
        let $name := root($term)//tei:titleStmt/tei:title/text()
              order by ft:score($term) descending
          return
          <div class="row">
                <a href="?{$params}&amp;id={data($id)}">{$name}</a>   <span class="badge pull-right"> {count($expanded//exist:match)}</span>
            <br/>
            <div>
             {kwic:summarize($term,<config width="40"/>)}
             </div>
             
               
        </div>
        

    };
    
    declare function app:showitem($node as node()*, $model as map(*), $id as xs:string?){
 let $params :=
                string-join(
                    for $param in request:get-parameter-names()
                    for $value in request:get-parameter($param, ())
                    return
                    if ($param = 'id') then ()
                    else if ($param = 'collection') then ()
                    else
                        $param || "=" || $value,
                    "&amp;"
                )
let $col := collection('/db/apps/guidelines/data')
let $id := request:get-parameter('id', ())
let $term := $col//id($id)
let $termName := $term/ancestor::tei:TEI//tei:titleStmt/tei:title/text()

return
if ($id = 'ontologyView') then (
<div class="container-fluid">
<div class="col-md-12">
        <div>
       <p class="lead">The Beta maṣāḥǝft ontology</p>
       <p><a href="https://betamasaheft.github.io/RDF/">OWLDoc Documentation</a></p>
        <p><a href="http://visualdataweb.de/webvowl/#url=https://raw.githubusercontent.com/BetaMasaheft/RDF/master/betamasaheft.json">View in WebVOWL</a></p>
    </div>
        <div>
        <p class="lead">The <i>Syntaxe du Codex</i> ontology  which we use for the description of the stratigraphy and history of manuscripts</p>
        <p><a href="https://betamasaheft.github.io/SyntaxeDuCodex/">OWLDoc Documentation</a></p>
        <p><a href="http://visualdataweb.de/webvowl/#url=https://raw.githubusercontent.com/BetaMasaheft/SyntaxeDuCodex/master/SyntaxeDuCodex.json">View in WebVOWL</a></p>
    </div>
    </div>
</div>
) 
else if ($id = 'schemaView') then (
<div class="container-fluid">
<div class="col-md-12">
{for $modRef in doc('/db/apps/guidelines/schema/tei-betamesaheft.xml')//tei:moduleRef
return 
<div class="row-fluid alert alert-info">{
('Module ' ||string($modRef/@key) || ' ' || (if($modRef/@except) then ('except: ' || string($modRef/@except)) else ())) 
}</div>
}
</div>
<div class="col-md-12">
{for $eleSpec in doc('/db/apps/guidelines/schema/tei-betamesaheft.xml')//tei:elementSpec
let $i := string($eleSpec/@ident)
let $rngel := $app:rng//rng:element[@name=$i]
order by $i
return 
<div class="row alert alert-warning">
<h2><a href="/Guidelines/?id={$i}">{$i}</a></h2>
<p class="lead">Mode : {string($eleSpec/@mode)}</p>
<p class="lead">Module : {string($eleSpec/@module)}</p>
{
transform:transform($eleSpec, 'xmldb:exist:///db/apps/guidelines/xslt/schemarules.xsl',()),
transform:transform($rngel, 'xmldb:exist:///db/apps/guidelines/xslt/schemarules.xsl',())
}</div>
}
</div>
</div>
) 
else if (starts-with($id, '@')) then (
let $a := substring-after($id, '@')
return
<div class="container-fluid">
<p>Th attribute <span class="label label-primary">{$id}</span> is mentioned in the following pages:</p>
<ul>
{
for $att in $col//tei:att[. = $a]
let $ref := $att/ancestor::tei:body/@xml:id
group by $R := $ref
let $name := $col//id($R)/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
return
<li><a href="/Guidelines/?id={$R}">{$name}</a></li>
}</ul>
</div>
) else
if ($id) then (
if($term/name() = 'body') then (
<div class="container-fluid">
<h2>{$termName}</h2>

{transform:transform($term, 'xmldb:exist:///db/apps/guidelines/xslt/text.xsl',())}
{if(doc('/db/apps/guidelines/data/listelements.xml')//tei:item[.=$id]) then (
<div class="alert alert-info"><p class="lead">TEI guidelines <a target="_blank" href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$id}.html">element {$id}</a></p></div>,
let $teielement := 'tei_' || $id
let $containerModel := $app:rng//rng:define[descendant::rng:ref[@name=$teielement]]/@name
let $elemContainer :=$app:rng//rng:define[descendant::rng:ref[@name=$containerModel]]/@name
let $elnames := for $ec in $elemContainer return app:modelorelem($ec)
return 
<div class="alert alert-info">Contained by: 
{for $e in distinct-values($elnames) return
<a class="badge" href="/Guidelines/?id={$e}">{$e}</a>}
</div>,
let $elemSpec := $app:rng//rng:element[@name=$id]
return transform:transform($elemSpec, 'xmldb:exist:///db/apps/guidelines/xslt/schemarules.xsl',()),
if(doc('/db/apps/guidelines/schema/tei-betamesaheft.xml')//tei:elementSpec[@ident=$id]) then (let $elemSpec := doc('/db/apps/guidelines/schema/tei-betamesaheft.xml')//tei:elementSpec[@ident=$id] return transform:transform($elemSpec, 'xmldb:exist:///db/apps/guidelines/xslt/schemarules.xsl',()) ) else ()
,
<div class="alert alert-success"><p>This element is mentioned in the following pages</p>
<ul >{for $occurrence in collection($config:data-root)//tei:gi[. = $id]
let $ref := $occurrence/ancestor::tei:body/@xml:id
group by $R := $ref
let $name := $col//id($R)/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
return
<li><a href="/Guidelines/?id={$R}">{$name}</a></li>
}
</ul></div>)
else (
<div class="alert alert-success"><p>This page is referred to in the following pages</p>
<ul >{for $occurrence in collection($config:data-root)//tei:ref[@target = $id]
let $ref := $occurrence/ancestor::tei:body/@xml:id
group by $R := $ref
let $name := $col//id($R)/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
return
<li><a href="/Guidelines/?id={$R}">{$name}</a></li>
}
</ul>
</div>
)}



</div>,
<div class="alert alert-warning">
<h4>Revisions of this page</h4>
<ul>
{
for $change in $term/ancestor::tei:TEI//tei:change
return
<li>{editors:editorKey($change/@who)} on {string($change/@when)}: {$change/text()}</li>
}
</ul>
</div>
) else
(<div class="lead">Alas, there is no page yet with ID <span class="label label-primary">{$id}</span>. If it is an element name, it might just need we do not have any page because there is no further specification to be given, so please look into the TEI guidelines for <a target="_blank" href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$id}.html">element {$id}</a>. Or do we need this page? <a class="btn btn-warning" target="_blank" href="https://github.com/BetaMasaheft/guidelines/issues/new?title=Please%20create%20page%20{$id}">
                               Click here to open an issue to ask for this page to be added to the guidelines.
                            </a></div>)
)
else (<div>
<h1>Welcome to the Beta maṣāḥǝft Guidelines!</h1>
<div><p>You can find here the text of the guidelines for encoding in TEI information about the 
Ethiopic and Eritrean Manuscript Cultures, which is linked and presented for reference in connection with the Beta maṣāḥǝft Schema.</p>
<p>We have tried to put as many examples as possible in the Schema as well as here in the Guidelines.</p>
<p>These encoding practice guidelines as well as the schema are maintained and used by the Beta maṣāḥǝft project but are open to any interested user. 
We hope they will be used by other practitioners in the field for their purposes, for more and more projects.</p>
<p>You can report problems and suggest changes in the <a href="https://github.com/BetaMasaheft/guidelines">GitHub repository</a>.</p>
</div>
<div class="lead alert alert-info">Browse and click on the left or Search and click on a search result to see it here.</div>
<div class="lead alert alert-warning">Some Quick Links
<ul>
<li><a href="/Guidelines?id=howto">Getting started</a></li>
<li><a href="/Guidelines?id=setup">Set up your working space</a> <a href="/Guidelines?id=workflow">(with some help in using GitHub)</a></li>
<li><a href="/Guidelines?id=general">The general entry point to the guidelines</a></li>
<li><a href="/Guidelines?id=images">Images</a></li>
<li><a href="/Guidelines?id=text-encoding">Text encoding</a></li>
<li><a href="/Guidelines?id=transliteration-principles">Transliteration</a></li>
<li><a href="/Guidelines?id=zotero">Bibliography</a></li>
</ul>
</div>
</div>)

};



(: minitabs uno per ogni toc e ogni toc una lista, cosi resta visibile la lista desiderata insieme allentita selezionata:)

declare function app:TableOfContents($node as node()*, $model as map(*)){
<div id="tocs">
<ul class="nav nav-tabs">
{for $toc in collection('/db/apps/guidelines/data/toc')//tei:TEI
let $name := string($toc//tei:body/@xml:id)
return
 
            <li>{if(starts-with($name, 'main')) then attribute class {'active'} else ()}<a data-toggle="tab" href="#toc{$name}">{$toc//tei:titleStmt/tei:title/text()}</a></li>
            }
            <li><a data-toggle="tab" href="#allelements">All Elements</a></li>
            <li><a data-toggle="tab" href="#allattributes">All Attributes</a></li>
            <li><a data-toggle="tab" href="#allpages">All Pages</a></li>
            </ul>
            <div class="tab-content">
            {for $toc in collection('/db/apps/guidelines/data/toc')//tei:TEI
let $name := string($toc//tei:body/@xml:id)
return
            <div id="toc{$name}">
            {if(starts-with($name, 'main')) then attribute class {'toc tab-pane fade in active'} else (attribute class {'toc tab-pane fade in'})}
            {app:tei2string($toc//tei:body)}
            </div>}
            <div id="allelements" class="toc tab-pane fade in">
            {app:tei2string(doc('/db/apps/guidelines/data/listelements.xml')//tei:body)}
            </div>
            <div id="allattributes" class="toc tab-pane fade in">
            <ul>
{for $att in collection('/db/apps/guidelines/data')//tei:att
group by $att
order by $att
return 
<li><a  href="/Guidelines/?id=@{$att/text()}">{$att/text()}</a>
</li>}</ul>
            </div>
            <div id="allpages" class="toc tab-pane fade in">
            <ul>
            {for $page in collection('/db/apps/guidelines/data/pages')//tei:TEI 
            let $id := string($page//tei:body/@xml:id)
            let $name := $page//tei:titleStmt/tei:title/text()
            order by $name ascending
            return
           <li><a href="/Guidelines/?id={$id}">{$name}</a></li>
        }</ul>
            </div>
            </div>

</div>
};

declare function app:tei2string($nodes as node()*) {
    
    for $node in $nodes
    return
        typeswitch ($node)
        case element(tei:list)
                return
               <ul>{app:tei2string($node/node())}</ul> 
            
    
        case element(tei:item)
        return
        if ($node/tei:list) then  app:tei2string($node/node()) else
        let $pageID := $node/text()
        let $page := collection($config:data-root)//id($pageID)
        let $id := if (count($page) gt 1) then 'there are two pages with id '||$pageID||'!' else string($page/@xml:id)
        let $title:= if (count($page) gt 1) then 'there are two pages with id '||$pageID||'!' else $page/ancestor::tei:TEI//tei:titleStmt/tei:title/text()
        return
        <li><a href="/Guidelines/?id={$id}">{$title}</a></li>
           
            case element()
                return
                    app:tei2string($node/node())
            default
                return
                    $node
};
