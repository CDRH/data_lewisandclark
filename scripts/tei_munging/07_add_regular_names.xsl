<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>

  <!-- Strip out date from xml:id to use in various capacities -->
  <xsl:variable name="date_match">
    <xsl:value-of select="normalize-space(substring-after(/TEI/@xml:id, 'lc.'))"></xsl:value-of>
  </xsl:variable>

  <!-- match everything and print out as is -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="bibl/author">
    <xsl:variable name="regularized_name">
      <xsl:choose>
        <xsl:when test="@xml:id = 'ml'">Lewis, Meriwether</xsl:when>
        <xsl:when test="@xml:id = 'wc'">Clark, William</xsl:when>
        <xsl:when test="@xml:id = 'jo'">Ordway, John</xsl:when>
        <xsl:when test="@xml:id = 'cf'">Floyd, Charles</xsl:when>
        <xsl:when test="@xml:id = 'pg'">Gass, Patrick</xsl:when>
        <xsl:when test="@xml:id = 'jw'">Whitehouse, Joseph</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      <xsl:attribute name="n"><xsl:value-of select="$regularized_name"/></xsl:attribute>
      <xsl:value-of select="."/>
      
    </xsl:element>
  </xsl:template>

  
</xsl:stylesheet>
