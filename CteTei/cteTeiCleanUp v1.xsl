<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xs:dc>This stylesheet clears-up the TEI output of CTE</xs:dc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" name="xml"/>
    
    <!-- some variables -->
    <xsl:variable name="vDateCurrentIso" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
    <xsl:variable name="vChange">
        <xsl:element name="change">
            <xsl:attribute name="when" select="$vDateCurrentIso"/>
            <xsl:text>Added some automated markup and cleared-up some of CTE's follies to "</xsl:text>
            <xsl:value-of select="base-uri()"/>
            <xsl:text>".</xsl:text>
        </xsl:element>
    </xsl:variable>
    
    
    <!-- copy all -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- save as new file -->
    <xsl:template match="TEI">
        <xsl:result-document href="{substring-before(base-uri(),'.')}-clean-{$vDateCurrentIso}.TEIP5.xml">
            <xsl:copy>
                <xsl:apply-templates select="@* |node()"/>
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
    
    <xsl:template match="revisionDesc">
        <xsl:copy>
            <xsl:copy-of select="$vChange"/>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- duplicate the value of the @rendition attribute as @type -->
    <xsl:template match="@rendition">
        <xsl:copy/>
        <xsl:attribute name="type">
            <xsl:value-of select="substring-after(.,'#')"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- deal with <note>s in the original file -->
    <xsl:template match="text//note">
        <!-- wrap the word preceding the note in a seg and provide an ID -->
        <!-- provide an empty anchor such as <ref> -->
        <xsl:element name="ref">
            <xsl:attribute name="type" select="@type"/>
            <xsl:attribute name="target" select="concat('#note_',generate-id())"/>
            <xsl:attribute name="xml:id" select="concat('note-ref_',generate-id())"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>