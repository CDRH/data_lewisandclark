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
  
  <!-- Split up bibl's -->
  
  <!-- 
  ml = Meriwether Lewis
  wc = William Clark
  jo = John Ordway
  cf = Charles Floyd
  pg = Patrick Gass
  jw = Joseph Whitehouse
  
  -->
  
  <!-- Add xml:id's to individual authors -->
  <xsl:template match="/TEI/teiHeader/fileDesc/sourceDesc/bibl">
    <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:variable name="title_text"><xsl:value-of select="title"/></xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($title_text,'Patrick Gass')">
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">pg</xsl:attribute>
            <xsl:text>Patrick Gass</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:when test="contains($title_text,'John Ordway')">
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">jo</xsl:attribute>
            <xsl:text>John Ordway</xsl:text>
          </xsl:element>
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">cf</xsl:attribute>
            <xsl:text>Charles Floyd</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:when test="contains($title_text,'Joseph Whitehouse')">
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">jw</xsl:attribute>
            <xsl:text>Joseph Whitehouse</xsl:text>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">ml</xsl:attribute>
            <xsl:text>Meriwether Lewis</xsl:text>
          </xsl:element>
          <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">wc</xsl:attribute>
            <xsl:text>William Clark</xsl:text>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>      
    </xsl:element>
  </xsl:template>
  
  <!-- do nothing because author is replaced above -->
  <xsl:template match="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author"></xsl:template>
  
  
  <!-- can't select on author because there may be more than one author... -->
  <!--<xsl:template match="/TEI/teiHeader/fileDesc/sourceDesc/bibl/author">
    <!-\-<xsl:value-of select="following-sibling::title"/>-\->
    <xsl:choose>
      <xsl:when test="contains(following-sibling::title,'Gass')"></xsl:when>
    </xsl:choose>
    <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">AUTHOR</xsl:element>
  </xsl:template>-->

</xsl:stylesheet>
