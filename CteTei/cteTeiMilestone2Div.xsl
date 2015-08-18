<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="no" name="xml"/>
    
    
    
    <!-- adapted from http://stackoverflow.com/questions/17618249/xsl-display-text-between-two-milestone-show-milestone-value-elsewhere -->

    <!-- Make some "preprocess" - just to splip everything containing pb -->
    <xsl:template name="preprocess" match="tei:TEI">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[not(child::tei:text)]"/>
            <!-- Only root element shouldn't be splitted -->
            <xsl:variable name="vPreprocess">
                <xsl:copy>
                    <xsl:apply-templates select="child::tei:text" mode="preprocess"/>
                </xsl:copy>
            </xsl:variable>
            <xsl:element name="tei:text">
            <xsl:for-each-group select="$vPreprocess/descendant::*" group-starting-with="tei:milestone[@unit='chapter']">
                <div type="chapter">
                    <xsl:copy-of select="current-group()[position() &gt; 1]" />
                    <!--<xsl:value-of select="current-grouping-key()/@n"/>-->
                </div>
            </xsl:for-each-group>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <!-- copy everything that is not preprocesses -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* |node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- preprocessing -->
    <xsl:template match="node() | @*" mode="preprocess">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="preprocess"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[tei:milestone[@unit='chapter']]" mode="preprocess">
        <!-- I don't know if tei:milestone[@unit='chapter'] could be in another element than p - so do it more generic -->
        <xsl:variable name="nodeName" select="name()" />
        <xsl:element name="{$nodeName}">
            <!-- Have to account there could be more tei:milestone[@unit='chapter'] elements - working with 1st of them -->
            <xsl:apply-templates select="tei:milestone[@unit='chapter'][1]/preceding-sibling::node()" mode="preprocess" />
        </xsl:element>
        <!-- here pb could be changed to something else -->
        <xsl:copy-of select="tei:milestone[@unit='chapter'][1]" />
        <!-- I have to continue with the rest of element - I store it into another variable 
            an encapsulate it with the element of the same name. Then it is processing
            in standard way. -->
        <xsl:variable name="restOfElement">
            <xsl:element name="{$nodeName}">
                <xsl:copy-of select="tei:milestone[@unit='chapter'][1]/following-sibling::node()" />
            </xsl:element>
        </xsl:variable>
        <xsl:apply-templates select="$restOfElement" mode="preprocess" />
    </xsl:template>
    
</xsl:stylesheet>
    
    