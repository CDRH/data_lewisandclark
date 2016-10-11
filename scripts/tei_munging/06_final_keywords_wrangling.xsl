<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.'))"></xsl:value-of>
  </xsl:variable>
  
  <xsl:variable name="file_id">
    <xsl:value-of select="/tei:TEI/@xml:id"/>
  </xsl:variable>

   
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/TEI/teiHeader/fileDesc/publicationStmt/address/addrLine">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = '?'"><!-- do nothing, get rid of element --></xsl:when>
      <xsl:when test="normalize-space(.) = ''"><!-- do nothing, get rid of element --></xsl:when>
      <xsl:otherwise>
        <xsl:element name="addrLine" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="/TEI//textClass/keywords">
    <xsl:element name="keywords" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="scheme"><xsl:value-of select="@scheme"/></xsl:attribute>
      <xsl:attribute name="n"><xsl:value-of select="@n"/></xsl:attribute>
    <xsl:choose>
      <xsl:when test="term"><xsl:apply-templates/></xsl:when>
      <xsl:otherwise><xsl:element name="term" namespace="http://www.tei-c.org/ns/1.0"/></xsl:otherwise>
    </xsl:choose>
    </xsl:element>
  
  </xsl:template>
  
</xsl:stylesheet>
