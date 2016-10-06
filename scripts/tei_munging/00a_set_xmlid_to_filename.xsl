<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all">

  <xsl:output indent="yes"></xsl:output>
  
  <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
  
  <!-- Split the filename using '\.' -->
  <xsl:variable name="filenamepart" select="substring-before($filename, '.xml')"/>

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
  
  <xsl:template match="/TEI">
    <xsl:element name="TEI"  namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id"><xsl:value-of select="$filenamepart"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>
