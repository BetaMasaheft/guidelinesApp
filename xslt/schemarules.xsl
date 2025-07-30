<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tE="http://www.tei-c.org/ns/Examples" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:http="http://expath.org/ns/http-client" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    
    <xsl:output encoding="UTF-8" media-type="html"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="refText"/>
    
    <xsl:template match="/">
        <div>
            <h2>Schema specification</h2>
            <xsl:apply-templates/>
        </div>
        
        
    </xsl:template>
    <xsl:template match="t:exemplum">
        <div>
            <h5>Example <xsl:value-of select="count(preceding-sibling::t:exemplum) +1"/></h5>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tE:egXML">
        <p>Example from <a href="http://betamasaheft.eu/{@source}"><xsl:value-of select="@source"/></a>
        </p>
        <div id="example{concat(string(ancestor::t:elementSpec/@ident), string(count(parent::t:exemplum/preceding-sibling::t:exemplum) +1))}"> 
            <pre><code class="xml"><xsl:apply-templates mode="escape" select="child::node()"/></code></pre>
        </div>
        
        
    </xsl:template>
    
    
    <xsl:template match="t:q">
        <xsl:text>'</xsl:text><xsl:value-of select="."/><xsl:text>'</xsl:text>
    </xsl:template>
    <xsl:template match="t:ref">
        <a xmlns="http://www.w3.org/1999/xhtml" href="{@target}"><xsl:value-of select="."/></a>
    </xsl:template>
    
    <xsl:template match="t:gi">
        <code xmlns="http://www.w3.org/1999/xhtml">&lt;<xsl:value-of select="."/>&gt;</code>
        <a href="/Guidelines/?id={.}">↗</a>
    </xsl:template>
    
    <xsl:template match="t:tag">
        <code xmlns="http://www.w3.org/1999/xhtml">&lt;<xsl:value-of select="."/>&gt;</code>
        <a href="/Guidelines/?id={substring-before(., ' ')}">↗</a>
    </xsl:template>
    
    <xsl:template match="t:content">
        <div>
            <h3>content</h3>
            <pre><code class="xml"><xsl:apply-templates mode="escape" select="."/></code></pre>
        </div>
    </xsl:template>
    <xsl:template match="t:classes">
        <div>
            <h3>classes</h3>
            <pre><code class="xml"><xsl:apply-templates mode="escape" select="."/></code></pre>
        </div>
    </xsl:template>
    
    <xsl:template match="t:attList">
        <div>
            <h3>Attibutes list</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="t:attDef">
        <div>
            <h4>attribute <span class="label label-primary">
                <xsl:value-of select="@ident"/>
            </span>
            </h4>
            <xsl:if test="t:datatype">This attribute can have a maximum of <xsl:value-of select="t:datatype/@maxOccurs"/> values separated by a space.</xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <xsl:template match="t:valList">
        <p>This is a <emph>
            <xsl:value-of select="@type"/>
        </emph> list of allowed values</p>
        <table class="table table-responsive">
            <thead>
                <tr>
                    <th>value</th>
                    <th>definition</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates/>
            </tbody>
        </table>
    </xsl:template>
    
    
    <xsl:template match="t:valItem">
        <tr>
            <td>
                <xsl:value-of select="@ident"/>
            </td>
            <td>
                <xsl:apply-templates select="t:desc"/>
            </td>
        </tr>
        
    </xsl:template>
    
    <xsl:template match="t:constraintSpec">
        <table class="table table-responsive">
            <thead>
                <tr>
                    <th>context</th>
                    <th>rule</th>
                    <th>report</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="t:constraint/sch:rule">
                    <tr>
                        <td>
                            <code>
                                <xsl:value-of select="@context"/>
                            </code>
                        </td>
                        <td>
                            <code>
                                <xsl:value-of select="sch:report/@test"/>
                            </code>
                        </td>
                        <td>
                            <xsl:value-of select="sch:report/text()"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
        
    </xsl:template>
    
    
    <!--  Begin  from https://stackoverflow.com/questions/1162352/converting-xml-to-escaped-text-in-xslt-->
    <xsl:template match="*" mode="escape">
        <!-- Begin opening tag -->
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        
        
        <!-- Attributes -->
        <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>="</xsl:text>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="."/>
            </xsl:call-template>
            <xsl:text>"</xsl:text>
        </xsl:for-each>
        
        <!-- End opening tag -->
        <xsl:text>&gt;</xsl:text>
        
        <!-- Content (child elements, text nodes, and PIs) -->
        <xsl:apply-templates select="node()" mode="escape"/>
        
        <!-- Closing tag -->
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="text()" mode="escape">
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="escape">
        <xsl:text>&lt;?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
        <xsl:text>?&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template name="escape-xml">
        <xsl:param name="text"/>
        <xsl:if test="$text != ''">
            <xsl:variable name="head" select="substring($text, 1, 1)"/>
            <xsl:variable name="tail" select="substring($text, 2)"/>
            <xsl:choose>
                <xsl:when test="$head = '&amp;'">&amp;amp;</xsl:when>
                <xsl:when test="$head = '&lt;'">&amp;lt;</xsl:when>
                <xsl:when test="$head = '&gt;'">&amp;gt;</xsl:when>
                <xsl:when test="$head = '&#34;'">&amp;quot;</xsl:when>
                <xsl:when test="$head = &#34;'&#34;">&amp;apos;</xsl:when>
                <xsl:otherwise><xsl:value-of select="$head"/></xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="$tail"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!--    end 
           from https://stackoverflow.com/questions/1162352/converting-xml-to-escaped-text-in-xslt-->
    
    
    
</xsl:stylesheet>