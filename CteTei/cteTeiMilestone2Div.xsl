<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no"/>



    <!-- adapted from http://stackoverflow.com/questions/17618249/xsl-display-text-between-two-milestone-show-milestone-value-elsewhere -->
    <!-- unfortunately the preprocess does produce a lot of redundant data -->

    <!-- Make some "preprocess" - just to splip everything containing pb -->
    <xsl:template match="tei:body">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- split all child elements -->
            <xsl:variable name="vPreprocess">
                <xsl:copy>
                    <xsl:apply-templates mode="preprocess" select="./node()"/>
                </xsl:copy>
            </xsl:variable>
                <xsl:for-each-group group-starting-with="tei:milestone[@unit='chapter']"
                    select="$vPreprocess/descendant::*">
                    <div type="chapter">
                        <xsl:copy-of select="current-group()[position() > 1]"/>
                        <!--<xsl:value-of select="current-grouping-key()/@n"/>-->
                    </div>
                </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>


    <!-- copy everything that is not preprocesses -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- preprocessing -->
    <xsl:template match="@* | node()" mode="preprocess">
        <xsl:copy>
            <xsl:apply-templates mode="preprocess" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[tei:milestone[@unit = 'chapter']]" mode="preprocess">
        <!-- I don't know if tei:milestone[@unit='chapter'] could be in another element than p - so do it more generic -->
        <xsl:variable name="nodeName" select="name()"/>
        <xsl:element name="{$nodeName}">
            <!-- Have to account there could be more tei:milestone[@unit='chapter'] elements - working with 1st of them -->
            <xsl:apply-templates mode="preprocess"
                select="tei:milestone[@unit = 'chapter'][1]/preceding-sibling::node()"/>
        </xsl:element>
        <!-- here pb could be changed to something else -->
        <xsl:copy-of select="tei:milestone[@unit = 'chapter'][1]"/>
        <!-- I have to continue with the rest of element - I store it into another variable 
            an encapsulate it with the element of the same name. Then it is processing
            in standard way. -->
        <xsl:variable name="restOfElement">
            <xsl:element name="{$nodeName}">
                <xsl:copy-of select="tei:milestone[@unit = 'chapter'][1]/following-sibling::node()"
                />
            </xsl:element>
        </xsl:variable>
        <xsl:apply-templates mode="preprocess" select="$restOfElement"/>
    </xsl:template>

</xsl:stylesheet>
