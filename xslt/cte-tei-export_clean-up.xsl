<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xs:dc>This stylesheet cleans the TEI output of CTE up and moves the inline notes into the back matter.</xs:dc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" name="xml"/>
    
    <!-- some variables -->
    <xsl:variable name="vDateCurrentIso" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
    <xsl:variable name="vRespEditor" select="'Till Grallert'"/>
    <xsl:variable name="vRespEditorInit">
        <xsl:for-each select="tokenize($vRespEditor,' ')">
            <xsl:value-of select="substring(.,1,1)"/>
        </xsl:for-each>
    </xsl:variable>
    <!-- documenting the changes -->
    <xsl:variable name="vChange">
        <xsl:element name="change">
            <xsl:attribute name="when" select="$vDateCurrentIso"/>
            <xsl:attribute name="who" select="concat('#pers_',$vRespEditorInit)"/>
            <xsl:text>Added some automated markup and cleared-up some of CTE's follies in "</xsl:text>
            <xsl:value-of select="base-uri()"/>
            <xsl:text>".</xsl:text>
        </xsl:element>
    </xsl:variable>
    <!-- strings for translating IJMES transcription into Arabic letters this is used for generating Arabic numerals for footnotes -->
    <xsl:variable name="vStringTranscribeIjmes" select="'btḥḫjdrzsṣḍṭẓʿfqklmnhāūīwy0123456789'"/>
    <xsl:variable name="vStringTranscribeArabic" select="'بتحخجدرزسصضطظعفقكلمنهاويوي٠١٢٣٤٥٦٧٨٩'"/>
    
    <!-- copy everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- save as new file -->
    <xsl:template match="/">
        <xsl:result-document href="{substring-before(base-uri(),'.')}-clean-{format-date(current-date(),'[Y0001][M01][D01]')}.TEIP5.xml" method="xml">
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <!-- document the changes in the teiHeader -->
    <xsl:template match="teiHeader">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
            <xsl:if test="not(descendant::revisionDesc)">
                <xsl:element name="revisionDesc">
                    <xsl:copy-of select="$vChange"/>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="titleStmt">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
            <xsl:if test="not(./respStmt/persName=$vRespEditor)">
                <xsl:element name="respStmt">
                    <xsl:element name="resp">
                        <xsl:text>TEI enhancements</xsl:text>
                    </xsl:element>
                    <xsl:element name="persName">
                        <xsl:attribute name="xml:id" select="concat('pers_',$vRespEditorInit)"/>
                        <xsl:value-of select="$vRespEditor"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="revisionDesc">
        <xsl:copy>
            <xsl:copy-of select="$vChange"/>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- translate milestones to lb -->
    <xsl:template match="milestone[@unit='line']">
        <xsl:element name="lb">
            <xsl:attribute name="n" select="translate(@n,$vStringTranscribeArabic,$vStringTranscribeIjmes)"/>
        </xsl:element>
    </xsl:template>
    <!-- translate milestones to pb -->
    <xsl:template match="milestone[@unit='page']">
        <xsl:element name="pb">
            <xsl:attribute name="n" select="translate(@n,$vStringTranscribeArabic,$vStringTranscribeIjmes)"/>
        </xsl:element>
    </xsl:template>
    
    <!-- remove <hi> tags without rendering information -->
    <xsl:template match="hi[not(@*)]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    
    <!-- duplicate the value of the @rendition attribute as @type -->
    <!-- note: tei:p cannot carry @type attributes -->
    <xsl:template match="@rendition[not(parent::p)]">
        <xsl:copy/>
        <xsl:attribute name="type">
            <xsl:value-of select="substring-after(.,'#')"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- create a back matter containing all the notes -->
    <xsl:template match="text">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
            <xsl:if test=".//note and not(child::back)">
                <xsl:element name="back">
                    <xsl:element name="div">
                        <xsl:attribute name="type" select="'notes'"/>
                        <xsl:apply-templates select=".//note" mode="mNotes"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- deal with <note>s in the original file -->
    <xsl:template match="text//note">
        <!--  the word preceding the note is wrapped in a <seg> by CTE-->
        <!-- provide an empty anchor such as <ref> -->
        <xsl:element name="ref">
            <xsl:attribute name="type" select="@type"/>
            <xsl:attribute name="target" select="concat('#note_',generate-id())"/>
            <xsl:attribute name="xml:id" select="concat('note-ref_',generate-id())"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text//note" mode="mNotes">
        <!-- wrap the word preceding the note in a seg and provide an ID -->
        <!-- provide an empty anchor such as <ref> -->
        <xsl:copy>
            <xsl:attribute name="xml:id" select="concat('note_',generate-id())"/>
            <!-- point to the preceding <seg>. This was particular to the TEI export I got from the OIB diwan edition -->
            <xsl:attribute name="target" select="concat('#',preceding-sibling::seg[1]/@xml:id)"/>
            <xsl:apply-templates select="@*"/>
            <!--<xsl:element name="ref">
                <xsl:attribute name="type" select="@type"/>
                <xsl:attribute name="target" select="concat('#note-ref_',generate-id())"/>
            </xsl:element>-->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>