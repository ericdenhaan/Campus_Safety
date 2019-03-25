<?xml version="1.0"?>
<!--master-transform-1.xslt-->
<!--Filter the provided XML to only the relevant data-->
<!--Written By: Eric Den Haan-->
<xsl:stylesheet version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:param name="institutionName" as="xs:string" required="yes"/>
  <xsl:output method="xml" indent="yes" encoding="US-ASCII"/>
  <xsl:strip-space elements="*"/>
  <xsl:template match="elem">
    <xsl:variable name="crimeType" select="./@name"/>
    <xsl:variable name="crimeInstances" select="."/>
    <xsl:if test="number(.)">
      <xsl:for-each select="1 to $crimeInstances">
        <crimeStat>
          <xsl:value-of select="$crimeType"/>
        </crimeStat>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  <xsl:template match="row">
    <xsl:if test="fn:not(fn:contains(child::elem[1], 'Subtotal'))">
      <xsl:if test="child::elem[1] != ''">
        <xsl:if test="child::elem[1] = $institutionName">
          <institution name="{child::elem[1]}">
            <crimeStats>
              <xsl:apply-templates/>
            </crimeStats>
          </institution>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template match="root">
    <institutions>
      <xsl:apply-templates/>
    </institutions>
  </xsl:template>
</xsl:stylesheet>