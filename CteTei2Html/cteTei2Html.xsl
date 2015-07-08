<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xs:dc>This stylesheet converts the TEI output from CTE into HTML using the rendition and language information to style the output. All the inline notes are separated from the text connected to the main body with hyperlinks.</xs:dc>
    
    <xsl:output method="text" name="text"/>
    <xsl:output encoding="UTF-8" indent="yes" method="html" omit-xml-declaration="yes" name="html"/>
    <xsl:include href="../Functions/BachFunctions v3.xsl"/>
    
   
    <xsl:template match="tei:TEI">
        <!-- generate CSS based on the <rendition> nodes in the <teiHeader> -->
        <xsl:result-document href="{substring-before(base-uri(),'.xml')}_cte_rendition-styles.css" format="text">
            <xsl:apply-templates select=".//tei:rendition" mode="mCss"/>
        </xsl:result-document>
        <!-- generate an HTML view -->
        <xsl:result-document href="{substring-before(base-uri(),'.xml')}.html" format="html">
            <xsl:apply-templates select=".//tei:text" mode="mHtml"/>
        </xsl:result-document>
    </xsl:template>

    
    <!-- generate a css file based on the rendition tags  -->
    <xsl:template match="tei:rendition[@scheme='css']" mode="mCss">
        <xsl:text>
            
        </xsl:text>
        <xsl:value-of select="concat('.',@xml:id)"/>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>}</xsl:text>
    </xsl:template>
    
    <!-- generate the html from the text node -->
    <xsl:template match="tei:text" mode="mHtml">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{substring-before(base-uri(),'.xml')}_cte_rendition-styles.css"/>
                <link rel="stylesheet" type="text/css" href="cte_main-styles.css"/>
                <title><xsl:value-of select="ancestor::tei:TEI//tei:fileDesc/tei:titleStmt/tei:title"/></title>
            </head>
            <body>
                <xsl:call-template name="templHtmlAttrLang">
                    <xsl:with-param name="pInput" select="."/>
                </xsl:call-template>
                <!-- main body of the text -->
                <div id="front">
                    <xsl:apply-templates select="./tei:front" mode="mHtml"/>
                </div>
                <div id="body">
                    <xsl:apply-templates select="./tei:body" mode="mHtml"/>
                </div>
                <div id="back">
                    <!-- notes -->
                <div id="notes">
                    <xsl:apply-templates select=".//tei:note[starts-with(@type,'n')]" mode="mNotes"/>
                </div>
                <!-- apparatus -->
                <div id="apparatus">
                    <xsl:apply-templates select=".//tei:note[starts-with(@type,'a')]" mode="mNotes"/>
                </div>
                </div>
                
            </body>
        </html>
    </xsl:template>
    
    <!-- HTML: omit all attributes that are not explicitly covered -->
    <xsl:template match="@*" mode="mHtml"/>
    
    <!-- convert the inline styling in @rend to @style -->
    <xsl:template match="@rend" mode="mHtml">
        <xsl:attribute name="style" >
            <!--<xsl:value-of select="parent::node()/@rend"/>-->
            <xsl:analyze-string select="." regex="(\-cte\-)(.[^:]*):(.[^;]*);">
                <xsl:matching-substring>
                    <xsl:message><xsl:text>we found a CTE custom style</xsl:text></xsl:message>
                    <xsl:if test="regex-group(2)='text-align'">
                        <xsl:if test="regex-group(3)='justify-center'">
                            <xsl:text>text-align:center;</xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="regex-group(2)='line-height'">
                        <!-- do nothing -->
                    </xsl:if>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:attribute>
    </xsl:template>
    
    <!-- additional TEI elements -->
    <!-- tei:head -->
    <xsl:template match="tei:head" mode="mHtml">
        <h1>
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="@* | node()" mode="mHtml"/>
        </h1>
    </xsl:template>
    <!-- tei:div -->
    <xsl:template match="tei:div" mode="mHtml">
        <div>
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="@* | node()" mode="mHtml"/>
        </div>
    </xsl:template>
    <!-- tei:lb -->
    <xsl:template match="tei:lb" mode="mHtml">
        <br/>
    </xsl:template>
    <!--  -->
    <xsl:template match="tei:ref" mode="mHtml">
        <a href="{@target}" target="_blank">
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="@* | node()" mode="mHtml"/>
        </a>
    </xsl:template>
    
    
    <!-- original elements from the CTE output -->
    <!-- tei:p -->
    <xsl:template match="tei:p" mode="mHtml">
        <p>
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:attribute name="class" select="substring-after(@rendition,'#')"/>
            <xsl:apply-templates select="@* | node()" mode="mHtml"/>
        </p>
    </xsl:template>
    
    <!-- CTE uses <hi> nodes for inline styling -->
    <xsl:template match="tei:hi" mode="mHtml">
        <span class="tei-hi">
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="@* | node()" mode="mHtml"/>
        </span>
    </xsl:template>
    
    <!-- create the hyperlink to the note text -->
    <xsl:template match="tei:note" mode="mHtml">
        <a class="anchor">
            <xsl:attribute name="id" select="concat('note-anchor_',generate-id())"/>
            <xsl:attribute name="href" select="concat('#note_',generate-id())"/>
            <!-- take care of different type of notes -->
            <xsl:choose>
                <xsl:when test="@type='n1'">
                    <xsl:text>م</xsl:text>
                    <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text][@type='n1']) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                </xsl:when>
                <xsl:when test="@type='a1'">
                    <xsl:text>ش</xsl:text>
                    <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text][@type='a1']) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text]) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    <!-- this should prevent the content of notes to be returned -->
    <xsl:template match="node()[ancestor::tei:note]" mode="mHtml"/>
    
    
    <!-- Produce notes  -->
    <xsl:template match="tei:note" mode="mNotes">
        <p class="note">
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:attribute name="id" select="concat('note_',generate-id())"/>
            <a class="anchor">
                <xsl:attribute name="href" select="concat('#note-anchor_',generate-id())"/>
                <!-- take care of different type of notes -->
                <xsl:choose>
                    <xsl:when test="@type='n1'">
                        <xsl:text>م</xsl:text>
                        <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text][@type='n1']) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                    </xsl:when>
                    <xsl:when test="@type='a1'">
                        <xsl:text>ش</xsl:text>
                        <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text][@type='a1']) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select=" translate(string(count(preceding::tei:note[ancestor::tei:text]) +1),$vStringTranscribeFromIjmes,$vStringTranscribeToArabic)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:apply-templates select="node()" mode="mNotes"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:note/tei:p" mode="mNotes">
        <span>
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:attribute name="class" select="substring-after(@rendition,'#')"/>
            <xsl:apply-templates select="node()" mode="mNotes"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:mentioned" mode="mNotes">
        <span class="tei-mentioned">
            <xsl:call-template name="templHtmlAttrLang">
                <xsl:with-param name="pInput" select="."/>
            </xsl:call-template>
            <xsl:apply-templates select="node()" mode="mNotes"/>
        </span>
    </xsl:template>
    
    <!-- add the HTML @lang attribute based on the containing element -->
    <xsl:template name="templHtmlAttrLang">
        <xsl:param name="pInput"/>
        <xsl:choose>
            <xsl:when test="$pInput/@xml:lang">
                <xsl:attribute name="lang" select="$pInput/@xml:lang"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="lang">
                    <xsl:value-of select="ancestor::node()[@xml:lang!=''][1]/@xml:lang"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>