<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tE="http://www.tei-c.org/ns/Examples" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:http="http://expath.org/ns/http-client" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:output encoding="UTF-8" media-type="html"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="refText"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

<xsl:template match="t:figure">
    <xsl:variable name="url" select="t:graphic/@url"/>
    <xsl:variable name="id" select="t:graphic/@xml:id"/>
    <div id="{$id}">
    <div id="openseadragon{$id}"/>
    <div class="caption">Fig. <xsl:value-of select="$id"/>. <xsl:apply-templates select="t:graphic/t:desc"/></div>
    <script type="text/javascript">
        <xsl:text>
                           OpenSeadragon({
                           id: "openseadragon</xsl:text>
        <xsl:value-of select="$id"/>
        <xsl:text>",
                           prefixUrl: "resources/openseadragon/images/",
                           preserveViewport: true,
                           visibilityRatio:    1,
                           minZoomLevel:       1,
                           defaultZoomLevel:   1,</xsl:text>
        <xsl:text>tileSources:   ["</xsl:text>
        <xsl:value-of select="$url"/>
        <xsl:text>"]
                           });
                        </xsl:text>
    </script>
    </div>
</xsl:template>
    
<xsl:template match="t:div[@type]">
    <section>
        <xsl:element name="h{substring-after(@type, 'level')}">
                <xsl:value-of select="t:head"/>
            </xsl:element>
        <xsl:apply-templates/>
    </section>
</xsl:template>
    <xsl:template match="t:table">
        <table class="table table-responsive">
            <thead>
                <tr>
                    <xsl:for-each select="t:row[@role='label']/t:cell">
                <th>
                            <xsl:value-of select="."/>
                        </th>
            </xsl:for-each>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="t:row[not(@role)]">
                    <tr>
                        <xsl:for-each select="t:cell">
                            <td>
                                <xsl:apply-templates select="."/>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>
    <xsl:template match="t:list">
        <xsl:element name="{if(starts-with(@type,'unordered')) then 'ul' else 'ol'}">
            <xsl:for-each select="t:item">
                <li>
                    <xsl:apply-templates/>
                </li>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="t:head"/>
    
    <xsl:template match="t:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="t:gi">
        <code>&lt;<xsl:value-of select="."/>&gt;</code>
        <a href="/Guidelines/?id={.}">↗</a>
    </xsl:template>
    
    <xsl:template match="t:tag">
        <code>&lt;<xsl:value-of select="."/>&gt;</code>
        <a href="/Guidelines/?id={substring-before(., ' ')}">↗</a>
    </xsl:template>
    
    <xsl:template match="t:att">
        <code>@<xsl:value-of select="."/>
        </code>
    </xsl:template>
    
    <xsl:template match="tE:egXML">
        <div><pre>
            <code class="xml">
                <xsl:apply-templates select="child::node()" mode="escape"/>
            </code>
        </pre>
            <p style="font-size:smaller;text-align:center">Example <xsl:value-of select="count(preceding::tE:egXML) +1"/></p>
        </div>
    </xsl:template>

    <xsl:template match="t:hi[@rend = 'sup']">
        <sup>
            <xsl:value-of select="."/>
        </sup>
    </xsl:template>

    <xsl:template match="t:foreign">
        <xsl:text> </xsl:text>
        <span lang="{@xml:lang}">

            <xsl:choose>
                <xsl:when test="@xml:lang = 'ar'">
                    <xsl:attribute name="dir">rtl</xsl:attribute>
                </xsl:when>
                <xsl:when test="@xml:lang = 'syr'">
                    <xsl:attribute name="dir">rtl</xsl:attribute>
                </xsl:when>
                <xsl:when test="@xml:lang = 'he'">
                    <xsl:attribute name="dir">rtl</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="dir">ltr</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>

        </span>
        <xsl:choose>
            <xsl:when test="@xml:lang = 'ar' or @xml:lang = 'syr' or @xml:lang = 'he'">
                <span dir="ltr"/>
            </xsl:when>

        </xsl:choose>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="t:ref">
        <xsl:choose>
            <xsl:when test="@type= 'bm'">
                <a href="http://betamasaheft.eu/{@target}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:when test="@type= 'figure'">
                <a href="{@target}">
                    Fig. <xsl:value-of select="substring-after(@target, '#')"/>
                </a>
            </xsl:when>
            <xsl:when test="starts-with(@target, 'http')">
                <a href="{@target}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a href="/Guidelines?id={@target}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="t:cit">
        <blockquote>
            <xsl:value-of select="t:quote"/>
        </blockquote>
    </xsl:template>

    <xsl:template match="t:hi[@rendition]">
        <xsl:choose>
            <xsl:when test="@rendition = 'simple:bold'">
                <b>
                    <xsl:apply-templates/>
                </b>
            </xsl:when>
            <xsl:when test="@rendition = 'simple:italic'">
                <i>
                    <xsl:apply-templates/>
                </i>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
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