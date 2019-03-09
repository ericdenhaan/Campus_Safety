<?xml version="1.0"?>
<!--master-transform.xslt-->
<!--Filter the provided XML to only the relevant data-->
<!--Written By: Eric Den Haan-->
<xsl:stylesheet version="2.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="xml" indent="yes" encoding="US-ASCII"/>
<xsl:strip-space elements="*"/>

<xsl:template match="elem">
    <xsl:if test="number(.)">
        <crimeStat name="{@name}">
            <xsl:value-of select="."/>
        </crimeStat>
    </xsl:if>
</xsl:template>

<xsl:template match="row">
    <xsl:if test="fn:not(fn:contains(child::elem[1], 'Subtotal'))">
        <xsl:if test="child::elem[1] != ''">
            <institution name="{child::elem[1]}">
                <xsl:apply-templates/>
            </institution>
        </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template match="root">
    <institutions>
        <xsl:apply-templates/>
    </institutions>
</xsl:template>
</xsl:stylesheet>