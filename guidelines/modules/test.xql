xquery version "3.1";

import module namespace entities = "http://joewiz.org/ns/xquery/entities" at "https://gist.githubusercontent.com/joewiz/8a2c3e2320da4c24058ccee5aec156f6/raw/0fc38d74a52d5ddfa7d0af0e5344148951b170e7/entities.xql";

declare function local:transform($nodes) {
    for $node in $nodes
    return
        typeswitch ($node)
            case element() return 
                element { name($node) } { $node/@*, local:transform($node/node()) }
            default return 
                try { parse-xml-fragment(entities:name-to-character($node)) } catch * { $node }
};

let $node := 
    <table heading="Text">
        <tr>
            <Type>Formaz. lav.</Type>
            <Note>&lt;strong&gt;01/06/16&lt;/strong&gt; - Some text - &amp;ograve;</Note>
        </tr>
        <tr>
            <Type>Risc. chimico</Type>
            <Note>&lt;strong&gt;02/06/18&lt;/strong&gt; - Some text - &amp;apos;</Note>
        </tr>
    </table>
    
    let $transformedNode := local:transform($node)
    
    let $stylesheet := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    
    <xsl:template match="table">
        <fo:block>
            <fo:block font-weight="bold" font-size="14pt" padding="10px" font-family="Verdana">
                <xsl:value-of select="@heading"/>
            </fo:block>
            
            <fo:block font-size="10pt">
                <fo:table border="solid" border-collapse="collapse">
                    <fo:table-header>
                        <fo:table-row>
                            <xsl:for-each select="*[1]/*">
                                <fo:table-cell>
                                    <fo:block font-weight="bold">
                                        <xsl:value-of select="name(.)"/>
                                    </fo:block>
                                </fo:table-cell>
                            </xsl:for-each>
                        </fo:table-row>
                    </fo:table-header>
                    <fo:table-body>
                        <xsl:apply-templates/>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block>
    </xsl:template>
    
    
    <xsl:template match="*">
        <fo:table-row>
            <xsl:for-each select="*">
                <fo:table-cell>
                    <fo:block>
                            <xsl:apply-templates/>
                    </fo:block>
                </fo:table-cell>
            </xsl:for-each>
        </fo:table-row>
    </xsl:template>
    
      <xsl:template match="strong">
      <fo:inline font-weight="bold">
        <xsl:apply-templates select="*|text()"/>
      </fo:inline>
    </xsl:template>
    
</xsl:stylesheet>

return

    transform:transform($transformedNode, $stylesheet, ())
    